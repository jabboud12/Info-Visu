
////// z is oriented in the wrong way for cylinders
////// show the ball in shift mode
////// do the mega bonus
///// choose photo for ball



float rotationX = 0;
float rotationZ = 0;
float x = 0;
float y = 0;
float speed = 1;
MovingBall ball;
float plateX = 300;
float plateY = 5;
float plateZ = 300;

boolean drawAxis = false;
boolean change_ball_color = false;
boolean shiftMode = false;

ArrayList<PVector> cylinders = new ArrayList();


//cylinder
float cylinderBaseSize = 30;
float cylinderHeight = 30;
int cylinderResolution = 40;

PShape openCylinder = new PShape();
PShape cylinderBases = new PShape();

//translated mouse coordinates
int mx, my;



void settings() {
  size(800, 800, P3D);
}

void setup() {

  
  ball = new MovingBall();

  cylinderSetup();
  
}

void draw() {
  mx = mouseX - width/2;
  my = mouseY - height/2;

  background(229, 228, 223);

  pushMatrix();
  translate(width/2, height/2);

  if (!shiftMode)
    regularMode();
  else
    shiftMode();
  popMatrix();
}

void shiftMode() {

  lights();
  fill(126);
 
  rect(-plateX/2, -plateZ/2, plateX, plateZ);

  for (int i = 0; i < cylinders.size(); ++i) {
    //shape(openCylinder, cylinders.get(i).x, cylinders.get(i).z); 
    shape(cylinderBases, cylinders.get(i).x, cylinders.get(i).z);
  }



  //////////////////////////////////////translate(width/2, height/2);
  //ball.display();

  //  ////////////////////////////////////translate(width/2, height/2);


  //rotateX(rotationX);
  //rotateZ(rotationZ);



  //MovingBall b = new MovingBall();
  //b.location = new PVector(ball.location.x,0 , ball.location.y);
  //b.display();


}

void mousePressed() {
  //check if the position of the cylinder to add is on the plate and wouldn't cause overlap
  if (shiftMode && mx >  -plateX/2 && mx < plateX/2 &&  my > -plateZ/2 && my < plateZ/2 && placeIsFree(mx, my)) {

    cylinders.add(new PVector(mx,0, my));
    System.out.println("Cylinder added : " + new PVector(mx,0, my)); //fixme

    System.out.println("add ");
  }
}

boolean placeIsFree(float x, float y) {
  System.out.println("mx = "+ x +" my = "+y);
  System.out.println("mx = "+ x +" my = "+y);
  ///                                              -ball,location.z because z axis is oriented in the wrong way
  if (Math.pow(ball.location.x - x, 2) + Math.pow(-ball.location.z - y, 2) < (ball.ball_radius + cylinderBaseSize)* (ball.ball_radius + cylinderBaseSize)) return false;

  for (int i = 0; i < cylinders.size(); ++i) {
    if ( Math.pow(cylinders.get(i).x - x, 2) + Math.pow(cylinders.get(i).z - y, 2)< (2*cylinderBaseSize)*(2*cylinderBaseSize)) return false;
  }
  return true;
}

void regularMode() {
  setLight();
  pushMatrix();

  rotateX(rotationX);
  rotateZ(rotationZ);


  noStroke();
  fill(0xC0, 0xFF, 0xEE);

  box(plateX, plateY, plateZ);


  if (drawAxis)
    drawAxis();  

  ball.update();
  ball.display();
  ball.checkEdges();
  ball.checkCylinderCollision();

  rotateX(PI/2);

  translate(0,0, plateY/2);
  for (int i = 0; i < cylinders.size(); ++i) {
    shape(openCylinder, cylinders.get(i).x, cylinders.get(i).z);
    shape(cylinderBases, cylinders.get(i).x, cylinders.get(i).z); 
  }

  popMatrix();
  drawInfo();
}

void setLight() {
  ambientLight(150, 150, 150);
  directionalLight(128, 128, 128, 1, 1, -1);
  lightFalloff(1, 0, 0);
  lightSpecular(0, 0, 0);
  pointLight(51, 102, 126, 35, 40, 36);
  //pointLight(255, 255, 255, 1, 1, -1);

  //lights();
}



/*
  This method is used to rotate the board following the mouse's movements when pressed
 */
void mouseDragged() {

  float angle_limit = PI/3;

  rotationX -= speed * (mouseY - pmouseY) / height;
  rotationZ += speed * (mouseX - pmouseX) / width;

  if (rotationZ > angle_limit)
    rotationZ = angle_limit;
  if (rotationZ < -angle_limit)
    rotationZ = - angle_limit;
  if (rotationX  > angle_limit)
    rotationX = angle_limit;
  if (rotationX < -angle_limit)
    rotationX = - angle_limit;
}

/*
  This method increments/decrements the rotation's speed of the board with the scrolling of the mouse
 */
void mouseWheel(MouseEvent e) {
  float speed_threshold = 0.2;
  float increment_coef = 0.05;
  float ev = e.getCount();

  if (speed < -ev * increment_coef + speed_threshold) 
    speed = speed_threshold;
  else
    speed += ev * increment_coef;

  println(speed);
}

void keyPressed() {
  if (keyCode == ENTER) {
    drawAxis = !drawAxis;
    change_ball_color = !change_ball_color;
  }  

  if (keyCode == SHIFT) 
    shiftMode = true;
}

void keyReleased() {
  if (keyCode == SHIFT) 
    shiftMode = false;
}



/*
  This method prints on the upper left corner of the window some information about the board
 */
void drawInfo() {
  noLights();
  translate(-width/2, -height/2);
  textSize(20);
  fill(255, 0, 0);
  text("RotationX : "+rotationX, 50, 50);
  fill(0, 0, 255);
  text("RotationZ : "+rotationZ, 50, 50 + 22);
  fill(0);
  text("Speed : "+speed, 50, 50 + 44);

}


void drawAxis() {
  float a = 300;  

  textSize(30);
  fill(0);
  strokeWeight(2);

  // Y axis
  stroke(0, 255, 0);
  line(0, -a, 0, 0, a, 0);
  text("Y", 0, a, 0);

  // X axis
  stroke(255, 0, 0);
  line(-a, 0, 0, a, 0, 0);
  text("X", a, 0, 0);

  // Z axis
  stroke(0, 0, 255);
  line(0, 0, -a, 0, 0, a);
  text("Z", 0, 0, a);



  noStroke();
}
