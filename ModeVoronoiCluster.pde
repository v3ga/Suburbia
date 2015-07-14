class ModeVoronoiCluster extends ModeVoronoi
{
  VerletPhysics2D physics;
  ArrayList clusters;

  boolean showPhysics = false;
  boolean showParticles = true;

  int nbClusters = 20;
  int nbPointsMin = 3;
  int nbPointsMax = 8;

  // --------------------------------------------------
  ModeVoronoiCluster(int nbClusters_, int nbPointsMin_, int nbPointsMax_)
  {
    this.name = "Cluster";
    this.nbClusters = nbClusters_;
    this.nbPointsMin = nbPointsMin_;
    this.nbPointsMax = nbPointsMax_;
  }  

  // --------------------------------------------------
  void initControls()
  {
  }
  
  // --------------------------------------------------
  void setup()
  {
    physics=new VerletPhysics2D();
    physics.setWorldBounds(new Rect(10, 10, width-20, height-20));

    newGraph();
  }



  // --------------------------------------------------
  void update()
  {
    physics.update();
  }

  // --------------------------------------------------
  void generate()
  {
    voronoi = new Voronoi();  
    for (int i = 0; i < clusters.size(); i++) 
    {
      Cluster c = (Cluster) clusters.get(i);
      for (int j=0; j<c.nodes.size(); j++)
      {
        voronoi.addPoint( (Vec2D)c.nodes.get(j) );
      }
    }

    super.generate();
  }

  // --------------------------------------------------
  void draw()
  {
    super.draw();
  }

  // --------------------------------------------------
  void draw3D()
  {
    super.draw3D();
  }

  // --------------------------------------------------
  void drawDebug()
  {
    super.drawDebug();
    
    // Display all points
    if (showParticles) {
      fill(0);
      noStroke();

      for (int i = 0; i < clusters.size(); i++) {
        Cluster c = (Cluster) clusters.get(i);
        c.display();
      }
    }

    // If we want to see the physics
    if (showPhysics) {
      for (int i = 0; i < clusters.size(); i++) {
        // Cluster internal connections
        Cluster ci = (Cluster) clusters.get(i);
        ci.showConnections();

        // Cluster connections to other clusters
        for (int j = i+1; j < clusters.size(); j++) {
          Cluster cj = (Cluster) clusters.get(j);
          ci.showConnections(cj);
        }
      }
    }
  }


  // --------------------------------------------------
  // Spawn a new random graph
  void newGraph() 
  {

    // Clear physics
    physics.clear();

    // Create new ArrayList (clears old one)
    clusters = new ArrayList();

    // Create 8 random clusters
    for (int i = 0; i < this. nbClusters; i++) 
    {
      Vec2D center = new Vec2D(width/2, height/2);
      clusters.add(new Cluster((int) random(nbPointsMin, nbPointsMax), random(40, 130), center, physics));
    }

    //	All clusters connect to all clusters	
    for (int i = 0; i < clusters.size(); i++) {
      for (int j = i+1; j < clusters.size(); j++) {
        Cluster ci = (Cluster) clusters.get(i);
        Cluster cj = (Cluster) clusters.get(j);
        ci.connect(cj);
      }
    }
  }
}

// --------------------------------------------------
class Node extends VerletParticle2D 
{

  Node(Vec2D pos) {
    super(pos);
  }

  // All we're doing really is adding a display() function to a VerletParticle
  void display() {
    ellipse(x, y, 5, 5);
  }
}

// --------------------------------------------------
class Cluster 
{

  // A cluster is a grouping of nodes
  ArrayList nodes;
  VerletPhysics2D physics = null;
  float diameter;

  // We initialize a Cluster with a number of nodes, a diameter, and centerpoint
  Cluster(int n, float d, Vec2D center, VerletPhysics2D physics) {

    // Pass physics object
    this.physics = physics;    

    // Initialize the ArrayList
    nodes = new ArrayList();

    // Set the diameter
    diameter = d;

    // Create the nodes
    for (int i = 0; i < n; i++) {
      // We can't put them right on top of each other
      nodes.add(new Node(center.add(Vec2D.randomVector())));
    }

    // Connect all the nodes with a Spring
    for (int i = 1; i < nodes.size(); i++) {
      VerletParticle2D pi = (VerletParticle2D) nodes.get(i);
      for (int j = 0; j < i; j++) {
        VerletParticle2D pj = (VerletParticle2D) nodes.get(j);
        // A Spring needs two particles, a resting length, and a strength
        physics.addSpring(new VerletSpring2D(pi, pj, diameter, 0.01));
      }
    }
  }

  void display() {
    // Show all the nodes
    for (int i = 0; i < nodes.size(); i++) {
      Node n = (Node) nodes.get(i);
      n.display();
    }
  }

  // This functons connects one cluster to another
  // Each point of one cluster connects to each point of the other cluster
  // The connection is a "VerletMinDistanceSpring"
  // A VerletMinDistanceSpring is a string which only enforces its rest length if the 
  // current distance is less than its rest length. This is handy if you just want to
  // ensure objects are at least a certain distance from each other, but don't
  // care if it's bigger than the enforced minimum.
  void connect(Cluster other) {
    ArrayList otherNodes = other.getNodes();
    for (int i = 0; i < nodes.size(); i++) {
      VerletParticle2D pi = (VerletParticle2D) nodes.get(i);
      for (int j = 0; j < otherNodes.size(); j++) {
        VerletParticle2D pj = (VerletParticle2D) otherNodes.get(j);
        // Create the spring
        physics.addSpring(new VerletMinDistanceSpring2D(pi, pj, (diameter+other.diameter)*0.5, 0.05));
      }
    }
  }


  // Draw all the internal connections
  void showConnections() {
    stroke(0, 150);
    for (int i = 0; i < nodes.size(); i++) {
      VerletParticle2D pi = (VerletParticle2D) nodes.get(i);
      for (int j = i+1; j < nodes.size(); j++) {
        VerletParticle2D pj = (VerletParticle2D) nodes.get(j);
        line(pi.x, pi.y, pj.x, pj.y);
      }
    }
  }

  // Draw all the connections between this Cluster and another Cluster
  void showConnections(Cluster other) {
    stroke(0, 50);
    ArrayList otherNodes = other.getNodes();
    for (int i = 0; i < nodes.size(); i++) {
      VerletParticle2D pi = (VerletParticle2D) nodes.get(i);
      for (int j = 0; j < otherNodes.size(); j++) {
        VerletParticle2D pj = (VerletParticle2D) otherNodes.get(j);
        line(pi.x, pi.y, pj.x, pj.y);
      }
    }
  }

  ArrayList getNodes() {
    return nodes;
  }
}

