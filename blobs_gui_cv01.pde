/*

 A gui based system for detecting blobs in a series of still images.
 
 Matthew Epler
 2013
 
 *NOTE: to be updated upon release of OpenCVPro by Greg Borenstein: https://github.com/atduskgreg/OpenCVPro
 **NTS: Processing folder should be set to old folder, located in Dropbox dir.
 
 */

import hypermedia.video.*;
import java.awt.*;
import controlP5.*;

ControlP5 controlP5;

// OPENCV VARIABLES  
OpenCV opencv;
int threshold;
boolean find = true;

// FILE VARIABLES
File dir;
String path = "/Users/matthewepler/Documents/Processing/PixelSorting/SortImageByNpx_iterate/data";
String[] files;
int counter;

// GUI VARIABLES
int currentFrame;


void setup() 
{  
  size( 1000, 800 );
  opencv = new OpenCV( this );
  controlP5 = new ControlP5( this );

  threshold = 80;
  currentFrame = 0; 

  if ( getDirectory( "/data" ) )
  {
    println( "HERE" );
  } 

  counter = 1;
}



boolean getDirectory( String s )
{
  try
  {
    dir = new File( s );
    files = dir.list();
    return true;
  } 
  catch( Exception e )
  {
    println( e );
    return false;
  }
}


void processAllImageFilesInDir()
{
  for (File child : dir.listFiles()) 
  {
    String filename = child.getName();
    if ( !filename.contains("Store") )
    {
      opencv.loadImage( filename );
      opencv.absDiff();
      opencv.threshold(threshold);
      Blob[] blobs = opencv.blobs( 100, width*height/3, 20, true ); // adjust first two values for min/max size of blobs
      background( 0 );
      for ( int i=0; i<blobs.length; i++ ) {

        Rectangle bounding_rect  = blobs[i].rectangle;
        float area = blobs[i].area;
        float circumference = blobs[i].length;
        Point centroid = blobs[i].centroid;
        Point[] points = blobs[i].points;

        // rectangle
        noFill();
        stroke( blobs[i].isHole ? 128 : 64 );
        rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );


        // centroid
        stroke(0, 0, 255);
        line( centroid.x-5, centroid.y, centroid.x+5, centroid.y );
        line( centroid.x, centroid.y-5, centroid.x, centroid.y+5 );
        noStroke();
        fill(0, 0, 255);
        text( area, centroid.x+5, centroid.y+5 );


        fill(255, 0, 255, 64);
        stroke(255, 0, 255);
        if ( points.length>0 ) {
          beginShape();
          for ( int j=0; j<points.length; j++ ) {
            vertex( points[j].x, points[j].y );
          }
          endShape(CLOSE);
        }

        noStroke();
        fill(255, 0, 255);
        text( circumference, centroid.x+5, centroid.y+15 );
      }
      save( "output/" + filename );
      println( counter + " of " + files.length );
      counter++;
    }
  }
}

public void stop() {
  opencv.stop();
  super.stop();
}

