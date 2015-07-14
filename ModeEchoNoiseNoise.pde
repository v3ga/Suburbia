class ModeEchoNoiseNoise extends ModeVoronoi
{
  ArrayList<ParticleSystemEchoNoise> particleSystems;
  PGraphics offscreen;
  ArrayList<Area> areaDrawable;
  Area areaBiggest;
  ParticleSystemEchoNoise particleSystemCurrent = null;

  ModeEchoNoiseNoise()
  {
    name = "ECHONOISE";
    cp5_prefix = "echoNoise";
  }


  // --------------------------------------------------
  boolean isDrawBackground() {
    return true;
  }
  // --------------------------------------------------
  void setup()
  {
    //    super.setup();
    voronoi_nb_points = 100;
    subdivide_factor_polygon_scale = 0.95;
    modeDistribution = 2;
    useOutsidePolygons = true;
    distributePoints();
    generate();
  }

  // --------------------------------------------------
  void draw()
  {
    if (offscreen != null)
    {
      offscreen.beginDraw();
      if (particleSystems != null)
      {
        //        for (ParticleSystemEchoNoise ps : particleSystems)
        //        {
        //ps.draw(offscreen);
        //        }
        
        if (particleSystemCurrent != null) 
        {
          particleSystemCurrent.draw(offscreen);
        }
      }
      offscreen.endDraw();

      image(offscreen, 0, 0, width, height);
    }

    for (Area area : areaDrawable)
    {
      area.draw();
    }

    if (particleSystemCurrent != null) 
    {
      Vec2D G = particleSystemCurrent.poly.getCentroid();
      noStroke();
      fill(200,0,0);
      ellipse(G.x, G.y, 5, 5);
    }
    
    if (particleSystemCurrent.done())
    {
      int index = particleSystems.indexOf(particleSystemCurrent);
      if (index <particleSystems.size()-1){
        particleSystemCurrent = particleSystems.get(index+1);
      }
    
    }
    
}


// --------------------------------------------------
void generate()
{
  super.generate();

  if (offscreen == null)
  {
    offscreen = createGraphics(width, height, JAVA2D);
  }

  if (offscreen != null && areas != null)
  {
    offscreen.beginDraw();
    offscreen.background(255);
    offscreen.pushMatrix();
    //      offscreen.scale(0.5);
    for (Area area : areas)
    {
      area.draw(offscreen);
    }
    offscreen.pushMatrix();
    offscreen.endDraw();

    areaDrawable = new ArrayList<Area>();
    for (Area area : areas)
    {
      saveAreaDrawable(area);
    }
    println(">>> drawable="+areaDrawable.size());

    particleSystems = new ArrayList<ParticleSystemEchoNoise>();
    areaBiggest = null;
    float circumference = 0.0f;
    for (Area area:areaDrawable)
    {
      if (area.polygon2D_scale != null)
      {
        Vec2D G = area.polygon2D_scale.getCentroid();
        ParticleSystemEchoNoise ps = new ParticleSystemEchoNoise(area.polygon2D_scale, G.x, G.y, 5);
        particleSystems.add( ps );
      }
    }

    println(">>> particleSystems.size()="+particleSystems.size());
    if (particleSystems.size()>0)
      particleSystemCurrent = particleSystems.get(0);
  }
}

void saveAreaDrawable(Area area)
{
  if (area == null) return;
  if (area.area1 == null && area.area2 == null)
  {
    areaDrawable.add(area);
  }
  else {
    if (area.area1!=null) saveAreaDrawable(area.area1);
    if (area.area2!=null) saveAreaDrawable(area.area2);
  }
}
}


// ==================================================
class ParticleSystemEchoNoise
{
  ArrayList<ParticleEchoNoise> particles;
  Polygon2D poly;

  // --------------------------------------------------
  ParticleSystemEchoNoise(Polygon2D poly_, float x_, float y_, int nb)
  {
    this.poly = poly_;
    this.setup(x_, y_, nb);
  }

  // --------------------------------------------------
  void setup(float x_, float y_, int nb)
  {
    particles = new ArrayList<ParticleEchoNoise>();
    for (int i=0;i<nb;i++) {
       float angle = map(i, 0, nb, 0, TWO_PI);
            PVector pos = new PVector( x_+10*cos(angle), y_+10*sin(angle)  );
      //PVector pos = new PVector( x_, y_  );

      particles.add(new ParticleEchoNoise(this, new PVector( x_, y_  ), new PVector(random(-1, 1), random(-1, 1)), 0));
      particles.add(new ParticleEchoNoise(this, pos, new PVector(random(-1, 1), random(-1, 1)), 2));
    }
  }

  // --------------------------------------------------
  boolean done()
  {
    if (particles.size()==0)
      return true;
    return false;
  }

  // --------------------------------------------------
  void draw(PGraphics pg)
  {
    for (int i=0;i<particles.size();i++)
    {
      ParticleEchoNoise c = particles.get(i);

      c.hit(pg);
      c.display(pg);
      c.move();
      c.giveBirth();
    }
    cleanup();
  }

  // --------------------------------------------------
  void cleanup()
  {
    for (int i=0;i<particles.size();i++) {
      ParticleEchoNoise c= particles.get(i);
      if (c.running==false) {
        //        println("removing "+i);
        particles.remove(i);
      }
    }
  }
}


// ==================================================
class ParticleEchoNoise
{
  ParticleSystemEchoNoise parent;

  PVector pos_before,pos, dir, vel;
  float x, y;
  float var, f;
  int t, type;
  boolean running;

  ParticleEchoNoise(ParticleSystemEchoNoise _parent, PVector _pos, PVector _dir, int _type) {
    parent = _parent;
    pos=_pos;
    x=round(pos.x);
    y=round(pos.y);
    dir=_dir;
    type=_type;
    if (type==0) {
      var=random(0.1, 1.5);
      f=round(random(20, 60));
    }    
    if (type==1) {
      var=random(0.1, 1);
      f=round(random(0, 30));
    }
    if (type==2) {
      var=0;
      f=round(random(10, 50));
    } 
    vel=new PVector(random(-var, var), random(-var, var));
    running=true;
    t=0;
  }

  void move() {
    if (running) {
      x=pos.x;
      y=pos.y;
      if (type==1)vel=new PVector(random(-var, var), random(-var, var));
      dir.add(vel);     
      dir.normalize();
      t++;
      pos.add(dir);
    }
  }

  void display(PGraphics pg) {
    if (running) {
      pg.point(round(x), round(y));
      //pg.stroke(0);
      //if (pos_before!=null){
        //pg.line(round(x), round(y),round(pos.x), round(pos.y));
      //}
    }
  }

  void hit(PGraphics pg) {
    if (pg.red(pg.get(round(pos.x), round(pos.y)))<255)running=false;
  }

  void giveBirth() {
    if (t%f==1) {
      if (type==0) this.parent.particles.add(new ParticleEchoNoise(parent, new PVector(x+random(-1, 1), y+random(-1, 1)), new PVector(random(-1, 1), random(-1, 1)), 0));
      if (type==1) this.parent.particles.add(new ParticleEchoNoise(parent, new PVector(x+random(-1, 1), y+random(-1, 1)), new PVector(random(-1, 1), random(-1, 1)), 1));
      if (type==2) this.parent.particles.add(new ParticleEchoNoise(parent, new PVector(x+random(-1, 1), y+random(-1, 1)), new PVector(random(-1, 1), random(-1, 1)), 2));
    }
  }
}

