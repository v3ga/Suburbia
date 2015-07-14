int depth_max = 0;
Script gScriptHeight=null;

class Area
{

  Polygon2D polygon2D, polygon2D_scale;
  Polygon2D polygon2D_1, polygon2D_2;
  Area area1 = null, area2 = null;
  Vec2D M, MM, N, G;
  int d;
  float h; // for drawing 3D
  int flag = 0;
  final static int flag_CLICKED = 0x01;
  CallBack cbSubdivide = null;
  boolean canSubdivide = true;

  // --------------------------------------------------
  Area(Polygon2D polygon2D_, int d_)
  {
    this.polygon2D = polygon2D_;
    this.G = polygon2D.getCentroid();
    this.d = d_;
    this.h = random(view3D_height_min, view3D_height_max);
  }

  // --------------------------------------------------
  void setCallback(CallBack cb_)
  {
    this.cbSubdivide = cb_;
  }

  // --------------------------------------------------
  void setFlag(int flag)
  {
    this.flag = flag;
  }

  // --------------------------------------------------
  void setScriptHeight(String s)
  {
    if (gScriptHeight == null)
    {
      gScriptHeight = new Script(s);
      gScriptHeight.parse();
      //println(gScriptHeight);
    }
  }

  // --------------------------------------------------
  void drawPolygon2D(PGraphics pg, Polygon2D polygon)
  {
    pg.beginShape();
    for (Vec2D v : polygon.vertices) {
      pg.vertex(v.x, v.y);
    }
    pg.endShape(CLOSE);
  }
  
  // --------------------------------------------------
  void drawPolygon2D(Polygon2D polygon)
  {
    beginShape();
    for (Vec2D v : polygon.vertices) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
  }

  // --------------------------------------------------
  void drawPolygon3D(Polygon2D polygon)
  {
    int nbPoints = polygon.vertices.size();
    Vec2D A, B;

    drawPolygon2D(polygon);

    beginShape(QUADS);
    for (int i=0;i<nbPoints;i++)
    {
      A = polygon.vertices.get(i);
      B = polygon.vertices.get((i+1)%nbPoints);

      vertex(A.x, A.y, 0);
      vertex(B.x, B.y, 0);
      vertex(B.x, B.y, h);
      vertex(A.x, A.y, h);
    }
    endShape();


    pushMatrix();
    translate(0, 0, h);
    drawPolygon2D(polygon);
    popMatrix();
  }

  // --------------------------------------------------
  void draw(PGraphics pg)
  {
    if (subdivide_draw_stroke)
    {
      pg.noFill();
      pg.stroke(0, subdivide_draw_alpha);
    }
    if (subdivide_draw_filled)
    {
      pg.fill(0, subdivide_draw_alpha);
    }

    if (area1 == null && area2 == null)
    {
      if (polygon2D_scale != null && subdivide_use_polygon_scale)
        drawPolygon2D(pg, polygon2D_scale);
      //gfx.polygon2D( polygon2D_scale );
    }
    else
    {
      if (area1 !=null) area1.draw(pg);
      if (area2 !=null) area2.draw(pg);
    }
  
  }

  // --------------------------------------------------
  void draw()
  {
    if (subdivide_draw_stroke)
    {
      noFill();
      stroke(0, subdivide_draw_alpha);
    }
    if (subdivide_draw_filled)
    {
      fill(0, subdivide_draw_alpha);
    }

    if (area1 == null && area2 == null)
    {
      if (polygon2D_scale != null && subdivide_use_polygon_scale)
        drawPolygon2D(polygon2D_scale);
      //gfx.polygon2D( polygon2D_scale );
    }
    else
    {
      if (area1 !=null) area1.draw();
      if (area2 !=null) area2.draw();
    }
  }

  // --------------------------------------------------
  void draw3D()
  {
    if (area1 == null && area2 == null)
    {
      if (polygon2D_scale != null && subdivide_use_polygon_scale)
      {
        stroke(0);
        strokeWeight(2);
        fill(255);
        drawPolygon3D(polygon2D_scale);
      }
    }
    else
    {
      if (area1 !=null) area1.draw3D();
      if (area2 !=null) area2.draw3D();
    }
  }

