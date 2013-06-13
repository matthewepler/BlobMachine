/*

 A gui based system for detecting blobs in a series of still images using OpenCV 1.1 library.
 
 Matthew Epler
 2013
 
 *NOTE: to be updated upon release of OpenCVPro by Greg Borenstein: https://github.com/atduskgreg/OpenCVPro
 **NTS: Processing folder should be set to old folder, located in Dropbox dir.
 
 // TO ADD
 -- button to launch OS directory window
 -- save as PNG to preserve alpha masking
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
String currentFile;
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
int smallText   = 14;
int largeText   = 16;
color clearText = color( 225 );
color valueText = color( 20, 214, 255 );
PFont guiFont;
int imageX, imageY, imageSize, imageAlpha;
boolean detectBlobs;
int minArea, maxArea, maxBlobs, maxVertices;
boolean findHoles;
color blobFill, blobStroke, blobAlpha;
color centrStroke, centrAlpha;
int centrSize;
color textColor;
int centrTextSize;
int strokeSize;

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
  
  currentFrame = 1; 
  counter = 1;
  
  imageX = windowLeft;
  imageY = 25;
  imageSize = windowWidth;
  imageAlpha = 255;
  
  threshold = 80;
  minArea = 100;
  maxArea = (width*height) / 3;
  maxBlobs = 20;
  findHoles = true;
  
  detectBlobs = true;
  blobFill =    color( #18FF04 );
  blobStroke =  color( #0028FF );
  centrStroke = color( #FF6E32 );
  centrTextSize = 10;
  centrSize = 10;
  strokeSize = 2;
}


void draw()
{
  background( 40 ); 
  
  if( detectBlobs )
  {
    // detect blobs on the current image and display
    currentFile = files[ currentFrame ];
    PImage currentImage = loadImage( files[ currentFrame ] );
    currentImage.resize( imageSize, 0 );
    tint( 255, imageAlpha );
    image( currentImage, imageX, imageY );
    noTint();
    detectBlobsSingleImage( currentFile );
  } else {
    // just show the image by itself
    String currentFile = files[ currentFrame ];
    PImage currentImage = loadImage( files[ currentFrame ] );
    currentImage.resize( imageSize, 0 );
    image( currentImage, imageX, imageY );
  }
  
  drawText();
  drawColorBoxes();
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
  Blob[] blobs = opencv.blobs( minArea, maxArea, maxBlobs, findHoles ); // uses basic constructor for blobs() in OpenCV 1.1

  blobFrame.beginDraw();
  blobFrame.background( 0, 0 );
  blobFrame.strokeWeight( strokeSize );
  
  for ( int i=0; i<blobs.length; i++ ) {

    Rectangle bounding_rect  = blobs[i].rectangle;
    float area = blobs[i].area;
    float circumference = blobs[i].length;
    Point centroid = blobs[i].centroid;
    Point[] points = blobs[i].points;

    // large bounding rectangle
//    blobFrame.noFill();
//    blobFrame.stroke( blobs[i].isHole ? 128 : 64 );
//    blobFrame.rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );

    blobFrame.fill( blobFill, blobAlpha );
    blobFrame.strokeWeight( strokeSize );
    blobFrame.stroke( blobStroke );
    if ( points.length>0 ) {
      blobFrame.beginShape();
      for ( int j=0; j<points.length; j++ ) {
        blobFrame.vertex( points[j].x, points[j].y );
      }
      blobFrame.endShape(CLOSE);
    }
    
    // centroid
    blobFrame.stroke( centrStroke, centrAlpha );
    blobFrame.line( centroid.x - (centrSize/2), centroid.y, centroid.x + (centrSize/2), centroid.y );
    blobFrame.line( centroid.x, centroid.y - (centrSize/2), centroid.x, centroid.y + (centrSize/2) );

    // text value
    blobFrame.noStroke();
    blobFrame.fill( textColor, centrAlpha );
    blobFrame.textSize( centrTextSize );
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
  
  int boxHeight = 20;
  int imageBoxLength = 50;
  int colorBoxLength = 80;
  
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
    
  // IMAGE ADJUSTMENTS
  //imageSize
  controlP5.Slider imageSize = controlP5.addSlider( "imageSize", windowWidth / 2, windowWidth * 2, windowWidth, horizMargin, verticalSpacer * 3, 250, 20 );
  imageSize.setCaptionLabel( "Size" );
  imageSize.captionLabel().style().setMarginLeft( -253 );
  imageSize.valueLabel().style().setMarginLeft( 200 );
  
  controlP5.Textfield imageSizeText = controlP5.addTextfield( "imageSizeText", 255 + horizMargin, verticalSpacer * 3, imageBoxLength, boxHeight );
  imageSizeText.setValue( windowWidth );
  imageSizeText.setColorBackground( color( 90 ) );
  imageSizeText.setCaptionLabel( "" );
  imageSizeText.setAutoClear( true );
  
  //imageX
  controlP5.Slider imageX = controlP5.addSlider( "imageX", windowLeft - 100, width - windowWidth/2, windowLeft, horizMargin, verticalSpacer * 4, 250, 20 );
  imageX.captionLabel().style().setMarginLeft( -253 );
  imageX.valueLabel().style().setMarginLeft( 200 );
  
  controlP5.Textfield imageXText = controlP5.addTextfield( "imageXText", 255 + horizMargin, verticalSpacer * 4, imageBoxLength, boxHeight );
  imageXText.setValue( windowWidth );
  imageXText.setColorBackground( color( 90 ) );
  imageXText.setCaptionLabel( "" );
  imageXText.setAutoClear( true );
  
  //imageY
  controlP5.Slider imageY = controlP5.addSlider( "imageY", -500, height/2, horizMargin, horizMargin, verticalSpacer * 5, 250, 20 );
  imageY.captionLabel().style().setMarginLeft( - 253 );
  imageY.valueLabel().style().setMarginLeft( 200 );
  
  controlP5.Textfield imageYText = controlP5.addTextfield( "imageYText", 255 + horizMargin, verticalSpacer * 5, imageBoxLength, boxHeight );
  imageYText.setValue( windowWidth );
  imageYText.setColorBackground( color( 90 ) );
  imageYText.setCaptionLabel( "" );
  imageYText.setAutoClear( true );
  
  //alpha
  controlP5.Slider imageAlpha = controlP5.addSlider( "imageAlpha", 0, 255, 255, horizMargin, verticalSpacer * 6, 250, 20 );
  imageAlpha.setCaptionLabel( "alpha" );
  imageAlpha.captionLabel().style().setMarginLeft( - 253 );
  imageAlpha.valueLabel().style().setMarginLeft( 200 );
  
  controlP5.Textfield imageAlphaText = controlP5.addTextfield( "imageAlphaText", 255 + horizMargin, verticalSpacer * 6, imageBoxLength, boxHeight );
  imageAlphaText.setValue( 255 );
  imageAlphaText.setColorBackground( color( 90 ) );
  imageAlphaText.setCaptionLabel( "" );
  imageAlphaText.setAutoClear( true );
  
  //reset
  controlP5.Button resetImage = controlP5.addButton( "resetImage", 0, horizMargin + 300 - 45, verticalSpacer * 7, imageBoxLength, boxHeight );
  resetImage.setCaptionLabel( "reset" );
   
  
  // BLOB DETECTION ADJUSTMENT
  // On/Off
  controlP5.Toggle blobToggle = controlP5.addToggle( "blobToggle", true, horizMargin, verticalSpacer * 10, 20, 20 );
  blobToggle.setCaptionLabel( "ON/OFF" );
  blobToggle.captionLabel().style().setMarginLeft( 25 ).setMarginTop( -23 );
  
  //findHoles
  controlP5.Toggle findHoles = controlP5.addToggle( "findHoles", true, horizMargin + 140, verticalSpacer * 10, 20, 20 );
  findHoles.setCaptionLabel( "find holes" );
  findHoles.captionLabel().style().setMarginLeft( 25 ).setMarginTop( -23 );
  
  // Threshold
  controlP5.Slider threshold = controlP5.addSlider( "threshold", 1, 300, 80, horizMargin, verticalSpacer * 11, 250, 20 );
  threshold.captionLabel().style().setMarginLeft( -253 );
  threshold.valueLabel().style().setMarginLeft( 190 );
  
  controlP5.Textfield thresholdText = controlP5.addTextfield( "thresholdText", 255 + horizMargin, verticalSpacer * 11, imageBoxLength, boxHeight );
  thresholdText.setValue( 80 );
  thresholdText.setColorBackground( color( 90 ) );
  thresholdText.setCaptionLabel( "" );
  thresholdText.setAutoClear( true );
  
  //minArea
  controlP5.Slider minArea = controlP5.addSlider( "minArea", 1, 200, 100, horizMargin, verticalSpacer * 12, 250, 20 );
  minArea.captionLabel().style().setMarginLeft( -253 );
  minArea.valueLabel().style().setMarginLeft( 190 );
  
  controlP5.Textfield minAreaText = controlP5.addTextfield( "minAreaText", 255 + horizMargin, verticalSpacer * 12, imageBoxLength, boxHeight );
  minAreaText.setValue( 80 );
  minAreaText.setColorBackground( color( 90 ) );
  minAreaText.setCaptionLabel( "" );
  minAreaText.setAutoClear( true );
  
  //maxArea
  controlP5.Slider maxArea = controlP5.addSlider( "maxArea", 100, 300000, 150000, horizMargin, verticalSpacer * 13, 250, 20 );
  maxArea.captionLabel().style().setMarginLeft( -253 );
  maxArea.valueLabel().style().setMarginLeft( 190 );
  
  controlP5.Textfield maxAreaText = controlP5.addTextfield( "maxAreaText", 255 + horizMargin, verticalSpacer * 13, imageBoxLength, boxHeight );
  maxAreaText.setValue( 80 );
  maxAreaText.setColorBackground( color( 90 ) );
  maxAreaText.setCaptionLabel( "" );
  maxAreaText.setAutoClear( true );
  
  //maxBlobs
  controlP5.Slider maxBlobs = controlP5.addSlider( "maxBlobs", 1, 150, 20, horizMargin, verticalSpacer * 14, 250, 20 );
  maxBlobs.captionLabel().style().setMarginLeft( -253 );
  maxBlobs.valueLabel().style().setMarginLeft( 190 );
  
  controlP5.Textfield maxBlobsText = controlP5.addTextfield( "maxBlobsText", 255 + horizMargin, verticalSpacer * 14, imageBoxLength, boxHeight );
  maxBlobsText.setValue( 80 );
  maxBlobsText.setColorBackground( color( 90 ) );
  maxBlobsText.setCaptionLabel( "" );
  maxBlobsText.setAutoClear( true );
  
  //resetBlobs
  controlP5.Button resetBlobs = controlP5.addButton( "resetBlobs", 0, horizMargin + 300 - 45, verticalSpacer * 15, imageBoxLength, boxHeight );
  resetBlobs.setCaptionLabel( "reset" );
  
  //blob colors
  controlP5.Textfield blobFillText = controlP5.addTextfield( "blobFillText", horizMargin + 225, int(verticalSpacer * 17.75), colorBoxLength, boxHeight );
  blobFillText.setCaptionLabel( "" );
  blobFillText.setColorBackground( color( 90 ) );
  blobFillText.setAutoClear( false );
  
  controlP5.Textfield blobStrokeText = controlP5.addTextfield( "blobStrokeText", horizMargin + 225, int(verticalSpacer * 18.75), colorBoxLength, boxHeight );
  blobStrokeText.setCaptionLabel( "" );
  blobStrokeText.setColorBackground( color( 90 ) );
  blobStrokeText.setAutoClear( false );
  
  controlP5.Textfield blobAlphaText = controlP5.addTextfield( "blobAlphaText", horizMargin + 225, int(verticalSpacer * 19.75), colorBoxLength, boxHeight );
  blobAlphaText.setValue( "255" );
  blobAlphaText.setCaptionLabel( "" );
  blobAlphaText.setColorBackground( color( 90 ) );
  blobAlphaText.setAutoClear( false );
  blobAlphaText.submit();
  
  //centroid color
  controlP5.Textfield centrStrokeText = controlP5.addTextfield( "centrStrokeText", horizMargin + 225, 550, colorBoxLength, boxHeight );
  centrStrokeText.setCaptionLabel( "" );
  centrStrokeText.setColorBackground( color( 90 ) );
  centrStrokeText.setAutoClear( false );
  
  controlP5.Textfield centrAlphaText = controlP5.addTextfield( "centrAlphaText", horizMargin + 225, 575, colorBoxLength, boxHeight );
  centrAlphaText.setValue( "255" );
  centrAlphaText.setCaptionLabel( "" );
  centrAlphaText.setColorBackground( color( 90 ) );
  centrAlphaText.setAutoClear( false );
  centrAlphaText.submit();

  //text color
  controlP5.Textfield textColorText = controlP5.addTextfield( "textColorText", horizMargin + 225, 625, colorBoxLength, boxHeight );
  textColorText.setCaptionLabel( "" );
  textColorText.setColorBackground( color( 90 ) );
  textColorText.setAutoClear( false );
  
  
  //SIZE SETTINGS
  //overall stroke
  controlP5.Textfield strokeSize = controlP5.addTextfield( "strokeSize", horizMargin + 225, 685, colorBoxLength, boxHeight );
  strokeSize.setValue( 2 );
  strokeSize.setCaptionLabel( "" );
  strokeSize.setColorBackground( color( 90 ) );
  strokeSize.setAutoClear( false );
  strokeSize.submit();
  
  //centroid
  controlP5.Textfield centrSize = controlP5.addTextfield( "centrSize", horizMargin + 225, 710, colorBoxLength, boxHeight );
  centrSize.setValue( 10 );
  centrSize.setCaptionLabel( "" );
  centrSize.setColorBackground( color( 90 ) );
  centrSize.setAutoClear( false );
  centrSize.submit();
  
  //text
  controlP5.Textfield centrTextSize = controlP5.addTextfield( "centrTextSize", horizMargin + 225, 735, colorBoxLength, boxHeight );
  centrTextSize.setValue( 10 );
  centrTextSize.setCaptionLabel( "" );
  centrTextSize.setColorBackground( color( 90 ) );
  centrTextSize.setAutoClear( false );
  centrTextSize.submit();
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
  text( "COLOR SETTINGS", horizMargin, 425 );
  text( "SIZE SETTINGS", horizMargin, 695 );
  fill( valueText, 155 );
  text( "(r,g,b)", horizMargin + 150, 425 );
  text( "Blob", horizMargin, 460 );
  text( "Centr.", horizMargin, 560 );
  text( "Text", horizMargin, 635 );
  fill( 255 );
  textSize( smallText );
  text( "Fill",   190, 460 );
  text( "Stroke", 190, 485 );
  text( "Alpha",  190, 510 );
  text( "Stroke", 190, 565 );
  text( "Alpha",  190, 590 );
  text( "Fill",   190, 640 );
  text( "Stroke", 190, 700 );
  text( "Centr",  190, 725 );
  text( "Text",   190, 750 );
}

void drawColorBoxes()
{
  //blob color
  strokeWeight( strokeSize );
  stroke( blobStroke );
  fill( blobFill, blobAlpha );
  rect( 95, 445, 75, 75 ); 
  
  //centroid stroke
  stroke( centrStroke, centrAlpha );
  line( 130, 545, 130, 595 );
  line( 105, 570, 155, 570 );
  
  //text sample
  fill( textColor );
  textSize( largeText * 1.5 );
  text( "1234.0", 89, 645 );
}

void resetImage()
{
  imageAlpha = 255;
  imageSize = windowWidth;
  imageX = windowLeft;
  imageY = horizMargin;
  controlP5.getController( "imageAlpha" ).setValue( imageAlpha );
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

void imageAlphaText( String theValue )
{
  int num = int( theValue );
  controlP5.Controller imageAlphaTextF = controlP5.getController( "imageAlpha" );
  imageAlphaTextF.setValue( num );
  imageAlphaTextF.setValueLabel( theValue ); 
}

void blobToggle()
{
  detectBlobs = !detectBlobs; 
}

void thresholdText( String theValue )
{
   int num = int( theValue );
   controlP5.Controller thresholdF = controlP5.getController( "threshold" );
   thresholdF.setValue( num );
   thresholdF.setValueLabel( theValue );
}

void minAreaText( String theValue )
{
  int num = int( theValue );
  controlP5.Controller minAreaF = controlP5.getController( "minArea" );
  minAreaF.setValue (num );
  minAreaF.setValueLabel( theValue ); 
  detectBlobsSingleImage( currentFile );
}

void maxAreaText( String theValue )
{
  int num = int( theValue );
  controlP5.Controller maxAreaF = controlP5.getController( "maxArea" );
  maxAreaF.setValue (num );
  maxAreaF.setValueLabel( theValue ); 
  detectBlobsSingleImage( currentFile );
}

void maxBlobsText( String theValue )
{
  int num = int( theValue );
  controlP5.Controller maxBlobsF = controlP5.getController( "maxBlobs" );
  maxBlobsF.setValue (num );
  maxBlobsF.setValueLabel( theValue ); 
  detectBlobsSingleImage( currentFile );
}

void resetBlobs()
{
  threshold = 80;
  minArea = 100;
  maxArea = (width*height) / 3;
  maxBlobs = 20;
  findHoles = true;
  controlP5.getController( "threshold" ).setValue( threshold );
  controlP5.getController( "minArea" ).setValue( minArea );
  controlP5.getController( "maxArea" ).setValue( maxArea );
  controlP5.getController( "maxBlobs" ).setValue( maxBlobs );
  controlP5.getController( "findHoles" ).setValue( 1 );
}

void blobStrokeText( String theValue )
{
  if( theValue.contains( "," ) )
  {
    String[] colorString = split( theValue, "," );
    blobStroke =  color( int( colorString[0] ), int( colorString[1] ), int( colorString[2] ) );
  } 
  else 
  {
    blobStroke = color( int( theValue ) ); 
  } 
}

void blobFillText( String theValue )
{
  if( theValue.contains( "," ) )
  {
    String[] colorString = split( theValue, "," );
    blobFill =  color( int( colorString[0] ), int( colorString[1] ), int( colorString[2] ) );
  } 
  else 
  {
    blobFill = color( int( theValue ) ); 
  } 
}

void blobAlphaText( String theValue )
{
  int num = int( theValue );
  blobAlpha = num; 
}

void centrStrokeText( String theValue )
{
  if( theValue.contains( "," ) )
  {
    String[] colorString = split( theValue, "," );
    centrStroke =  color( int( colorString[0] ), int( colorString[1] ), int( colorString[2] ) );
  } 
  else 
  {
    centrStroke = color( int( theValue ) ); 
  } 
}

void centrAlphaText( String theValue )
{
  int num = int( theValue );
  centrAlpha = num; 
}


void textColorText( String theValue )
{
  if( theValue.contains( "," ) )
  {
    String[] colorString = split( theValue, "," );
    textColor =  color( int( colorString[0] ), int( colorString[1] ), int( colorString[2] ) );
  } 
  else 
  {
    textColor = color( int( theValue ) ); 
  } 
}

void centrSize( String theValue )
{
  int num = int( theValue );
  centrSize = num; 
}

void strokeSize( String theValue )
{
  int num = int( theValue );
  strokeSize = num; 
}

void centrTextSize( String theValue )
{
  int num = int( theValue );
  centrTextSize = num; 
}

public void stop() {
  opencv.stop();
  super.stop();
}

