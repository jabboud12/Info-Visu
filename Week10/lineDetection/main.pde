import processing.video.*;



PImage img, imgCheck;
HScrollbar thresholdBar, thresholdBar1;
Capture cam;



void settings() {
  size(640 * 2, 480 * 2);
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

    cam = new Capture(this, 640, 480, cameras[0]);
    cam.start();
  } 
  
  thresholdBar = new HScrollbar(0, 20, 640 * 2 , 20);
  thresholdBar1 = new HScrollbar(0, 40, 640 * 2 , 20);

  // noLoop();
}

void draw() {

  try{

    if (cam.available() == true) 
      cam.read();
    
    img = cam.get();

    PImage img2 = img.copy();
    img2.loadPixels();
    img2.updatePixels();


    

    //fixme: choose optimal parameters
    img2 = thresholdHSB(img2, 100, 200, 100, 255, 45, 100);     // color thresholding
    image(img2, 0, img2.height);
    
    img2= convolute(img2);                                      // gaussian blur

    img2 = findConnectedComponents(img2, true);                 // blob detection
    image(img2, img2.width, img2.height);
    
    img2 = scharr(img2);                                        // edge detection
    img2 = threshold(img2, 100 );                               // Suppression of pixels with low brightness


    image(img2, 0, 0);
    image(img  , img2.width , 0);
    draw_lines( hough(img2) , img2.width );                     // Hough transform (+ draw lines on canvas)





    //thresholdBar.display();
    //thresholdBar.update();
    //thresholdBar1.display();
    //thresholdBar1.update();

  } catch (Exception e ){
    e.printStackTrace();
  }

}
