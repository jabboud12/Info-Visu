import processing.video.*;
import java.util.Arrays;

PImage img, board1, board2, board3, board4, nao, nao_blob, imgCheck;
List<PImage> images;
HScrollbar thresholdBar, thresholdBar1, thresholdBar2, thresholdBar3, thresholdBar4, thresholdBar5;
boolean twoBlobs = false;
//---------------------------------------------------------------------For Windows-----------------------------------------------------------------------------------------------------------//
//Capture cam;
//---------------------------------------------------------------------For Windows-----------------------------------------------------------------------------------------------------------//

//---------------------------------------------------------------------For Mac---------------------------------------------------------------------------------------------------------------//
/**Mac workaround**/Movie cam;
//---------------------------------------------------------------------For Mac---------------------------------------------------------------------------------------------------------------//



void settings() {
  size(640 * 2, 480 * 2);
}



void setup() {
  //--------------------------------------------------------------choose your fighter :-)------------------------------------------------------------------------------------------------------//
  //---------------------------------------------------------------------For Mac---------------------------------------------------------------------------------------------------------------//
  ///**Mac workaround**/cam = new Movie(this, "a.mov");
  ///**Mac workaround**/cam.loop();
  //---------------------------------------------------------------------For Mac---------------------------------------------------------------------------------------------------------------//

  //---------------------------------------------------------------------For Windows-----------------------------------------------------------------------------------------------------------//

  //String[] cameras = Capture.list();

  //if (cameras.length == 0) {
  //  println("There are no cameras available for capture.");
  //  exit();
  //} else {
  //  println("Available cameras:");
  //  for (int i = 0; i < cameras.length; i++) 
  //    println(cameras[i]);

  //  cam = new Capture(this, 640, 480, cameras[0]);
  //  cam.start();
  //} 
  //---------------------------------------------------------------------For Windows-----------------------------------------------------------------------------------------------------------//


  thresholdBar = new HScrollbar(0, 690, 640 * 2, 20, 47);
  thresholdBar1 = new HScrollbar(0, 715, 640 * 2, 20, 155);
  thresholdBar2 = new HScrollbar(0, 740, 640 * 2, 20, 100);
  thresholdBar3 = new HScrollbar(0, 765, 640 * 2, 20, 255);
  thresholdBar4 = new HScrollbar(0, 790, 640 * 2, 20, 28);
  thresholdBar5 = new HScrollbar(0, 815, 640 * 2, 20, 168);

  board1 = loadImage("board1.jpg");
  board2 = loadImage("board2.jpg");
  board3 = loadImage("board3.jpg");
  board4 = loadImage("board4.jpg");
  nao = loadImage("nao.jpg");
  nao_blob = loadImage("nao_blob.jpg");

  PImage [] imagess = {board1, board2, board3, board4, nao, nao_blob};  
  images = Arrays.asList(imagess);

  for (PImage img : images)
    img.resize(640, 480);

  img = images.get(0);

  //noLoop();
}
void draw() {

  try {

    //if (cam.available() == true) 
    //  cam.read();

    //img = cam.get();
    ///**Mac workaround**/img.resize(640,480);

    PImage img2 = img.copy();

    //PImage img2 = loadImage("board4.jpg");
    //img2.resize(640,480);
    img2.loadPixels();
    img2.updatePixels();


    //int minH = (int)(thresholdBar.getPos()*255);
    //int maxH = (int)(thresholdBar1.getPos()*255);
    //int minS = (int)(thresholdBar2.getPos()*255);
    //int maxS = (int)(thresholdBar3.getPos()*255);
    //int minB = (int)(thresholdBar4.getPos()*255);
    //int maxB = (int)(thresholdBar5.getPos()*255);

    // Optimal for all
    int minH = 47;
    int maxH = 155;
    int minS = 100;
    int maxS = 255;
    int minB = 28;
    int maxB = 168;
    
    img2 = thresholdHSB(img2, minH, maxH, minS, maxS, minB, maxB);  // color thresholding
    image(img2, 0 , img2.height);
    img2 = convolute(img2);                                      // gaussian blur     
    img2 = findConnectedComponents(img2, true);                 // blob detection
        image(img2, img2.width, img2.height);
    img2 = scharr(img2);                                        // edge detection
    //186
    img2 = threshold(img2, 100);                               // Suppression of pixels with low brightness
    image(img2, 0, 0);

    //if (twoBlobs) {
    //  PImage img1 = img.copy();
    //  img1 = thresholdHSB(img1, 20, 40, minS, maxS, minB, maxB);  // color thresholding
    //  img1 = convolute(img1);                                      // gaussian blur     
    //  img1 = findConnectedComponents(img1, true);                 // blob detection
    //  image(img1, img.width, img.height);
    //  img = scharr(img);                                        // edge detection
    //  //img = threshold(img, 100 );                               // Suppression of pixels with low brightness
    //  img1 = addImages(img2, img1, 10 );
    //  image(img1, img.width, 0);
    //}
    List<PVector> hough = hough(img2);
    image(img, img2.width, 0);

    pushMatrix();
    translate(img2.width, 0);
    draw_lines(hough, img2.width );          // Hough transform (+ draw lines on canvas)

    List<PVector> quad = findBestQuad(hough, img2.width, img2.height, img.height*img.width, 10000, true); 
    stroke(255, 0, 0);
    strokeWeight(10);
    if (!quad.isEmpty()) {
      println("printing quad");
      for (int i = 0; i< quad.size()-1; ++i) {
        line(quad.get(i).x, quad.get(i).y, quad.get(i+1).x, quad.get(i+1).y);
        //println("x = " + quad.get(i).x + " y = " + quad.get(i).y);
      }
      line(quad.get(0).x, quad.get(0).y, quad.get(quad.size()-1).x, quad.get(quad.size()-1).y);
    }
    strokeWeight(1);
    popMatrix();


    //thresholdBar.display();
    //thresholdBar.update();
    //thresholdBar1.display();
    //thresholdBar1.update();
    //thresholdBar2.display();
    //thresholdBar2.update();
    //thresholdBar3.display();
    //thresholdBar3.update();
    //thresholdBar4.display();
    //thresholdBar4.update();
    //thresholdBar5.display();
    //thresholdBar5.update();
    //fill(255,0,0);
    //text("minH = " + minH, 20,680);
    //text("maxH = " + maxH, 120,680);
    //text("minS = " + minS, 220,680);
    //text("maxS = " + maxS, 320,680);
    //text("minB = " + minB, 420,680);
    //text("maxB = " + maxB, 520,680);
  } 
  catch (Exception e ) {
    e.printStackTrace();
  }
}

void keyPressed() {
  switch (key) {
  case '1' : 
    img = images.get(0);
    break;
  case '2' : 
    img = images.get(1);
    break;
  case '3' : 
    img = images.get(2);
    break;
  case '4' : 
    img = images.get(3);
    break;
  case '5' : 
    img = images.get(4);
    break;
  case '6' : 
    img = images.get(5);
    break;
  default : 
    break;
  }
}
