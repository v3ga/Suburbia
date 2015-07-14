/**
 * This class implements a undirected vertex graph and provides basic connectivity information.
 * Vertices can only be added by defining edges, ensuring there're no isolated nodes
 * (but allowing for subgraphs/clusters).
 */
public class UndirectedGraph {

  // use vertex position as unique keys and a list of edges as its value
  private final Map<Vec2D, List<Edge>> vertexEdgeIndex = new HashMap<Vec2D, List<Edge>>();

  // set of all edges in the graph
  private final Set<Edge> edges = new HashSet<Edge>();

  // attempts to add new edge for the given vertices
  // if successful also add vertices to index and associate edge with each
  public void addEdge(Vec2D a, Vec2D b) {
    if (!a.equals(b)) {
      Edge e = new Edge(a, b);
      if (edges.add(e)) {
        addEdgeForVertex(a, e);
        addEdgeForVertex(b, e);
      }
    }
  }

  private void addEdgeForVertex(Vec2D a, Edge e) {
    List<Edge> vertEdges = vertexEdgeIndex.get(a);
    if (vertEdges == null) {
      vertEdges = new ArrayList<Edge>();
      vertexEdgeIndex.put(a, vertEdges);
    }
    vertEdges.add(e);
  }

  public Set<Edge> getEdges() {
    return edges;
  }

  // get list of edges for the given vertex (or null if vertex is unknown)
  public List<Edge> getEdgesForVertex(ReadonlyVec2D v) {
    return vertexEdgeIndex.get(v);
  }

  public Set<Vec2D> getVertices() {
    return vertexEdgeIndex.keySet();
  }
}

/**
 * A single immutable, undirected connection between two vertices.
 * Provides equals() & hashCode() implementations to ignore direction.
 */
public class Edge {

  public final ReadonlyVec2D a, b;

  public Edge(ReadonlyVec2D a, ReadonlyVec2D b) {
    this.a = a;
    this.b = b;
  }

  public boolean equals(Object o) {
    if (o != null && o instanceof Edge) {
      Edge e = (Edge) o;
      return
        (a.equals(e.a) && b.equals(e.b)) ||
        (a.equals(e.b) && b.equals(e.a));
    }
    return false;
  }

  public Vec2D getDirectionFrom(ReadonlyVec2D p) {
    Vec2D dir = b.sub(a);
    if (p.equals(b)) {
      dir.invert();
    }
    return dir;
  }
  
  public ReadonlyVec2D getOtherEndFor(ReadonlyVec2D p) {
    return p.equals(a) ? b : a;
  }

  public int hashCode() {
    return a.hashCode() + b.hashCode();
  }

  public String toString() {
    return a.toString() + " <-> " + b.toString();
  }
}
