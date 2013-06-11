/*

 A gui based system for detecting blobs in a series of still images.
 
 Matthew Epler
 2013
 
 *NOTE: to be updated upon release of OpenCVPro by Greg Borenstein: https://github.com/atduskgreg/OpenCVPro
 **NTS: Processing folder should be set to old folder, located in Dropbox dir.
 
 // TO ADD
 -- button to launch OS directory window
 
 */

import processing.opengl.*;
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
boolean detectBlobs;


void setup() 
{  
  size( 1200, 925);
  opencv = new OpenCV( this );
  
  getDirectory( "/Users/matthewepler/Dropbox/Processing_1_5/blobs_gui_cv01/data" );
  
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
  
  if( detectBlobs )
  {
    // detect blobs on the current image and display
    String currentFile = files[ currentFrame ];
    PImage currentImage = loadImage( files[ currentFrame ] );
    currentImage.resize( imageSize, 0 );
    image( currentImage, imageX, imageY );
    detectBlobsSingleImage( currentFile );
  } else {
    // just show the image by itself
    String currentFile = files[ currentFrame ];
    PImage currentImage = loadImage( files[ currentFrame ] );
    currentImage.resize( imageSize, 0 );
    image( currentImage, imageX, imageY );
  }
  
  drawText();
}


void processAllImageFilesInDir()
{
  for (File child : dir.listFiles()) 
  {
    String filename = child.getName();
    if ( !filename.contains("Store") && !filename.contains("vlw") )
    {
      detectBlobsSingleImage( filename );
      save( "output/" + filename );
      println( counter + " of " + files.length ); 
      counter++;
    }
  }
}


