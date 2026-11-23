// Todas las pantallas conservan las coordenadas del diseño original.
final int ANCHO_JUEGO = 1280;
final int ALTO_JUEGO = 720;
float temblorX, temblorY;
float escalaTemblor = 1;

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
  return ((mouseX - margenJuegoX()) / escalaJuego() - temblorX) / escalaTemblor;
}

float mouseJuegoY() {
  return ((mouseY - margenJuegoY()) / escalaJuego() - temblorY) / escalaTemblor;
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
  int ahora=millis();
  entradaPartida.actualizar(ahora);
  finalDelDia.actualizar(ahora);
  musicaAmbiente.actualizar(ahora);
  if (finalDelDia.cubreJuego(ahora)) {
    escalaTemblor=1;
    temblorX=temblorY=0;
    finalDelDia.mostrar(ahora);
    entradaPartida.mostrar(ahora);
    popMatrix();
    return;
  }
  if (pantalla==2 && !entradaPartida.activa) {
    escenarios.actualizar(ahora);
    cama.actualizarActividad(ahora);
    celular.actualizarActividad(ahora);
    if (!menuPausaAbierto) avisosPlazo.actualizar(ahora);
  }
  float intensidad=pantalla==2 && !cama.mostrandoEscena(ahora) ? hud.intensidadEstres() : 0;
  escalaTemblor=1+0.004*intensidad;
  temblorX=intensidad*(-ANCHO_JUEGO*0.002+sin(ahora*0.063)*1.35);
  temblorY=intensidad*(-ALTO_JUEGO*0.002+sin(ahora*0.079+0.6)*0.9);
  translate(temblorX,temblorY);
  scale(escalaTemblor);
  dibujarJuego();
  entradaPartida.mostrar(ahora);
  finalDelDia.mostrar(ahora);
  if (menuPausaAbierto) mostrarMenuPausa();
  popMatrix();
}