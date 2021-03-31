ArrayList<Multi_sin> multi_sin = new ArrayList<Multi_sin>();
ArrayList<Rect> rectangles = new ArrayList<Rect>();
Multi_sin pitch = new Multi_sin();
ArrayList<Multi_sin> speedometer_sinus = new ArrayList<Multi_sin>();
ArrayList<Logogram> logograms = new ArrayList<Logogram>();
int n_lines = 5;
int scale = 40;
int w = 3000;
int h = 3000;
int cols = w/scale;
int rows = h/scale;
float flying=0;
float translate = 0;
Led_chain ledchain = new Led_chain(25,25,false, 10);
Multi_sin ledchain_sin = new Multi_sin();
int time_int=0;
float time_float = 0;
float[][] terrain;
Led_matrix ledmatrix = new Led_matrix();
Random_dot randot = new Random_dot(170/2,250/2,170,250,4);
MultLevel multlevel = new MultLevel(6);
float bias = 0.5;
float thickness = 30;


class Random_dot{
  float x, y, w, h, r;
  Random_dot(float x_in, float y_in, float w_in, float h_in, float r_in){
    x=x_in;
    y=y_in;
    w=w_in;
    h=h_in;
    r=r_in;
  }

  void update(){
    if (random(h)<x) x-=5;
    else x+=5;

    if (random(w)<y) y-=5;
    else y+=5;
  }

