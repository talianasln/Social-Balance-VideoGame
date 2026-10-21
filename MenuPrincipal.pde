void mostrarMenu() {

  image(fondoInicio, 0, 0, width, height);

  boton("NUEVO JUEGO", 520, 225);
  boton("CONTINUAR", 520, 300);
  boton("CONFIGURACIÓN", 520, 375);
}


void boton(String texto, float x, float y) {

  float ancho = 240;
  float alto = 60;

  boolean encima = mouseX >= x &&
                   mouseX <= x + ancho &&
                   mouseY >= y &&
                   mouseY <= y + alto;

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

  // ================= MENÚ PRINCIPAL =================

  if (pantalla == 0) {

    // NUEVO JUEGO
    if (mouseX >= 520 && mouseX <= 760 &&
        mouseY >= 225 && mouseY <= 285) {

      pantalla = 1;

      // Reiniciar selección
      personajeSeleccionado = 0;
      tonoSeleccionado = -1;
    }
  }


  // ================= SELECCIÓN PERSONAJE =================

  else if (pantalla == 1) {

    // HOMBRE
    if (mouseX >= 285 && mouseX <= 620 &&
        mouseY >= 90 && mouseY <= 485) {

      personajeSeleccionado = 1;
    }


    // MUJER
    else if (mouseX >= 660 && mouseX <= 995 &&
             mouseY >= 90 && mouseY <= 485) {

      personajeSeleccionado = 2;
    }


    // BLANCO
    else if (dist(mouseX, mouseY, 520, 550) <= 27.5) {

      tonoSeleccionado = 0;
    }


    // TRIGUEÑO
    else if (dist(mouseX, mouseY, 640, 550) <= 27.5) {

      tonoSeleccionado = 1;
    }


    // MORENO
    else if (dist(mouseX, mouseY, 760, 550) <= 27.5) {

      tonoSeleccionado = 2;
    }


    // COMENZAR
    else if (personajeSeleccionado != 0 &&
             tonoSeleccionado != -1 &&
             mouseX >= 520 && mouseX <= 760 &&
             mouseY >= 620 && mouseY <= 680) {

      pantalla = 2;
    }
  }
  // ================= NIVEL 1 =================

else if (pantalla == 2) {


  // ==================================================
  // MINIJUEGO VERDADERO / FALSO
  // ==================================================

  if (verdaderoFalso.activa) {


    // ================= CERRAR =================

    if (verdaderoFalso.clicCerrar()) {

      verdaderoFalso.activa = false;

      // Volvemos al panel de tareas
      escritorio.interfazAbierta = true;

      return;
    }


    // ================= RESULTADO FINAL =================

    if (verdaderoFalso.terminado) {

      // Botón final
      if (mouseX >= 490 &&
          mouseX <= 790 &&
          mouseY >= 430 &&
          mouseY <= 490) {


        // ================= APROBÓ =================

        if (verdaderoFalso.aprobado) {

          // Aplicar efectos SOLO una vez
          hud.avanzarTiempo(90);

          hud.modificarEnergia(-20);

          hud.modificarEstres(15);


          // Completar Tarea 1
          escritorio.tarea1.completada = true;


          // Desbloquear Tarea 2
          escritorio.tarea2.bloqueada = false;


          // Cerrar minijuego
          verdaderoFalso.activa = false;


          // Volver a la habitación
          escritorio.interfazAbierta = false;

          return;
        }


        // ================= NO APROBÓ =================

        else {

          verdaderoFalso.iniciar();

          return;
        }
      }

      return;
    }


    // ================= YA RESPONDIÓ =================

    if (verdaderoFalso.respondida) {

      // SIGUIENTE
      if (mouseX >= 490 &&
          mouseX <= 790 &&
          mouseY >= 500 &&
          mouseY <= 555) {

        verdaderoFalso.siguientePregunta();

        return;
      }

      return;
    }


    // ================= VERDADERO =================

    if (mouseX >= 330 &&
        mouseX <= 600 &&
        mouseY >= 370 &&
        mouseY <= 435) {

      verdaderoFalso.responder(true);

      return;
    }


    // ================= FALSO =================

    if (mouseX >= 680 &&
        mouseX <= 950 &&
        mouseY >= 370 &&
        mouseY <= 435) {

      verdaderoFalso.responder(false);

      return;
    }


    return;
  }



  // ==================================================
  // INSTRUCCIONES
  // ==================================================

  if (instrucciones.abierta) {

    if (instrucciones.clicCerrar()) {

      instrucciones.cerrar();

      jugador.moviendoIzquierda = false;
      jugador.moviendoDerecha = false;
    }

    return;
  }



  // ==================================================
  // PANEL DEL ESCRITORIO
  // ==================================================

  if (escritorio.interfazAbierta) {


    // ================= CERRAR =================

    if (escritorio.clicCerrar()) {

      escritorio.cerrarInterfaz();

      return;
    }


    // ================= TAREA 1 =================

    if (!escritorio.tarea1.bloqueada &&
        !escritorio.tarea1.completada &&
        escritorio.clicRealizarTarea1()) {

      // Cerrar panel de tareas
      escritorio.interfazAbierta = false;

      // Iniciar minijuego
      verdaderoFalso.iniciar();

      return;
    }


    return;
  }



  // ==================================================
  // BOTÓN DE AYUDA
  // ==================================================

  if (hud.clicAyuda()) {

    instrucciones.abrir();

    jugador.moviendoIzquierda = false;
    jugador.moviendoDerecha = false;

    return;
  }
}
}
