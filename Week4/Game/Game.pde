float rotationX = 0;
float rotationZ = 0;
float x = 0;
float y = 0;
float speed = 1;
MovingBall ball;
float plateX = 300;
float plateY = 10;
float plateZ = 300;

boolean drawAxis = false;
boolean change_ball_color = false;

void settings() {
  size(600, 600, P3D);
}

void setup() {
  ball = new MovingBall();
}

void draw() {
  background(229, 228, 223);
  setLight();
  //noLights();

  pushMatrix();

  translate(width/2, height/2);
  rotateX(rotationX);
  rotateZ(rotationZ);


  noStroke();
  fill(0xc0, 0xff, 0xee);
  box(plateX, plateY, plateZ);

  if (drawAxis)
    drawAxis();  


  ball.update();
  ball.display();
  ball.checkEdges();

  popMatrix();

  drawInfo();
}

void setLight() {
  ambientLight(128, 128, 128);
  directionalLight(128, 128, 128, 0,  0, -1);
  lightFalloff(1, 0, 0);
  lightSpecular(0, 0, 0);
  pointLight(51, 102, 126, 35, 40, 36);
}

/*
  This method is used to rotate the board following the mouse's movements when pressed
 */
void mouseDragged() {

  float angle_limit = PI/3
  ;

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

}

void keyPressed() {
  if (keyCode == ENTER) {
    drawAxis = !drawAxis;
    change_ball_color = !change_ball_color;
  }
  if (key == 'r' || key == 'R') {
    reset();
  }
}

/*
  This method prints on the upper left corner of the window some information about the board
 */
void drawInfo() {
  noLights();
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

void reset() {
  ball = new MovingBall();
  rotationX = 0;
  rotationZ = 0;
  speed = 1;
}
