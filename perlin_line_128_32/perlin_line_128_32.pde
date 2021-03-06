// Using processing2arduino : https://github.com/tgieruc/art-duino/blob/main/processing2arduino128x32/processing2arduino128x32.ino


import processing.serial.*;
int nb_pixel_w = 128;
int nb_pixel_h = 32;

boolean pixelarray[][];
Visualizer visu = new Visualizer();

boolean NEGATIVE = false;
float[][] terrain;
int offsetterrain = 200;
Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port
ArrayList<Circle> circles = new ArrayList<Circle>();
Multi_sin pitch = new Multi_sin();
int line_length = 8;
int n_line_h = nb_pixel_h / line_length;
int n_line_w = nb_pixel_w / line_length;
int frame =0;

boolean rotated_pixelarray[][];



void arrayMerger(int arrayMerged[][], int x, int y){
  for (int i = x; i<x+arrayMerged.length; ++i){
    for (int j = y; j < y + arrayMerged[0].length; ++j ){
      if (arrayMerged[i-x][j-y]==1) set_pixel(i,j);
    }
  }
}
void arrayClearer(int arrayMerged[][], int x, int y){
  for (int i = x; i<x+arrayMerged.length; ++i){
    for (int j = y; j < y + arrayMerged[0].length; ++j ){
      if (arrayMerged[i-x][j-y]==1) clear_pixel(i,j);
    }
  }
}
void setup(){
  String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 2000000);


  size(1280,320);
  background(50);
  fill(250);
  noStroke();
  pixelarray  = new boolean[nb_pixel_h][nb_pixel_w];
  rotated_pixelarray  = new boolean[nb_pixel_h][nb_pixel_w];


  visu.init();
  pitch.generate(2*PI,PI/6,0,0,5);

  terrain = new float[n_line_h][n_line_w];
}

void rotate_pa(float angle){
  for (int x =0; x < nb_pixel_h; x++){
    for (int y = 0; y < nb_pixel_w; ++y){
      if (pixelarray[x][y]) set_pixelrotate((int)(cos(angle)*(x-16)+sin(angle)*(y-128/2)),(int)(cos(angle)*(x-16)-sin(angle)*(y-128/2)));
      else clear_pixelrotate((int)(cos(angle)*(x-16)+sin(angle)*(y-128/2)),(int)(cos(angle)*(x-16)-sin(angle)*(y-128/2)));
    }
  }
  pixelarray = rotated_pixelarray;
}

void tilted_line(float x, float y, float angle, float l){
  float dx = sin(angle)*l/2;
  float dy = cos(angle)*l/2;

  plotLine((int)(x-dx),(int) (y-dy),(int)(x+dx),(int) (y+dy));
}


void draw(){
  background(50);
  reset_pixelarray();

  update_map(0.05,0.01,0.01);
  for (int i = 0; i < n_line_h; ++i){
    for (int j = 0; j < n_line_w; ++j){
      tilted_line((i+0.5)*line_length,(j+0.5)*line_length,terrain[i][j]/10,line_length);
    }
  }

  frame++;



 serialWriteArray(pixelarray);
 visu.visualize(pixelarray);
 delay(100);
}

void zoom(float zm){
  int cx = 2;
  int cy = nb_pixel_w/2;
  for (int i = nb_pixel_h-1; i >= 0; --i){
    for (int j = 0; j < nb_pixel_w; ++j){
      rotated_pixelarray[(int)i][(int)j] = get_pixel((int)((i-cx)/zm+cx),(int)((j-cy)/zm+cy));
    }
  }
  pixelarray = rotated_pixelarray;
}


boolean get_pixel(int i, int j){
  if (i>=0 && i < nb_pixel_h && j >= 0 && j < nb_pixel_w){
    return pixelarray[i][j];
  }
  return false;
}



void smoke(int x, int y, int h, int w, float percent){
  for (int i = x; i < x+h; ++i){
    for (int j = y; j < y+w; ++j){
      if (random(1.)<percent) set_pixel(i,j);
      else clear_pixel(i,j);
    }
  }
}

void draw_buttons(){
  int w = 50;
  int h = 10;
  int x0 = 17;
  int y0= 17;
  float tilt = 0.4;
  for (int x = 0; x < h ; x+=2){
    for (int y = 0; y < w; y+=2){
      if (random(1.)<0.5) {
        set_pixel(x0+x,y0-(int)(tilt *x)+y);
        set_pixel(x0+x+1,y0-(int)(tilt *x+1)+y);
        set_pixel(x0+x,y0-(int)(tilt *x)+y+1);
        set_pixel(x0+x+1,y0-(int)(tilt *x+1)+y+1);
      }else {
        clear_pixel(x0+x,y0-(int)(tilt *x)+y);
        clear_pixel(x0+x+1,y0-(int)(tilt *x+1)+y);
        clear_pixel(x0+x,y0-(int)(tilt *x)+y+1);
        clear_pixel(x0+x+1,y0-(int)(tilt *x+1)+y+1);
        }
    }
  }
}

