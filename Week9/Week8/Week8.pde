
PImage img, imgCheck;
HScrollbar thresholdBar, thresholdBar1;

void settings() {
  size(800, 600);
}

void setup() {
  img = loadImage("board1.jpg");
    //img = loadImage("BlobDetection_Test.png");

  //imgCheck = loadImage("board1Scharr_new.bmp");
  thresholdBar = new HScrollbar(0, 580, 800, 20);
  thresholdBar1 = new HScrollbar(0, 560, 800, 20);


  noLoop(); // no interactive behaviour: draw() will be called only once.
}

void draw() {


  //image(img, 0, 0);//show image
  PImage img2 = img.copy();//make a deep copy
  img2.loadPixels();// load pixels
  //for (int x = 0; x < img2.width; x++)
  //  for (int y = 0; y < img2.height; y++)
  //    if (y%2==0)
  //      img2.pixels[y*img2.width+x] = color(0, 255, 0);

  img2.updatePixels();//update pixels

  //thresholdBar.display();
  //thresholdBar.update();
  //thresholdBar1.display();
  //thresholdBar1.update();

  //fixme: choose optimal parameters
  img2 = thresholdHSB(img2, 100, 200, 100, 255, 45, 100);     // color thresholding
  img2= convolute(img2);    // gaussian blur

  img2 = findConnectedComponents(img2, true);

  img2 = scharr(img2);     // edge detection
  img2 = threshold(img2, 100 ); // thresholding to keep only pixel with values>I, ex. I=100
  //image(img2, img.width, 0);
    image(img2, 0, 0);




  //println((int) (thresholdBar.getPos()*255)); // getPos() returns a value between 0 and 1
  //println(imagesEqual(img2, imgCheck));
}





PImage toHueMap(PImage img, float threshold1, float threshold2) {
  PImage result = createImage(img.width, img.height, HSB);
  result = img.copy();


  for (int i = 0; i < img.width * img.height; i++) {
    if (!(hue(img.pixels[i]) >= threshold1 && hue(img.pixels[i]) <= threshold2)) {
      result.pixels[i] = 0;
    } else{
      result.pixels[i] = color(255);
    }
  }
  return result;
}

PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
  PImage result = createImage(img.width, img.height, HSB);
  result = img.copy();



  for (int i = 0; i < img.width * img.height; i++) {
    if (!(hue(img.pixels[i]) >= minH && hue(img.pixels[i]) <= maxH && saturation(img.pixels[i]) >= minS && saturation(img.pixels[i]) <= maxS 
      && brightness(img.pixels[i]) >= minB && brightness(img.pixels[i]) <= maxB)) {
      result.pixels[i]=0;
    } else {
      result.pixels[i] = color(255);
    }
  }

  return result;
}


PImage threshold(PImage img, int threshold) {
  // create a new, initially transparent, 'result' image
  PImage result = createImage(img.width, img.height, RGB);

  for (int i = 0; i < img.width * img.height; i++) {
    // do something with the pixel img.pixels[i]
    if ((brightness(img.pixels[i])> threshold)) {
      result.pixels[i] = img.pixels[i];
    } else {
      result.pixels[i] = 0;
    }
  }
  return result;
}

boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height)
    return false;
  for (int i = 0; i < img1.width*img1.height; i++)
    //assuming that all the three channels have the same value
    if (red(img1.pixels[i]) != red(img2.pixels[i]))
      return false;
  return true;
}

PImage convolute(PImage img) {
  float[][] kernel1 = { 
    { 0, 0, 0 }, 
    { 0, 2, 0 }, 
    { 0, 0, 0 }};

  float[][] kernel2 = { 
    { 0, 1, 0 }, 
    { 1, 0, 1 }, 
    { 0, 1, 0 }};

  float[][] gaussianKernel = { 
    { 9, 12, 9 }, 
    { 12, 15, 12 }, 
    { 9, 12, 9 }};

  float normFactor = 99.f;
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
  // kernel size N = 3
  for (int x = 1; x<img.width-1; ++x) {
    for (int y = 1; y<img.height-1; ++y) {
      result.pixels[y * img.width + x] = 0;
      for (int i=-1; i<2; ++i) {
        for (int j=-1; j<2; ++j) {
          result.pixels[y * img.width + x] += brightness(img.pixels[(y+j) * img.width + x + i]) * gaussianKernel[j+1][i+1];
        }
      }
      result.pixels[y * img.width + x] /= normFactor;
      result.pixels[y * img.width + x] = color((int)(result.pixels[y * img.width + x]));
    }
  }
  result.updatePixels();
  return result;
}

PImage scharr(PImage img) {
  float[][] vKernel = {
    { 3, 0, -3 }, 
    { 10, 0, -10 }, 
    { 3, 0, -3 } };

  float[][] hKernel = {
    { 3, 10, 3 }, 
    { 0, 0, 0 }, 
    { -3, -10, -3 } };

  PImage result = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }
  float max=0;
  float[] buffer = new float[img.width * img.height];
  // *************************************
  // Implement here the double convolution
  // *************************************
  float normFactor = 1.f;
  for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges
    for (int x = 1; x < img.width - 1; x++) { // Skip left and right
      int sum_h = 0;
      int sum_v = 0;
      for (int i=-1; i<2; ++i) {
        for (int j=-1; j<2; ++j) {
          sum_h += brightness(img.pixels[(y+j) * img.width + x + i]) * hKernel[j+1][i+1];
          sum_v += brightness(img.pixels[(y+j) * img.width + x + i]) * vKernel[j+1][i+1];
        }
      }
      result.pixels[y * img.width + x] /= normFactor;
      result.pixels[y * img.width + x] = color((int)(result.pixels[y * img.width + x]));
      float  sum=sqrt(pow(sum_h, 2) + pow(sum_v, 2));
      if (sum> max )
        max = sum;
      buffer[y * img.width + x] = sum;
    }
  }

  for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges
    for (int x = 1; x < img.width - 1; x++) { // Skip left and right
      int val=(int) ((buffer[y * img.width + x] / max)*255);
      result.pixels[y * img.width + x]=color(val);
    }
  }
  return result;
}
