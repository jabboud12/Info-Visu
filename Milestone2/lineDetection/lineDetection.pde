import processing.video.*;

import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.Collections;



List<PVector> hough(PImage edgeImg) throws Exception {

    float discretizationStepsPhi = 0.02f; 
    float discretizationStepsR = 2.5f; 
    //int minVotes=500;
    int minVotes = 200;
    // define region size
    int regionSize = 10;
    
    
    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi +1);
    //The max radius is the image diagonal, but it can be also negative
    int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +
    edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);
    // our accumulator
    int[] accumulator = new int[phiDim * rDim];
    
    
    // pre-compute the sin and cos values
    float[] tabSin = new float[phiDim]; 
    float[] tabCos = new float[phiDim];
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop 
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }
    
    
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

                    double phi = phiStep * discretizationStepsPhi ;
                    if (phi < 0 || phi > Math.PI) throw new Exception("phi : "+phi+" not part of [0,PI]");
                    
                    //double r = x * Math.cos(phi) + y * Math.sin(phi) ;
                    //r *= 1./discretizationStepsR;
                    double r = x * tabCos[phiStep] + y * tabSin[phiStep] ;
                    r += rDim / 2.; // center r
                    if(r >= rDim || r < 0 ) throw new Exception("r : "+r+" not part of [0,"+rDim+"]");

                    accumulator[(int)(phiStep * rDim + r)] += 1.;
                }
                    
            }
        }
    }


    // ------- DEBUG --> DISPLAY ACCUMULATOR
    
      //PImage houghImg = createImage(rDim, phiDim, ALPHA);
      //for (int i = 0; i < accumulator.length; i++) {
      //  houghImg.pixels[i] = color(min(255, accumulator[i]));
      //}
      //// You may want to resize the accumulator to make it easier to see:
      //houghImg.resize(400, 400);
      //houghImg.updatePixels();
      //image(houghImg , edgeImg.width , 0 );
      
    // -------


    // use this or week 11 - 1 method for sorting and choosing best lines ??
    ArrayList<PVector> lines=new ArrayList<PVector>();
    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
    for (int idx = 0; idx < accumulator.length; idx++) {
        if (accumulator[idx] > minVotes ) {
            // first, compute back the (r, phi) polar coordinates:
            int accPhi = (int) (idx / (rDim));
            int accR = idx - (accPhi) * (rDim);
            float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
            float phi = accPhi * discretizationStepsPhi;
            if(checkMaxNeighbor(accumulator, idx, regionSize, phiDim)){
                lines.add(new PVector(r,phi));
                bestCandidates.add(idx);
            }
        }
    }
    println("lines size = " + lines.size());
    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    
    return lines;
}

boolean checkMaxNeighbor(int[] accumulator, int idx, int regionSize, int phiDim){
    int potentialMax = accumulator[idx];
    for (int i = -regionSize; i<=regionSize; ++i){
      for (int j = -regionSize; j<=regionSize; ++j){
        if ((idx +i + j*phiDim)>=0 && (idx +i + j*phiDim) < accumulator.length && accumulator[idx+i+j*phiDim ] > potentialMax)
           return false;
      }
    }
  return true;
}





void draw_lines(List<PVector> lines , int imageWidth){
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
    int x2 = imageWidth;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = imageWidth;
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

class HoughComparator implements java.util.Comparator<Integer> { 
  int[] accumulator;
  
  public HoughComparator(int[] accumulator) {
    this.accumulator = accumulator; 
  }
  
  @Override
  public int compare(Integer l1, Integer l2) { 
    if (accumulator[l1] > accumulator[l2] || (accumulator[l1] == accumulator[l2] && l1 < l2)) 
      return -1; 
    return 1;
  } 
}
