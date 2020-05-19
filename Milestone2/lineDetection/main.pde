import processing.video.*;
import java.util.Arrays;

PImage img, board1, board2, board3, board4, nao, nao_blob, imgCheck;
final int Width = 1500;
final int Height = 500;
List<PImage> images;
int imageIndex;
//HScrollbar thresholdBar, thresholdBar1, thresholdBar2, thresholdBar3, thresholdBar4, thresholdBar5;

final boolean twoBlobsMode = false;
final int nBestLinesPaddingThreshold = 7;


//---------------------------------------------------------------------For Windows-----------------------------------------------------------------------------------------------------------//
//Capture cam;
//---------------------------------------------------------------------For Windows-----------------------------------------------------------------------------------------------------------//

//---------------------------------------------------------------------For Mac---------------------------------------------------------------------------------------------------------------//
///**Mac workaround**/Movie cam;

//---------------------------------------------------------------------For Mac---------------------------------------------------------------------------------------------------------------//



void settings() {
  size(Width, Height);
  //fullScreen();
  if (surface != null)
    surface.setResizable(true);
}



void setup() {
  //--------------------------------------------------------------choose your fighter :-)------------------------------------------------------------------------------------------------------//
  //---------------------------------------------------------------------For Mac---------------------------------------------------------------------------------------------------------------//
  ///**Mac workaround**/    cam = new Movie(this, "a.mov");
  ///**Mac workaround**/    cam.loop();

  //---------------------------------------------------------------------For Mac---------------------------------------------------------------------------------------------------------------//

  //---------------------------------------------------------------------For Windows-----------------------------------------------------------------------------------------------------------//

  //  String[] cameras = Capture.list();

  //  if (cameras.length == 0) {
  //    println("There are no cameras available for capture.");
  //    exit();
  //  } else {
  //    println("Available cameras:");
  //    for (int i = 0; i < cameras.length; i++) 
  //      println(cameras[i]);

  //    cam = new Capture(this, 640, 480, cameras[0]);
  //    cam.start();

  //}

  //---------------------------------------------------------------------For Windows-----------------------------------------------------------------------------------------------------------//

  board1 = loadImage("board1.jpg");
  board2 = loadImage("board2.jpg");
  board3 = loadImage("board3.jpg");
  board4 = loadImage("board4.jpg");
  nao = loadImage("nao.jpg");
  nao_blob = loadImage("nao_blob.jpg");

  PImage [] imagess = {board1, board2, board3, board4, nao, nao_blob};  
  images = Arrays.asList(imagess);

  for (PImage img : images) {
    while (img.width> 700 || img.height>700)
      img.resize(img.width/2, img.height/2);
  }
  imageIndex = 0;
  img = images.get(imageIndex);
  surface.setSize(img.width * 3,img.height);

  //noLoop();
}
void draw() {

  try {
    background(0);

    //if (cam.available() == true) 
    //  cam.read();

    //img = cam.get();
    ///**Mac workaround**/    img.resize(640, 480);

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

    if (twoBlobsMode) {
      PImage img1 = img.copy();
      img1 = thresholdHSB(img1, 20, 40, minS, maxS, minB, maxB);  // color thresholding
      img1 = convolute(img1);                                      // gaussian blur     
      img1 = findConnectedComponents(img1, true);                 // blob detection
      //image(img1, img.width, img.height);
      img = scharr(img);                                        // edge detection
      img = threshold(img, 100 );                               // Suppression of pixels with low brightness
      img1 = addImages(img2, img1, 10 );
      image(img1, img.width, 0);
    }

    List<PVector> quad = new ArrayList<PVector>();
    int nBestLines = 1;
    List<PVector> hough = hough(imgThresholded, 8*nBestLines);

    image(img, 0, 0);                        //draw original image
    draw_lines(hough, img2.width, img2.height);          // Hough transform (+ draw lines on canvas)
    PImage cropped = get(0, 0, img2.width, img2.height);
    background(0);
    image(cropped, 0, 0);
    image(imgConnected, img2.width*2, 0);
    image(imgThresholded, img2.width, 0);



    do {
      quad = findBestQuad(hough, img2.width, img2.height, (int)((img2.height*0.9)*(img2.width*0.9)), (int)((img2.height*0.3)*(img2.width*0.3)), false);
      hough = hough(img2, 8*nBestLines);
      ++nBestLines;
    } while (quad.isEmpty() && nBestLines <nBestLinesPaddingThreshold);

    stroke(0);
    //draw corner circles
    for (int i = 0; i<quad.size(); ++i) {
      fill(color((i%4) *255, (i-1%4) *255, (i-2%4) *255, 100));      
      circle(quad.get(i).x, quad.get(i).y, 20);
    }
  } 
  catch (Exception e ) {
    e.printStackTrace();
  }
}


// Used to iterate over the 6 images  
void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT && imageIndex > 0) {
      imageIndex--;
    } else if (keyCode == RIGHT && imageIndex < 5) {
      imageIndex++;
    }
  }
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

  img = images.get(imageIndex);
  double newWidth = img.width * 3.0;
  double newImgHeight = img.height;
  while(newWidth > Width) {    
    newWidth *= 0.95;
    newImgHeight *= 0.95;
  }
  surface.setSize(img.width * 3,img.height);
  img.resize((int) (newWidth/3), (int) newImgHeight);
}
