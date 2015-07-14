class ModeGrid extends Mode
{
  ArrayList<Area> areas;
  ArrayList<Polygon2D> polygons;
  float margin = 10.0f;
  int resx = 1; //nb cells
  int resy = 1;

  // --------------------------------------------------
  ModeGrid(int resx_, int resy_)
  {
    this.name = "GRID";
    this.resx = resx_;
    this.resy = resy_;
  }

  void setPolygonScale(float f)
  {
    for (Area area : areas)
    {
      area.setPolygonScale(f);
    }
  }
  
  // --------------------------------------------------
  void setup()
  {
    generate();
  }

  // --------------------------------------------------
  void generate()
  {
    polygons = new ArrayList<Polygon2D>();
    float w = width - 2*margin;
    float h = height - 2*margin;
    float stepx = w/float(resx);
    float stepy = h/float(resy);

    float x=margin,y=margin;
    for (int j=0;j<resy;j++)
    {
      x = margin;
      for (int i=0;i<resx;i++)
      {
        Vec2D a = new Vec2D(x,y);
        Vec2D b = new Vec2D(x+stepx,y);
        Vec2D c = new Vec2D(x+stepx,y+stepy);
        Vec2D d = new Vec2D(x,y+stepy);
        
        Polygon2D polygon = new Polygon2D();
        polygon.add(a);
        polygon.add(b);
        polygon.add(c);
        polygon.add(d);
        
        polygons.add( polygon );
        x+=stepx;
      }  
      y+=stepy;
    }
    
    areas = new ArrayList<Area>();
    for (Polygon2D p : polygons)
    {
        Area area = new Area(p, 0);
        area.subdivide(0, subdivide_min, 0);

        areas.add( area );
    }
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
  void onSetDraw3D()
  {
    if (areas == null) return;

    // Create mesh    
    generate3D();
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
  void drawGrid()
  {
    for (Polygon2D p : polygons)
    {
      gfx.polygon2D(p);
    }    
  }

  // --------------------------------------------------
  void draw3D()
  {
    if (areas==null) return;

    pushMatrix();
    noFill();
    stroke(200, 0, 0);
    translate(-width/2, -height/2);
    drawGrid();    
    popMatrix();
    

    if (mesh!=null && meshGL!=null) 
    {

        GLGraphics renderer = (GLGraphics)applet.g;
        renderer.beginGL();
        renderer.gl.glDisable(GL.GL_LIGHTING);
        renderer.gl.glDisable(GL.GL_COLOR_MATERIAL);//        renderer.gl.glPolygonMode( GL.GL_FRONT_AND_BACK, GL.GL_FILL );
        meshGL.setTint(255,255,255,255);
        renderer.model(meshGL);

      
        meshGL.setTint(0,0,0,255);
        renderer.gl.glLineWidth(6.0f);
        renderer.gl.glPolygonMode( GL.GL_FRONT_AND_BACK, GL.GL_LINE );
        renderer.model(meshGL);

        renderer.gl.glPolygonMode( GL.GL_FRONT_AND_BACK, GL.GL_FILL );
        renderer.endGL();
    }

    
/*    fill(255);
    strokeWeight(2);
    stroke(0);
    if (mesh!=null) {
      if (view3D_normals)
        gfx.mesh(mesh, false, 15);
      else
        gfx.mesh(mesh);
    }
  }
*/
  }  

}
