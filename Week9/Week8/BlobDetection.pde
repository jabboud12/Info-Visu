import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

//PImage img, imgCheck;
//void settings() {
//  size(400, 200);
//}

//void setup() {
//  img = loadImage("BlobDetection_Test.png");


//  noLoop(); // no interactive behaviour: draw() will be called only once.
//}

//void draw() {
//  image(img, 0, 0);//show image
//  PImage img2 = img.copy();//make a deep copy
//  img2.loadPixels();
//  img2.updatePixels();

//  image(findConnectedComponents(img2, false), img.width, 0);
//}
//class BlobDetection {



PImage findConnectedComponents(PImage input, boolean onlyBiggest) {

  // First pass: labels the pixels and stores labels' equivalences
  PImage res = input.copy();
  int [] labels = new int [input.width*input.height];
  List<TreeSet<Integer>> labelsEquivalences = new ArrayList<TreeSet<Integer>>();
  TreeSet<Integer> s = new TreeSet<Integer>();
  s.add(0);
  labelsEquivalences.add(s);
  int threshold = 100;
  int currentLabel = 1;



  for (int i =0; i< input.width*input.height; ++i) 
    labels[i] = 0;


  for (int y = 1; y < input.height-1; ++y) {
    for (int x = 1; x < input.width-1; ++x) {


      if (brightness(input.pixels[y* input.width + x])  > threshold) {
        TreeSet<Integer> neighbors = new TreeSet<Integer>();
        neighbors.clear();

        for (int i=-1; i<2; ++i) {
          for (int j = -1; j<2; ++j) {
            if (brightness(input.pixels[(y+j) * input.width + x + i ])>=threshold && labels[(y+j) * input.width + x + i]!=0) {
              neighbors.add(labels[((y+j)* input.width + x + i)]);
            }
          }
        }


        if (neighbors.isEmpty()) {
          TreeSet<Integer> set = new TreeSet<Integer>();
          set.add(currentLabel);
          labelsEquivalences.add(set);
          labels[y* input.width + x] = currentLabel;
          currentLabel += 1;
        } else {

          labels[y* input.width + x] = neighbors.first();
          TreeSet<Integer> tree = new TreeSet<Integer>();
          for (int label : neighbors ) {
            tree.addAll(labelsEquivalences.get(label));
          }
          for (int label : tree) {
            TreeSet<Integer> t = labelsEquivalences.get(label);
            t.addAll(tree);
            labelsEquivalences.set(label, t);
          }
        }
      }
    }
  }


  // Second pass: re-labels the pixels by their equivalent class
  //if onlyBiggest==true, counts the number of pixels for each label

  int labelCount[] = new int[currentLabel+1];
  for (int i = 0; i<labelCount.length; ++i) {
      labelCount[i] = 0;
    }

  for (int x = 0; x < input.width; ++x) {
    for (int y = 0; y < input.height; ++y) {
      
      int label = labelsEquivalences.get(labels[y* input.width + x]).first();
      labels[y* input.width + x] = label;
      if (onlyBiggest)
        labelCount[label] = labelCount[label]+1;
    }
  }

 
  // if onlyBiggest==false, output an image with each blob colored in one uniform color
  // if onlyBiggest==true, output an image with the biggest blob in white and others in black
  int maxLabel = 1;
  if (onlyBiggest) {  
    for (int i = 1; i<labelCount.length; ++i) { //we don't take i = 0 because it is the background
      println(labelCount[i]);
      if (labelCount[i]>labelCount[maxLabel]) maxLabel = i;
    }
  }
  println("maxLabel" + maxLabel);



  for (int y = 0; y < input.height; ++y) {
    for (int x = 0; x < input.width; ++x) {
      res.pixels[y*input.width+x] = labels[y*input.width+x];
      if (onlyBiggest) {
        res.pixels[y*input.width+x] = ((res.pixels[y*input.width+x] == maxLabel) ?  color(255): color(0)) ;
        //if (res.pixels[y*input.width+x] == maxLabel) {
        //  color(255);
        //} else {
        //  color(0));
        //}
      } else {    //fixme !!!
        if (res.pixels[y*input.width+x]%7 == 1)  res.pixels[y*input.width+x] = color(123);
        if (res.pixels[y*input.width+x]%7 == 2)  res.pixels[y*input.width+x] = color(255, 0, 0);
        if (res.pixels[y*input.width+x]%7 == 3)  res.pixels[y*input.width+x] = color(0, 255, 0);
        if (res.pixels[y*input.width+x]%7 == 4)  res.pixels[y*input.width+x] = color(0, 0, 255);

        if (res.pixels[y*input.width+x]%7 == 5)  res.pixels[y*input.width+x] = color(255, 255, 0);
        if (res.pixels[y*input.width+x]%7 == 6)  res.pixels[y*input.width+x] = color(0, 255, 255);
        if (res.pixels[y*input.width+x]%7 == 7)  res.pixels[y*input.width+x] = color(255, 0, 255);
      }
    }
  }
 
  //println(labelCount[].toString());
  //println("current label " + currentLabel);
  return res;
}
//}
