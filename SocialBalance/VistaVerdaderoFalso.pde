// Vista del reto Verdadero o Falso.
// Arrastrar izquierda = FALSO; arrastrar derecha = VERDADERO.
class VistaVerdaderoFalso {
  VerdaderoFalso juego;
  boolean quiereSalir = false;
  boolean arrastrando = false;
  float pulsacionX, pulsacionY;
  float desplazamientoX, desplazamientoY;

  VistaVerdaderoFalso(VerdaderoFalso juego) {
    this.juego = juego;
  }

  boolean dentro(float px, float py, float x, float y, float w, float h) {
    return px >= x && px <= x+w && py >= y && py <= y+h;
  }

  void boton(float x, float y, float w, float h, String etiqueta) {
    stroke(226, 176, 153);
    strokeWeight(2);
    fill(dentro(mouseJuegoX(),mouseJuegoY(),x,y,w,h) ? color(155,107,100) : color(102,73,84));
    rect(x,y,w,h,10);
    fill(255,239,228);
    textAlign(CENTER,CENTER);
    textSize(19);
    text(etiqueta, x+w/2, y+h/2);
  }

  void mostrar() {
    long ahora = (long)millis();
    pushStyle();
    rectMode(CORNER);
    dibujarFondoMinijuego();
    fill(255,223,209);
    textAlign(LEFT,CENTER);
    textSize(26);
    text("SOCIAL BALANCE  /  VERDADERO O FALSO",98,76);
    dibujarCierreVentana();

    int seg = juego.inicioReloj < 0 ? 0 : (int)((ahora-juego.inicioReloj)/1000);
    String tiempo = nf(seg / 60,2) + ":" + nf(seg % 60,2);
    fill(65,39,45);
    textAlign(LEFT,CENTER);
    textSize(18);
    text("ACIERTOS: " + juego.aciertos + " / 5",101,143);
    text("ERRORES: " + juego.errores + " / 3",339,143);
    text("RESPONDIDAS: " + juego.preguntasContestadas() + " / 7",554,143);
    fill(65,39,45);
    textAlign(RIGHT,CENTER);
    textSize(31);
    text(tiempo,1159,143);
    textSize(12); text("TIEMPO REAL · SIN LÍMITE",1159,173);

    if (juego.terminado()) {
      fill(juego.completado() ? color(35,105,65) : color(155,45,55));
      textAlign(CENTER,CENTER);
      textSize(39);
      String titular = juego.completado() ? "¡RETO SUPERADO!" : "RETO NO SUPERADO";
      text(titular,ANCHO_JUEGO/2,269);
      fill(75,57,60);
      textSize(22);
      if (juego.estado == VerdaderoFalso.VICTORIA) {
        text("Conseguiste cinco respuestas correctas.",ANCHO_JUEGO/2,334);
      } else {
        text("Acumulaste tres errores: ya no puedes alcanzar los cinco aciertos.",ANCHO_JUEGO/2,334);

      }
      textSize(18);
      text("Resultado: " + juego.aciertos + " aciertos y " + juego.errores + " errores.",ANCHO_JUEGO/2,388);
      if (juego.completado()) {
        boton(447,492,386,65,"VOLVER AL COMPUTADOR");
      } else {
        boton(460,492,360,65,"REINTENTAR");
      }
      popStyle();
      return;
    }

    fill(75,57,60);
    textAlign(CENTER,CENTER);
    textSize(17);
    text("AFIRMACIÓN " + (juego.posicion+1) + " DE 7",ANCHO_JUEGO/2,188);

    // Zonas de destino bien diferenciadas y visibles.
    strokeWeight(2);
    stroke(207,130,137);
    fill(77,42,55);
    rect(95,250,297,265,18);
    stroke(130,200,170);
    fill(39,80,71);
    rect(888,250,297,265,18);
    noStroke();
    fill(255,220,223);
    textSize(26);
    text("FALSO",244,300);
    fill(207,247,223);
    text("VERDADERO",1037,300);
    fill(216,194,195);
    textSize(15);
    text("SUELTA AQUI",244,475);
    text("SUELTA AQUI",1037,475);

    float cx = 640, cy = 375;
    if (arrastrando && juego.estado == VerdaderoFalso.JUGANDO) {
      cx += desplazamientoX;
      cy += desplazamientoY;
    }
    stroke(233,188,168);
    strokeWeight(3);
    fill(235,210,193);
    rect(cx-240,cy-111,480,222,18);
    noStroke();
    fill(43,36,48);
    textAlign(CENTER,CENTER);
    textSize(19);
    text(juego.afirmacionActual(),cx-215,cy-87,430,174);

    if (juego.estado == VerdaderoFalso.EXPLICACION) {
      noStroke();
      fill(28,28,38,246);
      rect(160,525,960,125,12);
      fill(juego.ultimaCorrecta ? color(156,235,179) : color(255,164,172));
      textAlign(CENTER,CENTER);
      textSize(22);
      text(juego.ultimaCorrecta ? "¡CORRECTO!" : "INCORRECTO",640,545);
      fill(239,227,220);
      textSize(16);
      text(juego.explicacionActual(),640,576);
      boton(520,604,240,35,"SIGUIENTE");
    } else {
      fill(75,57,60);
      textAlign(CENTER,CENTER);
      textSize(16);
      text("Mantén presionada la tarjeta y arrastrala hacia uno de los extremos.",640,587);
      text("Soltarla en el centro no cuenta como respuesta.",640,615);
    }
    popStyle();
  }

  void presionar(float x,float y) {
    if (sobreCierreVentana(x,y)) {
      arrastrando = false;
      quiereSalir = true;
      return;
    }
    if (juego.terminado()) {
      if (juego.completado()) {
        if (dentro(x,y,447,492,386,65)) {
          quiereSalir = true;
        }
      } else if (dentro(x,y,460,492,360,65)) {
        gestorMinijuegos.reintentar();
      }
      return;
    }
    if (juego.estado == VerdaderoFalso.EXPLICACION && dentro(x,y,520,604,240,35)) { juego.siguiente(); return; }
    if (juego.estado == VerdaderoFalso.JUGANDO &&
        dentro(x,y,400,264,480,222)) {
      arrastrando = true;
      pulsacionX = x;
      pulsacionY = y;
      desplazamientoX = desplazamientoY = 0;
    }
  }

  void arrastrar(float x,float y) {
    if (!arrastrando) return;
    desplazamientoX = constrain(x-pulsacionX,-390,390);
    desplazamientoY = constrain(y-pulsacionY,-105,105);
  }

  void soltar(float x,float y) {
    if (!arrastrando) return;
    arrastrando = false;
    if (juego.estado != VerdaderoFalso.JUGANDO) return;
    // Se evalua la posicion del cursor al SOLTAR dentro de una zona, no
    // el centro de la tarjeta: funciona aunque la sujetes por un borde.
    // Un clic simple sin desplazamiento nunca puede contar como respuesta.
    if (Math.abs(x-pulsacionX) < 75) return;
    if (dentro(x,y,95,250,297,265)) juego.responder(false);
    else if (dentro(x,y,888,250,297,265)) juego.responder(true);
  }
}