  // --------------------------------------------------
  void addFacesToMesh(TriangleMesh mesh_)
  {
    if (area1 == null && area2 == null)
    {
      if (polygon2D_scale != null && subdivide_use_polygon_scale && polygon2D_scale.getCircumference()>=view3D_circumference_min)
      {
        TriangleMesh areaMesh = new TriangleMesh();

        // TODO : really necessary ? 
        if (polygon2D_scale.isClockwise())
          polygon2D_scale.reverseOrientation();

        // Centroid
        Vec2D G = polygon2D_scale.getCentroid();

        // Height
        if (gScriptHeight !=null && gScriptHeight.isParsed())
        {          
          float d = (new Vec3D(G.x-width/2, G.y-height/2, 0)).magnitude()/(0.5*view3D_diagonal);
          d = map(d, 0, 1, 0, 3);
          gScriptHeight.storeVariable("$d", d);
          gScriptHeight.evaluate();
          h = gScriptHeight.getVariable("$h").toFloat();
          //println("d="+d+";h="+h);
        }
        else
        {
          h = random(view3D_height_min, view3D_height_max);
        }

        // Centroid bottom + top
        Vec3D Gbottom = new Vec3D(G.x-width/2, 0, G.y-height/2);
        Vec3D Gtop = new Vec3D(G.x-width/2, h, G.y-height/2);

        // Generate triangles
        int nbPoints = polygon2D.getNumPoints();
        for (int i=0; i<nbPoints; i++)
        {
          Vec2D A = polygon2D_scale.vertices.get(i);
          Vec2D B = polygon2D_scale.vertices.get((i+1)%nbPoints);

          Vec3D a = new Vec3D(A.x-width/2, 0, A.y-height/2);
          Vec3D b = new Vec3D(B.x-width/2, 0, B.y-height/2);
          Vec3D c = new Vec3D(B.x-width/2, h, B.y-height/2);
          Vec3D d = new Vec3D(A.x-width/2, h, A.y-height/2);

          /*
          Vec3D a = new Vec3D(A.x-width/2,A.y-height/2,0);
           Vec3D b = new Vec3D(B.x-width/2,B.y-height/2,0);
           Vec3D c = new Vec3D(B.x-width/2,B.y-height/2,h);
           Vec3D d = new Vec3D(A.x-width/2,A.y-height/2,h);
           */

          areaMesh.addFace(Gbottom, b, a);
          areaMesh.addFace(Gtop, c, d);
          areaMesh.addFace(a, c, b);
          areaMesh.addFace(a, c, d);
        }

        areaMesh.computeFaceNormals();
        areaMesh.computeVertexNormals();
        areaMesh.faceOutwards();
        mesh_.addMesh(areaMesh);
      }
    }
    else
    {
      if (area1 !=null) area1.addFacesToMesh(mesh_);
      if (area2 !=null) area2.addFacesToMesh(mesh_);
    }
  }

  // --------------------------------------------------
  Polygon2D copyPolygon2D(Polygon2D p_)
  {
    Polygon2D p = new Polygon2D();
    for (Vec2D v : p_.vertices) {
      p.add(new Vec2D(v.x, v.y));
    }
    return p;
  }

