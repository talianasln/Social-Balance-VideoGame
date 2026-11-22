
// =============================================
// VISTA DEL MINIJUEGO DE MEMORIA
// =============================================

class VistaMemoria {

  Memoria memoria;
  boolean quiereSalir = false;

  PImage[] imagenesCartas;
  PImage reversoCarta;

  final float CARTA_ANCHO = 160;
  final float CARTA_ALTO = 124;
  final float ESPACIO_X = 22;
  final float ESPACIO_Y = 16;
  final float INICIO_X = 287;
  final float INICIO_Y = 205;

  final String[] temas = {
    "BIENESTAR",
    "EQUILIBRIO",
    "PRIVACIDAD",
    "RESPETO",
    "TIEMPO",
    "USO CONSCIENTE"
  };

  final String[] mensajes = {
    "Tu valor no depende de los likes que recibes.",
    "Mantén el equilibrio entre tu vida digital y la real.",
    "Protege tu privacidad. No compartas tus datos personales.",
    "Detrás de cada pantalla hay una persona. Comunícate con respeto.",
    "Organiza tu tiempo y haz pausas al usar las redes.",
    "No necesitas revisar el celular cada vez que recibes una notificación."
  };

  VistaMemoria(long ahora, PImage[] imagenes, PImage reverso) {

    memoria = new Memoria(ahora);

    imagenesCartas = imagenes;
    reversoCarta = reverso;
  }

  // =============================================
  // DIBUJAR PANTALLA
  // =============================================

  void mostrar() {

    long ahora = millis();

    memoria.actualizar(ahora);

    pushStyle();
    imageMode(CORNER);

    dibujarFondoMinijuego();

    // Encabezado.
    fill(255, 235, 220);
    textAlign(LEFT, CENTER);
    textSize(30);
    text("SOCIAL BALANCE / MEMORIA", 120, 65);

    fill(75, 57, 60);
    textSize(15);
    text(
      "Encuentra las seis parejas y relaciona cada imagen con un hábito digital.",
      122, 129
    );

    dibujarCierreVentana();
    textAlign(CENTER,CENTER);

    // Panel de parejas.
    fill(58, 48, 62);
    rect(962, 98, 187, 47, 12);

    fill(246, 218, 202);
    textSize(14);
    text("PAREJAS ENCONTRADAS", 1055, 111);

    textSize(25);
    text(memoria.paresResueltos + " / 6", 1055, 132);

    // Cronómetro.
    fill(58, 48, 62);
    rect(760, 98, 175, 47, 12);

    fill(246, 218, 202);
    textSize(14);
    text("TIEMPO RESTANTE", 847, 111);

    textSize(25);

    if (memoria.estaEnDerrota()) {
      fill(255, 149, 149);
    } else {
      fill(246, 218, 202);
    }

    text(
      memoria.segundosRestantes(ahora) + " s",
      847, 132
    );

    // Mensaje de estado.
    String aviso = "";

    if (memoria.estaTapadas()) {

      aviso = "Prepárate para memorizar las cartas.";

    } else if (memoria.estaMemorizando()) {

      long restante = Memoria.MEMORIZACION -
                      (ahora - memoria.inicioEstado);

      aviso = "¡MEMORIZA! Se ocultarán en " +
              (int)Math.max(1, (restante + 999) / 1000) + " s.";

    } else if (memoria.estaJugando()) {

      aviso = "Selecciona dos imágenes iguales.";

    } else if (memoria.estaEnDerrota()) {

      aviso = "Se agotó el tiempo. La ronda se reiniciará.";

    } else if (memoria.estaEnVictoria()) {

      aviso = "¡LOGRADO! Encontraste las seis parejas.";
    }

    textAlign(CENTER, CENTER);
    textSize(18);

    if (memoria.estaEnVictoria()) {
      fill(35, 105, 65);
    } else if (memoria.estaEnDerrota()) {
      fill(155, 45, 55);
    } else {
      fill(65, 39, 45);
    }

    text(aviso, ANCHO_JUEGO / 2, 169);

    // Dibujar las doce cartas.
    for (int i = 0; i < 12; i++) {

      float x = INICIO_X + (i % 4) * (CARTA_ANCHO + ESPACIO_X);
      float y = INICIO_Y + (i / 4) * (CARTA_ALTO + ESPACIO_Y);

      dibujarCarta(i, x, y);
    }

    // Instrucción inferior.
    fill(75, 57, 60);
    textSize(14);
    textAlign(CENTER, CENTER);

    if (memoria.estaEnVictoria()) {
      text("¡Completaste todos los hábitos!", 640, 639);
    } else {
      text(
        "Memoriza la ubicación de las imágenes antes de que se oculten.",
        640, 639
      );
    }

    // Botón de regreso después de ganar.
    if (memoria.estaEnVictoria() && !memoria.hayMensajeActivo()) {

      fill(102, 73, 84);
      stroke(226, 176, 153);
      rect(486, 653, 308, 40, 8);

      fill(255, 239, 228);
      noStroke();
      textSize(15);
      text("VOLVER AL COMPUTADOR", 640, 673);
    }

    // Ventana emergente del hábito encontrado.
    if (memoria.hayMensajeActivo()) {
      dibujarVentanaMensaje();
    }

    popStyle();
  }

