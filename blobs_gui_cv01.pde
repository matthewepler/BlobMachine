/*

 A gui based system for detecting blobs in a series of still images.
 
 Matthew Epler
 2013
 
 *NOTE: to be updated upon release of OpenCVPro by Greg Borenstein: https://github.com/atduskgreg/OpenCVPro
 **NTS: Processing folder should be set to old folder, located in Dropbox dir.
 
 // TO ADD
 -- button to launch OS directory window
 
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
String path;
String[] files;
int counter;

// GUI VARIABLES
int currentFrame = 1;
int horizMargin = 25;
int vertMargin  = 0;
int panelWidth  = 300;
int heightAdjust = 50;
int windowLeft;
int windowWidth;
int windowHeight;
int smallText   = 16;
int largeText   = 16;
color clearText = color( 225 );
color valueText = color( 20, 214, 255 );
PFont guiFont;
int imageX, imageY, imageSize;


void setup() 
{  
  size( 1200, 925);
  opencv = new OpenCV( this );
  
  getDirectory( "/Users/matthewepler/Dropbox/Processing/blobs_gui_cv01/data" );
  
  windowLeft  = panelWidth + (horizMargin*2);
  windowWidth = width - windowLeft - horizMargin;
  windowHeight= height - (horizMargin*2);
  
  guiFont = loadFont( "AndaleMono-48.vlw" );
  textFont( guiFont );
  initGui();

  threshold = 80;
  currentFrame = 1; 
  counter = 1;
  
  imageX = windowLeft;
  imageY = 25;
  imageSize = windowWidth;
}


void draw()
{
  background( 90 ); 
  
  String currentFile = files[ currentFrame ];
  if( !currentFile.contains( "Store" ) )
  {
    PImage currentImage = loadImage( files[ currentFrame ] );
    currentImage.resize( imageSize, 0 );
    image( currentImage, imageX, imageY );
  }
  
  //showGuiOutlines();
  drawText();
}


void processAllImageFilesInDir()
{
  for (File child : dir.listFiles()) 
  {
    String filename = child.getName();
    if ( !filename.contains("Store") && !filename.contains("vlw") )
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


void getDirectory( String s )
{
  path = s;
  dir = new File( path );
  
  if( dir.isDirectory() )
  {
    files = dir.list();
    String success = "Directory \'" + dir.getName() + "\' loaded successfully.";
    println( success );
  } 
  else
  {
    String fail = "Failed to load directory. Please verify the path string.";
    fail += "\n";
    fail += "Path = " + path;
    println( fail ); 
  }
}

void initGui()
{
  controlP5 = new ControlP5( this );
  controlP5.setControlFont( guiFont, 14 );
  CColor c =  new CColor();
  c.setBackground  ( color( 2, 52, 77 ) ); 
  c.setForeground  ( color( 0, 180, 234 ) );
  c.setCaptionLabel( color( 255 ) ); 
  c.setValueLabel  ( color( 255 ) );
  c.setActive      ( color( 155, 0, 0 ) );
  
  // Viewer Window
  controlP5.Button setPath = controlP5.addButton( "PATH", 0, windowLeft, height - 30, 75, 20 );
  setPath.setCaptionLabel( " <PATH>" );
  setPath.setColor( c );
  
  controlP5.Slider scrubber = controlP5.addSlider( "scrubber", 1, files.length, 0, windowLeft, windowHeight - 15, windowWidth, 15 );
  scrubber.setMin( 1 );
  scrubber.setNumberOfTickMarks( files.length );
  scrubber.snapToTickMarks( true );
  scrubber.setSliderMode(Slider.FLEXIBLE);
  int currFileNumber = int( scrubber.valueLabel().toString() );
  scrubber.setValueLabel( "File " + currFileNumber + " of " + files.length );
  scrubber.setCaptionLabel( "" );
  scrubber.setColor( c );
  
  // LEFT PANEL
  int verticalSpacer = 25;
    
  // Image Control
  controlP5.Slider imageSize = controlP5.addSlider( "imageSize", windowWidth / 2, windowWidth * 2, windowWidth, horizMargin, verticalSpacer * 3, 300, 20 );
  imageSize.setCaptionLabel( "Size" );
  imageSize.captionLabel().style().setMarginLeft( -303 );
  imageSize.valueLabel().style().setMarginLeft( 250 );
  //imageSize.captionLabel().style().setMarginTop( -20 );
  
  controlP5.Slider imageX = controlP5.addSlider( "imageX", windowLeft - 100, width - windowWidth/2, windowLeft, horizMargin, verticalSpacer * 4, 300, 20 );
  imageX.captionLabel().style().setMarginLeft( - 303 );
  imageX.valueLabel().style().setMarginLeft( 250 );
  
  controlP5.Slider imageY = controlP5.addSlider( "imageY", -500, height/2, horizMargin, horizMargin, verticalSpacer * 5, 300, 20 );
  imageY.captionLabel().style().setMarginLeft( - 303 );
  imageY.valueLabel().style().setMarginLeft( 250 );
  
  controlP5.Button resetImage = controlP5.addButton( "resetImage", 0, horizMargin + 300 - 50, verticalSpacer * 6, 50, 20 );
  resetImage.setCaptionLabel( "reset" );
  //resetImage.captionLabel().style().setMarginLeft(); 
  
  // Blob Detection Adjustment
  controlP5.Toggle blobToggle = controlP5.addToggle( "blobToggle", false, horizMargin, verticalSpacer * 16, 20, 20 );
  blobToggle.setCaptionLabel( "Blob Detection ON/OFF" );
}


void scrubber( int value )
{
  currentFrame = value;
  ((Slider)controlP5.controller("scrubber")).setValueLabel( "File " + value + " of " + files.length ); 
}

void setPath()
{
  // open a window for user to select path
  println( "setPath() temp empty" );  
}

void drawText()
{
  textSize( largeText );
  fill( valueText );
  String[] pathStrings = path.split("/");
  String relativePath  = ".../" + pathStrings[ pathStrings.length-2 ] + "/" + pathStrings[ pathStrings.length - 1 ];
  text( relativePath, windowLeft + 90, height - 12 ); 
  text( "IMAGE ADJUSTMENT", horizMargin, horizMargin * 2 );
}

void resetImage()
{
  imageSize = windowWidth;
  imageX = windowLeft;
  imageY = horizMargin;
  controlP5.getController( "imageSize" ).setValue( windowWidth );
  controlP5.getController( "imageX" ).setValue( windowLeft );
  controlP5.getController( "imageY" ).setValue( horizMargin );
}


void showGuiOutlines()
{
  // LEFT PANEL
  noFill();
  stroke( 255, 0, 0 );
  rect( horizMargin, vertMargin, panelWidth, height - (vertMargin*4) );
  
  // WINDOW
  stroke( 0, 0, 255 );
  rect( windowLeft, horizMargin, windowWidth, windowHeight );
}


public void stop() {
  opencv.stop();
  super.stop();
}

