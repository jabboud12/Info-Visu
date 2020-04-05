void drawInfo() {
  noLights();
  translate(-width/2, -height/2);
  if (!drawAxis) {
    textSize(20);
    fill(150, 0, 0);
    text("RotationX : "+rotationX, 50, 50);
    fill(0, 0, 200);
    text("RotationZ : "+rotationZ, 50, 50 + 22);
    fill(0, 100, 0);
    text("Speed : "+speed, 50, 50 + 44);
    fill(0);
    text("Press Enter to toggle debug mode", 50, 50 + 66);
  } else {
    textSize(12);
    fill(0);
    //strokeWeight(10);
    text("RotationX: " + rotationX + "  RotationZ: " + rotationZ + "  Speed: " + speed, 10, 20);
    text("Ball location: " + ball.location, 10, 32);
    text("Ball velocity: " + ball.velocity, 10, 44);
    if (generator.cylinders.size() != 0) {
      text("Villain at: " + generator.cylinders.get(0).x + " " + -generator.cylinders.get(0).y, 10, 56);
    } else {
      text("No villain placed", 10, 56);
    }
  }
}

void setLight() {
  ambientLight(150, 150, 150);
  directionalLight(128, 128, 128, 1, 1, -1);
  lightFalloff(1, 0, 0);
  lightSpecular(0, 0, 0);
  pointLight(51, 102, 126, 35, 40, 36);
  //pointLight(255, 255, 255, 1, 1, -1);
}

static float vect_norm(float ... x) {
  float sum = 0;
  for (int i = 0; i < x.length; ++i) {
    sum += x[i] * x[i];
  }
  return sum;
}
