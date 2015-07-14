class ModePolygonClick extends Mode
{
  Polygon2D polygon;
  Area area;
  

  // --------------------------------------------------
  ModePolygonClick()
  {
    name = "PolygonClick";    
  }
  
  // --------------------------------------------------
  void setup()
  {
    polygon = new Polygon2D();
  }
  
  // --------------------------------------------------
  void draw()
  {
    if (area!=null)
    {
      stroke(0);
      //strokeWeight(2);
      //gfx.polygon2D(area.polygon2D);
      strokeWeight(1);
      area.draw();
    }
  }

  // --------------------------------------------------
  void generate()
  {
      area = new Area(polygon,0);
      area.subdivide(0,subdivide_min,0);
  }
  
  // --------------------------------------------------
  void keyPressed()
  {
    if (key == ' ')
    {
      generate();
    }
  }

  
  // --------------------------------------------------
  void mousePressed()
  {
    polygon.add( new Vec2D(mouseX,mouseY) );
  }
}
