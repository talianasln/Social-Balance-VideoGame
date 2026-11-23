class Instrucciones {
  boolean abierta = true;
  PImage imagen;
  final float CIERRE_X=1210, CIERRE_Y=24, CIERRE_LADO=42;

  Instrucciones(PImage imagen) { this.imagen=imagen; }

  void mostrar() {
    if (!abierta) return;
    pushStyle(); rectMode(CORNER); imageMode(CORNER); noTint();
    dibujarImagenAjustada(imagen,0,0,ANCHO_JUEGO,ALTO_JUEGO);
    fill(clicCerrar() ? color(155,49,76) : color(108,25,49));
    stroke(255,235,200); strokeWeight(2);
    rect(CIERRE_X,CIERRE_Y,CIERRE_LADO,CIERRE_LADO,7);
    stroke(255,245,225); strokeWeight(3);
    line(CIERRE_X+13,CIERRE_Y+13,CIERRE_X+29,CIERRE_Y+29);
    line(CIERRE_X+29,CIERRE_Y+13,CIERRE_X+13,CIERRE_Y+29);
    popStyle();
  }

  void abrir() { abierta=true; }
  void cerrar() { abierta=false; }
  boolean clicCerrar() {
    return mouseJuegoX()>=CIERRE_X && mouseJuegoX()<=CIERRE_X+CIERRE_LADO &&
           mouseJuegoY()>=CIERRE_Y && mouseJuegoY()<=CIERRE_Y+CIERRE_LADO;
  }
}
