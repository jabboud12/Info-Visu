import processing.video.*;


PImage img, imgCheck;
HScrollbar thresholdBar, thresholdBar1, thresholdBar2, thresholdBar3, thresholdBar4, thresholdBar5;
//Capture cam;
///**Mac workaround**/Movie cam;



void settings() {
  size(640 * 2, 480 * 2);
}



void setup() {
   ///**Mac workaround**/cam = new Movie(this, "a.mov");
   ///**Mac workaround**/cam.loop();

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
  
  thresholdBar = new HScrollbar(0, 690, 640 * 2 , 20, 100);
  thresholdBar1 = new HScrollbar(0, 715, 640 * 2 , 20, 200);
  thresholdBar2 = new HScrollbar(0, 740, 640 * 2 , 20, 100);
  thresholdBar3 = new HScrollbar(0, 765, 640 * 2 , 20, 255);
  thresholdBar4 = new HScrollbar(0, 790, 640 * 2 , 20, 45);
  thresholdBar5 = new HScrollbar(0, 815, 640 * 2 , 20, 100);
  
  img = loadImage("board1.jpg");
  img.resize(640,480);

   //noLoop();
}

void draw() {

  try{

    //if (cam.available() == true) 
    //  cam.read();
    
    //img = cam.get();
    

    PImage img2 = img.copy();
    
    img2.loadPixels();
    img2.updatePixels();

    
    int minH = (int)(thresholdBar.getPos()*255);
    int maxH = (int)(thresholdBar1.getPos()*255);
    int minS = (int)(thresholdBar2.getPos()*255);
    int maxS = (int)(thresholdBar3.getPos()*255);
    int minB = (int)(thresholdBar4.getPos()*255);
    int maxB = (int)(thresholdBar5.getPos()*255);
    


    
    //fixme: choose optimal parameters
    //img2 = thresholdHSB(img2, 100, 200, 100, 255, 45, 100);     // color thresholding
    img2 = thresholdHSB(img2,minH, maxH, minS, maxS, minB, maxB);  // color thresholding
    image(img2, 0, img2.height);
    
    img2= convolute(img2);                                      // gaussian blur

    img2 = findConnectedComponents(img2, true);                 // blob detection
    image(img2, img2.width, img2.height);
    
    img2 = scharr(img2);                                        // edge detection
    img2 = threshold(img2, 100 );                               // Suppression of pixels with low brightness


    image(img2, 0, 0);
    image(img  , img2.width , 0);
    //draw_lines( hough(img2) , img2.width );                     // Hough transform (+ draw lines on canvas)
    //draw_lines(findBestQuad(hough(img2), 480,640, 100, 0, true), img2.width);
    List<PVector> quad = findBestQuad(hough(img2), 800, 600, 100000, 0, false); 
    stroke(255,0,0);
    if (!quad.isEmpty()){
    for (int i = 0; i< quad.size()-1; ++i){
    line(quad.get(i).x, quad.get(i).y, quad.get(i+1).x, quad.get(i+1).y);
    println("x = " + quad.get(i).x + " y = " + quad.get(i).y);
    }
    line(quad.get(0).x, quad.get(0).y, quad.get(quad.size()-1).x, quad.get(quad.size()-1).y);
    }


    
    thresholdBar.display();
    thresholdBar.update();
    thresholdBar1.display();
    thresholdBar1.update();
    thresholdBar2.display();
    thresholdBar2.update();
    thresholdBar3.display();
    thresholdBar3.update();
    thresholdBar4.display();
    thresholdBar4.update();
    thresholdBar5.display();
    thresholdBar5.update();
    fill(255,0,0);
    text("minH = " + minH, 20,680);
    text("maxH = " + maxH, 120,680);
    text("minS = " + minS, 220,680);
    text("maxS = " + maxS, 320,680);
    text("minB = " + minB, 420,680);
    text("maxB = " + maxB, 520,680);

    

  } catch (Exception e ){
    e.printStackTrace();
  }

}
