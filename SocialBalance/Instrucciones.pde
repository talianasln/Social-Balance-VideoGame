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
      width,
      height
    );


    // ================= IMAGEN =================

    float ancho = 850;

    // Mantener proporción original
    float alto =
      ancho * imagen.height / imagen.width;


    float x =
      width/2 - ancho/2;

    float y =
      height/2 - alto/2;


    image(
      imagen,
      x,
      y,
      ancho,
      alto
    );


    popStyle();
  }


  void abrir() {

    abierta = true;
  }


  void cerrar() {

    abierta = false;
  }
  
  boolean clicCerrar() {

  return mouseX >= 980 &&
         mouseX <= 1025 &&
         mouseY >= 65 &&
         mouseY <= 110;
}

}
