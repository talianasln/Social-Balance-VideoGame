// TAD pila enlazada: cada nodo guarda una conexión y el nodo siguiente.
class PilaConexiones {
  private class Nodo {
    final ConexionConceptos conexion;
    final Nodo siguiente;

    Nodo(ConexionConceptos conexion, Nodo siguiente) {
      this.conexion = conexion;
      this.siguiente = siguiente;
    }
  }

  private Nodo cima;
  private int cantidad;

  void apilar(ConexionConceptos conexion) {
    if (conexion == null) throw new IllegalArgumentException("Conexión nula");
    cima = new Nodo(conexion, cima);
    cantidad++;
  }

  ConexionConceptos desapilar() {
    if (estaVacia()) return null;
    ConexionConceptos conexion = cima.conexion;
    cima = cima.siguiente;
    cantidad--;
    return conexion;
  }

  boolean estaVacia() { return cima == null; }
  int cantidad() { return cantidad; }
  void vaciar() { cima = null; cantidad = 0; }
}
