
class Jugador {

  float x = 500;
  float y = 200;

  float velocidad = 4;

  // Tamaño del personaje en pantalla
  float anchoPersonaje = 380;
  float altoPersonaje = 380;

  // Límites de movimiento horizontal
  float limiteIzquierdo = 220;
  float limiteDerecho = 990;

  boolean moviendoIzquierda = false;
  boolean moviendoDerecha = false;
  boolean moviendoArriba = false;
  boolean moviendoAbajo = false;
  boolean caminando = false;

  // ================= SPRITES =================

  PImage hojaSprites;
  PImage[][] sprites = new PImage[4][4];
  PImage imagenQuieto;

  final int ABAJO = 0;
  final int IZQUIERDA = 1;
  final int DERECHA = 2;
  final int ARRIBA = 3;

  int direccion = ABAJO;
  int frameActual = 0;

  int cantidadFrames = 4;
  int tamanoFrame = 128;

  int ultimoCambioFrame = 0;
  int velocidadAnimacion = 150;


  // ================= CONSTRUCTOR =================

  Jugador() {
  cargarSprites();

  imagenQuieto = loadImage("ChicoPijamaQuieto.png");
  }


  // ================= CARGAR SPRITES =================

  void cargarSprites() {

    hojaSprites = loadImage("ChicoPijamaMovimientos.png");

    if (hojaSprites == null) {
      println("ERROR: No se encontró el spritesheet");
      return;
    }

    for (int fila = 0; fila < 4; fila++) {

      for (int columna = 0; columna < 4; columna++) {

        int frameX = columna * tamanoFrame;
        int frameY = fila * tamanoFrame;

        sprites[fila][columna] = hojaSprites.get(
          frameX,
          frameY,
          tamanoFrame,
          tamanoFrame
        );
      }
    }

    println("Sprites del personaje cargados correctamente");
  }


  // ================= ACTUALIZAR =================

  void actualizar() {

    float dx = (moviendoDerecha ? 1 : 0) - (moviendoIzquierda ? 1 : 0);
    float dy = (moviendoAbajo ? 1 : 0) - (moviendoArriba ? 1 : 0);
    if (dx != 0) direccion = dx < 0 ? IZQUIERDA : DERECHA;
    else if (dy != 0) direccion = dy < 0 ? ARRIBA : ABAJO;
    if (dx != 0 && dy != 0) { dx /= sqrt(2); dy /= sqrt(2); }
    float anteriorX = x, anteriorY = y;
    // Resolver por eje permite deslizarse junto a la cama sin atravesarla.
    if (posicionPermitida(x + dx * velocidad, y)) x += dx * velocidad;
    if (posicionPermitida(x, y + dy * velocidad)) y += dy * velocidad;
    caminando = x != anteriorX || y != anteriorY;

    // ================= ANIMACIÓN =================

    if (caminando) {

      if (millis() - ultimoCambioFrame >= velocidadAnimacion) {

        frameActual++;

        if (frameActual >= cantidadFrames) {
          frameActual = 0;
        }

        ultimoCambioFrame = millis();
      }

    } else {

      // Quieto mirando en la última dirección
      frameActual = 0;
    }
  }


  // ================= MOSTRAR =================

void mostrar() {

  // ================= PERSONAJE QUIETO =================

  if (!caminando) {

    if (imagenQuieto != null) {
      image(
        imagenQuieto,
        x,
        y,
        anchoPersonaje,
        altoPersonaje
      );
    }

    return;
  }


  // ================= PERSONAJE CAMINANDO =================

  PImage frame = sprites[direccion][frameActual];

  if (frame == null) {
    return;
  }

  image(
    frame,
    x,
    y,
    anchoPersonaje,
    altoPersonaje
  );
}


  float piesX() { return x + anchoPersonaje / 2; }
  float piesY() { return y + altoPersonaje * 0.96; }

  boolean posicionPermitida(float nuevaX, float nuevaY) {
    float px = nuevaX + anchoPersonaje / 2;
    float py = nuevaY + altoPersonaje * 0.96;
    if (nuevaX < limiteIzquierdo || nuevaX > limiteDerecho || py < 475 || py > 690) return false;
    // Huella de los pies, no el margen transparente del sprite.
    return !chocaMueble(px, py, 805, 390, 1165, 570) &&
           !chocaMueble(px, py, 1165, 460, 1280, 610);
  }

  boolean chocaMueble(float px, float py, float izquierda, float arriba, float derecha, float abajo) {
    return px + 22 > izquierda && px - 22 < derecha && py + 10 > arriba && py - 10 < abajo;
  }

  // ================= DETENER MOVIMIENTO =================

  void detenerMovimiento() {

    moviendoIzquierda = false;
    moviendoDerecha = false;
    moviendoArriba = false;
    moviendoAbajo = false;
    caminando = false;

    frameActual = 0;
  }
}


// ================= TECLADO =================
void keyPressed() {
  // Escape en un reto pide confirmar el abandono en vez de cerrar la aplicación.
  if (key == ESC && pantalla == 2 && gestorMinijuegos.activo != 0) {
    key = 0;
    gestorMinijuegos.solicitarSalida();
    return;
  }
  if (pantalla == 2 && gestorMinijuegos.activo != 0) {
    gestorMinijuegos.teclear(key,keyCode);
    return;
  }
  if (pantalla != 2 || hayInterfazAbierta()) {
    jugador.detenerMovimiento();
    return;
  }
  if (key == 'e' || key == 'E') {
    ObjetoInteractivo objeto = objetoCercano();
    if (objeto != null) objeto.abrirInterfaz();
    jugador.detenerMovimiento();
    return;
  }
  cambiarTeclaMovimiento(true);
}

void keyReleased() { cambiarTeclaMovimiento(false); }

void cambiarTeclaMovimiento(boolean pulsada) {
  if (jugador == null) return;
  if (key == 'a' || key == 'A' || (key == CODED && keyCode == LEFT)) jugador.moviendoIzquierda = pulsada;
  if (key == 'd' || key == 'D' || (key == CODED && keyCode == RIGHT)) jugador.moviendoDerecha = pulsada;
  if (key == 'w' || key == 'W' || (key == CODED && keyCode == UP)) jugador.moviendoArriba = pulsada;
  if (key == 's' || key == 'S' || (key == CODED && keyCode == DOWN)) jugador.moviendoAbajo = pulsada;
}
