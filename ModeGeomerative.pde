class ModeGeomerative extends ModeVoronoi
{
  RFont font;
  RShape shp;
  RPoint[] points;
  String text = "";
  String fontName = "";
  float segmentLength = 70;

  // --------------------------------------------------
  ModeGeomerative(String text_, String fontName_, int segmentLength_)
  {
    name = "Geomerative";
    cp5_prefix = "geomerative";
    text = text_;
    fontName = fontName_;    
    segmentLength = segmentLength_;
    println("segmentLength="+segmentLength);
  }

  // --------------------------------------------------
  void setup()
  {
    super.setup();
  }


  // --------------------------------------------------
  void initControls()
  {
    createControlsGroup();
    
    cp5.begin(5,5);
    cp5.addTextfield(cp5_prefix+"_text").setGroup(this.cp5Group).setAutoClear(false).setHeight(cp5_height).addListener(this).setPosition(5,5).setColorValue(0xffffffff);
    cp5.addSlider(cp5_prefix+"_segmentLength").setGroup(this.cp5Group).setHeight(cp5_height).addListener(this).setPosition(5,25).setRange(10,40).setValue(segmentLength);;
    cp5.end();
    createControls(38+20);
  }

  // --------------------------------------------------
  public void controlEvent(ControlEvent theEvent)
  {
    String name = theEvent.getController().getName();
    if (name.equals(cp5_prefix+"_text"))
    {
      this.text = theEvent.getController().getStringValue();
      this.distributePoints();
      this.areas = null;
      this.generate();
    }
    else if (name.equals(cp5_prefix+"_segmentLength"))
    {
      this.segmentLength = theEvent.getController().getValue();
      this.distributePoints();
      this.areas = null;
      this.generate();
    }
    else
    {
      super.controlEvent(theEvent);
    }
  }

  // --------------------------------------------------
  boolean filter(Polygon2D polygon_)
  {
    return (isOutside(polygon_) || isFlat(polygon_));
  }

  // --------------------------------------------------
  boolean isFlat(Polygon2D polygon_)
  {
    int nbVertices = polygon_.vertices.size();
    for (int i=0;i<nbVertices;i++){
      Vec2D A = polygon_.vertices.get(i);
      Vec2D B = polygon_.vertices.get((i+1)%nbVertices);
      Vec2D C = polygon_.vertices.get((i+2)%nbVertices);
      
      Vec2D BA = new Vec2D(A.x-B.x, A.y-B.y);
      Vec2D BC = new Vec2D(C.x-B.x, C.y-B.y);
    
      float angle = degrees( BC.angleBetween(BA,true) );
      // println(BA + "-" + BC + " / "+angle); 
      if (abs(angle) <= 2){
        return true;
      }
    }
    return false;
  }

  // --------------------------------------------------
  void distributePoints()
  {
    this.font = new RFont("fonts/"+fontName, 200, RFont.CENTER);
    // println("sL="+segmentLength);
    RCommand.setSegmentLength(segmentLength);
    RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

    shp = this.font.toShape(text);
    shp = RG.centerIn(shp, applet.g, 50);
    points = shp.getPoints();

    voronoi = new Voronoi();  
    for (int i=0; i<points.length; i++)
    {
      voronoi.addPoint( new Vec2D(points[i].x+width/2, points[i].y+height/2) );
    }
  }

  // --------------------------------------------------
  void draw()
  {
    super.draw();
  }

  // --------------------------------------------------
  void drawDebug()
  {
    pushMatrix();
      translate(width/2, height/2);
      noFill();
      stroke(200, 0, 0);
      for (int i=0;i<points.length;i++)
      {
        rect(points[i].x, points[i].y, 4, 4);
      }
    popMatrix();
    
    super.drawDebug();
  }
}

