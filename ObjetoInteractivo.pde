class ObjetoInteractivo {

  float zonaMinX;
  float zonaMaxX;

  boolean interfazAbierta = false;


  ObjetoInteractivo(float zonaMinX, float zonaMaxX) {
    this.zonaMinX = zonaMinX;
    this.zonaMaxX = zonaMaxX;
  }


  boolean jugadorCerca(Jugador jugador) {

    return jugador.x >= zonaMinX &&
           jugador.x <= zonaMaxX;
  }


  void abrirInterfaz() {
    interfazAbierta = true;
  }


  void cerrarInterfaz() {
    interfazAbierta = false;
  }
}
