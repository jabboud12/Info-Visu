import processing.video.*;
import java.util.Arrays;

PImage img, board1, board2, board3, board4, nao, nao_blob, imgCheck;
final int Width = 1500;
final int Height = 500;
List<PImage> images;
int imageIndex;

boolean twoBlobsMode = false;
boolean help = false;
boolean cameraMode = false; //fixme correct resizing on camera mode
final int nBestLinesPaddingThreshold = 0; //fixme set to 2 when using camera


//---------------------------------------------------------------------For Windows-----------------------------------------------------------------------------------------------------------//
Capture cam;
//---------------------------------------------------------------------For Windows-----------------------------------------------------------------------------------------------------------//

void settings() {
  size(Width, Height);
  //fullScreen();
  if (surface != null)
    surface.setResizable(true);
}



void setup() {

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
  surface.setTitle("Board 1 -- Corner detection || Edge detection || HSB thresholding");
  img = images.get(imageIndex);
  surface.setSize(img.width * 3, img.height);

  //noLoop();
  if (twoBlobsMode) {
    surface.setSize(width, height * 2);
  }
}



void draw() {

  try {
    background(0);
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


    image(img, 0, 0);                        //draw original image
    draw_lines(hough, img2.width, img2.height);          // Hough transform (+ draw lines on canvas)

    PImage cropped = get(0, 0, img2.width, img2.height);
    image(cropped, 0, 0);
    image(imgConnected, img2.width*2, 0);
    image(imgThresholded, img2.width, 0);


    if (twoBlobsMode) {
      imgBlob =img.copy();
      imgBlob = thresholdHSB(imgBlob, 26, 30, minS, maxS, minB, maxB);  // color thresholding
      imgBlob = convolute(imgBlob);                                      // gaussian blur     
      imgBlob = findConnectedComponents(imgBlob, true);                 // blob detection
      image(imgBlob, imgBlob.width * 2, imgBlob.height);
      image(imgConnected, img2.width, img2.height);
      imgBlob = addImages(imgBlob, imgConnected, 10);
      image(imgBlob, 0, imgBlob.height);
      imgBlob = scharr(imgBlob);                                        // edge detection
      imgBlob = threshold(imgBlob, 10);        // Suppression of pixels with low brightness
      image(imgBlob, imgBlob.width*2, 0);
    }

      QuadGraph q = new QuadGraph();
    do {
      quad = q.findBestQuad(hough, img2.width, img2.height, (int)((img2.height*0.9)*(img2.width*0.9)), (int)((img2.height*0.3)*(img2.width*0.3)), false);
     
      hough = hough(img2, 8*nBestLines);
      ++nBestLines;
    } while (quad.isEmpty() && nBestLines <nBestLinesPaddingThreshold);

    stroke(0);
    //draw corner circles
    for (int i = 0; i<quad.size(); ++i) {
      fill(color((i%4) *255, (i-1%4) *255, (i-2%4) *255, 100));      
      circle(quad.get(i).x, quad.get(i).y, 20);
    }


    if (help) {
      fill(200, 200, 200, 100);
      noStroke();
      rect(0, 0, width, height);
      fill(200);
      stroke(0);
      rect(width/2 - 170, height/2 - 60, 340, 120, 15);
      fill(0);
      surface.setTitle("Help");
      text(" - Use arrows or 1->6 to navigate between pictures ", width/2 - 160, height/2 - 25);
      text(" - Press B to enable/disable two blobs mode  ", width/2 - 160, height/2 -5 );
      text(" - Press C to enable/disable camera mode  ", width/2 - 160, height/2 + 15);
      text(" - Press H to enable/disable help menu  ", width/2 - 160, height/2 + 35);
      //text(" - Press Q to quit  ", width/2 - 160, height/2 + 55);

    }
  } 
  catch (Exception e ) {
    e.printStackTrace();
    exit();//remove
  }
}



void keyPressed() {
  switch(key) {
  case 'B':
  case 'b':
    if (cameraMode) break;
    twoBlobsMode = !twoBlobsMode;
    if (twoBlobsMode) {
      surface.setTitle("Two Blobs Mode ON -- Corner detection || Edge detection 1st Blob ||  Edge detection 2nd Blob ||" +
        " || HSB thresholding both blobs || HSB thresholding 1st blob || HSB thresholding 2nd blob");
      surface.setSize(width, images.get(5).height * 2);
    } else {
      surface.setTitle("Nao Blob -- Corner detection || Edge detection || HSB thresholding");

      surface.setSize(width, height / 2);
    }
    break;
  case 'C':
  case 'c':
    cameraMode = !cameraMode;
    if (cameraMode) {
      cam.start();
      surface.setTitle("Camera Mode -- Corner detection || Edge detection || HSB thresholding");
      surface.setSize(320*3, 240);
      //return; ??
    } else {
      cam.stop();
      img = images.get(0);
    surface.setTitle("Board 1 -- Corner detection || Edge detection || HSB thresholding");

    }
    break;
  case 'H':
  case 'h':
    help = !help;
    break;
  case 'Q':
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
  switch (key) {
  case '1' : 
    imageIndex = 0;
    surface.setTitle("Board 1 -- Corner detection || Edge detection || HSB thresholding");
    break;
  case '2' : 
    surface.setTitle("Board 2 -- Corner detection || Edge detection || HSB thresholding");
    imageIndex = 1;
    break;
  case '3' : 
    surface.setTitle("Board 3 -- Corner detection || Edge detection || HSB thresholding");
    imageIndex = 2;
    break;
  case '4' : 
    surface.setTitle("Board 4 -- Corner detection || Edge detection || HSB thresholding");
    imageIndex = 3;
    break;
  case '5' : 
    surface.setTitle("Nao -- Corner detection || Edge detection || HSB thresholding");
    imageIndex = 4;
    break;
  case '6' : 
    surface.setTitle("Nao Blob -- Corner detection || Edge detection || HSB thresholding");
    imageIndex = 5;
    break;
  default : 
    break;
  }

  img = images.get(imageIndex);
  double newWidth = img.width * 3.0;
  double newImgHeight = img.height;
  while (newWidth > Width) {    
    newWidth *= 0.95;
    newImgHeight *= 0.95;
  }
  surface.setSize(img.width * 3, img.height);
    img.resize((int) (newWidth/3), (int) newImgHeight);

}
