

class Cylinder {

  //cylinders
  float cylinderBaseSize = 20;
  float cylinderHeight = 30;
  int cylinderResolution = 40;
  PShape openCylinder = new PShape();
  PShape cylinderBases = new PShape();


  float x,y;

  Cylinder(float x_ , float y_){
    x = x_ ; 
    y = y_ ;
    cylinderSetup();
  }

  boolean isInside(Cylinder o){
    float norm = vect_norm(x - o.x , y - o.y);
    if (norm < 4 * cylinderBaseSize * cylinderBaseSize)
      return true;
    return false;
  }

  boolean isInside(MovingBall ball){
    float norm = vect_norm(ball.location.x - x, -ball.location.y - y);
    if (norm < (ball.ball_radius + cylinderBaseSize) * (ball.ball_radius + cylinderBaseSize))
      return true;
    return false;
  }


  void draw(){
    shape(openCylinder, x, y);
    shape(cylinderBases, x, y);
  }

  void drawShitMode(){
    shape(cylinderBases, x, y);
  }




  void cylinderSetup() {
  ////setup for cylinder
  float angle;
  float[] x_ = new float[cylinderResolution + 1];
  float[] y_ = new float[cylinderResolution + 1];

  //get the x and y position on a circle for all the sides
  for (int i = 0; i < x_.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x_[i] = sin(angle) * cylinderBaseSize;
    y_[i] = cos(angle) * cylinderBaseSize;
  }

  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);

  //draw the border of the cylinder
  fill(random(255), random(255), random(255));
  for (int i = 0; i < x_.length; i++) {
    openCylinder.vertex(x_[i], y_[i], 0);
    openCylinder.vertex(x_[i], y_[i], cylinderHeight);
  }
  openCylinder.endShape();

  // Closing the cylinder
  cylinderBases = createShape();
  cylinderBases.beginShape(TRIANGLE_FAN);
  for (int i=0; i< x_.length-1; ++i) {
    //create top surface for cylinder
    cylinderBases.vertex(0, 0, cylinderHeight);
    cylinderBases.vertex(x_[i], y_[i], cylinderHeight);
    cylinderBases.vertex(x_[i+1], y_[i+1], cylinderHeight);

    //create bottom surface for cylinder
    cylinderBases.vertex(0, 0, 0);
    cylinderBases.vertex(x_[i], y_[i], 0);
    cylinderBases.vertex(x_[i+1], y_[i+1], 0);

    cylinderBases.vertex(0, 0, 0);
  }
  cylinderBases.endShape();
  ////end setup for cylinder
}


}