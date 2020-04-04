// Physical constants
final float GRAVITY = 9.81;
final float mu = 0.01;
final float elasticity = 0.75;


class   MovingBall {
  
  PVector location;
  PVector velocity;
  PVector gravityForce;


  // Ball colors
  private float red, blue, green;
  private float redInit = 0xf1;
  private float greenInit = 0xd6;
  private float blueInit = 0xe7;
  boolean change = false;


  // Ball characteristics
  float mass; 
  float ball_radius;


  //PImage pattern = loadImage("metal.jpg"); 
  //PShape globe;


// ---- CONSTRUCTOR ------------------------------------------------------
  MovingBall() {
    location = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    gravityForce = new PVector(0, 0, 0);
    mass = 100;
    ball_radius = 15;
    red = redInit;
    green = greenInit;
    blue = blueInit;

    //globe = createShape(SPHERE, ball_radius);
    //globe.setStroke(false);
    //globe.setTexture(pattern);
  
  }



// ---- DRAW -------------------------------------------------------------
  void draw() {
    fill(red, green, blue);
    pushMatrix();
      translate(location.x, location.y - ball_radius - 2.5, -location.z);
      //shape(globe);
      sphere(ball_radius);
    popMatrix();
  }



// ---- UPDATE -----------------------------------------------------------
  void update() {
    // GravityForce
    gravityForce.x = sin(rotationZ) * GRAVITY;
    gravityForce.z = sin(rotationX) * GRAVITY;

    // FrictionForce
    float normalForce = 1;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);

    velocity.add(gravityForce.add(friction).div(mass));

    // UpdateLocation
    location.add(velocity);
  }

  




// ---- CHECK EDGES ------------------------------------------------------
  void checkCollision(Plate plate) {
    if (location.x < -plate.x/2) {
      velocity.x = -(velocity.x * elasticity);
      location.x = -plate.x/2;
      change = true;
    }

    if (location.x > plate.x/2) {
      velocity.x = -(velocity.x * elasticity);
      location.x = plate.x/2;
      change = true;
    }

    if (location.z < -plate.z/2) {
      velocity.z = -(velocity.z * elasticity); 
      location.z = -plate.z/2;
      change = true;
    }

    if (location.z > plate.z/2) {
      velocity.z = -(velocity.z * elasticity); 
      location.z = plate.z/2;
      change = true;
    }


    if (change_ball_color) {
      if (change) {
        change = false;
        red = random(255);
        green = random(255);
        blue = random(255);
      }
    } else {
      red = redInit;
      green = greenInit;
      blue = blueInit;
    }
  }


  // TODO : fixme !
  void checkCollision(ArrayList<Cylinder> cylinders){
    for ( Cylinder c : cylinders) {
          if ( c.isInside(this) ){ 
            PVector n = new PVector(c.x - location.x, 0, -c.y - location.z).normalize(); //fixme
            n = n.mult(2*velocity.dot(n));
            velocity.sub(n);
          } 
        }
  }


}
