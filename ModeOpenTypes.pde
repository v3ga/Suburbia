class ModeOpenTypes extends ModeGeomerative
{
  Area areaOver;

  // --------------------------------------------------
  ModeOpenTypes(String fontName_, int segmentLength_)
  {
    super("E", fontName_, segmentLength_);
    this.name = "OpenTypes";
    this.cp5_prefix = "ot";
  }

  // --------------------------------------------------
  void mouseMoved()
  {
    areaOver = null;
    Vec2D m = new Vec2D(mouseX, mouseY);   

    for (Area area : areas) 
    {
      boolean is = area.isPointInPolygon(m);
      if (is) {
        areaOver = area;
        break;
      }
    }
  }

  // --------------------------------------------------
  void mousePressed()
  {
    if (areaOver != null)
    {
      if ((areaOver.flag & Area.flag_CLICKED) > 0) 
      {
        areaOver.flag &= ~Area.flag_CLICKED;
        areaOver.setCallback( null );
      }
      else
      {
        areaOver.flag |= Area.flag_CLICKED;
        areaOver.setCallback( new CallBack(this,"onAreaSubdivide") );
      }
    }
  }

  // --------------------------------------------------
  void onAreaSubdivide(Area area_)
  {
    if (area_!=null)
    {
      if ((area_.flag & Area.flag_CLICKED) > 0) 
       area_.canSubdivide = false;
      else  
       area_.canSubdivide = true;
    }
  }

  // --------------------------------------------------
  void drawDebug()
  {
    super.drawDebug();

    pushStyle();
    strokeWeight(3);
    stroke(0, 200, 0);
    noFill();

    for (Area area : areas) 
    {
      if ( (area.flag & Area.flag_CLICKED)>0)
      {
        gfx.polygon2D(area.polygon2D);
      }
    }

    if (areaOver!=null)
    {
      gfx.polygon2D(areaOver.polygon2D);
    }

    popStyle();
  }
}