void detectBlobsSingleImage( String filename )
{
  opencv.loadImage( filename );
  PGraphics blobFrame = createGraphics( opencv.width, opencv.height, P2D );
  opencv.absDiff();
  opencv.threshold(threshold);
  Blob[] blobs = opencv.blobs( 100, width*height/3, 20, true ); // adjust first two values for min/max size of blobs

  blobFrame.beginDraw();
  blobFrame.background( 0, 0 );
  
  for ( int i=0; i<blobs.length; i++ ) {

    Rectangle bounding_rect  = blobs[i].rectangle;
    float area = blobs[i].area;
    float circumference = blobs[i].length;
    Point centroid = blobs[i].centroid;
    Point[] points = blobs[i].points;

    // rectangle
    blobFrame.noFill();
    blobFrame.stroke( blobs[i].isHole ? 128 : 64 );
    blobFrame.rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );


    // centroid
    blobFrame.stroke(0, 0, 255);
    blobFrame.line( centroid.x-5, centroid.y, centroid.x+5, centroid.y );
    blobFrame.line( centroid.x, centroid.y-5, centroid.x, centroid.y+5 );
    blobFrame.noStroke();
    blobFrame.fill(0, 0, 255);
    blobFrame.text( area, centroid.x+5, centroid.y+5 );


    blobFrame.fill(255, 0, 255, 64);
    blobFrame.stroke(255, 0, 255);
    if ( points.length>0 ) {
      blobFrame.beginShape();
      for ( int j=0; j<points.length; j++ ) {
        blobFrame.vertex( points[j].x, points[j].y );
      }
      blobFrame.endShape(CLOSE);
    }

    blobFrame.noStroke();
    blobFrame.fill(255, 0, 255);
    blobFrame.text( circumference, centroid.x+5, centroid.y+15 );
  }
  blobFrame.resize( imageSize, 0 );
  blobFrame.endDraw();
  image( blobFrame, imageX, imageY );
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
  
  controlP5.Slider scrubber = controlP5.addSlider( "scrubber", 1, files.length-1, 0, windowLeft, windowHeight - 15, windowWidth, 15 );
  scrubber.setMin( 1 );
  scrubber.setNumberOfTickMarks( files.length );
  scrubber.snapToTickMarks( true );
  scrubber.setSliderMode(Slider.FLEXIBLE);
  int currFileNumber = int( scrubber.valueLabel().toString() );
  scrubber.setValueLabel( "File " + currFileNumber + " of " + (files.length-1) );
  scrubber.setCaptionLabel( "" );
  scrubber.setColor( c );
  
  // LEFT PANEL
  int verticalSpacer = 25;
    
  // Image Control
  controlP5.Slider imageSize = controlP5.addSlider( "imageSize", windowWidth / 2, windowWidth * 2, windowWidth, horizMargin, verticalSpacer * 3, 250, 20 );
  imageSize.setCaptionLabel( "Size" );
  imageSize.captionLabel().style().setMarginLeft( -253 );
  imageSize.valueLabel().style().setMarginLeft( 200 );
  
  controlP5.Textfield imageSizeText = controlP5.addTextfield( "imageSizeText", 255 + horizMargin, verticalSpacer * 3, 50, 20 );
  imageSizeText.setValue( windowWidth );
  imageSizeText.setColorBackground( color( 90 ) );
  imageSizeText.setCaptionLabel( "" );
  imageSizeText.setAutoClear( true );
  
  controlP5.Slider imageX = controlP5.addSlider( "imageX", windowLeft - 100, width - windowWidth/2, windowLeft, horizMargin, verticalSpacer * 4, 250, 20 );
  imageX.captionLabel().style().setMarginLeft( -253 );
  imageX.valueLabel().style().setMarginLeft( 200 );
  
  controlP5.Textfield imageXText = controlP5.addTextfield( "imageXText", 255 + horizMargin, verticalSpacer * 4, 50, 20 );
  imageXText.setValue( windowWidth );
  imageXText.setColorBackground( color( 90 ) );
  imageXText.setCaptionLabel( "" );
  imageXText.setAutoClear( true );
  
  controlP5.Slider imageY = controlP5.addSlider( "imageY", -500, height/2, horizMargin, horizMargin, verticalSpacer * 5, 250, 20 );
  imageY.captionLabel().style().setMarginLeft( - 253 );
  imageY.valueLabel().style().setMarginLeft( 200 );
  
  controlP5.Textfield imageYText = controlP5.addTextfield( "imageYText", 255 + horizMargin, verticalSpacer * 5, 50, 20 );
  imageYText.setValue( windowWidth );
  imageYText.setColorBackground( color( 90 ) );
  imageYText.setCaptionLabel( "" );
  imageYText.setAutoClear( true );
  
  controlP5.Button resetImage = controlP5.addButton( "resetImage", 0, horizMargin + 300 - 45, verticalSpacer * 6, 50, 20 );
  resetImage.setCaptionLabel( "reset" );
   
  
  
  // Blob Detection Adjustment
  controlP5.Toggle blobToggle = controlP5.addToggle( "blobToggle", false, horizMargin, verticalSpacer * 10, 20, 20 );
  blobToggle.setCaptionLabel( "ON/OFF" );
  blobToggle.captionLabel().style().setMarginLeft( 25 ).setMarginTop( -20 );
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
  text( "BLOB DETECTION SETTINGS", horizMargin, horizMargin * 9 );
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

void imageSizeText( String theValue )
{
  int num = int( theValue );
  controlP5.Controller imageSizeF = controlP5.getController( "imageSize" );
  imageSizeF.setValue( num );
  imageSizeF.setValueLabel( theValue );
}

void imageXText( String theValue )
{
  int num = int( theValue );
  controlP5.Controller imageXF = controlP5.getController( "imageX" );
  imageXF.setValue( num );
  imageXF.setValueLabel( theValue );
}

void imageYText( String theValue )
{
  int num = int( theValue );
  controlP5.Controller imageYF = controlP5.getController( "imageY" );
  imageYF.setValue( num );
  imageYF.setValueLabel( theValue ); 
}

void blobToggle()
{
  detectBlobs = !detectBlobs; 
}


public void stop() {
  opencv.stop();
  super.stop();
}

