import processing.svg.*;


class Triangle{
  int item1;
  int item2;
  int item3;
  int temp;
  Triangle(int i1, int i2, int i3){
    item1 = i1;
    item2 = i2;
    item3 = i3;
    sort();
  }
  void set(int i1, int i2, int i3){
    item1 = i1;
    item2 = i2;
    item3 = i3;
    sort();
  }
  void sort(){
    if (item1>item2) {
      temp = item1;
      item1 = item2;
      item2 = temp;
    }
    if (item2>item3) {
      temp = item2;
      item2 = item3;
      item3 = temp;
      if (item1>item2) {
      temp = item1;
      item1 = item2;
      item2 = temp;
      }
    }
  }
  void prinTri(){
    print(item1,item2,item3,"\n");
  }

}

class Dual{
  int item;
  float distance;
  Dual(int i, float d){
    item = i;
    distance = d;
  }
  void set(int i, float d){
    item = i;
    distance = d;
  }
}

class Segment{
  Node n1;
  Node n2;
  Segment(Node n1in, Node n2in){
    n1 = n1in;
    n2 = n2in;
    sort();
  }
  void sort() {
   if (n1.closest.get(0).item > n2.closest.get(0).item) {
     Node temp;
     temp = n1;
     n1 = n2;
     n2 = temp;
   }
  }
}

class Node{
  float x;
  float y;
  ArrayList<Dual> closest = new ArrayList<Dual>();
  Node(float x_in, float y_in){
    x = x_in;
    y = y_in;
  }
  void drawNode(){
    ellipse(x,y,1,1);
  }
  void set_closest(){
    for (int i = 0; i < nbr_nodes; ++i){
      closest.add(new Dual(i, nodeDistance(this,nodes.get(i))));
    }

    boolean sorted = false;
    Dual temp = new Dual(0,0);
    while(!sorted){
      sorted = true;
      for (int i = 0; i < nbr_nodes-1; ++i){
        if (closest.get(i).distance > closest.get(i+1).distance){
          temp.item = closest.get(i).item;
          temp.distance = closest.get(i).distance;
          closest.get(i).set(closest.get(i+1).item, closest.get(i+1).distance);
          closest.get(i+1).set(temp.item, temp.distance);
          sorted = false;
        }
      }
    }
  }
}




ArrayList<Node> nodes = new ArrayList<Node>();
ArrayList<Segment> segments = new ArrayList<Segment>();
ArrayList<Triangle> triangles = new ArrayList<Triangle>();
int nbr_nodes = 1000;
int nbr_line  = 10;
int num = 0;

void setup() {
  background(255);
  int maxsize_x = 800;
  int maxsize_y = 800;
  size(800,800);


  nodes.add(new Node(0,0));
  nodes.add(new Node(0,maxsize_y));
  nodes.add(new Node(maxsize_x,0));
  nodes.add(new Node(maxsize_x,maxsize_y));
  for (int i = 4; i < nbr_nodes; ++i) {
     nodes.add( new Node(random(0,maxsize_x),random(0,maxsize_y)));
  }
  for (Node temp : nodes) {
   temp.set_closest();
  }
 for (int i = 1; i < nbr_nodes; ++i){
  for (Node temp : nodes) {

      if (!alreadyDrawn(temp, nodes.get(temp.closest.get(i).item))) {
        segments.add(new Segment(temp, nodes.get(temp.closest.get(i).item)));
      }
    }
  }
  countTriangles();
}

void draw(){
  if (num < triangles.size()){
    Triangle temp = triangles.get(num);
    boolean draw = true;
    for (Segment tempseg : segments) {
      if (shouldNotDrawTriangle(temp,tempseg.n1, tempseg.n2)){
        draw=false;
      }
    }
    if (draw){
        drawLine(nodes.get(temp.item1),nodes.get(temp.item2));
        drawLine(nodes.get(temp.item1),nodes.get(temp.item3));
        drawLine(nodes.get(temp.item2),nodes.get(temp.item3));
        int ran = (int) random(-5,5);
        for (int i = 0 ; i < (nbr_line+ran) ; ++i) {
          drawLine(new Node((nodes.get(temp.item2).x - nodes.get(temp.item3).x)
          / (nbr_line+ran)*i+nodes.get(temp.item3).x,(nodes.get(temp.item2).y
          - nodes.get(temp.item3).y)/(nbr_line+ran)*i+nodes.get(temp.item3).y),
          new Node((nodes.get(temp.item1).x - nodes.get(temp.item3).x)
          / (nbr_line+ran)*i+nodes.get(temp.item3).x,(nodes.get(temp.item1).y
          - nodes.get(temp.item3).y)/(nbr_line+ran)*i+nodes.get(temp.item3).y));
        }
      }
  }
  num++;
  // saveFrame("line-######.png");
  if (num == triangles.size()) stop();
}



boolean equalNodes(Node n1, Node n2) {
  return (n1.x==n2.x && n1.y==n2.y);
}

