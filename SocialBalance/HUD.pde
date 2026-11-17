class HUD {

  int energia = 75;
  int estres = 20;
  int concentracion = 80;
  int descansoAcumulado = 0;

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


  int minutosDelDia() { return hora * 60 + minutos; }
  int tiempoDisponible() { return max(0, FIN_DIA - minutosDelDia()); }
  boolean puedeAvanzarTiempo(int cantidad) {
    return cantidad >= 0 && cantidad <= tiempoDisponible();
  }
  boolean avanzarTiempo(int cantidad) {
    if (!puedeAvanzarTiempo(cantidad)) return false;
    int total = minutosDelDia() + cantidad;
    hora = total / 60;
    minutos = total % 60;
    return true;
  }

  boolean descansar(int duracion) {
    if ((duracion != 15 && duracion != 30) || descansoAcumulado + duracion > MAX_DESCANSO) return false;
    if (!avanzarTiempo(duracion)) return false;
    descansoAcumulado += duracion;
    modificarEnergia(duracion == 15 ? 10 : 20);
    return true;
  }

  boolean usarCelular(int duracion) {
    if (duracion != 15 && duracion != 30) return false;
    if (!avanzarTiempo(duracion)) return false;
    modificarEstres(duracion == 15 ? -12 : -20);
    modificarEnergia(duracion == 15 ? -3 : -6);
    modificarConcentracion(duracion == 15 ? -3 : -6);
    return true;
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
      mouseJuegoX() >= x &&
      mouseJuegoX() <= x + tamano &&
      mouseJuegoY() >= y &&
      mouseJuegoY() <= y + tamano;


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

    return mouseJuegoX() >= 1175 &&
           mouseJuegoX() <= 1235 &&
           mouseJuegoY() >= 20 &&
           mouseJuegoY() <= 80;
  }
}
