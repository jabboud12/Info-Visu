void drawInfo( float rotationX , float rotationZ , float speed) {
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