boolean shouldNotDrawTriangle(Triangle temp, Node n3, Node n4){
  Node n1 = nodes.get(temp.item1);
  Node n2 = new Node((nodes.get(temp.item2).x + nodes.get(temp.item3).x)/2,(nodes.get(temp.item2).y + nodes.get(temp.item3).y)/2);
  boolean c1 = doIntersect(n1,n2,n3,n4);
  boolean c2 = equalNodes(nodes.get(temp.item2),n3) && !equalNodes(nodes.get(temp.item3),n4)&&!equalNodes(nodes.get(temp.item1),n4);
  boolean c3 = equalNodes(nodes.get(temp.item2),n4) && !equalNodes(nodes.get(temp.item3),n3)&&!equalNodes(nodes.get(temp.item1),n3);
  boolean c4 = equalNodes(nodes.get(temp.item3),n3) && !equalNodes(nodes.get(temp.item2),n4)&&!equalNodes(nodes.get(temp.item1),n4);
  boolean c5 = equalNodes(nodes.get(temp.item3),n4) && !equalNodes(nodes.get(temp.item2),n3)&&!equalNodes(nodes.get(temp.item1),n3);
  return (c1&&(c2||c3||c4||c5));
}


boolean checkDuplicateTriangle(Triangle temp){
  for (int k = 0; k < triangles.size(); ++k){
    if ((temp.item1 == triangles.get(k).item1 &&
         temp.item2 == triangles.get(k).item2 &&
         temp.item3 == triangles.get(k).item3)){
      return true;
    }
  }
  return false;
}

void countTriangles(){
  int n1,n2;
  Triangle temp = new Triangle(1,1,1);
  for (int i=0; i < segments.size() ; ++i){
     n1=segments.get(i).n1.closest.get(0).item;
     n2=segments.get(i).n2.closest.get(0).item;
     for (int j = 0; j < segments.size();++j){
       if (n2==segments.get(j).n1.closest.get(0).item) {
         for (int k = 0; k < segments.size(); ++k){
           if (n1 == segments.get(k).n1.closest.get(0).item && segments.get(j).n2.closest.get(0).item== segments.get(k).n2.closest.get(0).item){
             temp.set(n1,n2,segments.get(j).n2.closest.get(0).item);
             if(!checkDuplicateTriangle(temp)) triangles.add(new Triangle(temp.item1,temp.item2,temp.item3));
           }
         }
       }
     }
  }
}




boolean alreadyDrawn(Node n1, Node n2) {
  for (Segment temp : segments){
    if (doIntersect(n1,n2,temp.n1,temp.n2) &&
       (n1!=temp.n1 && n1!=temp.n2 && n2!=temp.n1 && n2!=temp.n2) ||
       (n1==temp.n1 && n2==temp.n2) || ( n1==temp.n2 && n2==temp.n1 ) ){
      return true;
    }
  }
  return false;
}

float nodeDistance(Node n1, Node n2) {
  return sqrt((n2.x - n1.x)*(n2.x - n1.x) + (n1.y - n2.y)*(n1.y - n2.y));
}


void drawLine(Node n1, Node n2){
  line(n1.x,n1.y,n2.x,n2.y);
}


// Given three colinear Nodes p, q, r, the function checks if
// Node q lies on line segment 'pr'
static boolean onSegment(Node p, Node q, Node r)
{
    if (q.x <= Math.max(p.x, r.x) && q.x >= Math.min(p.x, r.x) &&
        q.y <= Math.max(p.y, r.y) && q.y >= Math.min(p.y, r.y))
    return true;

    return false;
}

// To find orientation of ordered triplet (p, q, r).
// The function returns following values
// 0 --> p, q and r are colinear
// 1 --> Clockwise
// 2 --> Counterclockwise
static float orientation(Node p, Node q, Node r)
{
    // See https://www.geeksforgeeks.org/orientation-3-ordered-Nodes/
    // for details of below formula.
    float val = (q.y - p.y) * (r.x - q.x) -
            (q.x - p.x) * (r.y - q.y);

    if (val == 0) return 0; // colinear

    return (val > 0)? 1: 2; // clock or counterclock wise
}

// The main function that returns true if line segment 'p1q1'
// and 'p2q2' intersect.
static boolean doIntersect(Node p1, Node q1, Node p2, Node q2)
{
    // Find the four orientations needed for general and
    // special cases
    float o1 = orientation(p1, q1, p2);
    float o2 = orientation(p1, q1, q2);
    float o3 = orientation(p2, q2, p1);
    float o4 = orientation(p2, q2, q1);

    // General case
    if (o1 != o2 && o3 != o4)
        return true;
    // Special Cases
    // p1, q1 and p2 are colinear and p2 lies on segment p1q1
    if (o1 == 0 && onSegment(p1, p2, q1)) return true;

    // p1, q1 and q2 are colinear and q2 lies on segment p1q1
    if (o2 == 0 && onSegment(p1, q2, q1)) return true;

    // p2, q2 and p1 are colinear and p1 lies on segment p2q2
    if (o3 == 0 && onSegment(p2, p1, q2)) return true;

    // p2, q2 and q1 are colinear and q1 lies on segment p2q2
    if (o4 == 0 && onSegment(p2, q1, q2)) return true;

    return false; // Doesn't fall in any of the above cases
}
