boolean menuPausaAbierto;
int inicioMenuPausa;
int tiempoEnMenuPausa;

// Los temporizadores del juego se detienen mientras está abierto el menú.
public int millis() {
  int ahora=menuPausaAbierto ? inicioMenuPausa : super.millis();
  return ahora-tiempoEnMenuPausa;
}

void abrirMenuPausa() {
  if (pantalla==0 || menuPausaAbierto) return;
  inicioMenuPausa=super.millis();
  menuPausaAbierto=true;
  if (jugador!=null) jugador.detenerMovimiento();
  if (pantalla!=2 || gestorMinijuegos.mostrandoContexto) return;
  if (gestorMinijuegos.activo==3) gestorMinijuegos.vistaVerdaderoFalso.arrastrando=false;
  if (gestorMinijuegos.activo==4) gestorMinijuegos.conceptos.cancelarSeleccion();
  if (gestorMinijuegos.activo==5) gestorMinijuegos.vistaOrdenarPasos.cancelarArrastre();
}

void cerrarMenuPausa() {
  tiempoEnMenuPausa+=super.millis()-inicioMenuPausa;
  menuPausaAbierto=false;
}

void procesarMenuPausa() {
  if (sobreSeleccion(520,325,240,60)) cerrarMenuPausa();
  else if (sobreSeleccion(520,398,240,60)) {
    if (pantalla==2 && !escenarios.cambiando() && gestorMinijuegos.activo==0) guardado.guardar();
    cerrarMenuPausa();
    entradaPartida.iniciar(0);
  }
}

void mostrarMenuPausa() {
  pushStyle();
  rectMode(CORNER);
  noStroke();
  fill(22,15,25,172);
  rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
  fill(48,34,44);
  stroke(225,177,146);
  strokeWeight(2);
  rect(400,210,480,285,16);
  fill(255,222,193);
  textAlign(CENTER,CENTER);
  textSize(28);
  text("Juego en pausa",640,257);
  textSize(15);
  text("Volver al comienzo cerrará la partida actual.",640,295);
  boton("SEGUIR JUGANDO",520,325);
  boton("VOLVER AL COMIENZO",520,398);
  popStyle();
}
