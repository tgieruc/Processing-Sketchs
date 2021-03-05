class Node {
  float radius;
  float angle;
  float center_x;
  float center_y;

  Node(float r_in, float a_in, float x_in, float y_in) {
    radius = r_in;
    angle =  a_in;
    center_x = x_in;
    center_y = y_in;
  }

  void draw_node(){
    ellipse(center_x + cos(angle)*radius, center_y + sin(angle)*radius,1,1);
  }
}





ArrayList<Node> nodes = new ArrayList<Node>();
int size;
int nbr_node;
int nbr_cercle = 85;


void setup() {
  background(255);
  size(800,800);
  for (int i = 0; i < nbr_cercle; i++) {
    nbr_node = (1+i)*10;
    for (int j = 0; j < nbr_node; ++j) {
      nodes.add(new  Node(4*(1+i),random(-0.1,0.1)+j*((2*PI)/(nbr_node)),height/2,width/2));
    }
  }
  size = nodes.size();

  for (Node temp : nodes) {
    fill(0);
    stroke(0);
    temp.draw_node();
  }
  save("tree_trunk.png");
}

void draw(){

}
