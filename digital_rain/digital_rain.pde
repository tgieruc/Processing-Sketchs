ArrayList<Dot> dots = new ArrayList<Dot>();
float color_grad;
float dotSize = 5;

class Dot {
  float x;
  float y;
  float old_delta;
  float new_delta;

  Dot(float x_in, float y_in){
    x = x_in;
    y = y_in;
  }

  void drawDot() {
    ellipse(y,x,dotSize,dotSize);
  }
  void set_old_delta(float delta) {
    old_delta = delta;
  }
  void set_new_delta(float delta) {
    new_delta = delta;
  }
  void update_x() {
    x += old_delta;
  }
  void new_to_old(){
    old_delta = new_delta;
  }
  void update_y() {
    y+=random(-0.5,0.5);
  }
}

//-------------------------------

void setup() {
  background(255);
  size(1080,1350);
  for (int i = 0; i < width; i += 1) {
    dots.add(new  Dot(0,i));

  }
  frameRate(60);
}

void draw(){
  stroke(255 - color_grad, 0, 0);
  fill(255 - color_grad, 0, 0);
  for (Dot temp : dots){
    temp.drawDot();
    temp.update_y();
  }
  if (dotSize > 1){
    dotSize -= 0.1;
  }
  updateDots();
  color_grad = color_grad+0.25;
  if (color_grad>235) stop();
}

void updateDots(){
  for (Dot temp : dots){
    temp.old_delta=random(5);
  }
  softenDots();

  for (Dot temp : dots){
    temp.update_x();
  }
}

void softenDots(){
  dots.get(0).set_new_delta((dots.get(0).old_delta+dots.get(1).old_delta+dots.get(3).old_delta)/abs(dots.get(1).y-dots.get(0).y));
  dots.get(dots.size()-1).set_new_delta((dots.get(dots.size()-1).old_delta+dots.get(dots.size()-2).old_delta+dots.get(dots.size()-3).old_delta)/abs(dots.get(dots.size()-1).y-dots.get(dots.size()-2).y));
  for (int i = 1; i < dots.size()-1; ++i){
    dots.get(i).set_new_delta((dots.get(i-1).old_delta+dots.get(i).old_delta+dots.get(i+1).old_delta)/abs(dots.get(i+1).y-dots.get(i-1).y));
  }
  for (Dot temp : dots) {
    temp.new_to_old();
  }
}