  // =============================================
  // DIBUJAR CARTAS
  // =============================================

  void dibujarCarta(int indice, float x, float y) {

    boolean visible = memoria.visible(indice);

    int idImagen = memoria.cartas[indice];

    PImage imagen = visible
      ? imagenesCartas[idImagen]
      : reversoCarta;

    pushStyle();

    strokeWeight(3);

    if (memoria.acertadas[indice]) {
      stroke(156, 238, 173);
    } else {
      stroke(190, 160, 175);
    }

    noFill();
    rect(x, y, CARTA_ANCHO, CARTA_ALTO, 8);

    if (imagen != null) {

      image(
        imagen,
        x + 3,
        y + 3,
        CARTA_ANCHO - 6,
        CARTA_ALTO - 6
      );

    } else {

      noStroke();
      fill(60, 50, 65);

      rect(
        x + 3,
        y + 3,
        CARTA_ANCHO - 6,
        CARTA_ALTO - 6
      );

      fill(255);
      textAlign(CENTER, CENTER);
      textSize(14);

      text(
        "Imagen no cargada",
        x + CARTA_ANCHO / 2,
        y + CARTA_ALTO / 2
      );
    }

    popStyle();
  }

  // =============================================
  // VENTANA EMERGENTE
  // =============================================

  void dibujarVentanaMensaje() {

    int id = memoria.obtenerIdMensaje();

    if (id < 0 || id >= mensajes.length) {
      return;
    }

    pushStyle();

    // Oscurecer el fondo para destacar el mensaje.
    noStroke();
    fill(0, 0, 0, 175);
    rect(0, 0, ANCHO_JUEGO, ALTO_JUEGO);

    // Ventana principal.
    fill(45, 36, 53);
    stroke(232, 190, 169);
    strokeWeight(3);
    rect(330, 250, 620, 220, 18);

    // Encabezado.
    noStroke();
    fill(232, 190, 169);
    textAlign(CENTER, CENTER);
    textSize(17);
    text("¡HÁBITO DESBLOQUEADO!", 640, 292);

    // Nombre del tema.
    fill(190, 222, 190);
    textSize(23);
    text(temas[id], 640, 335);

    // Mensaje educativo.
    fill(255, 239, 228);
    textSize(19);
    textAlign(CENTER, CENTER);

    text(
      mensajes[id],
      390, 365, 500, 65
    );

    // Aviso de pausa.
    fill(205, 185, 199);
    textSize(13);
    text(
      "El cronómetro está pausado mientras lees.",
      640, 443
    );

    popStyle();
  }

  // =============================================
  // INTERACCIÓN CON EL RATÓN
  // =============================================

  void presionar(float px, float py, long ahora) {

    memoria.actualizar(ahora);

    // Botón X.
    if (
      sobreCierreVentana(px,py)
    ) {
      quiereSalir = true;
      return;
    }

    // No permitir jugar mientras se lee el mensaje.
    if (memoria.hayMensajeActivo()) {
      return;
    }

    // Botón para regresar después de ganar.
    if (
      memoria.estaEnVictoria() &&
      px >= 486 && px <= 794 &&
      py >= 653 && py <= 693
    ) {
      quiereSalir = true;
      return;
    }

    // Solo seleccionar cartas durante el juego.
    if (!memoria.estaJugando()) {
      return;
    }

    for (int i = 0; i < 12; i++) {

      float x = INICIO_X + (i % 4) * (CARTA_ANCHO + ESPACIO_X);
      float y = INICIO_Y + (i / 4) * (CARTA_ALTO + ESPACIO_Y);

      if (
        px >= x && px <= x + CARTA_ANCHO &&
        py >= y && py <= y + CARTA_ALTO
      ) {
        memoria.elegir(i, ahora);
        return;
      }
    }
  }
}
