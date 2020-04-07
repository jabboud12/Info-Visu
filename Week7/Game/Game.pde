PGraphics gameSurface;
PGraphics background;
PGraphics topView;
PGraphics scoreboard;
PGraphics barChart;
HScrollbar hs;
ArrayList<Integer> points = new ArrayList<Integer>();


int padding = 5;
int bottomTab = 200;
int topViewDim = bottomTab-2*padding;

// simulation preferences
private boolean drawAxis = false;
private boolean change_ball_color = false;
private boolean shiftMode = false;

//score
private float score = 0;
private float lastHit = 0;
private int secs = 0;


//translated mouse coordinates
float mx, my;

// rotation settings
float rotationX = 0;
float rotationZ = 0;
float speed = 1;

// MODEL
CylinderGenerator generator;
MovingBall ball;
Plate plate;


void reset() {
  ball = new MovingBall();
  generator = new CylinderGenerator();
  rotationX = 0;
  rotationZ = 0;
  speed = 1;
}


// -------- MAIN LOOP ---------------------------------------------------------

void settings() {
  //size(1200, 850, P3D);
  fullScreen(P3D);
}

void setup() {
  //background(100);

  frameRate(50);
  ball = new MovingBall();
  plate = new Plate();
  generator = new CylinderGenerator();
  gameSurface = createGraphics(width, height-bottomTab, P3D);
  background = createGraphics(width, bottomTab, P2D);
  topView = createGraphics(topViewDim, topViewDim, P2D);
  scoreboard = createGraphics(topViewDim, topViewDim, P2D);
  barChart = createGraphics(width - 2*topViewDim - 6*padding, topViewDim, P2D);
  hs = new HScrollbar(3*topViewDim, height-20, 300, 20);
}

void draw() {
  drawGame();
  image(gameSurface, 0, 0);
  drawBackground();
  image(background, 0, height-bottomTab);
  drawTopView(topView);
  image(topView, padding, height-bottomTab+padding);
  drawScoreboard(scoreboard);
  image(scoreboard, topViewDim+ 2*padding, height-bottomTab+padding);
  drawBarChart(barChart);
  image(barChart, 2*topViewDim + 4*padding, height -bottomTab+padding);
  hs.update();
  hs.display();
  
}

void drawBarChart(PGraphics surface) {
  surface.beginDraw();
  surface.background(225, 220, 159);
  secs += 1;
  if (secs>=50) {
    secs=0;
    points.add((int)(score/10));//right rounding for negative numbers??
  }

  float squareDim = (1+hs.getPos());
  for (int i = 0; i<points.size(); ++i) {
    for (int j= 0; j<abs(points.get(i)); ++j) {
      int k = (points.get(i)>0) ? -1 : 1;
      //surface.rect(i*5*hs.getPos()*5, (topViewDim)/2 +5*hs.getPos()*5, 5*hs.getPos()*5, 5*hs.getPos()*5);
      surface.rect(i*5*squareDim, (topViewDim)/2 +7.5*j*k, 5*squareDim, 7.5);
    }
  }
  surface.endDraw();
}




void drawScoreboard(PGraphics surface) {
  surface.beginDraw();
  surface.background(187);
  surface.text("Score :\n " + score(), padding, 2*padding );
  String velocity = String.format("%.1f", ball.velocity.mag());
  surface.text("\n\n\nVelocity : \n" + velocity, padding, 2*padding + 22);
  String lastHit = String.format("%.2f", lastHit());
  surface.text("\n\n\nLast score :\n" + lastHit, padding, 2*padding + 88);
  surface.endDraw();
}
void drawTopView(PGraphics surface) {
  surface.beginDraw();
  surface.background(255, 0, 0);
  surface.fill(11, 79, 107);

  surface.rect(0, 0, topViewDim, topViewDim);
  //surface.fill(11,79,107);
  //surface.rect(0,0,200,200);
  surface.noFill();
  generator.drawPoints(surface);
  ball.drawBall(surface);
  surface.endDraw();
}


void drawBackground() {
  background.beginDraw();
  background.endDraw();
}

void increaseScore(float x) { 
  lastHit = x*10;
  score += lastHit;
}
void decreaseScore() {
  score -= 10;
}
float score() {
  return score;
};
float lastHit() {
  return lastHit;
}

void drawGame() {
  gameSurface.beginDraw();
  mx = mouseX - width/2.0;
  my = mouseY - (height-bottomTab)/2.0;
  gameSurface.background(229, 228, 223);

  gameSurface.pushMatrix();
  gameSurface.translate(width/2, (height-bottomTab)/2);
  if (!shiftMode) 
    regularMode();
  else 
  shiftMode();
  gameSurface.popMatrix();
  gameSurface.endDraw();
}


// ----------------------------------------------------------------------------


// REGULAR MODE
void regularMode() {

  setLight(gameSurface);

  gameSurface.pushMatrix();

  gameSurface.rotateX(rotationX);
  gameSurface.rotateZ(rotationZ);

  plate.draw(gameSurface);

  if (drawAxis)
    plate.drawAxis(gameSurface);  

  ball.update();
  ball.draw(gameSurface);
  ball.checkCollision(plate);
  ball.checkCollision(generator.cylinders);

  gameSurface.rotateX(PI/2);

  generator.draw(gameSurface);
  generator.update(plate, ball);

  gameSurface.popMatrix();

  drawInfo(gameSurface, rotationX, rotationZ, speed);
}


// SHIFT MODE
void shiftMode() {
  gameSurface.lights();
  gameSurface.fill(126);

  gameSurface.rect(-plate.x/2, -plate.z/2, plate.x, plate.z);

  // Draw the cylinders
  generator.drawShitMode(gameSurface);


  // Draw the ball
  gameSurface.translate(ball.location.x, -ball.location.z);
  gameSurface.sphere(ball.ball_radius);
}





// ----EVENT HANDLERS ----------------------------------------------------


void mousePressed() {

  if (shiftMode) {
    CylinderGenerator newGen = new CylinderGenerator(mx, my);
    if (!newGen.isInside(ball) && plate.isInside(newGen))
      generator = newGen;
  }
}


//  This method is used to rotate the board following the mouse's movements when dragged
void mouseDragged() {

  float angle_limit = PI/3;
  //fixme : ask TA
  if (mouseY<height-bottomTab) {
    rotationX -= speed * (mouseY - pmouseY) / height;
    rotationZ += speed * (mouseX - pmouseX) / width;
  }

  if (rotationZ > angle_limit)
    rotationZ = angle_limit;
  if (rotationZ < -angle_limit)
    rotationZ = - angle_limit;
  if (rotationX  > angle_limit)
    rotationX = angle_limit;
  if (rotationX < -angle_limit)
    rotationX = - angle_limit;
}

//  This method increments/decrements the rotation's speed of the board with the scrolling of the mouse
void mouseWheel(MouseEvent e) {
  float speed_threshold_min = 0.2;
  float speed_threshold_max = 10;
  float increment_coef = 0.05;
  float ev = e.getCount();

  if (speed < -ev * increment_coef + speed_threshold_min) 
    speed = speed_threshold_min;
  else if (speed > - ev * increment_coef + speed_threshold_max) 
    speed = speed_threshold_max;
  else
    speed += ev * increment_coef;
}




void keyPressed() {
  if (keyCode == ENTER) {
    drawAxis = !drawAxis;
    change_ball_color = !change_ball_color;
  }  

  if (keyCode == SHIFT) 
    shiftMode = true;

  if (key == 'R' || key == 'r')
    reset();
}

void keyReleased() {
  if (keyCode == SHIFT) 
    shiftMode = false;
}
