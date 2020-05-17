import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

PImage img, imgCheck;
void settings() {
  size(700, 500);
}

void setup() {
  img = loadImage("hough_test.bmp");


  noLoop(); // no interactive behaviour: draw() will be called only once.
}

void draw() {
  PImage img2 = img.copy();//make a deep copy
  img2.loadPixels();
  img2.updatePixels();
  image(img2 , 0 , 0);
  

  try {
    draw_lines(hough(img2) , img2);
  }catch (  Exception e){
    e.printStackTrace();
  }
  
}





List<PVector> hough(PImage edgeImg) {

    float discretizationStepsPhi = 0.01f; 
    float discretizationStepsR = 1.5f; 
    int minVotes=1100; 
    
    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi +1);
    //The max radius is the image diagonal, but it can be also negative
    int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +
    edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);
    // our accumulator
    int[] accumulator = new int[phiDim * rDim];
    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
        for (int x = 0; x < edgeImg.width; x++) {
            // Are we on an edge?
            if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
                // ...determine here all the lines (r, phi) passing through
                // pixel (x,y), convert (r,phi) to coordinates in the
                // accumulator, and increment accordingly the accumulator.
                // Be careful: r may be negative, so you may want to center onto
                // the accumulator: r += rDim / 2
              
                for(int phiStep = 0 ; phiStep < phiDim ; phiStep += 1) {

                    float phi = phiStep * discretizationStepsPhi;

                    float r = ( x * (float)Math.cos(phi) + y * (float)Math.sin(phi) ) ;
                    r *= discretizationStepsR;
                    r += rDim / 2; // center r

                    accumulator[(int)(phi * rDim + r)] += 1.;
                }
                    
            }
        }
    }


    ArrayList<PVector> lines=new ArrayList<PVector>();
    for (int idx = 0; idx < accumulator.length; idx++) {
        if (accumulator[idx] > minVotes) {
            // first, compute back the (r, phi) polar coordinates:
            int accPhi = (int) (idx / (rDim));
            int accR = idx - (accPhi) * (rDim);
            float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
            float phi = accPhi * discretizationStepsPhi;
            lines.add(new PVector(r,phi));
        }
    }


    return lines;
}




void draw_lines(List<PVector> lines , PImage edgeImg){
  for (int idx = 0; idx < lines.size(); idx++) {
    PVector line=lines.get(idx);
    float r = line.x;
    float phi = line.y;
    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)
    // compute the intersection of this line with the 4 borders of
    // the image
    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = edgeImg.width;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
    // Finally, plot the lines
    stroke(204,102,0);
    if (y0 > 0) {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    }
    else {
      if (x1 > 0) {
        if (y2 > 0)
          line(x1, y1, x2, y2);
        else
          line(x1, y1, x3, y3);
      }
      else
        line(x2, y2, x3, y3);
    }
  }

}
