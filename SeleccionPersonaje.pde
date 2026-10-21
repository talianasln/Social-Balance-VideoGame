void mostrarSeleccionPersonaje() {

  image(fondoInicio, 0, 0, width, height);

  // Oscurecer fondo
  fill(0, 150);
  noStroke();
  rect(0, 0, width, height);


  // ================= CUADROS =================

  float cuadroW = 335;
  float cuadroH = 395;

  float hombreX = 285;
  float hombreY = 90;

  float mujerX = 660;
  float mujerY = 90;


  // ================= IMÁGENES SEGÚN TONO =================

  // Blanco por defecto solo para mostrar la vista previa
  PImage imagenHombre = hombreBlanco;
  PImage imagenMujer = mujerBlanca;

  if (tonoSeleccionado == 1) {
    imagenHombre = hombreTrigueno;
    imagenMujer = mujerTriguena;
  }

  else if (tonoSeleccionado == 2) {
    imagenHombre = hombreMoreno;
    imagenMujer = mujerMorena;
  }


  // ================= HOMBRE =================

  boolean encimaHombre =
    mouseX >= hombreX && mouseX <= hombreX + cuadroW &&
    mouseY >= hombreY && mouseY <= hombreY + cuadroH;

  if (personajeSeleccionado == 1) {
    fill(255, 40);
    stroke(255);
    strokeWeight(6);
  }

  else if (encimaHombre) {
    fill(255, 25);
    stroke(255);
    strokeWeight(4);
  }

  else {
    fill(0, 100);
    stroke(180);
    strokeWeight(2);
  }

  rect(hombreX, hombreY, cuadroW, cuadroH, 12);

  image(imagenHombre,
        hombreX,
        hombreY,
        cuadroW,
        cuadroH);


  // ================= MUJER =================

  boolean encimaMujer =
    mouseX >= mujerX && mouseX <= mujerX + cuadroW &&
    mouseY >= mujerY && mouseY <= mujerY + cuadroH;

  if (personajeSeleccionado == 2) {
    fill(255, 40);
    stroke(255);
    strokeWeight(6);
  }

  else if (encimaMujer) {
    fill(255, 25);
    stroke(255);
    strokeWeight(4);
  }

  else {
    fill(0, 100);
    stroke(180);
    strokeWeight(2);
  }

  rect(mujerX, mujerY, cuadroW, cuadroH, 12);

  image(imagenMujer,
        mujerX,
        mujerY,
        cuadroW,
        cuadroH);


  // ================= TONOS DE PIEL =================

  dibujarTono(520, 550, #EFBD94, 0); // Blanco
  dibujarTono(640, 550, #C89169, 1); // Trigueño
  dibujarTono(760, 550, #AC714C, 2); // Moreno


  // ================= BOTÓN COMENZAR =================

  // Solo aparece cuando ambas opciones están seleccionadas
  if (personajeSeleccionado != 0 &&
      tonoSeleccionado != -1) {

    botonComenzar(520, 620);
  }
}


void dibujarTono(float x, float y, color tono, int numeroTono) {

  float diametro = 55;

  boolean encima =
    dist(mouseX, mouseY, x, y) <= diametro/2;


  if (tonoSeleccionado == numeroTono) {
    stroke(255);
    strokeWeight(6);
  }

  else if (encima) {
    stroke(255);
    strokeWeight(4);
  }

  else {
    stroke(180);
    strokeWeight(2);
  }

  fill(tono);
  circle(x, y, diametro);
}


void botonComenzar(float x, float y) {

  float ancho = 240;
  float alto = 60;

  boolean encima =
    mouseX >= x && mouseX <= x + ancho &&
    mouseY >= y && mouseY <= y + alto;

  if (encima) {
    fill(255, 180);
    stroke(255);
    strokeWeight(3);
  }

  else {
    fill(0, 180);
    stroke(255);
    strokeWeight(2);
  }

  rect(x, y, ancho, alto, 8);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(22);
  text("COMENZAR", x + ancho/2, y + alto/2);
}
