import processing.video.*; //<>// //<>//
import gab.opencv.*;
import java.util.Arrays;

PGraphics gameSurface;
PGraphics background;
PGraphics topView;
PGraphics scoreboard;
PGraphics barChart;
HScrollbar hs;
ArrayList<Integer> points = new ArrayList<Integer>();

PImage pattern; 

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

Movie mov;

PImage img, board1, board2, board3, board4, nao, nao_blob, imgCheck;
final int Width = 1500;
final int Height = 500;
List<PImage> images;
int imageIndex;

boolean twoBlobsMode = false; // Enable and disable blob detection mode for an item on the board
boolean help = true; // Enable and disable help mode
boolean cameraMode = false; //fixme correct resizing on camera mode

// Maium number of lines allowed for the edges of the board
final int nBestLinesPaddingThreshold = 2; 

// The structure of titles is: Original image -- Detection mode || Edge detection ... (each || ... || is an image displayed by order)
String [] titles = { "Board 1 -- Corner detection || Edge detection || HSB thresholding", 
  "Board 2 -- Corner detection || Edge detection || HSB thresholding", 
  "Board 3 -- Corner detection || Edge detection || HSB thresholding", 
  "Board 4 -- Corner detection || Edge detection || HSB thresholding", 
  "Nao -- Corner detection || Edge detection || HSB thresholding", 
  "Nao Blob -- Corner detection || Edge detection || HSB thresholding", 
  "Help", 
  "Two Blobs Mode ON -- Corner detection || Edge detection 1st Blob ||  Edge detection 2nd Blob ||" +
  " || HSB thresholding both blobs || HSB thresholding 1st blob || HSB thresholding 2nd blob", 
  "Camera Mode -- Corner detection || Edge detection || HSB thresholding"};

// If board corners are not detected, try to lower these two doubles below by 0.05
double widthFactor = 0.9;
double heightFactor = 0.9;

PVector vectRot = new PVector(0, 0, 0);
List<PVector> quad = new ArrayList<PVector>();
List<PVector> corners = new ArrayList<PVector>();

List<PVector> hough;

Capture cam;

OpenCV opencv;

TwoDThreeD rot;

//ImageProcessing improc;

KalmanFilter2D corner1;
KalmanFilter2D corner2;
KalmanFilter2D corner3;
KalmanFilter2D corner4;


// Parameters for HSB thresholding
int minH = 47;   //47
int maxH = 142; //142
int minS = 30;  //68
int maxS = 255; //255
int minB = 28;   //28
int maxB = 168; //168

// pre-compute the sin and cos values
float[] tabSin; 
float[] tabCos;
float ang;
float inverseR;

HScrollbar hm;
HScrollbar bm;
HScrollbar sm;
HScrollbar h;
HScrollbar b;
HScrollbar s;

//class ImageProcessing extends PApplet {
void settings() {
  size(960, 540);
}

void setup() {
  // pre-compute the sin and cos values
  tabSin = new float[phiDim]; 
  tabCos = new float[phiDim];
  ang = 0;
  inverseR = 1.f / discretizationStepsR;
  for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
    // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop 
    tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
    tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
  }

  opencv = new OpenCV(this, 100, 100);
  rot = new TwoDThreeD(width, height, 0);

  corner1 = new KalmanFilter2D(1, 2);
  corner2 = new KalmanFilter2D(1, 2);
  corner3 = new KalmanFilter2D(1, 2);
  corner4 = new KalmanFilter2D(1, 2);

  mov = new Movie(this, "testvideo.avi");
  mov.loop();
  mov.volume(0);
  //mov.speed(0.1);

  b = new HScrollbar(0, height - 100, width, 10, minB/255 * width);
  bm = new HScrollbar(0, height - 100, width, 10, minB);
  h = new HScrollbar(0, height - 100, width, 10, minB);
  hm = new HScrollbar(0, height - 100, width, 10, minB);
  s = new HScrollbar(0, height - 100, width, 10, minB);
  sm = new HScrollbar(0, height - 100, width, 10, minB);
}

void draw() {
  background(200);
  try {
    if (mov.available() == true) {
      mov.read();
    }
    img = mov.get();
    img.resize(320, 180);
    image(img, 0, 0);

    b.update();
    b.display();
    text("minB = " + (int) (b.getPos() * 255), 50, height -150);
    //if (frameCount % 50 == 0 || frameCount == 1) {

    img = thresholdHSB(img, minH, maxH, minS, maxS, (int) (b.getPos() * 255), maxB);  // color thresholding
    img = convolute(img);       // gaussian blur   
    image(img, 0, img.height);

    img = findConnectedComponents(img, true);                // blob detection
    image(img, img.width, 0);
    img = scharr(img);                                        // edge detection
    image(img, img.width*2, 0);
    img = threshold(img, 100);                               // Suppression of pixels with low brightness


    int nBestLines = 1;
    //hough = hough(img, 1);

    QuadGraph q = new QuadGraph();
    do {
      hough = hough(img, 4*nBestLines);
      quad = q.findBestQuad(hough, img.width, img.height, (int)((img.height*0.9)*(img.width*0.9)), (int)((img.height*0.2)*(img.width*0.2)), false);
      corners = new ArrayList(quad);

      ++nBestLines;
    } while (quad.isEmpty() && nBestLines < nBestLinesPaddingThreshold);
    if (!quad.isEmpty()) {
      corners = new ArrayList(quad);
    }
    //} else if (corners.size() == 4) {
    //  corners.set(0, corner1.predict_and_correct(corners.get(0)));
    //  corners.set(1, corner2.predict_and_correct(corners.get(1)));
    //  corners.set(2, corner3.predict_and_correct(corners.get(2)));
    //  corners.set(3, corner4.predict_and_correct(corners.get(3)));
    //}

    //draw_lines(hough, img.width, img.height);          // Hough transform (+ draw lines on canvas)

    //stroke(0);
    ////draw corner circles
    //if (corners.size() != 0) {
    //  for (int i = 0; i<corners.size(); ++i) {
    //    fill(color((i%4) *255, (i-1%4) *255, (i-2%4) *255, 100));      
    //    circle(corners.get(i).x, corners.get(i).y, 20);
    //  }
    //  for (PVector corner : corners) {
    //    corner.z = 1;
    //  }
    //  vectRot = rot.get3DRotations(corners);
    //}
  } 
  catch (Exception e ) {
    e.printStackTrace();
    exit();//remove
  }
}


void draw_lines(List<PVector> lines, int imageWidth, int imageHeight) {
  int x0 = 0;
  int y1 = 0;
  int x2 = imageWidth;
  int y3 = imageWidth;
  for (int idx = 0; idx < lines.size(); idx++) {
    PVector line=lines.get(idx);
    float r = line.x;
    float phi = line.y;
    //println("r = " + r + "phi = " + phi);
    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)
    // compute the intersection of this line with the 4 borders of
    // the image

    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));

    //println("x0 = " + x0 + " y0 = " + y0);
    //println("x1 = " + x1 + " y1 = " + y1);
    //println("x2 = " + x2 + " y2 = " + y2);
    //println("x3 = " + x3 + " y3 = " + y3);

    // Finally, plot the lines
    stroke(204, 102, 0);
    if (y0 > 0) {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    } else {
      if (x1 > 0) {
        if (y2 > 0)
          line(x1, y1, x2, y2);
        else 
        line(x1, y1, x3, y3);
      } else
        line(x2, y2, x3, y3);
    }
  }
}
//}
