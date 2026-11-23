class ListaTareas implements Iterable<Tarea> {
  private class Nodo {
    final Tarea tarea;
    Nodo siguiente;
    Nodo(Tarea tarea) { this.tarea=tarea; }
  }

  private Nodo primero, ultimo;
  private int cantidad;

  void agregar(Tarea tarea) {
    Nodo nuevo=new Nodo(tarea);
    if (ultimo==null) primero=nuevo;
    else ultimo.siguiente=nuevo;
    ultimo=nuevo;
    cantidad++;
  }

  int cantidad() { return cantidad; }

  public java.util.Iterator<Tarea> iterator() {
    return new java.util.Iterator<Tarea>() {
      private Nodo actual=primero;
      public boolean hasNext() { return actual!=null; }
      public Tarea next() {
        if (!hasNext()) throw new java.util.NoSuchElementException();
        Tarea tarea=actual.tarea;
        actual=actual.siguiente;
        return tarea;
      }
    };
  }
}
