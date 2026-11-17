class ObjetoInteractivo {

  float zonaMinX;
  float zonaMaxX;
  float zonaMinY = 475;
  float zonaMaxY = 580;

  boolean interfazAbierta = false;


  ObjetoInteractivo(float zonaMinX, float zonaMaxX) {
    this.zonaMinX = zonaMinX;
    this.zonaMaxX = zonaMaxX;
  }


  boolean jugadorCerca(Jugador jugador) {

    return jugador.piesX() >= zonaMinX && jugador.piesX() <= zonaMaxX &&
           jugador.piesY() >= zonaMinY && jugador.piesY() <= zonaMaxY;
  }


  void abrirInterfaz() {
    interfazAbierta = true;
  }


  void cerrarInterfaz() {
    interfazAbierta = false;
  }
}
