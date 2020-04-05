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

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  My3DPoint trans = new My3DPoint(p.x - eye.x, p.y - eye.y, p.z - eye.z);
  float pt = (-eye.z) / (p.z - eye.z);
  My2DPoint point = new My2DPoint(trans.x * pt, trans.y * pt);
  return point;
}
