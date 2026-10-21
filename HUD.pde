class HUD {

  int energia = 100;
  int estres = 0;
  int concentracion = 100;

  // Hora inicial: 8:00 AM
  int hora = 8;
  int minutos = 0;


  void mostrar() {

    pushStyle();

    // ================= HORA =================

    dibujarTarjetaHora(25, 20);


    // ================= ENERGÍA =================

    dibujarBarra(
      "ENERGÍA",
      energia,
      175,
      20
    );


    // ================= ESTRÉS =================

    dibujarBarra(
      "ESTRÉS",
      estres,
      425,
      20
    );


    // ================= CONCENTRACIÓN =================

    dibujarBarra(
      "CONCENTRACIÓN",
      concentracion,
      675,
      20
    );


    // ================= AYUDA =================

    dibujarBotonAyuda();

    popStyle();
  }


  void dibujarTarjetaHora(float x, float y) {

    fill(0, 190);
    stroke(255);
    strokeWeight(2);

    rect(x, y, 125, 60, 10);


    fill(255);
    textAlign(CENTER, CENTER);
    textSize(21);

    text(
      obtenerHora(),
      x + 62.5,
      y + 30
    );
  }


  void dibujarBarra(
    String nombre,
    int valor,
    float x,
    float y
  ) {

    float ancho = 220;
    float alto = 60;


    // Caja
    fill(0, 190);
    stroke(255);
    strokeWeight(2);

    rect(x, y, ancho, alto, 10);


    // Nombre
    fill(255);
    textAlign(LEFT, CENTER);
    textSize(14);

    text(
      nombre,
      x + 15,
      y + 18
    );


    // Valor
    textAlign(RIGHT, CENTER);

    text(
      valor + "/100",
      x + ancho - 15,
      y + 18
    );


    // Fondo de barra
    noStroke();
    fill(70);

    rect(
      x + 15,
      y + 36,
      ancho - 30,
      10,
      5
    );


    // Barra
    fill(230);

    float anchoBarra = map(
      valor,
      0,
      100,
      0,
      ancho - 30
    );

    rect(
      x + 15,
      y + 36,
      anchoBarra,
      10,
      5
    );
  }


  // ================= HORA =================

  String obtenerHora() {

    String periodo = "AM";
    int horaMostrar = hora;

    if (hora >= 12) {
      periodo = "PM";
    }

    if (horaMostrar > 12) {
      horaMostrar -= 12;
    }

    if (horaMostrar == 0) {
      horaMostrar = 12;
    }


    String minutosTexto = nf(minutos, 2);


    return horaMostrar + ":" +
           minutosTexto + " " +
           periodo;
  }


  void avanzarTiempo(int minutosExtra) {

    minutos += minutosExtra;


    while (minutos >= 60) {

      minutos -= 60;
      hora++;
    }


    if (hora >= 24) {
      hora -= 24;
    }
  }


  // ================= ESTADÍSTICAS =================

  void modificarEnergia(int cantidad) {

    energia += cantidad;

    energia = constrain(
      energia,
      0,
      100
    );
  }


  void modificarEstres(int cantidad) {

    estres += cantidad;

    estres = constrain(
      estres,
      0,
      100
    );
  }


  void modificarConcentracion(int cantidad) {

    concentracion += cantidad;

    concentracion = constrain(
      concentracion,
      0,
      100
    );
  }


  // ================= AYUDA =================

  void dibujarBotonAyuda() {

    float x = 1175;
    float y = 20;

    float tamano = 60;


    boolean encima =
      mouseX >= x &&
      mouseX <= x + tamano &&
      mouseY >= y &&
      mouseY <= y + tamano;


    if (encima) {
      fill(255, 180);
      stroke(255);
      strokeWeight(3);
    }

    else {
      fill(0, 190);
      stroke(255);
      strokeWeight(2);
    }


    rect(
      x,
      y,
      tamano,
      tamano,
      10
    );


    fill(255);
    textAlign(CENTER, CENTER);
    textSize(32);

    text(
      "?",
      x + tamano/2,
      y + tamano/2 - 2
    );
  }


  boolean clicAyuda() {

    return mouseX >= 1175 &&
           mouseX <= 1235 &&
           mouseY >= 20 &&
           mouseY <= 80;
  }
}
