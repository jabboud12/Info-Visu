float rotationX = 0;
float rotationZ = 0;
float speed = 1;


void settings() {
  size(500, 500, P3D);
  
}



void setup(){
  
}


void draw(){
  background(200);
  
  println(mouseX , mouseY);

  pushMatrix();
  camera(0 , 0 , 1000, 0, 0, 0, 0, 1, 0);
  
  
  //lights();
  
    pushMatrix();
      rotationZ = map(speed * mouseY, 0, height, -1.04 , 1.04);
      rotationX = map(speed * mouseX, 0, width, -1.04 , 1.04);
      rotateZ( rotationX);
      rotateX(rotationZ);
      
      box(200, 20, 200);
      
      pushMatrix();
        drawAxis();
      popMatrix();
    popMatrix();
  
  popMatrix();
  
  drawInfo();
  
}


void mouseWheel(MouseEvent e){
 
  float ev = e.getCount();
  speed += ev*0.1;
  println(speed);
  
}


void drawInfo(){
  textSize(20);
  text("RotationX : "+rotationX, 50 , 50);
  text("RotationZ : "+rotationZ,50, 50 + 22);
  text("Speed : "+speed,50, 50 + 44);
}


void drawAxis()
{
    
    float a = 300;  
    
    textSize(50);
    
    // Y axis
    stroke(0, 255, 0);
    line(0, -a, 0, 0, a, 0);
    text("Y",0,a,0);
 
    // X axis
    stroke(255, 0, 0);
    line(-a, 0, 0, a, 0, 0);
    text("X",a,0,0);
 
    // Z axis
    stroke(0, 0, 255);
    line(0, 0, -a, 0, 0, a);
    text("Z",0,0,a);
    
}
