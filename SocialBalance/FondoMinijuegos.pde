// Fondo compartido: se carga una sola vez y respeta las coordenadas del juego.
void dibujarFondoMinijuego() {
  dibujarFondoComputador(0,0,ANCHO_JUEGO,ALTO_JUEGO);
  dibujarVentanaEmergente();
}

void dibujarFondoComputador(float x,float y,float ancho,float alto) {
  if (fondoInterfazEscritorio==null) return;
  pushStyle();
  pushMatrix();
  translate(x,y);
  scale(ancho/1672.0,alto/941.0);
  imageMode(CORNER);
  rectMode(CORNER);
  noTint();
  image(fondoInterfazEscritorio,0,0,1672,941);
  // Cubrir la hora impresa en la barra y mostrar la hora virtual.
  noStroke();
  fill(119,68,101);
  rect(1534,882,124,46,8);
  fill(255,238,225);
  textAlign(CENTER,CENTER);
  textSize(23);
  text(hud.obtenerHora(),1596,905);
  popMatrix();
  popStyle();
}

void dibujarVentanaEmergente() {
  pushStyle();
  imageMode(CORNER); rectMode(CORNER); noTint(); noStroke();
  if(fondoMinijuegos!=null) image(fondoMinijuegos,0,0,ANCHO_JUEGO,ALTO_JUEGO);
  else {
    fill(211,202,181); rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
  }
  popStyle();
}

// Cuadro derecho de la barra incluida en VentanaEmergente.PNG (2560 x 1440).
boolean sobreCierreVentana(float x,float y) {
  return x>=1190 && x<=1228 && y>=43 && y<=81;
}

void dibujarCierreVentana() {
  pushStyle(); rectMode(CORNER);
  if(sobreCierreVentana(mouseJuegoX(),mouseJuegoY())) {
    noStroke(); fill(255,65); rect(1190,43,38,38);
  }
  stroke(255,240,225); strokeWeight(3);
  line(1200,53,1218,71); line(1218,53,1200,71);
  popStyle();
}
