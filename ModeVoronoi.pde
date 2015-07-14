class ModeVoronoi extends Mode
{
  Voronoi voronoi;
  UndirectedGraph graph;
  ArrayList<Area> areas;
  int modeDistribution = 1;
  Script scriptHeight;
  boolean useDelaunay = false;
  String cp5_prefix = "";
  Vec2D graphSelectedVertex=null;
  float graphSnapDist = 10;
  Path2D path;
  Path3D path3D;
  Path3DTraveller path3DTraveller;
  boolean isTraveller = false;
  boolean useOutsidePolygons = false;

  // --------------------------------------------------
  ModeVoronoi()
  {
    name = "GEOMETRY";
    cp5_prefix = "geom";
  }


  // --------------------------------------------------
  void createControls(float y)
  {
    cp5.addTextfield(cp5_prefix+"scriptHeight").setGroup(this.cp5Group).setAutoClear(false).setHeight(cp5_height).addListener(this).setPosition(5, y).setColorValue(0xffffffff);
    y = y+cp5_height+16;
    cp5.addToggle(cp5_prefix+"useDelaunay").setGroup(this.cp5Group).setPosition(5, y).setValue(useDelaunay).addListener(this);
    y = y+cp5_height+16;
    cp5.addButton(cp5_prefix+"SavePath").setLabel("Save Path").setGroup(this.cp5Group).setPosition(5, y).plugTo(this);
    y = y+cp5_height;
    cp5.addToggle(cp5_prefix+"NavigationPath").setLabel("Navigation").setGroup(this.cp5Group).setPosition(5, y).plugTo(this);
  }

  // --------------------------------------------------
  void initControls()
  {
    super.initControls();

    DropdownList dlModes = cp5.addDropdownList("modesShapes");
    dlModes.setBarHeight(cp5_height).setItemHeight(cp5_height).setPosition(5, 5+cp5_height).setWidth(100);
    dlModes.captionLabel().style().marginTop = 6;
    dlModes.setGroup(this.cp5Group);
    dlModes.addItem("RANDOM", 0);
    dlModes.addItem("CIRCLES", 1);
    dlModes.addItem("SPIRAL", 2);
    dlModes.addListener(this);

    createControls(25);
  }

  // --------------------------------------------------
  public void geomSavePath()
  {
    if (path!=null)
    {
      path.save("path.xml");
    }
  }

  // --------------------------------------------------
  public void geomNavigationPath(boolean is)
  {
    isTraveller = is;
  }

  // --------------------------------------------------
  public void controlEvent(ControlEvent theEvent)
  {
    String name = theEvent.getName();
    if (theEvent.isGroup())
    {
      if (name.equals("modesShapes"))
      {
        this.modeDistribution = (int)theEvent.getGroup().getValue();
        this.distributePoints();
        this.generate();
      }
    }
    else
      if (name.equals(cp5_prefix+"scriptHeight"))
      {
        String strScript = theEvent.getStringValue();
        scriptHeight = new Script(strScript);
        scriptHeight.parse();
      }
      else
        if (name.equals(cp5_prefix+"useDelaunay"))
        {
          useDelaunay = (theEvent.getValue()) == 1 ? true : false;
          areas = null;
          generate();
        }
  }


  // --------------------------------------------------
  void setup()
  {
    distributePoints();
    generate();
    loadPath();
  }

  // --------------------------------------------------
  void loadPath()
  {
    path = new Path2D();
    if (path.load("path.xml"))
    {
      path3D = new Path3D(path);
      path3DTraveller = new Path3DTraveller(path3D);
    }
  }


  // --------------------------------------------------
  void mouseMoved()
  {
    graphSelectedVertex = null;
    if (graph!=null)
    {
      Vec2D mousePos=new Vec2D(mouseX, mouseY);
      for (Vec2D v : graph.getVertices()) 
      {
        if (mousePos.distanceToSquared(v) < graphSnapDist) {
          graphSelectedVertex=v;
          break;
        }
      }
    }
  }

  // --------------------------------------------------
  void mousePressed()
  {
    if (path!=null && graphSelectedVertex!=null)
    {
      path.add( new Vec2D(graphSelectedVertex.x, graphSelectedVertex.y) );
      path3D = new Path3D(path);
      path3DTraveller = new Path3DTraveller(path3D);
    }
  }  
  // --------------------------------------------------
  void distributePoints()
  {
    voronoi = new Voronoi();  

    // >>> RANDOM
    if (modeDistribution == 0)
    {
      for ( int i = 0; i < voronoi_nb_points; i++ ) {
        voronoi.addPoint( new Vec2D( random(width), random(height) ) );
      }
    }
    // >>> CIRCLES
    else if (modeDistribution == 1)
    {
      voronoi.addPoint( new Vec2D(width/2, height/2) );
      float angle=0.0f;
      float r = 1.0f;
      for ( int i = 0; i < voronoi_nb_points; i++ ) 
      {
        angle = float(i)/float(voronoi_nb_points)*TWO_PI;
        r = random(0.8, 1)*0.3*min(width, height);
        for (int j=0 ;j<10 ; j++)
        {
          voronoi.addPoint( new Vec2D( width/2+map(j, 0, 10, 1, 2)*random(1.1, 1.5)*r*cos(angle), height/2+map(j, 0, 10, 1, 2)*random(1.1, 1.5)*r*sin(angle) ) );
          //voronoi.addPoint( new Vec2D( width/2+random(1.1, 1.5)*r*cos(angle), height/2+random(1.1, 1.5)*r*sin(angle) ) );
        }
      }
    }
    // >>> SPIRALES
    else if (modeDistribution == 2)
    {
      voronoi.addPoint( new Vec2D(width/2, height/2) );
      float angle=0.0f;
      float r = 1.0f;
      for ( int i = 0; i < voronoi_nb_points; i++ ) 
      {
        angle = float(i)/float(voronoi_nb_points)*TWO_PI;
        r = random(0.8, 1)*0.5*map(angle, 0, TWO_PI, 0, 1)*min(width, height);
        voronoi.addPoint( new Vec2D( width/2+r*cos(angle), height/2+r*sin(angle) ) );
        //  voronoi.addPoint( new Vec2D( width/2+random(1.1,1.5)*r*cos(angle), height/2+random(1.1,1.5)*r*sin(angle) ) );
      }
    }
  }

  // --------------------------------------------------
  void setPolygonScale(float f)
  {
    for (Area area : areas)
    {
      area.setPolygonScale(f);
    }
  }

  // --------------------------------------------------
  void update()
  {
    if (view3D)
    {
      if (path3DTraveller != null && isTraveller) 
        path3DTraveller.update();
    }
  }

  // --------------------------------------------------
  void beginDraw3D()
  {
    if (path3DTraveller != null && isTraveller) 
    {
      hint(ENABLE_DEPTH_TEST);
      path3DTraveller.doCamera();
    }
    else
    {
      beginCamera();
      camera(0, 0, zView3D, 0, 0, 0, 0, -1, 0);
      endCamera();
      super.beginDraw3D();
    }
  }


  // --------------------------------------------------
  void endDraw3D()
  {
    if (!isTraveller)
      super.endDraw3D();

    beginCamera();
    camera();
    endCamera();
  }

  // --------------------------------------------------
  void draw()
  {
    if (areas == null) return;
    for (Area area : areas)
    {
      area.draw();
    }
  }

  // --------------------------------------------------
  void onSetDraw3D()
  {
    if (voronoi == null) return;
    if (areas == null) return;

    // Create mesh    
    generate3D();
  }

  // --------------------------------------------------
  void generate3D()
  {
    mesh = new TriangleMesh();
    for (Area area : areas)
    {
      area.addFacesToMesh(mesh);
    }
    meshGL = convertGLModel(mesh);
  }

  // --------------------------------------------------
  void export3D()
  {
    if (mesh !=null)
    {
      try {
        String now = timestamp();
        String fileID="export_"+now;
        FileOutputStream fs;
        fs=new FileOutputStream(sketchPath("exports/3d/"+fileID+".stl"));
        mesh.saveAsSTL(fs);
        fs=new FileOutputStream(sketchPath("exports/3d/"+fileID+".obj"));
        mesh.saveAsOBJ(fs);
      }
      catch(Exception e) {
        e.printStackTrace();
      }
    }
  }

  // --------------------------------------------------
  void draw3D()
  {
    if (voronoi == null) return;

    pushMatrix();
    noFill();
    stroke(200, 0, 0);
    translate(-width/2, 0, -height/2);
    rotateX(PI/2);

    if (useDelaunay)
    {
      for (Triangle2D t : voronoi.getTriangles())
      {
        gfx.triangle(t);
      }
    }
    else
    {
      for (Polygon2D region : voronoi.getRegions())
      {
        gfx.polygon2D(region);
      }
    }
    popMatrix();

    if (__DEBUG__)
    {
      noFill();
      stroke(0, 200, 0);
      ellipse(0, 0, view3D_diagonal, view3D_diagonal);
    }

    if (mesh!=null) {

      if (meshGL!=null)
      {
        GLGraphics renderer = (GLGraphics)applet.g;
        renderer.beginGL();
        renderer.gl.glDisable(GL.GL_LIGHTING);
        renderer.gl.glDisable(GL.GL_COLOR_MATERIAL);//        renderer.gl.glPolygonMode( GL.GL_FRONT_AND_BACK, GL.GL_FILL );
        meshGL.setTint(255, 255, 255, 255);
        renderer.model(meshGL);


        meshGL.setTint(0, 0, 0, 255);
        renderer.gl.glLineWidth(6.0f);
        renderer.gl.glPolygonMode( GL.GL_FRONT_AND_BACK, GL.GL_LINE );
        renderer.model(meshGL);

        renderer.gl.glPolygonMode( GL.GL_FRONT_AND_BACK, GL.GL_FILL );
        renderer.endGL();
      }
    }

    if (path3D !=null)
    {
      stroke(0, 200, 0);
      path3D.draw();
    }
  }

  // --------------------------------------------------
  void drawDebug()
  {
    noFill();
    stroke(200, 0, 0);
    if (voronoi != null)
    {
      if (useDelaunay)
      {
        for (Triangle2D t : voronoi.getTriangles())
        {
          gfx.triangle(t);
        }
      }
      else
      {
        for (Polygon2D region : voronoi.getRegions())
        {
          gfx.polygon2D(region);
        }
      }
    }
    if (graphSelectedVertex!=null)
    {
      stroke(0, 200, 0);
      ellipse(graphSelectedVertex.x, graphSelectedVertex.y, graphSnapDist, graphSnapDist);
    }

    if (path != null)
    {
      stroke(0, 200, 0);
      path.draw();
    }
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
  boolean isOutside(Polygon2D p_)
  {
    if (useOutsidePolygons) return false;
    
    boolean is = false;
    for (Vec2D v:p_.vertices) {
      if (v.x<0 || v.x>width || v.y<0 || v.y>height) return true;
    }

    return is;
  }

  // --------------------------------------------------
  boolean filter(Polygon2D polygon_)
  {
    return isOutside(polygon_);
  }
  
  // --------------------------------------------------
  void generate()
  {
    graph = null;
    path = null;
    path3D = null;

    if (areas == null)
    {
      areas = new ArrayList<Area>();

      // DELAUNAY
      if (useDelaunay)
      {
        for ( Triangle2D t : voronoi.getTriangles() ) 
        {
          Polygon2D polygon = new Polygon2D();
          polygon.add(t.a);
          polygon.add(t.b);
          polygon.add(t.c);

          if (!filter(polygon))
          {
            Area area = new Area(polygon, 0);
            //area.subdivide(0, subdivide_min, 0);

            areas.add( area );
          }
        }
      }
      // VORONOI
      else
      {
        if (subdivide_voronoi_compute_graph)
        {
          graph=new UndirectedGraph();
          path = new Path2D();
        }

        for ( Polygon2D polygon : voronoi.getRegions() ) 
        {
          if (!filter(polygon))
          {
            Area area = new Area(polygon, 0);
            //area.subdivide(0, subdivide_min, 0);

            areas.add( area );

            /*            if (subdivide_voronoi_compute_graph)
             {
             for (int i=0,num=polygon.vertices.size(); i<num; i++) 
             {
             graph.addEdge(polygon.vertices.get(i), polygon.vertices.get((i+1)%num));
             }
             }
             */
          }
        }
      }
    }

    if (areas != null)
    {
      for (Area area : areas)
        area.subdivide(0, subdivide_min, 0);
    }
    
    
  }
}

