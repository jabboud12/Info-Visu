float rotationX = 0;
float rotationZ = 0;
float x = 0;
float y = 0;
float speed = 1;
boolean isMoving = false;
MovingBall ball;
float plateX = 300;
float plateY = 10;
float plateZ = 300;

void settings() {
  size(500, 500, P3D);
}

void setup() {
  
  ball = new MovingBall();
}

void draw() {
  background(255);

  

  pushMatrix();
    camera(0, 0, 900, 0, 0, 0, 0, 1, 0);
  
    rotateZ(rotationX);
    rotateX(-rotationZ);
    
    ball.update();
    ball.display();
    ball.checkEdges();
  
    noStroke();
    fill(150, 150, 150);
    box(plateX, plateY, plateZ);
  
    drawAxis();

  popMatrix();
  
  drawInfo();
}









class   MovingBall {
  PVector location;
  PVector velocity;
  float mass; 
  
  MovingBall() {
    location = new PVector(0,0,0);
    velocity = new PVector(0,0,0);
    mass = 100;
  }
  
  void update() {
    
    // GravityForce
    PVector gravityForce = new PVector( 0, 0 , 0);
    int gravityConstant = 10;
    gravityForce.x = sin(rotationX) * gravityConstant;
    gravityForce.z = sin(rotationZ) * gravityConstant;
    
    // FricctionForce
    float normalForce = 1;
    float mu = 0.01;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);

    // UpdateLocation
    velocity.add(gravityForce.add(friction).div(mass));
    location.add(velocity);
  }
  
  
  void display() {
    pushMatrix();
    translate(location.x , location.y-30 , location.z);
    sphere(30);
    popMatrix();
  }
  void checkEdges() {
    
    if(location.x < -plateX/2){
      location.x = -plateX/2;
      velocity.x = -velocity.x;
    }
    if(location.x > plateX/2){
      location.x = plateX/2;
      velocity.x = -velocity.x;
    }
    if(location.z < -plateZ/2){ 
      location.z = -plateZ/2;
      velocity.z = -velocity.z;
    }
    if( location.z > plateZ/2){
      location.z = plateZ/2;
      velocity.z = -velocity.z;
    }
    
    
    
    
  }
}













void mouseDragged() {
    
    float angle_limit = PI/3;
    
    float diffZ = speed * (mouseY - pmouseY) / height;
    float diffX = speed * (mouseX - pmouseX) / width;
    
    rotationZ += diffZ;
    rotationX += diffX;
    
    if (rotationZ + diffZ > angle_limit)
      rotationZ = angle_limit;
    if (rotationZ + diffZ < -angle_limit)
      rotationZ = - angle_limit;
    if (rotationX + diffX > angle_limit)
      rotationX = angle_limit;
    if (rotationX + diffX < -angle_limit)
      rotationX = - angle_limit;
    isMoving = true;
 
}


void mouseWheel(MouseEvent e) {
  float speed_threshold = 0.2;
  float ev = e.getCount();
  if (speed < -ev*0.1 + speed_threshold) {
    speed = speed_threshold;
  } else { 
    speed += ev*0.05;
  }
  println(speed);
}


void drawInfo() {
  textSize(20);
  fill(255, 0, 0);
  text("RotationX : "+rotationX, 50, 50);
  fill(0, 0, 255);
  text("RotationZ : "+rotationZ, 50, 50 + 22);
  fill(0);
  text("Speed : "+speed, 50, 50 + 44);
}


void drawAxis()
{

  float a = 300;  

  textSize(50);

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
}
