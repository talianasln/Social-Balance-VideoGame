final float MENU_X = 520;
final float MENU_Y = 350;
final float MENU_PASO = 75;

boolean sobreOpcionMenu(int indice) {
  float y = MENU_Y + indice * MENU_PASO;
  return mouseJuegoX() >= MENU_X && mouseJuegoX() <= MENU_X + 240 &&
         mouseJuegoY() >= y && mouseJuegoY() <= y + 60;
}

void mostrarMenu() {

  image(fondoInicio, 0, 0, ANCHO_JUEGO, ALTO_JUEGO);

  boton("NUEVO JUEGO", MENU_X, MENU_Y);
  boton("CONTINUAR", MENU_X, MENU_Y + MENU_PASO);
  boton("CONFIGURACIÓN", MENU_X, MENU_Y + 2 * MENU_PASO);
  boton("SALIR", MENU_X, MENU_Y + 3 * MENU_PASO);
  if (!guardado.avisoMenu.isEmpty()) {
    pushStyle();
    rectMode(CORNER); noStroke(); fill(45,31,41,235);
    rect(395,305,490,34,8);
    fill(255,240,225); textAlign(CENTER,CENTER); textSize(16);
    text(guardado.avisoMenu,640,322);
    popStyle();
  }
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
  if (presentacionInicial.activa || !mouseDentroDelJuego()) return;
  if (menuPausaAbierto) { procesarMenuPausa(); return; }

  // ================= MENÚ PRINCIPAL =================

  if (pantalla == 0) {

    // NUEVO JUEGO
    if (sobreOpcionMenu(0)) {

      guardado.avisoMenu="";
      reiniciarDia();
      pantalla = 1;

      // Reiniciar selección
      personajeSeleccionado = 0;

    }
    else if (sobreOpcionMenu(1)) {
      guardado.continuar();
    }
    else if (sobreOpcionMenu(3)) {
      exit();
    }
  }


  // ================= SELECCIÓN PERSONAJE =================

  else if (pantalla == 1) {
    seleccionarPersonajeConClick();
  }
  // ================= NIVEL 1 =================

else if (pantalla == 2) {
    if (gestorMinijuegos.derrota.length()>0) { gestorMinijuegos.clickDerrota(); return; }
    if (escenarios.cambiando() || cama.actividadEnCurso) return;
    if (introduccionDomingo.abierta) { introduccionDomingo.procesarClick(); return; }
    if (encargoBiblioteca.abierto || (puedeMostrarEncargo() && encargoBiblioteca.sobreBoton())) {
      encargoBiblioteca.procesarClick();
      return;
    }
    if (gestorMinijuegos.activo != 0) { gestorMinijuegos.presionar(); return; }
    if (puedeConsultarCalendario() && (hud.calendario.abierto || hud.calendario.sobreBoton())) {
      hud.calendario.procesarClick();
      return;
    }
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
  if (menuPausaAbierto) return;
  if (pantalla==2 && gestorMinijuegos.activo==3 && !gestorMinijuegos.modalAbierto())
    gestorMinijuegos.vistaVerdaderoFalso.arrastrar(mouseJuegoX(),mouseJuegoY());
}

void mouseReleased() {
  if (menuPausaAbierto || pantalla!=2 || gestorMinijuegos.modalAbierto()) return;
  if (gestorMinijuegos.activo==4) {
    gestorMinijuegos.vistaConceptos.soltar(mouseJuegoX(),mouseJuegoY());
  } else if (gestorMinijuegos.activo==5) {
    gestorMinijuegos.vistaOrdenarPasos.soltar(mouseJuegoX(),mouseJuegoY());
  } else if (gestorMinijuegos.activo==3) {
    gestorMinijuegos.vistaVerdaderoFalso.soltar(mouseJuegoX(),mouseJuegoY());
    gestorMinijuegos.sincronizar();
  }
}
