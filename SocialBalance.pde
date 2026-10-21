PImage fondoInicio;

PImage hombreBlanco;
PImage hombreTrigueno;
PImage hombreMoreno;

PImage mujerBlanca;
PImage mujerTriguena;
PImage mujerMorena;

PImage hombreBlancoDerecha;
PImage hombreBlancoIzquierda;



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

PImage cuartoHombre;
PImage cuartoMujer;

Jugador jugador;
Escritorio escritorio;

HUD hud;

PImage imagenInstrucciones;
Instrucciones instrucciones;

VerdaderoFalso verdaderoFalso;

void setup() {
  size(1280, 720);

  fondoInicio = loadImage("PantallaDeInicio.png");

  hombreBlanco = loadImage("HombreEstaticoBlanco.png");
  hombreTrigueno = loadImage("HombreEstaticoTrigueño.png");
  hombreMoreno = loadImage("HombreEstaticoMoreno.png");

  mujerBlanca = loadImage("MujerEstaticaBlanca.png");
  mujerTriguena = loadImage("MujerEstaticaTrigueña.png");
  mujerMorena = loadImage("MujerEstaticaMorena.png");
  
  cuartoHombre = loadImage("CuartoHombre.png");
  cuartoMujer = loadImage("CuartoMujer.png");
  
  hombreBlancoDerecha = loadImage("HombreBlancoSpriteDerecha.png");
  hombreBlancoIzquierda = loadImage("HombreBlancoSpriteIzquierda.png");
  
  jugador = new Jugador();
  escritorio = new Escritorio(220, 235);
  
  hud = new HUD();
  
  imagenInstrucciones = loadImage("Instrucciones.png");
  
  instrucciones = new Instrucciones(imagenInstrucciones);
  
  verdaderoFalso = new VerdaderoFalso();
}


void draw() {

  if (pantalla == 0) {
    mostrarMenu();
  }

  else if (pantalla == 1) {
    mostrarSeleccionPersonaje();
  }

  else if (pantalla == 2) {

  // ================= HABITACIÓN =================

  if (personajeSeleccionado == 1) {

    image(
      cuartoHombre,
      0,
      0,
      width,
      height
    );
  }

  else if (personajeSeleccionado == 2) {

    image(
      cuartoMujer,
      0,
      0,
      width,
      height
    );
  }


  // ================= JUGADOR =================

  // Solo puede moverse si no hay interfaces abiertas
  if (!escritorio.interfazAbierta &&
    !instrucciones.abierta &&
    !verdaderoFalso.activa) {

  jugador.actualizar();
}


  jugador.mostrar();


  // ================= ESCRITORIO =================

  // No mostrar interacción si están abiertas
  // las instrucciones
  if (!instrucciones.abierta) {

    escritorio.actualizar(jugador);
  }


  // ================= HUD =================

  hud.mostrar();


  // ================= INSTRUCCIONES =================

  instrucciones.mostrar();
  
  verdaderoFalso.mostrar();
}

//  mostrarCoordenadas();
}


// Coordenadas temporales para diseñar
//void mostrarCoordenadas() {
//
//  fill(0, 180);
//  noStroke();
//  rect(10, 10, 170, 45);
//
//  fill(255);
//  textAlign(LEFT, CENTER);
//  textSize(18);
//  text("X: " + mouseX + "  Y: " + mouseY, 20, 32);
//}
