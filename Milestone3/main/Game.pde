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

ImageProcessing imgproc;
test testim;

PVector rotVect = new PVector(0, 0, 0);


void reset() {
  ball = new MovingBall();
  generator = new CylinderGenerator();
  rotationX = 0;
  rotationZ = 0;
  speed = 1;
}


// -------- MAIN LOOP ---------------------------------------------------------

void settings() {
  size(1200, 850, P3D);
  //fullScreen(P3D);
}

void setup() {

  //---------------------------------------- Image Processing ------------------------------------//
  opencv = new OpenCV(this, 100, 100);

  // Enable the camera
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) 
      println(cameras[i]);

    cam = new Capture(this, 320, 240, cameras[0]);
    //cam.start();
  }

  // Load images and store them in an array
  board1 = loadImage("board1.jpg");
  board2 = loadImage("board2.jpg");
  board3 = loadImage("board3.jpg");
  board4 = loadImage("board4.jpg");
  nao = loadImage("nao.jpg");
  nao_blob = loadImage("nao_blob.jpg");

  PImage [] imagess = {board1, board2, board3, board4, nao, nao_blob}; 

  images = Arrays.asList(imagess);

  //// Set the size of the image according to the screen's dimensions (just an aesthetic addition, to keep the images' dimensions proportional)
  //for (PImage img : images) {
  //  double newWidth = img.width * 3.0;
  //  double newImgHeight = img.height;
  //  while (newWidth > Width) {
  //    newWidth *= widthFactor;
  //    newImgHeight *= heightFactor;
  //  }
  //  img.resize((int) (newWidth/3), (int) newImgHeight);
  //}

  // Start with the first image, board1.jpg
  imageIndex = 0;
  surface.setTitle("Board 1 -- Corner detection || Edge detection || HSB thresholding");
  img = images.get(imageIndex);
  //surface.setSize(img.width * 3, img.height);

  rot = new TwoDThreeD(img.width, img.height, 0);

  if (twoBlobsMode) {
    surface.setSize(width, height * 2);
  }
  //---------------------------------------- Image Processing ------------------------------------//


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

  //---------------------------------------- Image Processing ------------------------------------//
  try {
    //background(0);
    if (cameraMode) {
      if (cam.available() == true) 
        cam.read();

      img = cam.get();
    }

    PImage img2 = img.copy();

    img2.loadPixels();
    img2.updatePixels();

    // Optimal for all
    int minH = 47;
    int maxH = 142;
    int minS = 68;
    int maxS = 255;
    int minB = 28;
    int maxB = 168;

    img2 = thresholdHSB(img2, minH, maxH, minS, maxS, minB, maxB);  // color thresholding
    img2 = convolute(img2);                                      // gaussian blur     
    PImage imgConnected = findConnectedComponents(img2, true);                 // blob detection
    img2 = scharr(imgConnected);                                        // edge detection
    PImage imgThresholded = threshold(img2, 100);                               // Suppression of pixels with low brightness
    PImage imgBlob;

    List<PVector> quad = new ArrayList<PVector>();
    int nBestLines = 1;
    List<PVector> hough = hough(imgThresholded, 8*nBestLines);


    //image(img, 0, 0);                        //draw original image
    //draw_lines(hough, img2.width, img2.height);          // Hough transform (+ draw lines on canvas)

    //PImage cropped = get(0, 0, img2.width, img2.height);
    //image(cropped, 0, 0);
    //image(imgConnected, img2.width*2, 0);
    //image(imgThresholded, img2.width, 0);


    //if (twoBlobsMode) {
    //  imgBlob =img.copy();
    //  imgBlob = thresholdHSB(imgBlob, 26, 30, minS, maxS, minB, maxB);  // color thresholding
    //  imgBlob = convolute(imgBlob);                                      // gaussian blur     
    //  imgBlob = findConnectedComponents(imgBlob, true);                 // blob detection
    //  image(imgBlob, imgBlob.width * 2, imgBlob.height);
    //  image(imgConnected, img2.width, img2.height);
    //  imgBlob = addImages(imgBlob, imgConnected, 10);
    //  image(imgBlob, 0, imgBlob.height);
    //  imgBlob = scharr(imgBlob);                                        // edge detection
    //  imgBlob = threshold(imgBlob, 10);        // Suppression of pixels with low brightness
    //  image(imgBlob, imgBlob.width*2, 0);
    //}

    QuadGraph q = new QuadGraph();
    do {
      quad = q.findBestQuad(hough, img2.width, img2.height, (int)((img2.height*0.9)*(img2.width*0.9)), (int)((img2.height*0.3)*(img2.width*0.3)), false);
      for (PVector point : quad) {
        point.z = 1;
      }
      rotVect = rot.get3DRotations(quad);

      rotationX = rotVect.x + PI;
      rotationZ = rotVect.y;

      hough = hough(img2, 8*nBestLines);
      ++nBestLines;
    } while (quad.isEmpty() && nBestLines < nBestLinesPaddingThreshold);

    //stroke(0);
    ////draw corner circles
    //for (int i = 0; i<quad.size(); ++i) {
    //  fill(color((i%4) *255, (i-1%4) *255, (i-2%4) *255, 100));      
    //  circle(quad.get(i).x, quad.get(i).y, 20);
    //}

    // Popup bubble that will give the different keys to use in order to navigate between pictures and modes
    if (help) {
      // First create a translucid rectangle to show that help mode is activated
      fill(200, 200, 200, 100);
      noStroke();
      rect(0, 0, width, height);
      // The second rectangle is the bubble where the information is written
      fill(200);
      stroke(0);
      rect(width/2 - 170, height/2 - 50, 340, 120, 15);
      fill(0);
      surface.setTitle(titles[6]);
      // Instructions
      text(" - Use arrows or 1->6 to navigate between pictures ", width/2 - 160, height/2 - 25);
      text(" - Press B to enable/disable two blobs mode  ", width/2 - 160, height/2 -5 );
      text(" - Press C to enable/disable camera mode  ", width/2 - 160, height/2 + 15);
      text(" - Press H to enable/disable help menu  ", width/2 - 160, height/2 + 35);
      text(" - Press Q to quit  ", width/2 - 160, height/2 + 55);
    }
  } 
  catch (Exception e ) {
    e.printStackTrace();
    exit();//remove
  }
  //---------------------------------------- Image Processing ------------------------------------//
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
      surface.rect(i*5*squareDim, (topViewDim)/2 +7.5*j*k, 5*squareDim, 7.5);
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

  //gameSurface.rotateX(PI/2);

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

  switch(key) {
  case 'b':
    if (cameraMode) break;
    twoBlobsMode = !twoBlobsMode;
    if (twoBlobsMode) {
      surface.setTitle(titles[7]);

      surface.setSize(width, images.get(5).height * 2);
    } else {
      surface.setSize(width, height / 2);
    }
    break;
  case 'c': // Enable camera mode
    cameraMode = !cameraMode;
    if (cameraMode) {
      cam.start();
      surface.setTitle(titles[8]);
      surface.setSize(320*3, 240);
    } else {
      cam.stop();
    }
    break;
  case 'h': // Enable help mode
    help = !help;
    if (!help) {
      if (cameraMode)
        surface.setTitle(titles[8]);
      if (twoBlobsMode) 
        surface.setTitle(titles[7]);
    }

    break;
  case 'q':
    println("Exiting normally");
    exit();
    break;
  default :
    break;
  }
  if (cameraMode) return;
  if (twoBlobsMode) {
    imageIndex = 5;
    img = images.get(imageIndex);
    surface.setSize(img.width*3, height);
    return;
  }
  if (key == CODED) {
    if (keyCode == LEFT && imageIndex > 0) {
      imageIndex--;
    } else if (keyCode == RIGHT && imageIndex < 5) {
      imageIndex++;
    }
  }

  // Switch images with differents number keys pressed
  switch (key) {
  case '1' : 
    imageIndex = 0;
    break;
  case '2' :
    imageIndex = 1;
    break;
  case '3' :
    imageIndex = 2;
    break;
  case '4' :
    imageIndex = 3;
    break;
  case '5' :
    imageIndex = 4;
    break;
  case '6' :
    imageIndex = 5;
    break;
  default : 
    break;
  }

  // After determining the current mode and current image, fetch the image and resize it and the window accordingly
  img = images.get(imageIndex);
  surface.setTitle(titles[imageIndex]);
  //double newWidth = img.width * 3.0;
  //double newImgHeight = img.height;
  //while (newWidth > Width) {    
  //  newWidth *= widthFactor;
  //  newImgHeight *= heightFactor;
  //}
  //surface.setSize(img.width * 3, img.height);
  //img.resize((int) (newWidth/3), (int) newImgHeight);
}

void keyReleased() {
  if (keyCode == SHIFT) 
    shiftMode = false;
}
