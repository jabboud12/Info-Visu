
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
