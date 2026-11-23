class HUD {

  final CalendarioJuego calendario = new CalendarioJuego();
  final java.util.ArrayList<Integer> avisosEstado = new java.util.ArrayList<Integer>();
  int energia = 75;
  int estres = 20;
  int concentracion = 80;
  int descansoAcumulado = 0;
  private int tareasAlUsarCelular = -1;

  int ultimoUsoCelular() { return tareasAlUsarCelular; }
  void restaurarUltimoUsoCelular(int tareas) { tareasAlUsarCelular=tareas; }

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
      false,
      175,
      20
    );


    // ================= ESTRÉS =================

    dibujarBarra(
      "ESTRÉS",
      estres,
      true,
      425,
      20
    );


    // ================= CONCENTRACIÓN =================

    dibujarBarra(
      "CONCENTRACIÓN",
      concentracion,
      false,
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
    boolean invertirColor,
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
    fill(colorEstado(invertirColor ? 100-valor : valor));

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


  int colorEstado(int nivel) {
    if (nivel<30) return color(237,99,105);
    if (nivel>70) return color(113,214,151);
    return lerpColor(color(245,159,80),color(249,224,108),map(nivel,30,70,0,1));
  }

  final int UMBRAL_EFECTO_ESTRES = 62;

  float intensidadEstres() {
    if (estres<UMBRAL_EFECTO_ESTRES) return 0;
    // Solo se puede empezar una tarea con 60 o menos, y el mayor costo es +22.
    return constrain(map(estres,UMBRAL_EFECTO_ESTRES,MAX_ESTRES_PARA_TAREA+22,0.18,1),0,1);
  }

  void actualizarAvisosEstado() {
    actualizarAviso(0,estres>=UMBRAL_EFECTO_ESTRES);
    actualizarAviso(1,energia<30);
    actualizarAviso(2,concentracion<30);
  }

  private void actualizarAviso(int estado,boolean mostrar) {
    Integer aviso=Integer.valueOf(estado);
    if (!mostrar) avisosEstado.remove(aviso);
    else if (!avisosEstado.contains(aviso)) avisosEstado.add(aviso);
  }

  void mostrarAvisosEstado() {
    pushStyle();
    rectMode(CORNER);
    textAlign(CENTER,CENTER);
    textSize(16);
    for (int i=0; i<avisosEstado.size(); i++) {
      int estado=avisosEstado.get(i);
      float y=(escritorio.interfazAbierta || cama.interfazAbierta || celular.interfazAbierta ? 702 : 648)-i*36;
      String mensaje=estado==0 ? "El estrés empieza a abrumarte. Tómate un rato con el celular." :
        estado==1 ? "Te queda poca energía. Descansa en la cama para recuperarla." :
        "Te cuesta concentrarte. Descansa en la cama antes de iniciar otra tarea.";
      noStroke();
      fill(35,25,45,235);
      rect(220,y-32,840,32,8);
      fill(255,205,179);
      text(mensaje,640,y-16);
    }
    popStyle();
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

  int limiteDescanso() { return MAX_DESCANSO+encargoBiblioteca.descansoAdicional(); }

  boolean descansar(int duracion) {
    if ((duracion != 15 && duracion != 30) || descansoAcumulado + duracion > limiteDescanso()) return false;
    if (!avanzarTiempo(duracion)) return false;
    descansoAcumulado += duracion;
    modificarEnergia(duracion == 15 ? 10 : 20);
    modificarConcentracion(recuperacionConcentracion(duracion));
    return true;
  }

  int recuperacionConcentracion(int duracion) { return duracion == 15 ? 8 : 16; }

  int alivioCelular(int duracion) { return duracion == 15 ? 12 : 20; }

  boolean celularDisponible() {
    return escritorio.cantidadCompletadas() > tareasAlUsarCelular;
  }

  boolean usarCelular(int duracion) {
    if (duracion != 15 && duracion != 30) return false;
    if (!celularDisponible() || !avanzarTiempo(duracion)) return false;
    tareasAlUsarCelular = escritorio.cantidadCompletadas();
    modificarEstres(-alivioCelular(duracion));
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
