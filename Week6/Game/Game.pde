// simulation preferences
boolean drawAxis = false;
boolean change_ball_color = false;
boolean shiftMode = false;




//translated mouse coordinates
float mx, my;

// rotation settings
float rotationX = 0;
float rotationZ = 0;
float speed = 1;

// MODEL
CylinderGenerator generator;
MovingBall ball;
Plate plate;


void reset() {
  ball = new MovingBall();
  generator = new CylinderGenerator();
  rotationX = 0;
  rotationZ = 0;
  speed = 1;
}


// -------- MAIN LOOP ---------------------------------------------------------

void settings() {
  size(800, 800, P3D);
}

void setup() {
  frameRate(50);
  ball = new MovingBall();
  plate = new Plate();
  generator = new CylinderGenerator();
}

void draw() {
  mx = mouseX - width/2.0;
  my = mouseY - height/2.0;
  background(229, 228, 223);

  pushMatrix();
    translate(width/2, height/2);
    if (!shiftMode) 
      regularMode();
    else 
      shiftMode();
  popMatrix();

}


// ----------------------------------------------------------------------------


// REGULAR MODE
void regularMode() {

  setLight();

  pushMatrix();

    rotateX(rotationX);
    rotateZ(rotationZ);

    plate.draw();

    if (drawAxis)
      plate.drawAxis();  

    ball.update();
    ball.draw();
    ball.checkCollision(plate);
    ball.checkCollision(generator.cylinders);

    rotateX(PI/2);

    generator.draw();
    generator.update(plate , ball);

  popMatrix();

  drawInfo(rotationX , rotationZ , speed);
}


// SHIFT MODE
void shiftMode() {
  lights();
  fill(126);

  rect(-plate.x/2, -plate.z/2, plate.x, plate.z);

  // Draw the cylinders
  generator.drawShitMode();
  

  // Draw the ball
  translate(ball.location.x, -ball.location.z);
  sphere(ball.ball_radius);
}





// ----EVENT HANDLERS ----------------------------------------------------


void mousePressed() {

  if (shiftMode){
    CylinderGenerator newGen = new CylinderGenerator(mx , my);
    if(!newGen.isInside(ball) && plate.isInside(newGen))
      generator = newGen;
  }
    
}


//  This method is used to rotate the board following the mouse's movements when dragged
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

//  This method increments/decrements the rotation's speed of the board with the scrolling of the mouse
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

  if (keyCode == SHIFT) 
    shiftMode = true;

  if (key == 'R' || key == 'r')
    reset();
  
}

void keyReleased() {
  if (keyCode == SHIFT) 
    shiftMode = false;
}
