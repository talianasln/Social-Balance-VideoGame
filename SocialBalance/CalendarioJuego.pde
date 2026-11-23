boolean puedeConsultarCalendario() {
  return !introduccionDomingo.abierta && !instrucciones.abierta && gestorMinijuegos.activo==0 && gestorMinijuegos.derrota.isEmpty();
}

class CalendarioJuego {
  boolean abierto = false;

  private boolean sobre(float x,float y,float ancho,float alto) {
    return mouseJuegoX()>=x && mouseJuegoX()<=x+ancho &&
           mouseJuegoY()>=y && mouseJuegoY()<=y+alto;
  }

  private float botonX() { return escritorio.interfazAbierta ? 178 : 25; }
  private float botonY() { return escritorio.interfazAbierta ? 668 : 650; }

  boolean sobreBoton() { return sobre(botonX(),botonY(),52,48); }

  void procesarClick() {
    if (abierto) {
      if (sobre(1195,50,48,42)) abierto=false;
    } else if (sobreBoton()) {
      abierto=true;
      jugador.detenerMovimiento();
    }
  }

  int minutosParaEmpezar(Tarea tarea) {
    return tarea.minutosParaEmpezar();
  }

  int colorEstado(Tarea tarea) {
    if (tarea.estaCompletada()) return color(66,100,52);
    int margen=minutosParaEmpezar(tarea);
    if (margen<=15) return color(153,29,48);
    if (margen<30) return color(139,80,15);
    return color(76,37,36);
  }

  void mostrar() {
    pushStyle();
    rectMode(CORNER);
    if (abierto) mostrarPanel();
    else dibujarBoton();
    popStyle();
  }

  private void dibujarBoton() {
    pushMatrix();
    translate(botonX()-25,botonY()-650);
    stroke(227,194,184);
    strokeWeight(2);
    fill(sobreBoton() ? color(116,78,103) : color(35,25,45));
    rect(25,650,52,48,8);
    noFill();
    rect(38,662,26,24,3);
    line(38,670,64,670);
    line(44,658,44,666);
    line(58,658,58,666);
    point(46,677);
    point(55,677);
    point(46,682);
    point(55,682);
    popMatrix();
  }

  private void mostrarPanel() {
    noStroke();
    fill(26,15,23,178);
    rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    pushMatrix();
    translate(88,46);
    scale(0.66);
    imageMode(CORNER);
    noTint();
    image(fondoCalendario,0,0,1672,941);
    textAlign(CENTER,CENTER);
    fill(76,37,36);
    textSize(49);
    text("Calendario",836,149);
    textSize(25);
    text("Hora actual: "+hud.obtenerHora(),836,192);

    fill(255,240,210);
    textSize(31);
    text("Tarea",380,302);
    text("Hora de entrega",860,302);
    text("Estado y última hora de inicio",1370,302);

    int fila=0;
    for (Tarea tarea : escritorio.tareas) {
      float y=391+fila*88;
      fila++;
      int margen=minutosParaEmpezar(tarea);
      if (!tarea.estaCompletada() && margen<30) {
        fill(margen<=15 ? color(247,208,200) : color(251,226,163));
        rect(1128,y-29,480,60,18);
      }
      if (tarea.estaCompletada()) {
        stroke(colorEstado(tarea));
        strokeWeight(8);
        strokeCap(ROUND);
        line(79,y,91,y+12);
        line(91,y+12,114,y-15);
        noStroke();
      }
      fill(76,37,36);
      textSize(29);
      text(tarea.nombre,380,y);
      text(tarea.horaLimite(),860,y);
      fill(colorEstado(tarea));
      String estado=tarea.estaCompletada() ? "Hecha" : "Pendiente";
      if (tarea.estaCompletada()) text(estado,1370,y);
      else {
        textSize(26);
        text(estado,1370,y-14);
        textSize(21);
        text("Empezar a más tardar: "+tarea.ultimaHoraDeInicio(),1370,y+15);
      }
    }
    popMatrix();

    fill(sobre(1195,50,48,42) ? color(151,57,73) : color(111,39,54));
    stroke(251,225,175);
    strokeWeight(2);
    rect(1195,50,48,42,8);
    fill(255,240,210);
    textAlign(CENTER,CENTER);
    textSize(20);
    text("X",1219,71);
  }
}
