class Path2D
{
  ArrayList<Vec2D> points = new ArrayList<Vec2D>();

  // --------------------------------------------------
  void add(Vec2D p) {
    points.add(p);
  }

  // --------------------------------------------------
  void draw()
  {
    Vec2D A, B;
    for (int i=0, nb=points.size()-1; i<nb ; i++)
    {
      A = points.get(i);
      B = points.get(i+1);
      line(A.x, A.y, B.x, B.y);
    }
  }

  // --------------------------------------------------
  boolean load(String filename)
  {
    XMLElement xml = new XMLElement(applet, "paths/"+filename);
    if (xml == null) return false;

    int nbPoints = xml.getChildCount();
    if (nbPoints>0)
    {
      points = new ArrayList<Vec2D>();
      for (int i=0;i<nbPoints;i++)
      {
        XMLElement v = xml.getChild(i);
        points.add( new Vec2D(v.getFloat("x"), v.getFloat("y")) );
      }
      return true;
    }

    return false;
  }

  // --------------------------------------------------
  void save(String filename)
  {
    String s = "<path>\n";
    int nbPoints = points.size();
    for (int i=0;i<nbPoints;i++)
    {
      Vec2D v = points.get(i);
      s+="\t<v x=\""+v.x+"\" y=\""+v.y+"\" />\n";
    }
    s += "</path>\n";
    saveStrings("data/paths"+filename, new String[] {
      s
    }
    );
  }
}


class Path3D extends Spline3D
{
//  List<Vec3D> vertices;
  float arcLen = 0.0f;
  Vec3D T, B, N;

  // --------------------------------------------------
  Path3D(Path2D path2D)
  {
    if (path2D.points.size()>2)
    {
      for (Vec2D p : path2D.points) 
      {
        this.add( new Vec3D(p.x-width/2, random(4.4*view3D_height_max, 4.5*view3D_height_max), p.y-height/2  ));
      }

      this.getDecimatedVertices(10, true);
      this.arcLen = getEstimatedArcLength();
    }
  }

  // --------------------------------------------------
  Vec3D getVertex(float t)
  {
    Vec3D v = new Vec3D();

    float len = t*arcLen;
    for (int i=0; i<arcLenIndex.length-1; i++)
    {
      if (arcLenIndex[i] <= len && len <arcLenIndex[i+1])
      {
        float delta = len-arcLenIndex[i];
        float frac = delta / (arcLenIndex[i+1]-arcLenIndex[i]);
        Vec3D vi = vertices.get(i);
        Vec3D vi1 = vertices.get(i+1);
        v.set( lerp(vi.x, vi1.x, frac), lerp(vi.y, vi1.y, frac), lerp(vi.z, vi1.z, frac) );
        break;
      }
    }
    return v;
  }

  // --------------------------------------------------
  Matrix4x4 getOrientation(float t)
  {
    float tstep = 0.0025;
    if (t+tstep>1.0f)
      t = 1.0-tstep;
    Vec3D v0 = getVertex(t);
    Vec3D v1 = getVertex(t+tstep);
    this.T = v1.sub(v0);
    this.N = new Vec3D(v0.x+v1.x, v0.y+v1.y, v0.z+v1.z);
    this.B = T.cross(N);
    N = B.cross(T);

    N.normalize();
    B.normalize();
    T.normalize();

    Matrix4x4 m = new Matrix4x4();
    m.set(
    N.x, B.x, T.x, 0.0, 
    N.y, B.y, T.y, 0.0, 
    N.z, B.z, T.z, 0.0, 
    0.0, 0.0, 0.0, 1.0);


    return m;
  }


  // --------------------------------------------------
  void draw()
  {
    if (vertices == null) return;

    Vec3D A, B;
    for (int i=0, nb=vertices.size(); i<nb-1 ; i++)
    {
      A = vertices.get(i);
      B = vertices.get(i+1);
      line(A.x, A.y, A.z, B.x, B.y, B.z);
    }
  }
}

class Path3DTraveller
{
  Vec3D pos = new Vec3D();
  Matrix4x4 orientation;
//  float[] orientation = new float[16];
  float speed = 0.0005;
  float t = 0.0f;
  Path3D path;

  Path3DTraveller(Path3D path_)
  {
    this.path = path_;
  }


  void update()
  {
    t += speed;
    if (t>=1.0f) t=0.0f;

    pos = path.getVertex(t);
    orientation = path.getOrientation(t);
  }


  void doCamera()
  {
    beginCamera();
    float c = 20.0f;
    Vec3D T2 = new Vec3D(path.T.x, path.T.y, path.T.z);
    T2 = T2.getRotatedAroundAxis(path.B, map(mouseX, 0, width, -PI/2, PI/2));
    Vec3D center = new Vec3D(pos.x+T2.x*c, pos.y+T2.y*c, pos.z+T2.z*c); 
    camera(pos.x, pos.y, pos.z, 0, 0, 0, 0.0f, -1.0f, 0.0f);
    //camera(pos.x, pos.y, pos.z, center.x, center.y, center.z, 0.0f, 1.0f, 0.0f);

    endCamera();
  }
}

