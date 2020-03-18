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
  final float mu = 1.1;
  final float elasticity = 0.75;

  PImage pattern; 
  PShape globe;



  MovingBall() {
    location = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    gravityForce = new PVector(0, 0, 0);
    mass = 100;
    ball_radius = 15;
    red = redInit;
    green = greenInit;
    blue = blueInit;

    pattern = loadImage("metal.jpg");

    globe = createShape(SPHERE, ball_radius);
    globe.setStroke(false);
    globe.setTexture(pattern);
    ;
  }

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


  void display() {
    fill(red, green, blue);
    pushMatrix();
    translate(location.x, location.y - ball_radius - plateY/2, -location.z);


    shape(globe);

    //sphere(ball_radius);
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



  void checkCylinderCollision() {



    //-cylinder.get(i).z twice because z is oriented int the wrong way
    for (int i = 0; i< cylinders.size(); ++i) {
      if (Math.pow(cylinders.get(i).x - location.x, 2) + Math.pow(-cylinders.get(i).z - location.z, 2)< (ball_radius+cylinderBaseSize)*(ball_radius+cylinderBaseSize)) {//fixme
        PVector n = new PVector(cylinders.get(i).x - location.x, 0, -cylinders.get(i).z - location.z).normalize(); //fixme
        n = n.mult(2*velocity.dot(n));

        velocity.sub(n);
      }
    }
  }
}
