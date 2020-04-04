class Plate {

// plane settings


float x = 300;
float y = 5;
float z = 300;


void draw(){
    noStroke();
    fill(0xC0, 0xFF, 0xEE);
    box(x, y, z);
}


boolean isInside(float mx , float my){
    return (mx > -x/2) && (mx < x/2) && (my > -z/2) && (my < z/2);
}


boolean isInside(Cylinder c ){
    return !((c.x - c.cylinderBaseSize < -x/2) ||
           (c.x + c.cylinderBaseSize > x/2)  || 
           (c.y - c.cylinderBaseSize < -z/2) || 
           (c.y + c.cylinderBaseSize > z/2));
}

boolean isInside(CylinderGenerator c ){
    return isInside(c.cylinders.get(0));
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


}