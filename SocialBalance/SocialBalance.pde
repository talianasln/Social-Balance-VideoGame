boolean modoDebug = false;
PImage fondoInicio;

// Imágenes para selección de personaje
PImage hombreBlanco;
PImage hombreTrigueno;
PImage hombreMoreno;

PImage fondoInterfazEscritorio;
PImage imagenTarjetaTarea;

PImage mujerBlanca;
PImage mujerTriguena;
PImage mujerMorena;

// Fondos de habitaciones
PImage cuartoHombre;
PImage cuartoMujer;

// Pantallas
int pantalla = 0;
// 0 = Menú principal
// 1 = Selección de personaje
// 2 = Nivel 1

int personajeSeleccionado = 0;
// 0 = Ninguno
// 1 = Hombre
// 2 = Mujer

int tonoSeleccionado = -1;
// -1 = Ninguno
// 0 = Blanco
// 1 = Trigueño
// 2 = Moreno

// Objetos principales
Jugador jugador;
Escritorio escritorio;
HUD hud;
Cama cama;
Celular celular;

PImage imagenInstrucciones;
Instrucciones instrucciones;

GestorMinijuegos gestorMinijuegos;


// ================= SETUP =================

void setup() {

  fullScreen();

  // Mantener estilo Pixel Art
  noSmooth();

  // Menú principal
  fondoInicio = loadImage("PantallaDeInicio.png");

  // Selección de personaje masculino
  hombreBlanco = loadImage("HombreEstaticoBlanco.png");
  hombreTrigueno = loadImage("HombreEstaticoTrigueño.png");
  hombreMoreno = loadImage("HombreEstaticoMoreno.png");

  // Selección de personaje femenino
  mujerBlanca = loadImage("MujerEstaticaBlanca.png");
  mujerTriguena = loadImage("MujerEstaticaTrigueña.png");
  mujerMorena = loadImage("MujerEstaticaMorena.png");

  // Habitaciones
  cuartoHombre = loadImage("CuartoHombre.png");
  cuartoMujer = loadImage("CuartoMujer.png");

  // Crear jugador (carga el nuevo spritesheet)
  jugador = new Jugador();

  // Escritorio
  escritorio = new Escritorio(390, 455);

  // HUD
  hud = new HUD();
  cama = new Cama();
  celular = new Celular();

  // Instrucciones
  imagenInstrucciones = loadImage("Instrucciones.png");
  instrucciones = new Instrucciones(imagenInstrucciones);

  // Minijuego
  gestorMinijuegos = new GestorMinijuegos();

  fondoInterfazEscritorio = loadImage("InterfazEscritorio.png");
  imagenTarjetaTarea = loadImage("TarjetaTarea.png");
}


// ================= DRAW =================

void dibujarJuego() {

  // MENÚ PRINCIPAL
  if (pantalla == 0) {
    mostrarMenu();
  }

  // SELECCIÓN DE PERSONAJE
  else if (pantalla == 1) {
    mostrarSeleccionPersonaje();
  }

  // NIVEL 1
  else if (pantalla == 2) {

    // ================= HABITACIÓN =================

    if (personajeSeleccionado == 1) {

      image(
        cuartoHombre,
        0,
        0,
        ANCHO_JUEGO,
        ALTO_JUEGO
      );

    } else if (personajeSeleccionado == 2) {

      image(
        cuartoMujer,
        0,
        0,
        ANCHO_JUEGO,
        ALTO_JUEGO
      );
    }


    // ================= JUGADOR =================

    boolean puedeMoverse = !hayInterfazAbierta() && focused;

    if (puedeMoverse) {
      jugador.actualizar();
    } else {
      jugador.detenerMovimiento();
    }

    jugador.mostrar();


    // ================= ESCRITORIO =================

    if (escritorio.interfazAbierta) escritorio.mostrarInterfaz();
    if (!hayInterfazAbierta()) mostrarAyudaRecorrido();


    // ================= HUD =================

    hud.mostrar();
    cama.mostrar();
    celular.mostrar();


    // ================= INSTRUCCIONES =================

    instrucciones.mostrar();


    // ================= MINIJUEGO =================

    gestorMinijuegos.mostrar();
  }

  // mostrarCoordenadas();
  
  if (modoDebug) {
  mostrarCuadricula();
}


}



void mostrarCuadricula() {

  pushStyle();

  // Cuadrícula cada 20 píxeles
  strokeWeight(1);

  for (int x = 0; x <= ANCHO_JUEGO; x += 20) {

    if (x % 100 == 0) {
      stroke(255, 120);
    } else {
      stroke(255, 35);
    }

    line(x, 0, x, ALTO_JUEGO);
  }

  for (int y = 0; y <= ALTO_JUEGO; y += 20) {

    if (y % 100 == 0) {
      stroke(255, 120);
    } else {
      stroke(255, 35);
    }

    line(0, y, ANCHO_JUEGO, y);
  }

  // Coordenadas del mouse
  noStroke();
  fill(15, 15, 20, 230);
  rect(10, ALTO_JUEGO - 45, 225, 35, 5);

  fill(255);
  textAlign(LEFT, CENTER);
  textSize(15);

  text(
    "X: " + mouseJuegoX() + "  Y: " + mouseJuegoY(),
    20,
    ALTO_JUEGO - 28
  );

  // Cruz de posición del mouse
  stroke(255, 200, 100);
  strokeWeight(1);

  line(mouseJuegoX() - 10, mouseJuegoY(),
       mouseJuegoX() + 10, mouseJuegoY());

  line(mouseJuegoX(), mouseJuegoY() - 10,
       mouseJuegoX(), mouseJuegoY() + 10);

  popStyle();
}


// ================= COORDENADAS =================

// void mostrarCoordenadas() {
//
//   fill(0, 180);
//   noStroke();
//   rect(10, 10, 170, 45);
//
//   fill(255);
//   textAlign(LEFT, CENTER);
//   textSize(18);
//   text("X: " + mouseJuegoX() + " Y: " + mouseJuegoY(), 20, 32);
// }
