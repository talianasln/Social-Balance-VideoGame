class GestorTareas implements Iterable<Tarea> {
  private final ListaTareas lista=new ListaTareas();
  private final GestorPuntuacion puntuacion=new GestorPuntuacion();

  void agregar(Tarea tarea) {
    if (tarea==null || consultar(tarea.id)!=null) throw new IllegalArgumentException("Tarea nula o repetida");
    lista.agregar(tarea);
  }

  Tarea consultar(int id) {
    for (Tarea tarea : lista) if (tarea.id==id) return tarea;
    return null;
  }

  boolean completar(int id) {
    Tarea tarea=consultar(id);
    if (tarea==null || !tarea.marcarCompletada()) return false;
    puntuacion.agregar(1);
    return true;
  }

  int cantidad() { return lista.cantidad(); }
  int puntos() { return puntuacion.consultar(); }
  public java.util.Iterator<Tarea> iterator() { return lista.iterator(); }
}
