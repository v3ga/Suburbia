// ----------------------------------------------------------------
String timestamp() 
{
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

// ----------------------------------------------------------------
int mouseWheel=0;
class MouseWheelInput implements MouseWheelListener{  
    
  void mouseWheelMoved(MouseWheelEvent e) {  
    mouseWheel=e.getWheelRotation();  
    println(mouseWheel);
  }  
  
} 

// ----------------------------------------------------------------
GLModel convertGLModel(TriangleMesh mesh)
{
  float[] vertices=mesh.getMeshAsVertexArray();
  int nbVertices = vertices.length/4;

  float[] normals=mesh.getVertexNormalsAsArray();
  
  GLModel m = new GLModel(this, nbVertices, TRIANGLES, GLModel.STATIC);
  
  m.beginUpdateVertices();
    for (int i = 0; i < nbVertices; i++) m.updateVertex(i, vertices[4*i], vertices[4*i+1], vertices[4*i+2]);
  m.endUpdateVertices(); 
  
  m.initNormals();
  m.beginUpdateNormals();
  for (int i = 0; i < nbVertices; i++) m.updateNormal(i, normals[4 * i], normals[4 * i + 1], normals[4 * i + 2]);
  m.endUpdateNormals();  

  return m;
}

// ----------------------------------------------------------------
class CallBack 
{
  private String methodName;
  private Object scope;

  public CallBack(Object scope, String methodName) 
  {
    this.methodName = methodName;
    this.scope = scope;
  }

  public Object invoke(Object... parameters) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException 
  {
    Method method = scope.getClass().getMethod(methodName, getParameterClasses(parameters));
    return method.invoke(scope, parameters);
  }

  private Class[] getParameterClasses(Object... parameters) 
  {
    Class[] classes = new Class[parameters.length];
    for (int i=0; i < classes.length; i++) {
      classes[i] = parameters[i].getClass();
    }
    return classes;
  }
  
  public String toString()
  {
	  return "Callback : scope="+this.scope+";methodName="+methodName;
  }
}
