void setAngles() {
  if (rotatingXplus)
    angleX += ROTATE_DELTA;
  if (rotatingXminus)
    angleX -= ROTATE_DELTA;
  if (rotatingYplus)
    angleY += ROTATE_DELTA;
  if (rotatingYminus)
    angleY -= ROTATE_DELTA;
}

void keyPressed() {
  switch(keyCode) {
  case UP:
    rotatingXplus = true;
    break;
  case DOWN:
    rotatingXminus = true;
    break;
  case RIGHT:
    rotatingYplus = true;
    break;
  case LEFT:
    rotatingYminus = true;
    break;
  default: 
    break;
  }
}

void keyReleased() {
  switch(keyCode) {
  case UP:
    rotatingXplus = false;
    break;
  case DOWN:
    rotatingXminus = false;
    break;
  case RIGHT:
    rotatingYplus = false;
    break;
  case LEFT:
    rotatingYminus = false;
    break;
  default: 
    break;
  }
}