class Sinus {
  float sin_amplitude;
  float omega;
  float phi;
  float k;
  Sinus(float A_in, float omega_in, float phi_in, float k_in){
    sin_amplitude = A_in;
    omega = omega_in;
    phi = phi_in;
    k = k_in;
  }

  float get_amplitude(float t, float x){
    return sin_amplitude*sin(omega*t+k*x+phi);
  }
}

class Multi_sin {
  ArrayList<Sinus> sinuses = new ArrayList<Sinus>();

  void generate(float amplitude_max, float omega_max, float phi_max, float k_max, int n_sin){
    for (int i = 0; i < n_sin; ++i){
      sinuses.add(new Sinus(random(amplitude_max/(float) n_sin),random(omega_max),random(phi_max),random(k_max)));
    }
  }

  void addSin(float sin_amplitude, float omega, float phi, float k){
    sinuses.add(new Sinus(sin_amplitude, omega, phi, k));
  }

  float get_amplitude(float t, int x) {
    float sin_amplitude = 0;
    for (Sinus temp : sinuses){
      sin_amplitude += temp.get_amplitude(t, x);
    }
    return sin_amplitude;
  }
}


void reset_pixelarray(){
  for (int i = 0; i < nb_pixel_h; ++i){
    for (int j = 0; j < nb_pixel_w; ++j){
      clear_pixel(i,j);
    }
  }
}

float flying;


void plotFilledTriangle(int x0,int y0, int x1, int y1, int x2, int y2){
  int dx10 = abs(x1-x0);
  int dx20 = abs(x0-x2);
  int dx21 = abs(x1-x2);

  if (dx10 > dx20 && dx10 > dx21){
    plotFilledTriangleUp(x0,y0,x1,y1,x2,y2);
  } else if (dx20 > dx10 && dx20 > dx21){
    plotFilledTriangleUp(x0,y0,x2,y2,x1,y1);
  } else {
    plotFilledTriangleUp(x1,y1,x2,y2,x0,y0);
  }
}

void update_map(float flyingdelta, float xoffdelta, float yoffdelta){
  flying -= flyingdelta;
  float yoff = flying;
  for (int y = 0; y < n_line_w; y++){
    float xoff = 0;
    for (int x = 0; x <n_line_h; x++){
      terrain[x][y]=map(noise(xoff,yoff),0,1,-2*PI*10,2*PI*10);
      yoff+=yoffdelta;
    }
    xoff+=xoffdelta;
  }
}

void plotSpaceshipStruct(){
  NEGATIVE = !NEGATIVE;
  plotFilledTriangle(0,0,15,11,32,0);
  plotFilledTriangle(32,0,15,128-11,14,11);
  plotFilledTriangle(32,0,15,128-11,32,128);
  plotFilledTriangle(0,128,15,128-11,32,128);
  NEGATIVE = !NEGATIVE;

  plotLine(0,0,15,11);
  plotLine(32,0,15,11);
  plotLine(32,128,15,128-11);
  plotLine(0,128,15,128-11);
  plotLine(15,128-11,15,11);
}


class Circle{
  int x, y, r;
  Circle(int xc, int yc, int rc){
    x = xc;
    y = yc;
    r = rc;
  }

  void plot(){
    plotFilledCircle(x,y,r);
  }
}

void set_pixel(int x, int y){
  if (x>=0 && x < nb_pixel_h && y >= 0 && y < nb_pixel_w){
    pixelarray[x][y] = !NEGATIVE;
  }
}
void set_pixelrotate(int x, int y){
  if (x>=0 && x < nb_pixel_h && y >= 0 && y < nb_pixel_w){
    rotated_pixelarray[x][y] = !NEGATIVE;
  }
}

void clear_pixel(int x, int y){
  if (x>=0 && x < nb_pixel_h && y >= 0 && y < nb_pixel_w){
    pixelarray[x][y] = NEGATIVE;
  }
}
void clear_pixelrotate(int x, int y){
  if (x>=0 && x < nb_pixel_h && y >= 0 && y < nb_pixel_w){
    rotated_pixelarray[x][y] = NEGATIVE;
  }
}

void plotFilledTriangleUp(float x0, float y0, float x1, float y1,float x2, float y2){
    float x = x0;
    float y = y0;
    float xp, yp;
    float dx10 = x1-x0;
    float dx20 = x2-x0;
    float dy10 = y1-y0;
    float dy20 = y2-y0;
    for (float i = 0; i != dx10; i+=dx10/abs(dx10)){
      for (float j = 0; j!= dx20; j+=dx20/abs(dx20)){
        x=x0+i;
        y = y0+i/dx10*dy10;
        xp = x0+j;
        yp = y0+j/dx20*dy20;
        plotLine((int)x,(int)y,(int)xp,(int)yp);
      }

    }
}

