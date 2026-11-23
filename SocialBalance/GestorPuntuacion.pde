class GestorPuntuacion {
  private int puntos;

  int consultar() { return puntos; }

  void agregar(int cantidad) {
    if (cantidad<0) throw new IllegalArgumentException("Cantidad negativa");
    actualizar(Math.addExact(puntos,cantidad));
  }

  void actualizar(int total) {
    if (total<0) throw new IllegalArgumentException("Puntuación negativa");
    puntos=total;
  }
}
