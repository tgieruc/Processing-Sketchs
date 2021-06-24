float[][] terrain;
float flying = 0;
int scale = 140;
int w = 1280;
int h = 720;
int first_frame = 980;
int last_frame  = 1347;

PImage photo;

void setup(){
  size(1280, 720);
  background(50);
  fill(250);
  stroke(250);
  strokeWeight(1);
  frameRate(30);
}
int current_frame = first_frame;
void draw(){
  background(50);
  fill(250);
    stroke(250);
  strokeWeight(1);

  String imageName = "out"+ current_frame +".png";
  current_frame++;
  photo = loadImage(imageName);
  photo.loadPixels();
  float wImage = photo.width;
  color c = color(0,0,0);
  for (int i = 0; i < scale; ++i){
    for (int j = 0; j < scale * h / w; ++j){
      c = photo.get((int) (0.5 + i) * w / scale, (int) (0.5 + j) * w / scale);
      int intensity =  ((c >> 16 & 0xFF) + (c >> 8 & 0xFF) + (c & 0xFF))/3;
      ellipse((0.5+i) * w / scale * w / wImage, (0.5 + j) * w / scale * w / wImage,
              map(intensity, 0, 255, 0, w / scale * w / wImage),
              map(intensity, 0, 255, 0, w / scale * w / wImage));
    }
  }
  // saveFrame("line-######.png");

  if (current_frame == last_frame) exit();

}


void rectangle_center(float x, float y, float dx, float dy){
  rect(x - dx / 2, y - dy / 2, dx, dy);
}
