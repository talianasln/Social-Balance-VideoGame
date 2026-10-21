class Jugador {

  float x = 500;
  float y = 200;

  float velocidad = 14;

  // Tamaño del personaje EN PANTALLA
  float anchoPersonaje = 380;
  float altoPersonaje = 380;

  // Límites horizontales
  float limiteIzquierdo = 220;
  float limiteDerecho = 600;

  boolean moviendoIzquierda = false;
  boolean moviendoDerecha = false;

  int frameActual = 0;
  int ultimoCambioFrame = 0;

  int cantidadFrames = 5;

  // Cada frame original mide 128x128
  int tamanoFrame = 128;

  // Milisegundos entre frames
  int velocidadAnimacion = 120;


  void actualizar() {

    // ================= MOVIMIENTO =================

    if (moviendoIzquierda) {
      x -= velocidad;
    }

    if (moviendoDerecha) {
      x += velocidad;
    }


    // ================= LÍMITES =================

    x = constrain(x, limiteIzquierdo, limiteDerecho);


    // ================= ANIMACIÓN =================

    if (moviendoIzquierda || moviendoDerecha) {

      if (millis() - ultimoCambioFrame > velocidadAnimacion) {

        frameActual++;

        if (frameActual >= cantidadFrames) {
          frameActual = 0;
        }

        ultimoCambioFrame = millis();
      }
    }

    else {
      frameActual = 0;
    }
  }


  void mostrar() {

    // ================= QUIETO =================

    if (!moviendoIzquierda && !moviendoDerecha) {

      image(
        hombreBlanco,
        x,
        y,
        anchoPersonaje,
        altoPersonaje
      );

      return;
    }


    // ================= SPRITE SEGÚN DIRECCIÓN =================

    PImage sprite;

    if (moviendoDerecha) {
      sprite = hombreBlancoDerecha;
    }
    else {
      sprite = hombreBlancoIzquierda;
    }


    // ================= FRAME =================

    int frameX = frameActual * tamanoFrame;

    PImage frame = sprite.get(
      frameX,
      0,
      tamanoFrame,
      tamanoFrame
    );


    image(
      frame,
      x,
      y,
      anchoPersonaje,
      altoPersonaje
    );
  }
}


// ================= TECLADO =================

void keyPressed() {

  if (pantalla != 2) {
    return;
  }
  
  // No permitir controles con instrucciones abiertas
  if (instrucciones.abierta) {
    return;
  }
  
  if (verdaderoFalso.activa) {
  return;
  }


  // ================= INTERACTUAR =================

  if ((key == 'e' || key == 'E') &&
      escritorio.jugadorCerca(jugador) &&
      !escritorio.interfazAbierta) {

    escritorio.abrirInterfaz();

    jugador.moviendoIzquierda = false;
    jugador.moviendoDerecha = false;

    return;
  }


  // Bloquear movimiento mientras el panel esté abierto
  if (escritorio.interfazAbierta) {
    return;
  }


  // ================= MOVIMIENTO =================

  if (key == 'a' || key == 'A') {
    jugador.moviendoIzquierda = true;
  }

  if (key == 'd' || key == 'D') {
    jugador.moviendoDerecha = true;
  }

  if (key == CODED) {

    if (keyCode == LEFT) {
      jugador.moviendoIzquierda = true;
    }

    if (keyCode == RIGHT) {
      jugador.moviendoDerecha = true;
    }
  }
}


void keyReleased() {

  if (key == 'a' || key == 'A') {
    jugador.moviendoIzquierda = false;
  }

  if (key == 'd' || key == 'D') {
    jugador.moviendoDerecha = false;
  }

  if (key == CODED) {

    if (keyCode == LEFT) {
      jugador.moviendoIzquierda = false;
    }

    if (keyCode == RIGHT) {
      jugador.moviendoDerecha = false;
    }
  }
}
