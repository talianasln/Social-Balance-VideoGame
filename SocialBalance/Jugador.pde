
class Jugador {

  float x = 500;
  float y = 200;

  float velocidad = 4;

  // Tamaño del personaje en pantalla
  float anchoPersonaje = 280;
  float altoPersonaje = 280;

  // Límites horizontales medidos en los pies, independientes del sprite.
  float limiteIzquierdo = 180;
  float limiteDerecho = 1255;

  boolean moviendoIzquierda = false;
  boolean moviendoDerecha = false;
  boolean moviendoArriba = false;
  boolean moviendoAbajo = false;
  boolean caminando = false;

  // ================= SPRITES =================

  PImage hojaSprites;
  int framesDescanso = 1;
  int frameDescanso = 0;
  int ultimoFrameDescanso = 0;
  int velocidadDescanso = 250;
  PImage imagenQuieto;

  final int ABAJO = 0;
  final int IZQUIERDA = 1;
  final int DERECHA = 2;
  final int ARRIBA = 3;

  int direccion = ABAJO;
  int frameActual = 0;

  int cantidadFrames = 4;

  int ultimoCambioFrame = 0;
  int velocidadAnimacion = 150;


  // ================= CONSTRUCTOR =================

  Jugador() {
    reiniciarPosicion();
    // Los recursos se cargan al confirmar la selección, no los tres a la vez.
  }

  void reiniciarPosicion() {
    // Conservar la posición inicial de los pies al cambiar el tamaño del dibujo.
    x = 665 - anchoPersonaje / 2;
    y = 517 - altoPersonaje * 0.96;
    detenerMovimiento();
  }

  void cargarPersonaje(int indice) {
    detenerMovimiento(); direccion = ABAJO;
    hojaSprites = null; imagenQuieto = null;
    PersonajeConfig config = personajes[indice-1];
    int ladoHoja=resolucionSprite(max(anchoPersonaje,altoPersonaje))*4;
    imagenQuieto = cargarImagenPersonaje(config.descanso,ladoHoja,4,1);
    framesDescanso = imagenQuieto!=null ? 4 : 1;
    hojaSprites = cargarImagenPersonaje(config.movimientos,ladoHoja,true);
    // Mientras falta una animación, conservar la identidad del personaje.
    if (imagenQuieto==null && hojaSprites==null) imagenQuieto=config.preview;
    frameDescanso=0;
    ultimoFrameDescanso=millis();
    ultimoCambioFrame=millis();
  }

  int filaSprite() {
    if (direccion==ARRIBA) return 0;
    if (direccion==DERECHA) return 1;
    if (direccion==ABAJO) return 2;
    return 3;
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

    // Descanso animado; también sirve provisionalmente si falta caminar.
    if ((!caminando || hojaSprites==null) && framesDescanso>1 &&
        millis()-ultimoFrameDescanso>=velocidadDescanso) {
      frameDescanso=(frameDescanso+1)%framesDescanso;
      ultimoFrameDescanso=millis();
    }

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
  if ((!caminando || hojaSprites==null) && imagenQuieto!=null) {
    if (framesDescanso>1) {
      int celda=imagenQuieto.width/framesDescanso;
      int sx=frameDescanso*celda;
      dibujarSpriteNitido(imagenQuieto,x,y,anchoPersonaje,altoPersonaje,sx,0,sx+celda,imagenQuieto.height);
    } else dibujarImagenAjustada(imagenQuieto,x,y,anchoPersonaje,altoPersonaje);
    return;
  }
  if (hojaSprites!=null) {
    int tamano=hojaSprites.width/4;
    int sx=(caminando ? frameActual : 0)*tamano;
    int sy=filaSprite()*tamano;
    // Dibujar una celda evita duplicar en memoria las 16 imágenes.
    dibujarSpriteNitido(hojaSprites,x,y,anchoPersonaje,altoPersonaje,sx,sy,sx+tamano,sy+tamano);
  } else {
    pushStyle(); fill(220,190,200); noStroke();
    ellipse(piesX(),piesY()-90,65,140);
    popStyle();
  }
}

  float piesX() { return x + anchoPersonaje / 2; }
  float piesY() { return y + altoPersonaje * 0.96; }

  boolean posicionPermitida(float nuevaX, float nuevaY) {
    float px = nuevaX + anchoPersonaje / 2;
    float py = nuevaY + altoPersonaje * 0.96;
    if (px < limiteIzquierdo || px > limiteDerecho || py < 475 || py > 690) return false;
    // Huella de los pies, no el margen transparente del sprite.
    float bordeCama = personajeSeleccionado==2 ? 750 : 800;
    return !chocaMueble(px, py, bordeCama, 390, 1170, 585) &&
           !chocaMueble(px, py, 1170, 460, 1280, 655) &&
           !chocaMueble(px, py, 150, 380, bordeDerechoEscritorio(), 550) &&
           !chocaMueble(px, py, 0, 0, 155, 650);
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
