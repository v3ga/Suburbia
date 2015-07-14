// http://forum.processing.org/one/topic/toxiclib-voronoi-example-sketch.html


// --------------------------------------------------
import java.io.*;
import java.util.*;
import java.lang.reflect.*;
import java.awt.event.*;
import processing.opengl.*;
import processing.pdf.*;
import controlP5.*;
import geomerative.*;
import toxi.geom.mesh.TriangleMesh;
import toxi.geom.mesh2d.*;
import toxi.geom.*;
import toxi.geom.Line2D;
import toxi.geom.Polygon2D;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import toxi.processing.*;
import toxi.math.*;
import codeanticode.glgraphics.*;
import javax.media.opengl.*;


// --------------------------------------------------
ToxiclibsSupport gfx;
Mode modeCurrent = null;
ArrayList<Mode> modes;
PApplet applet;
ControlP5 cp5;
ArcBall arcball;
float zView3D=-300, zView3DTarget=-300, zView3DDir=1;

// --------------------------------------------------
boolean __DEBUG__ = true;
boolean doSaveframe = false;
boolean doSavePDF = false;
boolean view3D = false;
boolean view3D_normals = false;
float view3D_height_min = 50;
float view3D_height_max = 150;
float view3D_circumference_min = 50.0;
float subdivide_min = 200.0; // if subdivide_use_circumference = true
float view3D_diagonal = 1.0f;
int subdivide_depth_max = 10;
boolean subdivide_use_circumference = false;
float subdivide_angle_normal = PI/10;
float subdivide_random = 0.9;
float[] subdivide_segment_f = {
  0.2, 0.8
};
boolean subdivide_use_polygon_scale = true;
float subdivide_factor_polygon_scale = 0.90;
boolean subdivide_draw_filled = false;
boolean subdivide_draw_stroke = true;
float subdivide_draw_alpha = 100;
boolean subdivide_voronoi_compute_graph = true;
int voronoi_nb_points = 100;


// --------------------------------------------------
void setup()
{
/*  gScriptHeight = new Script("$h = 0.4*exp(0-($d*$d)/2)*10");
  gScriptHeight.parse();
  gScriptHeight.storeVariable("$d", 2);
if (gScriptHeight.isParsed())
{
          gScriptHeight.evaluate();
float          h = gScriptHeight.getVariable("$h").toFloat();
println(h);
} 
  */
  
  size(1024, 768 , GLConstants.GLGRAPHICS);  
  smooth();
  rectMode(CENTER);
  frame.addMouseWheelListener(new MouseWheelInput()); 
  gfx = new ToxiclibsSupport( this );
  RG.init(this);
  applet=(PApplet)this;
  arcball = new ArcBall(applet);

  initControls();

  modes = new ArrayList<Mode>();
  modes.add( new ModeVoronoi() );
  // modes.add( new ModePolygonClick() );
  modes.add( new ModeGeomerative("SUB", "Futura.ttf", 25) );
  modes.add( new ModeVoronoiCluster(15, 10, 20) );
  modes.add( new ModeGrid(20,20) );
  modes.add( new ModeOpenTypes("Futura.ttf", 100) );
//  modes.add( new ModeEchoNoiseNoise());

  for (Mode mode : modes) {
    mode.initControls();
  }
  updateControlsMode();

  selectMode(2);
}

// --------------------------------------------------
void generate()
{
  if (modeCurrent!=null)
    modeCurrent.generate();
}

// --------------------------------------------------
void export()
{
  doSaveframe = true;
}

// --------------------------------------------------
void exportPDF()
{
  doSavePDF = true;
}

// --------------------------------------------------
void selectMode(int which)
{
  if (which < modes.size())
  {
    Mode modeSelected = modes.get(which);
    if (modeCurrent == null || (modeCurrent != null && modeCurrent != modeSelected))
    {
      if (modeCurrent !=null)
      {
        modeCurrent.showControls(false);
      }

      modeCurrent = modeSelected;
      modeCurrent.setup();
      modeCurrent.showControls(true);

      println("selecting "+modeCurrent.name);
    }
  }
}

// --------------------------------------------------
void draw()
{
  if (modeCurrent!=null)
    modeCurrent.update();


  if (doSavePDF && !view3D) {
    beginRecord(PDF, "exports/pdf/export_"+timestamp()+".pdf"); // not working with ToxicLibsGFX
  }

  if (modeCurrent!=null) 
  {
    view3D_diagonal = sqrt(width*width + height*height); // TODO : move this elsewhere
    if (view3D)
    {
      background(255);
      modeCurrent.beginDraw3D();
      modeCurrent.draw3D();
      modeCurrent.endDraw3D();
    }
    else
    {
      if (modeCurrent.isDrawBackground()) 
        background(255);
      modeCurrent.draw();
    }

    if (doSavePDF && !view3D) {
      endRecord();
      doSavePDF = false;
    }

    if (doSaveframe) {
      saveFrame("exports/img/export_"+timestamp()+".png");
      doSaveframe = false;
    }

    if (modeCurrent!=null && __DEBUG__ && !view3D) 
      modeCurrent.drawDebug();

    if (view3D){
      hint(DISABLE_DEPTH_TEST);
    }

    cp5.draw();
  }
}

// --------------------------------------------------
void mouseMoved()
{
  if (cp5.window(this).isMouseOver()) return;
  if (modeCurrent!=null)
  {
    modeCurrent.mouseMoved();
  }
}

// --------------------------------------------------
void mousePressed()
{
  if (cp5.window(this).isMouseOver()) return;

  if (modeCurrent!=null)
  {
    modeCurrent.mousePressed();
    if (view3D) {
      arcball.mousePressed();
    }
  }
}

// --------------------------------------------------
void mouseDragged()
{
  if (cp5.window(this).isMouseOver()) return;

  if (view3D) {
    arcball.mouseDragged();
  }
}

// --------------------------------------------------
void mouseReleased()
{
  if (cp5.window(this).isMouseOver()) return;
  
  if (view3D) {
    arcball.mouseReleased();
  }
}

// --------------------------------------------------
void keyPressed()
{
    if (modeCurrent!=null) 
      modeCurrent.keyPressed();
}

// --------------------------------------------------
void keyNavigation()
{
  if (keyPressed) 
  {
    if (keyCode == UP)
    {
       zView3DTarget += 10;
       
    }
    else
    if (keyCode == DOWN)
    {
       zView3DTarget -= 10;
    } 
    zView3DTarget = constrain(zView3DTarget, -1000,200);
  }

   zView3D += (zView3DTarget-zView3D)*0.3;
}

