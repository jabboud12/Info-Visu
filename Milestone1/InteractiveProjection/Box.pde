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

My2DBox projectBox (My3DPoint eye, My3DBox box) {
  My2DPoint[] trans = new My2DPoint[box.p.length];
  for (int i = 0; i < box.p.length; i++)
    trans[i] = projectPoint(eye, box.p[i]);
  return new My2DBox(trans);
}