  // --------------------------------------------------
  // Subidvision en donnant un index de vertex du polygon
  // Génère deux polygon enfant 
  void subdivide(int indexA, float circumferenceMin, int depth)
  {

    int nbPoints = this.polygon2D.getNumPoints();
    int indexA_ = indexA%nbPoints;
    int indexB_ = (indexA+1)%nbPoints;
    if (indexB_<indexA_) {
      int tmp = indexA_;
      indexA_ = indexB_;
      indexB_ = tmp;
    }

    Vec2D A = polygon2D.vertices.get(indexA_);
    Vec2D B = polygon2D.vertices.get(indexB_);

    // Find normal relative to edge that points inside the polygon
    Vec2D AB = (new Vec2D(B)).subSelf(A);
    this.N = AB.perpendicular().normalize();
    if (polygon2D.isClockwise()) N = N.getInverted();
    N = N.rotate(random(-subdivide_angle_normal, subdivide_angle_normal));

    // Point from which we subdivide    
    float f = random(subdivide_segment_f[0], subdivide_segment_f[1]);
    this.M = new Vec2D(A.x+f*(B.x-A.x), A.y+f*(B.y-A.y));

    // throw a ray for intersection along the normal N from point M    
    Line2D lineSplit = new Line2D(M, M.add(N.scale(10000)));

    // Find intersection with other edge
    int indexAA=0, indexBB=0;
    for (int i=0; i<nbPoints ; i++)
    {
      if ( i!= indexA_)
      { 
        indexAA = i;
        indexBB = (i+1)%nbPoints;

        Vec2D AA = polygon2D.vertices.get(indexAA);
        Vec2D BB = polygon2D.vertices.get(indexBB);

        Line2D edge = new Line2D(AA, BB);
        Line2D.LineIntersection isec=lineSplit.intersectLine(edge);
        if (isec.getType()==Line2D.LineIntersection.Type.INTERSECTING) 
        {
          this.MM = isec.getPos();

          // >>> Polygon1
          this.polygon2D_1 = new Polygon2D();
          this.polygon2D_1.add(M);
          int indexP1 = indexB_; 
          while (indexP1!=indexAA)
          {
            this.polygon2D_1.add( polygon2D.vertices.get(indexP1) );
            indexP1=(indexP1+1)%nbPoints;
          }
          this.polygon2D_1.add(AA);
          this.polygon2D_1.add(MM);

          // >>> Polygon2
          this.polygon2D_2 = new Polygon2D();
          this.polygon2D_2.add(MM);
          int indexP2 = indexBB; 
          while (indexP2!=indexA_)
          {
            this.polygon2D_2.add( polygon2D.vertices.get(indexP2) );
            indexP2=(indexP2+1)%nbPoints;
          }
          this.polygon2D_2.add(A);
          this.polygon2D_2.add(M);

          break;
        }
      }
    }


    try {
      canSubdivide = true;
      if (cbSubdivide != null)
      {
        cbSubdivide.invoke(this); // will position canSubdivide
      }
      
      if (canSubdivide)
      {
        if (this.polygon2D_1!=null && depth<subdivide_depth_max && (random(1)<subdivide_random)) 
        {
          subdivideArea(0, circumferenceMin, depth);
        }    
        if (this.polygon2D_2!=null && depth<subdivide_depth_max && (random(1)<subdivide_random)) 
        {
          subdivideArea(1, circumferenceMin, depth);
        }
      }
      else
      {
        println("here");
        polygon2D_scale = null;
        polygon2D_1 = null;
        polygon2D_2 = null;
        area1 = null;
        area2 = null;
      }
    } 
    catch (Exception e) {
      println(e);
    }
  }

  // --------------------------------------------------
  void subdivideArea(int which, float circumferenceMin, int depth) {
    if (which == 0)
    {
      area1 = new Area(polygon2D_1, depth);
      area1.subdivide((int)random(0, this.polygon2D_1.getNumPoints()-1), circumferenceMin, ++depth);
      area1.copyAndScale(subdivide_factor_polygon_scale);
    }
    else
    {
      area2 = new Area(polygon2D_2, depth);
      area2.subdivide((int)random(0, this.polygon2D_2.getNumPoints()-1), circumferenceMin, ++depth);
      area2.copyAndScale(subdivide_factor_polygon_scale);
    }
  }

  // --------------------------------------------------
  void setPolygonScale(float f)
  {
    if (area1 == null && area2 == null)
    {
      copyAndScale(f);
    }

    if (area1 != null) area1.setPolygonScale(f);
    if (area2 != null) area2.setPolygonScale(f);
  }

  // --------------------------------------------------
  void copyAndScale(float f)
  {
    this.polygon2D_scale = copyPolygon2D(polygon2D);
    this.scalePolygon2D(f);
  }

  // --------------------------------------------------
  void scalePolygon2D(float f)
  {
    int nbPoints = this.polygon2D_scale.getNumPoints();
    for (int i=0; i<nbPoints ; i++)
    {
      Vec2D V = polygon2D_scale.vertices.get(i);    
      Vec2D GV = (new Vec2D(V)).subSelf(G); 
      GV.scaleSelf(f);
      V.set(G.x+GV.x, G.y+GV.y);
    }
  }

  // --------------------------------------------------
  boolean isPointInPolygon(Vec2D p)
  {
    if (polygon2D!=null)
    {
      return polygon2D.containsPoint(p);
    }
    return false;
  }
}

