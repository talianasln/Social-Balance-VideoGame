void mostrarMenu() {

  image(fondoInicio, 0, 0, ANCHO_JUEGO, ALTO_JUEGO);

  boton("NUEVO JUEGO", 520, 225);
  boton("CONTINUAR", 520, 300);
  boton("CONFIGURACIÓN", 520, 375);
}


void boton(String texto, float x, float y) {

  float ancho = 240;
  float alto = 60;

  boolean encima = mouseJuegoX() >= x &&
                   mouseJuegoX() <= x + ancho &&
                   mouseJuegoY() >= y &&
                   mouseJuegoY() <= y + alto;

  if (encima) {
    fill(255, 180);
    stroke(255);
    strokeWeight(3);
  }
  else {
    fill(0, 150);
    stroke(255);
    strokeWeight(2);
  }

  rect(x, y, ancho, alto, 8);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(22);
  text(texto, x + ancho/2, y + alto/2);
}


void mousePressed() {
  if (!mouseDentroDelJuego()) return;

  // ================= MENÚ PRINCIPAL =================

  if (pantalla == 0) {

    // NUEVO JUEGO
    if (mouseJuegoX() >= 520 && mouseJuegoX() <= 760 &&
        mouseJuegoY() >= 225 && mouseJuegoY() <= 285) {

      reiniciarDia();
      pantalla = 1;

      // Reiniciar selección
      personajeSeleccionado = 0;
      tonoSeleccionado = -1;
    }
  }


  // ================= SELECCIÓN PERSONAJE =================

  else if (pantalla == 1) {

    // HOMBRE
    if (mouseJuegoX() >= 285 && mouseJuegoX() <= 620 &&
        mouseJuegoY() >= 90 && mouseJuegoY() <= 485) {

      personajeSeleccionado = 1;
    }


    // MUJER
    else if (mouseJuegoX() >= 660 && mouseJuegoX() <= 995 &&
             mouseJuegoY() >= 90 && mouseJuegoY() <= 485) {

      personajeSeleccionado = 2;
    }


    // BLANCO
    else if (dist(mouseJuegoX(), mouseJuegoY(), 520, 550) <= 27.5) {

      tonoSeleccionado = 0;
    }


    // TRIGUEÑO
    else if (dist(mouseJuegoX(), mouseJuegoY(), 640, 550) <= 27.5) {

      tonoSeleccionado = 1;
    }


    // MORENO
    else if (dist(mouseJuegoX(), mouseJuegoY(), 760, 550) <= 27.5) {

      tonoSeleccionado = 2;
    }


    // COMENZAR
    else if (personajeSeleccionado != 0 &&
             tonoSeleccionado != -1 &&
             mouseJuegoX() >= 520 && mouseJuegoX() <= 760 &&
             mouseJuegoY() >= 620 && mouseJuegoY() <= 680) {

      pantalla = 2;
    }
  }
  // ================= NIVEL 1 =================

else if (pantalla == 2) {
    if (gestorMinijuegos.derrota.length()>0) { gestorMinijuegos.clickDerrota(); return; }
    if (gestorMinijuegos.activo != 0) { gestorMinijuegos.presionar(); return; }
    if (cama.interfazAbierta) { cama.procesarClick(); return; }
    if (celular.interfazAbierta) { celular.procesarClick(); return; }
    if (instrucciones.abierta) {
      if (instrucciones.clicCerrar()) { instrucciones.cerrar(); jugador.detenerMovimiento(); }
      return;
    }
    if (escritorio.interfazAbierta) { escritorio.procesarClick(); return; }
    if (hud.clicAyuda()) { instrucciones.abrir(); jugador.detenerMovimiento(); }
  }
}

void mouseDragged() {
  if (pantalla==2 && gestorMinijuegos.activo==3 && !gestorMinijuegos.modalAbierto())
    gestorMinijuegos.vistaVerdaderoFalso.arrastrar(mouseJuegoX(),mouseJuegoY());
}

void mouseReleased() {
  if (pantalla==2 && gestorMinijuegos.activo==3 && !gestorMinijuegos.modalAbierto()) {
    gestorMinijuegos.vistaVerdaderoFalso.soltar(mouseJuegoX(),mouseJuegoY(),(long)millis());
    gestorMinijuegos.sincronizar();
  }
}
