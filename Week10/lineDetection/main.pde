
PImage img, imgCheck;
HScrollbar thresholdBar, thresholdBar1;

void settings() {
  size(800, 600);
}



void setup() {
  img = loadImage("data/board1.jpg");
  //img = loadImage("BlobDetection_Test.png");
  //imgCheck = loadImage("board1Scharr_new.bmp");
  
  thresholdBar = new HScrollbar(0, 580, 800, 20);
  thresholdBar1 = new HScrollbar(0, 560, 800, 20);

  noLoop(); // no interactive behaviour: draw() will be called only once.
}

void draw() {

  try{

    PImage img2 = img.copy();//make a deep copy
    img2.loadPixels();// load pixels
    img2.updatePixels();//update pixels

    //thresholdBar.display();
    //thresholdBar.update();
    //thresholdBar1.display();
    //thresholdBar1.update();

    //fixme: choose optimal parameters
    img2 = thresholdHSB(img2, 100, 200, 100, 255, 45, 100);     // color thresholding
    img2= convolute(img2);                                      // gaussian blur

    img2 = findConnectedComponents(img2, true);

    img2 = scharr(img2);                // edge detection
    img2 = threshold(img2, 100 );       // thresholding to keep only pixel with values>I, ex. I=100


    image(img2, 0, 0);
    draw_lines( hough(img2) , img2.width );

  } catch (Exception e ){
    e.printStackTrace();
  }

}
