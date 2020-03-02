void settings() {
  size(1000, 1000, P2D);
}

void setup() {
}

void draw() {
  background(0xfff, 0xff, 0xff);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);

  //rotated around x
  float[][] transform1 = rotateXMatrix(-PI/8);
  input3DBox = transformBox(input3DBox, transform1);
  projectBox(eye, input3DBox).render();

  //rotated and translated
  float[][] transform2 = translationMatrix(200, 200, 0);
  input3DBox = transformBox(input3DBox, transform2);
  projectBox(eye, input3DBox).render();

  //rotated, translated, and scaled
  float[][] transform3 = scaleMatrix(2, 2, 2);
  input3DBox = transformBox(input3DBox, transform3);
  projectBox(eye, input3DBox).render();
}

My2DBox projectBox (My3DPoint eye, My3DBox box) {
  My2DPoint[] trans = new My2DPoint[box.p.length];
  for (int i = 0; i < box.p.length; i++)
    trans[i] = projectPoint(eye, box.p[i]);
  return new My2DBox(trans);

  /*  Use this code in draw() to test this method, with ideal window size 400x400
   My3DPoint eye = new My3DPoint(-100, -100, -5000);
   My3DPoint origin = new My3DPoint(0, 0, 0); //The first vertex of your cuboid
   My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
   projectBox(eye, input3DBox).render();
   */
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  My3DPoint trans = new My3DPoint(p.x - eye.x, p.y - eye.y, p.z - eye.z);
  float pt = (-eye.z) / (p.z - eye.z);
  My2DPoint point = new My2DPoint(trans.x * pt, trans.y * pt);
  return point;

  /* Use this code in draw() to test this method, with ideal window size 400x400
   My3DPoint eye = new My3DPoint(-100, -100, -5000);
   My2DPoint p1 = projectPoint(eye, new My3DPoint(0, 0, 0));
   My2DPoint p2 = projectPoint(eye, new My3DPoint(100, 0, 0));
   My2DPoint p3 = projectPoint(eye, new My3DPoint(100, 150, 0));
   My2DPoint p4 = projectPoint(eye, new My3DPoint(100, 150, 300));
   
   line (p1.x, p1.y, p2.x, p2.y);
   line (p2.x, p2.y, p3.x, p3.y);
   line (p3.x, p3.y, p4.x, p4.y);
   */
}

class My2DPoint {
  float x;
  float y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  void render() {
    strokeWeight(3);
    //Front face
    stroke(255, 0, 0);
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[1].x, s[1].y, s[2].x, s[2].y);
    line(s[2].x, s[2].y, s[3].x, s[3].y);
    line(s[3].x, s[3].y, s[0].x, s[0].y);
    //Vertices connecting front and back faces
    stroke(0, 0, 255);
    line(s[0].x, s[0].y, s[4].x, s[4].y);
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    line(s[5].x, s[5].y, s[1].x, s[1].y);
    line(s[2].x, s[2].y, s[6].x, s[6].y);
    //Back face
    stroke(0, 255, 0);
    line(s[5].x, s[5].y, s[6].x, s[6].y);
    line(s[7].x, s[7].y, s[6].x, s[6].y);
    line(s[4].x, s[4].y, s[7].x, s[7].y);
    line(s[4].x, s[4].y, s[5].x, s[5].y);
  }
}

class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ) {
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{new My3DPoint(x, y+dimY, z+dimZ), 
      new My3DPoint(x, y, z+dimZ), 
      new My3DPoint(x+dimX, y, z+dimZ), 
      new My3DPoint(x+dimX, y+dimY, z+dimZ), 
      new My3DPoint(x, y+dimY, z), 
      origin, 
      new My3DPoint(x+dimX, y, z), 
      new My3DPoint(x+dimX, y+dimY, z)
    };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

/// The following functions are matrices/matrix operations used in transformations
float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][] {{1, 0, 0, 0}, 
    {0, cos(angle), -sin(angle), 0}, 
    {0, sin(angle), cos(angle), 0}, 
    {0, 0, 0, 1}});
}
float[][] rotateYMatrix(float angle) {
  return(new float[][] {{cos(angle), 0, sin(angle), 0}, 
    {0, 1, 0, 0}, 
    {-sin(angle), 0, cos(angle), 0}, 
    {0, 0, 0, 1}});
}
float[][] rotateZMatrix(float angle) {
  return(new float[][] {{cos(angle), -sin(angle), 0, 0}, 
    { sin(angle), cos(angle), 0, 0}, 
    {0, 0, 1, 0}, 
    {0, 0, 0, 1}});
}
float[][] scaleMatrix(float x, float y, float z) {
  return(new float[][] {{x, 0, 0, 0}, 
    { 0, y, 0, 0}, 
    {0, 0, z, 0}, 
    {0, 0, 0, 1}});
}
float[][] translationMatrix(float x, float y, float z) {
  return(new float[][] {{1, 0, 0, x}, 
    { 0, 1, 0, y}, 
    {0, 0, 1, z}, 
    {0, 0, 0, 1}});
}

// Matrix product of dimensions 4x4 * 4x1
float[] matrixProduct(float[][] a, float[] b) {
  float[] mat = new float[a.length];
  for (int i = 0; i < mat.length; i++) {
    float sum = 0;
    for (int j = 0; j < mat.length; j++) {
      sum += a[i][j] * b[j];
    }
    mat[i] = sum;
  }
  return mat;
}

//Applies the given matrix transformation to the 3D box given 
My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] p = new My3DPoint[box.p.length];
  for (int i = 0; i < p.length; i++)
    p[i] = euclidian3DPoint(matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i]))); 

  return new My3DBox(p);
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}
