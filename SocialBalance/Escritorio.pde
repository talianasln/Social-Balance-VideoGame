class Escritorio extends ObjetoInteractivo {

  Tarea tarea1;
  Tarea tarea2;


  Escritorio(float zonaMinX, float zonaMaxX) {

    super(zonaMinX, zonaMaxX);

    // ================= TAREAS =================

    tarea1 = new Tarea(
      "TAREA 1",
      "1 h 30 min",
      20,
      15,
      "1:00 PM",
      false
    );

    tarea2 = new Tarea(
      "TAREA 2",
      "2 h",
      30,
      25,
      "5:00 PM",
      true
    );
  }


  void actualizar(Jugador jugador) {

    if (!interfazAbierta && jugadorCerca(jugador)) {
      mostrarMensajeInteraccion();
    }

    if (interfazAbierta) {
      mostrarInterfaz();
    }
  }


  // ================= MENSAJE DE INTERACCIÓN =================

  void mostrarMensajeInteraccion() {

    float x = width / 2;
    float y = 650;

    rectMode(CENTER);

    fill(0, 190);
    stroke(255);
    strokeWeight(2);

    rect(x, y, 330, 55, 10);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(20);

    text("Presiona E para interactuar", x, y);

    rectMode(CORNER);
  }


  // ================= INTERFAZ =================

  void mostrarInterfaz() {

    // Oscurecer habitación
    fill(0, 165);
    noStroke();
    rect(0, 0, width, height);


    float panelX = 190;
    float panelY = 75;

    float panelW = 900;
    float panelH = 570;


    // Panel principal
    fill(25, 27, 35, 250);
    stroke(220);
    strokeWeight(2);

    rect(panelX, panelY, panelW, panelH, 20);


    // ================= TÍTULO =================

    fill(255);
    textAlign(LEFT, CENTER);
    textSize(32);

    text(
      "TAREAS",
      panelX + 45,
      panelY + 50
    );


    fill(180);
    textSize(16);

    text(
      "Organiza tus actividades académicas",
      panelX + 45,
      panelY + 85
    );


    // Línea separadora
    stroke(90);
    strokeWeight(1);

    line(
      panelX + 40,
      panelY + 115,
      panelX + panelW - 40,
      panelY + 115
    );


    // ================= TARJETAS =================

    mostrarTarjeta(
      tarea1,
      250,
      230
    );

    mostrarTarjeta(
      tarea2,
      665,
      230
    );


    // ================= BOTÓN X =================

    mostrarBotonCerrar();
  }


  // ================= TARJETA =================

  void mostrarTarjeta(Tarea tarea, float x, float y) {

    float ancho = 365;
    float alto = 330;


    // Fondo tarjeta
    fill(38, 41, 52);
    stroke(100);
    strokeWeight(2);

    rect(x, y, ancho, alto, 15);


    // Nombre
    fill(255);
    textAlign(LEFT, CENTER);
    textSize(25);

    text(
      tarea.nombre,
      x + 30,
      y + 40
    );


    // Línea
    stroke(80);

    line(
      x + 25,
      y + 70,
      x + ancho - 25,
      y + 70
    );


    // ================= DATOS =================

    fill(210);
    textSize(18);

    text(
      "Duración: " + tarea.duracion,
      x + 30,
      y + 110
    );

    text(
      "Energía: -" + tarea.energia,
      x + 30,
      y + 150
    );

    text(
      "Estrés: +" + tarea.estres,
      x + 30,
      y + 190
    );

    text(
      "Límite: " + tarea.horaLimite,
      x + 30,
      y + 230
    );



// ================= BOTÓN =================

float botonX = x + 30;
float botonY = y + 265;

float botonW = ancho - 60;
float botonH = 45;


// ================= COMPLETADA =================

if (tarea.completada) {

  fill(90);
  stroke(150);

  rect(
    botonX,
    botonY,
    botonW,
    botonH,
    8
  );

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(17);

  text(
    "COMPLETADA",
    botonX + botonW/2,
    botonY + botonH/2
  );
}


// ================= BLOQUEADA =================

else if (tarea.bloqueada) {

  fill(65);
  stroke(90);

  rect(
    botonX,
    botonY,
    botonW,
    botonH,
    8
  );

  fill(150);
  textAlign(CENTER, CENTER);
  textSize(17);

  text(
    "BLOQUEADA",
    botonX + botonW/2,
    botonY + botonH/2
  );
}


// ================= DISPONIBLE =================

else {

  boolean encima =
    mouseX >= botonX &&
    mouseX <= botonX + botonW &&
    mouseY >= botonY &&
    mouseY <= botonY + botonH;


  if (encima) {
    fill(255, 200);
    stroke(255);
  }

  else {
    fill(230);
    stroke(255);
  }

  strokeWeight(2);

  rect(
    botonX,
    botonY,
    botonW,
    botonH,
    8
  );


  fill(20);
  textAlign(CENTER, CENTER);
  textSize(17);

  text(
    "REALIZAR",
    botonX + botonW/2,
    botonY + botonH/2
  );
}
  }


  // ================= X =================

  void mostrarBotonCerrar() {

    boolean encima = clicCerrar();


    if (encima) {
      fill(255, 100);
    }
    else {
      fill(255, 30);
    }

    noStroke();

    rect(
      1020,
      100,
      40,
      40,
      8
    );


    fill(255);
    textAlign(CENTER, CENTER);
    textSize(24);

    text(
      "X",
      1040,
      118
    );
  }


  boolean clicCerrar() {

    return mouseX >= 1020 &&
           mouseX <= 1060 &&
           mouseY >= 100 &&
           mouseY <= 140;
  }
  
  boolean clicRealizarTarea1() {

  // Posición de la tarjeta 1:
  // x = 250
  // y = 230

  float botonX = 280;
  float botonY = 495;

  float botonW = 305;
  float botonH = 45;


  return mouseX >= botonX &&
         mouseX <= botonX + botonW &&
         mouseY >= botonY &&
         mouseY <= botonY + botonH;
}
}
