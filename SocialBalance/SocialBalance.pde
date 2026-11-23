PFont fuenteJuego;
PImage fondoInicio;

PImage fondoInterfazEscritorio;
PImage fondoMinijuegos;
PImage imagenInterfazCelular, imagenInterfazDescanso;
PImage fondoCalendario;
IntroduccionDomingo introduccionDomingo = new IntroduccionDomingo();

// Fondos de habitaciones
PImage cuarto2;
PImage cuarto1;
Escenarios escenarios = new Escenarios();
EncargoBiblioteca encargoBiblioteca = new EncargoBiblioteca();

// Pantallas
int pantalla = 0;
// 0 = Menú principal
// 1 = Selección de personaje
// 2 = Nivel 1

int personajeSeleccionado = 0;
// 0 = Ninguno, 1 = Chico, 2 = Chica, 3 = NoBin

// Objetos principales
Jugador jugador;
Escritorio escritorio;
HUD hud;
Cama cama;
Celular celular;

PImage imagenInstrucciones;
Instrucciones instrucciones;

GestorMinijuegos gestorMinijuegos;

// Imágenes del minijuego Memoria
PImage reversoMemoria;
PImage[] imagenesMemoria = new PImage[6];

// ================= SETUP =================

void setup() {

  fullScreen();

  // Mantener estilo Pixel Art
  noSmooth();
  // Fuente lógica de Java: disponible también en los equipos de los compañeros.
  fuenteJuego = new PFont(new java.awt.Font("SansSerif",java.awt.Font.BOLD,24),true);
  textFont(fuenteJuego);

  // Menú principal
  fondoInicio = loadImage("PantallaDeInicio.png");

  prepararPersonajes();
  cargarEscenasDormir();

  // Habitaciones
  cuarto2 = loadImage("Cuarto2.png");
  cuarto1 = loadImage("Cuarto1.png");
  escenarios.cargar();

  // Crear jugador (carga el nuevo spritesheet)
  jugador = new Jugador();

  // Escritorio
  escritorio = new Escritorio();

  // HUD
  hud = new HUD();
  imagenInterfazCelular = cargarImagenPanelActividad("InterfazCelular.png");
  imagenInterfazDescanso = cargarImagenPanelActividad("InterfazDescanso.png");
  cama = new Cama();
  celular = new Celular();

  // Instrucciones
  // Las instrucciones ahora se dibujan como texto sobre VentanaEmergente.
  imagenInstrucciones = loadImage("InterfazGuia.png");
  instrucciones = new Instrucciones(imagenInstrucciones);

  // Minijuego
  gestorMinijuegos = new GestorMinijuegos();

  fondoInterfazEscritorio = loadImage("InterfazEscritorio.png");
  fondoMinijuegos = loadImage("VentanaEmergente.PNG");
  fondoCalendario = loadImage("Calendario.png");
  introduccionDomingo.cargar();

  // Imágenes de las cartas de Memoria
  reversoMemoria = loadImage("ReversoTM.png");

  imagenesMemoria[0] = loadImage("BienestarTM.png");
  imagenesMemoria[1] = loadImage("EquilibrioTM.png");
  imagenesMemoria[2] = loadImage("PrivacidadTM.png");
  imagenesMemoria[3] = loadImage("RespetoTM.png");
  imagenesMemoria[4] = loadImage("TiempoTM.png");
  imagenesMemoria[5] = loadImage("CelularTM.png");
  finalDelDia.cargar();
  musicaAmbiente.cargar();
  presentacionInicial.iniciar();
}

PImage cargarImagenPanelActividad(String archivo) {
  return new java.io.File(dataPath(archivo)).isFile() ? loadImage(archivo) : null;
}


// ================= DRAW =================

void dibujarJuego() {

  // MENÚ PRINCIPAL
  if (pantalla == 0) {
    if (!presentacionInicial.mostrar()) mostrarMenu();
  }

  // SELECCIÓN DE PERSONAJE
  else if (pantalla == 1) {
    mostrarSeleccionPersonaje();
  }

  // NIVEL 1
  else if (pantalla == 2) {

    // ================= HABITACIÓN =================

    int ahora=millis();
    if (cama.mostrandoEscena(ahora)) {
      cama.mostrarEscena(ahora);
      if (!menuPausaAbierto) avisosPlazo.mostrar(ahora);
      return;
    }
    hud.actualizarAvisosEstado();
    float intensidad=hud.intensidadEstres();
    PImage cuartoActual = escenarios.fondo();
    boolean fondoDescanso=cama.interfazAbierta && cama.yaDurmio;
    if (fondoDescanso) dibujarImagenDescanso(ahora);
    else if (cuartoActual != null) image(cuartoActual, 0, 0, ANCHO_JUEGO, ALTO_JUEGO);

    escenarios.dibujarEstanteCentral();
    if (escenarios.enHabitacion() && !fondoDescanso) dibujarBrillosHabitacion(ahora);

    // ================= JUGADOR =================

    boolean puedeMoverse = !hayInterfazAbierta() && focused;

    if (puedeMoverse) {
      jugador.actualizar();
      escenarios.comprobarSalida();
    } else {
      jugador.detenerMovimiento();
    }

    if (!fondoDescanso) jugador.mostrar();
    encargoBiblioteca.mostrarMarcadores();


    // ================= ESCRITORIO =================

    if (escritorio.interfazAbierta) escritorio.mostrarInterfaz();
    if (!hayInterfazAbierta()) mostrarAyudaRecorrido();


    // ================= HUD =================

    if (!introduccionDomingo.abierta && !escritorio.interfazAbierta) hud.mostrar();
    cama.mostrar();
    celular.mostrar();


    // ================= INSTRUCCIONES =================

    instrucciones.mostrar();


    // ================= MINIJUEGO =================

    gestorMinijuegos.mostrar();
    if (intensidad>0) {
      pushStyle();
      rectMode(CORNER);
      noStroke();
      fill(20,13,27,29*intensidad);
      rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
      popStyle();
      dibujarBordesEstres(intensidad);
    }
    if (puedeConsultarCalendario() && !escenarios.cambiando()) {
      if (!hud.calendario.abierto) hud.mostrarAvisosEstado();
      hud.calendario.mostrar();
    }
    if (encargoBiblioteca.abierto || puedeMostrarEncargo()) encargoBiblioteca.mostrar();
    if (!menuPausaAbierto) avisosPlazo.mostrar(ahora);
    introduccionDomingo.mostrar();
    cama.mostrarSalidaDelPanel(ahora);
    escenarios.mostrarFundido(millis());
  }
}
