  void setup(){
    size(800,800);
    background(255);
    frameRate(30);
  }
  float y=0;
  int time = 0;
  void draw(){
    if (time%1==0) y+=0.00005;
    fill(0);
    background(255);

    for (int i = 0; i < 1600; ++i){
      ellipse(width/2+width/2*sin(0.02*time+i*2.1),height/2+height/2*sin(0.02*time+y*i),10,10);
    }
    time++;
  }
