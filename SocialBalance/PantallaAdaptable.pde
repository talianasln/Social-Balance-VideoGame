// Todas las pantallas conservan las coordenadas del diseño original.
final int ANCHO_JUEGO = 1280;
final int ALTO_JUEGO = 720;

float escalaJuego() {
  return min(width / float(ANCHO_JUEGO), height / float(ALTO_JUEGO));
}

float margenJuegoX() {
  return (width - ANCHO_JUEGO * escalaJuego()) / 2.0;
}

float margenJuegoY() {
  return (height - ALTO_JUEGO * escalaJuego()) / 2.0;
}

// Se calculan al consultar: también funcionan entre fotogramas, en los clics.
float mouseJuegoX() {
  return (mouseX - margenJuegoX()) / escalaJuego();
}

float mouseJuegoY() {
  return (mouseY - margenJuegoY()) / escalaJuego();
}

boolean mouseDentroDelJuego() {
  return mouseJuegoX() >= 0 && mouseJuegoX() < ANCHO_JUEGO &&
         mouseJuegoY() >= 0 && mouseJuegoY() < ALTO_JUEGO;
}

void draw() {
  if (fuenteJuego!=null) textFont(fuenteJuego);
  background(0);
  pushMatrix();
  translate(margenJuegoX(), margenJuegoY());
  scale(escalaJuego());
  dibujarJuego();
  popMatrix();
}