float distance(int x0, int y0, int x1, int y1){
  return sqrt((x1-x0)*(x1-x0)+(y1-y0)*(y1-y0));
}


int toHex(boolean pixelarray[][], int i, int j) {
  int sum = 0;
  if (pixelarray[i][j++]) sum+=128;
  if (pixelarray[i][j++]) sum+=64;
  if (pixelarray[i][j++]) sum+=32;
  if (pixelarray[i][j++]) sum+=16;
  if (pixelarray[i][j++]) sum+=8;
  if (pixelarray[i][j++]) sum+=4;
  if (pixelarray[i][j++]) sum+=2;
  if (pixelarray[i][j++]) sum++;
  return sum;
}



void serialWriteArray(boolean pixelarray[][]){

  println("sending");
  for (int i = 0; i < nb_pixel_h; ++i){
    for (int j = 0; j < nb_pixel_w/8; ++j){
      myPort.write(toHex(pixelarray,i,8*j));
    }
  }
}




class Visualizer{
  float scale;
  boolean positive;

  void init(){
    scale = height/nb_pixel_h;
    positive = true;
  }
  void positive(){
    positive = true;
  }
  void negative(){
    positive = false;
  }

  void visualize(boolean pixelarray[][]){
    for (int i = 0; i < nb_pixel_h; ++i){
      for (int j = 0; j < nb_pixel_w; ++j){
        if (pixelarray[i][j] == positive) rect(j*scale, i*scale, scale, scale);
      }
    }
  }

}

void plotFilledCircle(int xc, int yc, int r){
  int x,y,m;
  x = 0;
  y = r;
  m = 5-4*r;
  while (x <= y){
    set_pixel(x+xc,y+yc);
    set_pixel(y+xc,x+yc);
    set_pixel(-x+xc,y+yc);
    set_pixel(-y+xc,x+yc);
    set_pixel(x+xc,-y+yc);
    set_pixel(y+xc,-x+yc);
    set_pixel(-x+xc,-y+yc);
    set_pixel(-y+xc,-x+yc);
    plotLine(x+xc,y+yc,-x+xc,y+yc);
    plotLine(x+xc,-y+yc,-x+xc,-y+yc);
    plotLine(y+xc,x+yc,-y+xc,x+yc);
    plotLine(y+xc,-x+yc,-y+xc,-x+yc);
    if (m > 0){
      y--;
      m-= 8*y;
    }
    x++;
    m+=8*x+4;
  }
}

void plotRectangle(int x, int y, int h, int w){
  for (int i = x; i < x+h; ++i){
    for (int j = y; j < y+w; ++j){
      set_pixel(i,j);
    }
  }
}

void plotCircle(int xc, int yc, int r){
  int x,y,m;
  x = 0;
  y = r;
  m = 5-4*r;
  while (x <= y){
    set_pixel(x+xc,y+yc);
    set_pixel(y+xc,x+yc);
    set_pixel(-x+xc,y+yc);
    set_pixel(-y+xc,x+yc);
    set_pixel(x+xc,-y+yc);
    set_pixel(y+xc,-x+yc);
    set_pixel(-x+xc,-y+yc);
    set_pixel(-y+xc,-x+yc);
    if (m > 0){
      y--;
      m-= 8*y;
    }
    x++;
    m+=8*x+4;
  }
}


void plotLineLow(int x0, int y0, int x1, int y1){
  float dx = x1 - x0;
  float dy = y1 - y0;
  float yi = 1;
  if (dy < 0){
    yi = -1;
    dy = -dy;
  }
  float D = 2*dy - dx;
  int y = y0;
  for (int x = x0; x < x1; ++x){
    set_pixel(x,y);
    if (D > 0){
      y+= yi;
      D+= 2*(dy-dx);
    } else {
      D+= 2*dy;
    }
  }
}
void plotLineHigh(int x0, int y0, int x1, int y1){
  float dx = x1 - x0;
  float dy = y1 - y0;
  float xi = 1;
  if (dx < 0){
    xi = -1;
    dx = -dx;
  }
  float D = 2*dx - dy;
  int x = x0;
  for (int y= y0; y < y1; ++y){
    set_pixel(x,y);
    if (D > 0){
      x+= xi;
      D+= 2*(dx-dy);
    } else {
      D+= 2*dx;
    }
  }
}

void plotLine(int x0, int y0, int x1, int y1) {
    if (abs(y1 - y0) < abs(x1 - x0)){
      if (x0 > x1)
          plotLineLow(x1, y1, x0, y0);
      else
          plotLineLow(x0, y0, x1, y1);
    } else {
        if (y0 > y1)
            plotLineHigh(x1, y1, x0, y0);
        else
            plotLineHigh(x0, y0, x1, y1);
    }
}


int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
}
