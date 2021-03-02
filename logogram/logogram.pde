float bias = 0.4;
int temps = 0;
float thickness = 50;
ArrayList<Logogram> logograms = new ArrayList<Logogram>();

class Node{
  float x;
  float y;
  Node(float x_in, float y_in){
    x = x_in;
    y = y_in;
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
    Node tempn1=new Node(x+n1.x*delta,y+n1.y*delta);
    Node tempn2=new Node(x+n2.x*delta,y+n2.y*delta);

   line(n1.x,n1.y,n2.x,n2.y);
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
    subgen(d/2, h/2);
  }

  void subgen(int i, int j){
    grid_nodes[i][j][0] = true;
    grid_nodes[i][j][1] = true;
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
    }
  }
}



void setup() {
  background(50);
  size(1000,1000);
  fill(255);
  stroke(255);
  strokeWeight(5);

  logo_matrix(5,5,4,4);

  save("logogram4.png");
  frameRate(75);
}


void draw(){
  // background(50);

  // falling_logograms(width/2-400,-800,800,height+800,4,5,5*temps++);
}


void logo_matrix(int c, int l,int dx,int dy){
  for (int i = 0; i < c; ++i) {
    for (int j = 0; j < l; ++j) {
      logograms.add(new Logogram(dx,dy));
      logograms.get(i*c+j).draw_logogram(i*(width/c)+width/c/c,width/c/c+j*(height/l),width/dx/2/c);
    }
  }
}


void falling_logograms(float x, float y, float d, float h, float dx, float dy, float time){
  float delta=d/dx;
  noStroke();
  fill(255);
  stroke(255);
  if (time % (d)==0) {
    logograms.add(0,new Logogram((int)dx,(int)dy));
  }
  print(logograms.size());
  if ((logograms.size()-2)*delta*dy>h) logograms.remove(logograms.size()-1);
  for (int i = 0 ; i < logograms.size(); ++i){
    logograms.get(i).draw_logogram(x,y+i*d+time%(d),delta);
  }
  noStroke();
  fill(50);
  rect(x,y,d,d);
}


void draw_line(Node n1, Node n2){
  line(n1.x,n1.y,n2.x,n2.y);
}


float distNode(Node n1, Node n2){
  return sqrt(pow(n1.x-n2.x,2)+pow(n1.y-n2.y,2));
}
