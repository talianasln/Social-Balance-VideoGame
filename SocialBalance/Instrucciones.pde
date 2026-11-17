class Instrucciones {

  PImage imagen;

  boolean abierta = true;


  Instrucciones(PImage imagen) {

    this.imagen = imagen;
  }


  void mostrar() {

    if (!abierta) {
      return;
    }


    pushStyle();


    // ================= OSCURECER CUARTO =================

    fill(0, 170);
    noStroke();

    rect(
      0,
      0,
      ANCHO_JUEGO,
      ALTO_JUEGO
    );


    // ================= IMAGEN =================

    float ancho = 850;

    // Mantener proporción original
    float alto =
      ancho * imagen.height / imagen.width;


    float x =
      ANCHO_JUEGO/2 - ancho/2;

    float y =
      ALTO_JUEGO/2 - alto/2;


    image(
      imagen,
      x,
      y,
      ancho,
      alto
    );


    // Controles actualizados sin modificar la ilustración original.
    rectMode(CORNER);
    fill(22, 19, 24, 245);
    stroke(206, 165, 150);
    rect(180, 620, 920, 75, 10);
    fill(255, 225, 210);
    textAlign(CENTER, CENTER);
    textSize(17);
    text("WASD / Flechas: moverte en cuatro direcciones   |   E: interactuar", 640, 642);
    text("Baja junto a la cama y camina hacia la derecha para llegar al celular.", 640, 672);
    popStyle();
  }


  void abrir() {

    abierta = true;
  }


  void cerrar() {

    abierta = false;
  }
  
  boolean clicCerrar() {

  return mouseJuegoX() >= 980 &&
         mouseJuegoX() <= 1025 &&
         mouseJuegoY() >= 65 &&
         mouseJuegoY() <= 110;
}

}