  void draw_random_dot(float xpos, float ypos){

    ellipse(x+xpos,y+ypos,3*r,2*r);
    rect(x+xpos-4*r, y+ypos-r/4,8*r,r/2);
    rect(x+xpos-r/4,y+ypos,r/2,-2*r);
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

//----

class Rect {
 Node n1,n2,n3,n4,corner;
 float h,l,alpha,dx,dy;

 Rect(Node corner_in, float l, float h, float alpha){
   float tana = tan(alpha);
   float l2=-(l-h*tana)/(tana*tana-1);
   float h2=-(h-l*tana)/(tana*tana-1);
   float l1=l-l2;
   float h1=h-h2;
   n1=new Node(corner_in.x+l,corner_in.y+h1);
   n2=new Node(corner_in.x+l2,corner_in.y+h);
   n3=new Node(corner_in.x,corner_in.y+h2);
   n4=new Node(corner_in.x+l1,corner_in.y);
 }

 void draw_rect(){
   draw_line(n1,n2);
   draw_line(n2,n3);
   draw_line(n3,n4);
   draw_line(n4,n1);
 }
}


//----

class Node{
  float x;
  float y;
  Node(float x_in, float y_in){
    x = x_in;
    y = y_in;
  }
  void drawNode(){
    ellipse(x,y,1,1);
  }
}

//-----

class Led_chain{
  int n_leds;
  int dx;
  int dy;
  float radius;

  Led_chain(int n, int d, boolean horizontal, float r){
    n_leds = n;
    if (horizontal){
      dx=d;
      dy=0;

    } else {
      dx=0;
      dy=d;
    }
    radius = r;
  }

  void draw_leds(float x, float y,int activate){
     for (int i = 0; i < n_leds; ++i){
       if (activate==i) fill(#FF7000);
       else noFill();
       ellipse(x+dx*i,y+dy*i,2*radius, 2*radius);
     }
  }
}

class Led_matrix{
  float dx,dy,radius;
  int n_x, n_y;
  boolean[][] led_activation;
  void set_infos(float r, int nx, int ny){
    radius=r;
    n_x=nx;
    n_y=ny;
    led_activation = new boolean[n_x][n_y];
  }

  void random_arr(){
    for (int i = 0; i < n_x; ++i){
      for (int j = 0; j < n_y; ++j){
        led_activation[i][j]=(random(1)<0.5);
      }
    }
  }

  void draw_led_matrix(float x, float y, float d){
    float delta=(d+radius)/(float)n_x;
    for (int i = 0; i < n_x; ++i){
      for (int j = 0; j < n_y; ++j){
        if (led_activation[i][j]) fill(#FF7000);
        else noFill();
        ellipse(radius+x+i*delta,radius+y+j*delta,radius*2,radius*2);
      }
    }
  }
}


class MultLevel {
  ArrayList<Multi_sin> levels = new ArrayList<Multi_sin>();

  MultLevel(int n){
    for (int i = 0; i < n; ++i){
      addLevel();
    }
  }

  void addLevel(){
    levels.add(new Multi_sin());
    levels.get(levels.size()-1).generate(1,PI,0,0,4);
  }

 void drawLevels(float x, float y, float dx, float dy, float temps){
   for (int i = 0; i < levels.size(); ++i){
     noFill();
     rect(x+i*dx,y+dy,dx,-dy);
     fill(#FF7000);
     float amplitude = (0.5+levels.get(i).get_amplitude(temps,0));
     if (amplitude > 1) amplitude = 1;
     rect(x+i*dx,y+dy,dx,-abs(amplitude)*dy);
   }
 }
}



class Logogram {
  int d,h;
  boolean[][][] grid_nodes;
  ArrayList<Segment> segments = new ArrayList<Segment>();
  Logogram(int d_in, int h_in){
    d = d_in;
    h = h_in;
    grid_nodes = new boolean[d][h][2];
    generate();
  }

  void generate(){
    subgen(d/2,h/2);
  }

  void subgen(int i, int j){
    grid_nodes[i][j][0]=true;
    grid_nodes[i][j][1]=true;
    if (i>0 && random(1)>bias)  if (!grid_nodes[i-1][j][1]){
      segments.add(new Segment(new Node(i,j),new Node(i-1,j)));
      subgen(i-1,j);
    }
    if (i<d-1 && random(1)>bias) if (!grid_nodes[i+1][j][1]){
      segments.add(new Segment(new Node(i,j),new Node(i+1,j)));
      subgen(i+1,j);
    }
    if (j>0 && random(1)>bias) if (!grid_nodes[i][j-1][1]){
      segments.add(new Segment(new Node(i,j),new Node(i,j-1)));
      subgen(i,j-1);
    }
    if (j<h-1 && random(1)>bias) if (!grid_nodes[i][j+1][1]) {
      segments.add(new Segment(new Node(i,j),new Node(i,j+1)));
      subgen(i,j+1);
    }
  }

  void draw_logogram(float x, float y, float delta){
    for (Segment temp : segments){
      line(temp.n1.x*delta+x,y+temp.n1.y*delta,temp.n2.x*delta+x,y+temp.n2.y*delta);
      //temp.draw_segment(x,y,delta);
    }
  }
}


class Segment{
  Node n1;
  Node n2;
  Segment(Node n1in, Node n2in){
    n1 = n1in;
    n2 = n2in;
  }
  void draw_segment(float x, float y, float delta){
    n1=new Node(x+n1.x*delta,y+n1.y*delta);
    n2=new Node(x+n2.x*delta,y+n2.y*delta);

    for (int i = 0; i < (int) distNode(n1,n2);++i){
      ellipse(n1.x+i*(n2.x-n1.x)/distNode(n1,n2),n1.y+i*(n2.y-n1.y)
              /distNode(n1,n2),thickness/2,thickness/2);
    }
  }
}







// --------------------------------------------------------------------------------------------------------

void setup() {
  background(#FF7000);
  size(1080,1350,P3D);
  fill(255);
  stroke(255);
  for (int i = 0 ; i < n_lines; ++i){
    multi_sin.add(new Multi_sin());
    multi_sin.get(i).generate(random(100),random(50),random(12),random(0.6),20);
  }
  terrain = new float[cols][rows];
  for (int i = 0 ; i < 4; ++i){
    speedometer_sinus.add(new Multi_sin());
    speedometer_sinus.get(i).generate(2*PI,0.5,1,0,5);
  }
  pitch.generate(PI/6,PI/6,0,0,5);
  ledchain_sin.generate(10,PI,0,0,5);
  ledmatrix.set_infos(5,15,10);

  frameRate(30);
}



void draw(){
  background(#FF7000);
  time_float+=0.22;
  time_int++;
  draw_map();

  strokeWeight(2);
  noFill();
  rect(0,0,width,height);

  draw_table();
  draw_walls();;

  draw_left_board(time_int, time_float);
  draw_right_board(time_int, time_float);


  hint(ENABLE_DEPTH_TEST);

  // saveFrame("line-######.png");

}

//----------------------------------------------

void draw_map(){
  noFill();
  stroke(255);
  strokeWeight(1);
  flying -= 0.1;
  float yoff = flying;
  for (int y = 0; y < rows; y++){
    float xoff = 0;
    for (int x = 0; x < cols; x++){
      terrain[x][y]=map(noise(xoff,yoff),0,1,-70,70);
      xoff+=0.2;
    }
    yoff+=0.2;
  }


  translate(width/2, height/2 - 500);
  rotateX(PI/3);
  rotateY(pitch.get_amplitude(time_float,0));
  translate += sin(pitch.get_amplitude(time_float,0));
  translate(20*translate - w/2,-h/2);

  for (int y = 0; y < rows - 1; y++){
    beginShape(TRIANGLE_STRIP);
    for(int x = 0; x < cols; x++){
      vertex(x*scale,y*scale,terrain[x][y]);
      vertex(x*scale,(y+1)*scale,terrain[x][y+1]);
    }
    endShape();
  }

  translate(w/2-20*translate,h/2);
  rotateY(-pitch.get_amplitude(time_float,0));
  rotateX(-PI/3);
  translate(-width/2,-height/2+500);

  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();
}


void draw_walls(){
  fill(255);
  stroke(#FF7000);

  rotateY(-PI/2);
  rect(0,height/2,width,height/2);
  translate(0,0,-width);
  rect(0,height/2,width,height/2);
  translate(0,0,width);
  rotateY(PI/2);
}

void draw_table() {
  fill(255);
  stroke(#FF7000);

  rotateX(PI/6);
  translate(0,-180,-500);
  rect(0,height/2,width,height/2);
  line(width/2,height/2,width/2,height);
}

void draw_left_board(int time_int, float time_float){
  ledchain.draw_leds(50 , height/2+50,(int) (10+  ledchain_sin.get_amplitude(time_float,0)*2));
  falling_logograms(120,height/2,100,height/2,15,5,10*time_int);
  draw_second_left_column(250,height/2,250);
}

void draw_second_left_column(float x, float y,float d){
  draw_speedometers(time_float,x,y+100);

  artificial_horizon(x+d-100/2,y+100+100/2,100/2.5,2*pitch.get_amplitude(time_float,0));
  ledmatrix.draw_led_matrix(x,y+250,d);

  if (time_int%15==0) ledmatrix.random_arr();

  draw_aiming_system(x,y+450,d, time_int);
}

void draw_right_board(int time_int, float time_float){
  draw_sin_system();
  multlevel.drawLevels(width/2+100, height/2+350,(width/2-200)/6,150,0.4*time_float);
  steering_wheel(width-270,height-130,300,150,-2*pitch.get_amplitude(time_float,0));
}

void draw_speedometers(float time_float, float x, float y){
  strokeWeight(2);
  stroke(#FF7000);
  noFill();
  rect(x,y,100,100);
  draw_speedometer(x+25,y+25,20,PI/2+speedometer_sinus.get(0).get_amplitude(time_float,0));
  draw_speedometer(x+75,y+75,20,PI/2+speedometer_sinus.get(1).get_amplitude(time_float,0));
  draw_speedometer(x+25,y+75,20,PI/2+speedometer_sinus.get(2).get_amplitude(time_float,0));
  draw_speedometer(x+75,y+25,20,PI/2+speedometer_sinus.get(3).get_amplitude(time_float,0));
}

void draw_aiming_system(float y, float x, float d, int time_int){
  noFill();
  if ((time_int%60)<30) draw_rectinrect(time_int%60,x,y,200,d);
  else  draw_rectinrect(60-time_int%60,x,y,200,d);
  randot.update();
  randot.draw_random_dot(y,x);
}

void draw_sin_system(){
  int quadrant_length=100;
  rect(width/2+100,height/2+100,width/2-200,200);
  rect(width/2+150,height/2+100,quadrant_length,200);
  rect(width-150-quadrant_length,height/2+100,quadrant_length,200);

  strokeWeight(1);  // Default
  oscilines(n_lines,(int) width/2+150,(int) height/2+100,(int)quadrant_length,200);
  oscilines(n_lines,(int)width-150-quadrant_length,(int)height/2+100,(int)quadrant_length,200);
  draw_inter_lines(n_lines,width/2+100,height/2+100,50,200);
  draw_inter_lines(n_lines,(int) width/2+150+quadrant_length,height/2+100,40,200);
  draw_inter_lines(n_lines,width-150,height/2+100,50,200);
  draw_buttons(n_lines, width/2+80, height/2+100, 50, 200);
}

void falling_logograms(float x, float y, float d, float h, float dx, float dy, float time_float){
  strokeWeight(2);
  fill(#FF7000);
  rect(x-10,y,d+10,h);

  float delta=d/dx;

  stroke(255);
  if (time_float % (d)==0) {
    logograms.add(0,new Logogram((int)dx,(int)dy));
  }

  if ((logograms.size()-1)*delta*dy>h) logograms.remove(logograms.size()-1);
  for (int i = 0 ; i < logograms.size(); ++i){
    logograms.get(i).draw_logogram(x,y+i*d+time_float%(d),delta);
  }
  noStroke();
  fill(255);
  rect(x-10,y,d+10,d);
}



float distNode(Node n1, Node n2){
  return sqrt(pow(n1.x-n2.x,2)+pow(n1.y-n2.y,2));
}




void draw_line(Node n1, Node n2){
  line(n1.x,n1.y,n2.x,n2.y);
}


//-----

void draw_inter_lines(int n_lines,  int y, int x,int d, int h){
  for (int i=0; i<n_lines;++i){
    for (int j=y; j < y+d;++j){
      ellipse(  j,x+h/n_lines*i+h/2/n_lines+random(-abs(multi_sin.get(i).get_amplitude(time_float,j)),abs(multi_sin.get(i).get_amplitude(time_float/10,j))),2,2);
    }
  }
}

void oscilines(int n_lines,  int y, int x,int d, int h){
    for (int i = 0 ; i < n_lines; ++i){
    for (int j = y ; j < y+d; ++j){
      ellipse(j,x+h/n_lines*i+h/2/n_lines+multi_sin.get(i).get_amplitude(time_float/10,j),2,2);
    }
  }
}

void draw_rectinrect(int n, float x, float y, float h, float d){
  for (int i = 0; i < n ; ++i) {
    rectangles.add(new Rect(new Node(y,x),d,h,3*PI/20/n*i));
  }
  for (int i = 0; i < n ; ++i) {
    rectangles.add(new Rect(new Node(y,x),d,h,PI/2-3*PI/20/n*i));
  }

  for (int i=0; i < 2*n; ++i){
    rectangles.get(i).draw_rect();
  }
  rectangles.clear();
}

void draw_buttons(int n_lines, float x, float y, int d, int h){
  for (int i = 0; i < n_lines; ++i){
    strokeWeight(1);
    noFill();
    if (multi_sin.get(i).get_amplitude(time_float/10,(int) x) > 0) fill(#FF7000);
    ellipse(x,y+h/n_lines*i+h/2/n_lines,10,10);
  }
}

void draw_speedometer(float x, float y, float r, float angle) {
  fill(255);
  ellipse(x,y,2*r,2*r);
  line(x, y, x+0.8*cos(angle)*r, y-0.8*sin(angle)*r);
}

void artificial_horizon(float x, float y, float radius, float angle){
  noFill();
  rect(x-1.25*radius,y-1.25*radius,2.5*radius,2.5*radius);
  fill(255);
  ellipse(x, y, 2.5*radius, 2.5*radius);
  line(x,y,x+1.25*radius*cos(7*PI/6),y+1.25*radius*sin(7*PI+PI/6));
  line(x,y,x+1.25*radius*cos(4*PI/3),y+1.25*radius*sin(4*PI/3));
  line(x,y,x+1.25*radius*cos(3*PI/2),y+1.25*radius*sin(3*PI/2));
  line(x,y,x+1.25*radius*cos(-PI/6),y+1.25*radius*sin(-PI/6));
  line(x,y,x+1.25*radius*cos(-PI/3),y+1.25*radius*sin(-PI/3));
  fill(#FF7000);
  arc(x,y,2.5*radius,2.5*radius,0,PI,CHORD);
  fill(255);
  ellipse(x, y, 2*radius, 2*radius);
  fill(#FF7000);
  arc(x,y,2*radius,2*radius,0+angle,PI+angle,CHORD);

  if(angle%(2*PI)>0 && angle%(2*PI)<PI/2) fill(#FF7000);
  else noFill();
  ellipse(x+cos(-PI/4)*1.4*radius,y+sin(-PI/4)*1.4*radius,0.2*radius,0.2*radius);
  if(!(angle%(2*PI)>0 && angle%(2*PI)<PI/2)) fill(#FF7000);
  else noFill();
  ellipse(x+cos(-3*PI/4)*1.4*radius,y+sin(-3*PI/4)*1.4*radius,0.2*radius,0.2*radius);
}

void steering_wheel(float x, float y, float w, float h, float angle){
  noStroke();
  translate(x,y);
  rect(-w/16,h/4,w/8,w/5);
  ellipse(0,h/4+w/5,w/8,w/12);
  rotateZ(angle);

  ellipse(0,h/6,0.6*w,0.6*h);
  rect(-w/2,0,w,h/3,18);
  fill(255);
  rect(-w/4,h/12,w/2,h/6,18);
  fill(#FF7000);
  stroke(255);
  rect(-w/2,h/2,h/3,-h/2,18);
  rect(-w/2-h/32,h/2,1.2*h/3,h/4,18);
  rect(-w/2-h/32,h/4+h/2,1.2*h/3,h/4,18);

  rect(w/2,h/2,-h/3,-h/2,18);
  rect(w/2+h/16,h/2,-1.2*h/3,h/4,18);
  rect(w/2+h/16,h/4+h/2,-1.2*h/3,h/4,18);


  rotateZ(-angle);

  translate(-x,-y);
}
