int cp5_height = 18;
color cp5_group_bg_color = color(0,50);
DropdownList dlModes;
Toggle tgView3D;

// --------------------------------------------------
void initControls()
{
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);

  cp5.setColorLabel(0xffffffff);
  cp5.setColorValue(0xff000000);
  cp5.setColorForeground(0xffFDEB34);
  cp5.setColorBackground(0xff000000);
  cp5.setColorActive(0xffFDEB34);


  dlModes = cp5.addDropdownList("modes");
  dlModes.setBarHeight(cp5_height).setItemHeight(cp5_height).setPosition(0,cp5_height).setWidth(100);
  dlModes.captionLabel().style().marginTop = 6;

  Group groupGlobals = cp5.addGroup("Globals").setBackgroundHeight(320).setPosition(100+5,20).setBarHeight(20).setWidth(300).setBackgroundColor(cp5_group_bg_color);
  groupGlobals.captionLabel().style().marginTop = 6;
  
  cp5.begin(5,5);

  cp5.addButton("generate").setHeight(cp5_height).setGroup(groupGlobals);
  cp5.addButton("export").setHeight(cp5_height).setGroup(groupGlobals);
  cp5.addButton("exportPDF").setHeight(cp5_height).setGroup(groupGlobals).linebreak();
  cp5.addToggle("debug").setHeight(cp5_height).setValue(__DEBUG__).setGroup(groupGlobals).linebreak().captionLabel().setColor(0xff000000);

  cp5.addSlider("subdivide_factor_polygon_scale").setGroup(groupGlobals).setHeight(cp5_height).setRange(0.6f,4.0f).setValue(subdivide_factor_polygon_scale).setTriggerEvent(Slider.RELEASE).linebreak();
  cp5.addSlider("subdivide_depth_max").setGroup(groupGlobals).setHeight(cp5_height).setRange(1,10).setNumberOfTickMarks(10).setValue(subdivide_depth_max).setTriggerEvent(Slider.RELEASE).linebreak();
  cp5.addSlider("subdivide_random").setGroup(groupGlobals).setHeight(cp5_height).setRange(0.8,1.0).setValue(subdivide_random).setTriggerEvent(Slider.RELEASE).linebreak();

  cp5.addSlider("subdivide_draw_alpha").setGroup(groupGlobals).setHeight(cp5_height).setRange(0,255).setValue(subdivide_draw_alpha).linebreak();
  cp5.addToggle("subdivide_draw_stroke").setGroup(groupGlobals).setHeight(cp5_height).setValue(subdivide_draw_stroke).linebreak().captionLabel().setColor(0xff000000);
  cp5.addToggle("subdivide_draw_filled").setGroup(groupGlobals).setHeight(cp5_height).setValue(subdivide_draw_filled).linebreak().captionLabel().setColor(0xff000000);
  tgView3D = cp5.addToggle("view3D").setGroup(groupGlobals).setHeight(cp5_height).setValue(view3D);
  tgView3D.captionLabel().setColor(0xff000000);
  cp5.addToggle("view3D_normals").setGroup(groupGlobals).setHeight(cp5_height).setValue(view3D_normals).linebreak().captionLabel().setColor(0xff000000);
 // cp5.addSlide("view3D_height_max").setGroup(groupGlobals).setHeight(cp5_height).setValue(view3D_normals).linebreak().captionLabel().setColor(0xff000000);
  cp5.addSlider("view3D_circumference_min").setGroup(groupGlobals).setHeight(cp5_height).setRange(0,100).setValue(view3D_circumference_min).setTriggerEvent(Slider.RELEASE).linebreak();
  cp5.addButton("export3D").setHeight(cp5_height).setGroup(groupGlobals).linebreak();

  cp5.end();
}

//
void modes()
{
println("modes");
}

// --------------------------------------------------
void view3D()
{
  if (tgView3D!=null)
  {
    view3D = tgView3D.getValue()>0 ? true : false;
    if (modeCurrent!=null && view3D)
      modeCurrent.onSetDraw3D();
  }
}

// --------------------------------------------------
void export3D()
{
  if (modeCurrent!=null)
    modeCurrent.export3D();
}

// --------------------------------------------------
void updateControlsMode()
{
  int indexMode = 0;
  for (Mode mode : modes){
    dlModes.addItem(mode.name, indexMode++);
  }
}

// --------------------------------------------------
void controlEvent(ControlEvent theEvent) 
{
  if (theEvent.isGroup()) 
  {
    //println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
    String name = theEvent.getGroup().getName();  
    if (name.equals("modes"))
    {
      selectMode( (int)theEvent.getGroup().getValue() );
    }
  }
}

// --------------------------------------------------
void subdivide_factor_polygon_scale(float v)
{
  subdivide_factor_polygon_scale = v;
  if (modeCurrent!=null)
    modeCurrent.setPolygonScale(v);
}

// --------------------------------------------------
void debug(boolean is)
{
  __DEBUG__ = is;
}

// --------------------------------------------------
void subdivide_depth_max(float v)
{
  subdivide_depth_max = (int)v;
  if (modeCurrent!=null)
    modeCurrent.setSubdivideDepthMax();
}

// --------------------------------------------------
void subdivide_random(float v)
{
  subdivide_random = v;
  if (modeCurrent!=null)
    modeCurrent.setSubdivideRandom();
}


