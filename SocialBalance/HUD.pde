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


  final PFont letraHUD = new PFont(new java.awt.Font("SansSerif",java.awt.Font.PLAIN,20),true);

  void mostrar() {
    pushStyle();
    rectMode(CORNER);
    textFont(letraHUD);
    tarjetaHUD(25,20,125);
    fill(85,48,57);
    textAlign(CENTER,CENTER);
    textSize(20);
    text(obtenerHora(),87.5,49);
    dibujarBarra("Energía",energia,energia,175,color(239,204,137));
    dibujarBarra("Estrés",estres,100-estres,425,color(224,159,169));
    dibujarBarra("Concentración",concentracion,concentracion,675,color(171,187,216));
    dibujarBotonAyuda();
    popStyle();
  }

  private void tarjetaHUD(float x,float y,float ancho) {
    noStroke();
    fill(63,35,43,100);
    rect(x,y+3,ancho,56,10);
    fill(253,239,221);
    stroke(154,94,99);
    strokeWeight(1.5);
    rect(x,y,ancho,56,10);
  }

  private void dibujarBarra(String nombre,int valor,int bienestar,float x,int acento) {
    float y=20;
    tarjetaHUD(x,y,220);
    noStroke();
    fill(acento);
    ellipse(x+16,y+17,9,9);
    fill(77,46,56);
    textAlign(LEFT,CENTER);
    textSize(16);
    text(nombre,x+26,y+17);
    textAlign(RIGHT,CENTER);
    textSize(14);
    text(valor+"/100",x+205,y+17);
    fill(226,207,199);
    rect(x+13,y+33,194,12,6);
    if (valor>0) {
      fill(colorEstado(bienestar));
      rect(x+13,y+33,194*valor/100.0,12,6);
    }
  }

  int colorEstado(int nivel) {
    if (nivel<30) return color(218,133,140);
    if (nivel>70) return color(153,188,147);
    return lerpColor(color(230,170,111),color(242,215,139),map(nivel,30,70,0,1));
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
