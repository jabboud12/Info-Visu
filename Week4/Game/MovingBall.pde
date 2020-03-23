class   MovingBall {
  PVector location;
  PVector velocity;
  PVector gravityForce;

  private float red, blue, green;
  private float redInit = 0xf1;
  private float greenInit = 0xd6;
  private float blueInit = 0xe7;

  boolean change = false;

  // Ball characteristics
  float mass; 
  float ball_radius;

  // Physical constants
  final float GRAVITY = 9.81;
  final float mu = 0.1;
  final float elasticity = 0.9;

  MovingBall() {
    location = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    gravityForce = new PVector(0, 0, 0);
    mass = 100;
    ball_radius = 20;
    red = redInit;
    green = greenInit;
    blue = blueInit;
  }

  void update() {
    // GravityForce
    gravityForce.x = sin(rotationZ) * GRAVITY;
    gravityForce.z = sin(rotationX) * GRAVITY;
    //gravityForce.y = GRAVITY;

    // FrictionForce
    float normalForce = 1;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);

    //float v_y = velocity.y;

    velocity.add(gravityForce.add(friction).div(mass));

    //velocity.y = v_y + gravityForce.y;

    // UpdateLocation
    location.add(velocity);
  }


  void display() {
    fill(red, green, blue);
    pushMatrix();
    translate(location.x, location.y - ball_radius - plateY/2, -location.z);

    sphere(ball_radius);
    popMatrix();
  }

  void checkEdges() {
    if (location.x < -plateX/2) {// || location.x > plateX/2) 
      velocity.x = -(velocity.x * elasticity);
      location.x = -plateX/2;
      change = true;
    }

    if (location.x > plateX/2) {// || location.x > plateX/2) 
      velocity.x = -(velocity.x * elasticity);
      location.x = plateX/2;
      change = true;
    }

    if (location.z < -plateZ/2) {// || location.z > plateZ/2) 
      velocity.z = -(velocity.z * elasticity); 
      location.z = -plateZ/2;
      change = true;
    }

    if (location.z > plateZ/2) {// || location.z > plateZ/2) 
      velocity.z = -(velocity.z * elasticity); 
      location.z = plateZ/2;
      change = true;
    }

    //if (location.y > 0) {// || location.z > plateZ/2) 
    //  velocity.y = -(velocity.y * elasticity); 
    //  location.y =  0;
    //  //change = true;
    //}

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
}
