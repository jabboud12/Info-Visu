

void cylinderSetup() {
  ////setup for cylinder
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];

  //get the x and y position on a circle for all the sides
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }

  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);

  //draw the border of the cylinder
  fill(random(255), random(255), random(255));
  for (int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], y[i], 0);
    openCylinder.vertex(x[i], y[i], cylinderHeight);
  }
  openCylinder.endShape();

  // Closing the cylinder
  cylinderBases = createShape();
  cylinderBases.beginShape(TRIANGLE_FAN);
  for (int i=0; i< x.length-1; ++i) {
    //create top surface for cylinder
    cylinderBases.vertex(mouseX, mouseY, cylinderHeight);
    cylinderBases.vertex(x[i], y[i], cylinderHeight);
    cylinderBases.vertex(x[i+1], y[i+1], cylinderHeight);

    //create bottom surface for cylinder
    cylinderBases.vertex(mouseX, mouseY, 0);
    cylinderBases.vertex(x[i], y[i], 0);
    cylinderBases.vertex(x[i+1], y[i+1], 0);

    cylinderBases.vertex(mouseX, mouseY, 0);
  }
  cylinderBases.endShape();
  ////end setup for cylinder
}
