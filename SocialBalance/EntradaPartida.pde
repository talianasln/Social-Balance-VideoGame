class EntradaPartida {
  final int FIN_SALIDA=1650, INICIO_ENTRADA=2400, DURACION=4000;
  int inicio;
  int origen, destino;
  boolean activa;

  void iniciar(int siguientePantalla) {
    inicio=millis();
    origen=pantalla;
    destino=siguientePantalla;
    activa=true;
  }

  int transcurrido(int ahora) { return ahora-inicio; }

  float progreso(int tiempo,int desde,int hasta) {
    float t=constrain((tiempo-desde)/float(hasta-desde),0,1);
    return t*t*(3-2*t);
  }

  void actualizar(int ahora) {
    if (!activa) return;
    int tiempo=transcurrido(ahora);
    if (pantalla!=destino && tiempo>=INICIO_ENTRADA) {
      pantalla=destino;
      if (destino==0) personajeSeleccionado=0;
      else if (origen==1) guardado.guardar();
    }
    if (tiempo>=DURACION) activa=false;
  }

  void mostrar(int ahora) {
    if (!activa) return;
    int tiempo=transcurrido(ahora);
    float oscuro=progreso(tiempo,0,FIN_SALIDA)-progreso(tiempo,INICIO_ENTRADA,DURACION);
    pushStyle();
    rectMode(CORNER);
    noStroke();
    fill(0,255*oscuro);
    rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    popStyle();
  }
}

EntradaPartida entradaPartida=new EntradaPartida();
