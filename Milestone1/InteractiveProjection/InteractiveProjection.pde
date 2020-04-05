float angleX = 0;
float angleY = 0;

boolean rotatingXplus = false;
boolean rotatingXminus = false;
boolean rotatingYplus = false;
boolean rotatingYminus = false;

final float ROTATE_DELTA = 0.01;

void settings() {
  size(1000, 1000, P2D);
}

void setup() {
}

void draw() {
  background(255);

  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
  
  // Next method and 2 matrices take care of user input (arrows) to rotate boxes
  setAngles();

  float[][] rotateXBoxes = rotateXMatrix(angleX);
  input3DBox = transformBox(input3DBox, rotateXBoxes);

  float[][] rotateYBoxes = rotateYMatrix(angleY);
  input3DBox = transformBox(input3DBox, rotateYBoxes);


  // First small box
  float[][] transform1 = rotateXMatrix(-PI/8);
  input3DBox = transformBox(input3DBox, transform1);
  projectBox(eye, input3DBox).render();

  // First box rotated and translated into a middle one
  float[][] transform2 = translationMatrix(200, 200, 0);
  input3DBox = transformBox(input3DBox, transform2);
  projectBox(eye, input3DBox).render();

  // Rotated, translated, and scaled into a third bigger box
  float[][] transform3 = scaleMatrix(2, 2, 2);
  input3DBox = transformBox(input3DBox, transform3);
  projectBox(eye, input3DBox).render();
}
