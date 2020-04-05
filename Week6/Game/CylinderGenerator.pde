class CylinderGenerator {

  ArrayList<Cylinder> cylinders;

  // source position is at cylinders.get(0)
  PShape villain = loadShape("robotnik.obj");

  //FIXME : put it in setup instead of here
  float theta;


  CylinderGenerator() {
    cylinders = new ArrayList();
  }

  CylinderGenerator(float x, float y) {
    cylinders = new ArrayList();
    cylinders.add( new Cylinder(x, y) );
  }

  float oldAngle=0;
  void draw() {

    // TODO : draw the source on top of cylinders.get(0)

    for ( Cylinder c : cylinders)
      c.draw();


    if (cylinders.size() >0) {
      float x = cylinders.get(0).x;
      float y = cylinders.get(0).y;
      float x0 = ball.location.x;
      float y0 = ball.location.y;
      theta = acos((ball.location.z - y)/ sqrt((x-x0)*(x-x0) + (y-y0)*(y-y0)));
      
    //villain.rotateY( theta-oldAngle);
    //oldAngle = theta;
    
      pushMatrix();
      rotateX(PI/2);
      rotateY(PI);

      translate(-x, 30/*cylinder height*/, y);
      scale(25);       
      shape(villain, 0, 0);
      popMatrix();
    }      

  }
  

  


  void drawShitMode() {
    for ( Cylinder c : cylinders)
      c.drawShitMode();
  }


  boolean isInside(MovingBall ball) {
    return cylinders.get(0).isInside(ball);
  }

  void update( Plate plate, MovingBall ball ) {



    if ( cylinders.isEmpty()  )
      return ;


    for ( int i=0; i< cylinders.size(); i++) {
      if ( cylinders.get(i).isInside(ball) ) {
        if (i == 0) {
          // Yeah you killed the SOURCE !!
          cylinders = new ArrayList();
          return;
        }
        cylinders.remove(i);
        i = i-1;
      }
    }

    if (frameCount % 50 != 0 )
      return ;


    int numAttempts = 100;

    for (int i=0; i< numAttempts; i++) {

      // Pick a cylinder and its center.
      int index = int(random(cylinders.size()));
      Cylinder new_cylinder = cylinders.get(index).copy();


      // Try to add an adjacent cylinder.
      float angle = random(TWO_PI);
      new_cylinder.x += sin(angle) * 2 * new_cylinder.cylinderBaseSize;
      new_cylinder.y += cos(angle) * 2 * new_cylinder.cylinderBaseSize;


      boolean noCylinderCollision = true;
      for (Cylinder c1 : cylinders)
        if (c1.isInside(new_cylinder)) noCylinderCollision = false;



      // TODO : i dont understant why it doesn t work wtith isInside uncommented ?
      if (plate.isInside(new_cylinder) /* && new_cylinder.isInside(ball)*/ && noCylinderCollision) {
        cylinders.add(new_cylinder);
        break;
      }
    }
  }
}
