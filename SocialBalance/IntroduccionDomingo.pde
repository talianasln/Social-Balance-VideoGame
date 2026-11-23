class IntroduccionDomingo {
  boolean abierta;
  PImage cartel;
  final float BOTON_X=510, BOTON_Y=560, BOTON_ANCHO=260, BOTON_ALTO=40;

  void cargar() {
    cartel=loadImage("TutorialDomingo.png");
  }

  void procesarClick() {
    if (sobreSeleccion(BOTON_X,BOTON_Y,BOTON_ANCHO,BOTON_ALTO)) abierta=false;
  }

  void mostrar() {
    if (!abierta) return;
    pushStyle();
    rectMode(CORNER);
    imageMode(CORNER);
    noTint();
    noStroke();
    fill(39,21,28,198);
    rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    if (cartel!=null) {
      float ancho=1100, alto=ancho*cartel.height/cartel.width;
      image(cartel,(ANCHO_JUEGO-ancho)/2,42,ancho,alto);
    }
    fill(sobreSeleccion(BOTON_X,BOTON_Y,BOTON_ANCHO,BOTON_ALTO) ? color(151,57,73) : color(111,39,54));
    rect(BOTON_X,BOTON_Y,BOTON_ANCHO,BOTON_ALTO,10);
    fill(255,243,216);
    textAlign(CENTER,CENTER);
    textSize(18);
    text("COMENZAR",BOTON_X+BOTON_ANCHO/2,BOTON_Y+BOTON_ALTO/2);
    popStyle();
  }
}
