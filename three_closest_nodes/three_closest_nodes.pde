class Node{
  float x;
  float y;
  int closest1, closest2, closest3;
  Node(float x_in, float y_in){
    x = x_in;
    y = y_in;
    closest1 = 100;
    closest2 = 100;
    closest3 = 100;
  }
  void drawNode(){
    ellipse(x,y,1,1);
  }
  void setclosest1(int n) {
    closest1 = n;
  }
  void setclosest2(int n) {
    closest2 = n;
  }
  void setclosest3(int n) {
    closest3 = n;
  }
}

ArrayList<Node> nodes = new ArrayList<Node>();
float r,g,b;
int itteration = 0;
int nbr_nodes = 5000;


float nodeDistance(Node n1, Node n2) {
  return sqrt((n2.x - n1.x)*(n2.x - n1.x) + (n1.y - n2.y)*(n1.y - n2.y));
}


void setup() {
  background(50);

  size(800,800);

  for (int i = 0; i < nbr_nodes; ++i) {
     nodes.add( new Node(random(0,1000),random(0,1000)));
  }
  float k = 0;

  findCloseNode();

  frameRate(400);
}

void draw(){
  //saveFrame("line-######.png");
  for (int subitt = 0; subitt < 17; subitt++){
    if (itteration < nodes.size()) {
      Node temp = nodes.get(itteration);
      stroke(255);
      drawLine(temp, nodes.get(temp.closest1));
      drawLine(temp, nodes.get(temp.closest2));
      drawLine(temp, nodes.get(temp.closest3));
      itteration++;
    } else {
      exit();
    }
  }



}

void drawLine(Node n1, Node n2){
  Node temp = new Node(n1.x, n1.y);
  float dx = (n2.x-n1.x)/nodeDistance(n1,n2);
  float dy = (n2.y-n1.y)/nodeDistance(n1,n2);

  while (nodeDistance(n1,n2) > nodeDistance(temp,n1)){
    temp.drawNode();
    temp.x+=dx;
    temp.y+=dy;
  }
}

void findCloseNode(){
  for (int i = 0; i < nbr_nodes; ++i) {
    float minDist = 1001*sqrt(2);
    float secondMinDist = 10001*sqrt(2);
    float thirdMinDist = 10001*sqrt(2);
    for (int j = 0; j < nbr_nodes; ++j) {
      if (i!=j) {
        if (nodeDistance(nodes.get(i),nodes.get(j)) < minDist){
          thirdMinDist = secondMinDist;
          secondMinDist = minDist;
          minDist = nodeDistance(nodes.get(i),nodes.get(j));
          nodes.get(i).setclosest3(nodes.get(i).closest2);
          nodes.get(i).setclosest2(nodes.get(i).closest1);
          nodes.get(i).setclosest1(j);
        } else if (nodeDistance(nodes.get(i),nodes.get(j)) < secondMinDist){
          thirdMinDist = secondMinDist;
          secondMinDist = nodeDistance(nodes.get(i),nodes.get(j));
          nodes.get(i).setclosest3(nodes.get(i).closest2);
          nodes.get(i).setclosest2(j);
        } else if (nodeDistance(nodes.get(i),nodes.get(j)) < thirdMinDist){
          thirdMinDist = nodeDistance(nodes.get(i),nodes.get(j));
          nodes.get(i).setclosest3(j);
        }
      }
    }
  }
}
