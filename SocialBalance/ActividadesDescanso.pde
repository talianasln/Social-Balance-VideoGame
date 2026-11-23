// Parámetros configurables compartidos por las actividades y los minijuegos.
final int FIN_DIA = 21 * 60 + 30;
final int MAX_DESCANSO = 105;
final int MAX_ESTRES_PARA_TAREA = 60;
final int MIN_CONCENTRACION_PARA_TAREA = 30;
int penalizacionFalloMinutos = 15;

boolean hayInterfazAbierta() {
  return menuPausaAbierto || escenarios.cambiando() || escritorio.interfazAbierta || cama.interfazAbierta || celular.interfazAbierta ||
         instrucciones.abierta || introduccionDomingo.abierta || encargoBiblioteca.abierto || hud.calendario.abierto || gestorMinijuegos.activo != 0 || gestorMinijuegos.derrota.length()>0;
}

ObjetoInteractivo objetoCercano() {
  if (!escenarios.enHabitacion()) return null;
  if (celular.jugadorCerca(jugador)) return celular;
  if (cama.jugadorCerca(jugador)) return cama;
  if (escritorio.jugadorCerca(jugador)) return escritorio;
  return null;
}

void mostrarAyudaRecorrido() {
  ObjetoInteractivo objeto = objetoCercano();
  String mensaje = "Acércate a alguna zona para interactuar";
  if (escenarios.cercaPuerta()) mensaje = escenarios.enHabitacion() ? "E: salir al pasillo" : "E: volver a la habitación";
  else if (escenarios.actual==escenarios.PASILLO) mensaje = "Avanza por el pasillo para llegar a la biblioteca";
  else if (escenarios.actual==escenarios.BIBLIOTECA) {
    if (!encargoBiblioteca.disponible()) mensaje="Parece que no tengo nada que hacer aquí por ahora.";
    else if (encargoBiblioteca.estanteCercano()>=0) mensaje="E: revisar estante (−10 de energía)";
    else mensaje="Vuelve por el centro de la parte inferior para salir al pasillo";
  }
  else if (objeto == cama) mensaje = "E: descansar en la cama";
  else if (objeto == celular) mensaje = "E: usar el celular";
  else if (objeto == escritorio) mensaje = "E: actividades académicas";
  pushStyle();
  rectMode(CORNER);
  fill(22, 19, 24, 230); stroke(206, 165, 150);
  rect(330, 665, 620, 40, 9);
  fill(255, 225, 210); textSize(18); textAlign(CENTER, CENTER);
  text(mensaje, 640, 685);
  popStyle();
}

// Panel compartido: evita duplicar botones, selección y cierre.
abstract class PanelActividad extends ObjetoInteractivo {
  int duracion = 15;
  String titulo;
  String aviso = "";
  int inicioActividad;
  boolean actividadEnCurso;

  PanelActividad(String titulo, float minX, float maxX, float minY, float maxY) {
    super(minX, maxX);
    this.titulo = titulo;
    zonaMinY = minY; zonaMaxY = maxY;
  }
  abstract String detalle();
  abstract String bloqueo();
  abstract boolean aplicar();
  abstract String accion();

  void abrirInterfaz() {
    super.abrirInterfaz();
    duracion = 15; aviso = "";
    jugador.detenerMovimiento();
  }

  boolean sobre(float x, float y, float w, float h) {
    float escala=escalaPanel();
    float px=640+(mouseJuegoX()-640)/escala, py=360+(mouseJuegoY()-360)/escala;
    return px>=x && px<=x+w && py>=y && py<=y+h;
  }

  void dibujarBoton(String texto, float x, float y, float w, float h, boolean seleccionado, boolean habilitado) {
    fill(!habilitado ? color(65,57,63) : seleccionado || sobre(x,y,w,h) ? color(133,91,83) : color(54,43,49));
    stroke(218,173,157); strokeWeight(seleccionado ? 3 : 1);
    rect(x,y,w,h,8);
    fill(habilitado ? color(255,237,224) : color(165));
    textAlign(CENTER,CENTER); textSize(19);
    text(texto,x+w/2,y+h/2);
  }

  float escalaPanel() { return 1; }

  PImage imagenPanel() { return null; }

  float xCierre() { return imagenPanel()!=null ? 1210 : 1060; }
  float yCierre() { return imagenPanel()!=null ? 24 : 125; }
  float yDuracion() { return imagenPanel()!=null ? 225 : 235; }
  float yAccion() { return imagenPanel()!=null ? 590 : 535; }

  void dibujarFondoPanel() { dibujarFondoComputador(20,15,1240,690); }

  boolean progresoEnPanel() { return true; }

  void mostrar() {
    if (!interfazAbierta) return;
    pushStyle(); rectMode(CORNER); imageMode(CORNER);
    noStroke(); fill(0,118); rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    PImage imagen=imagenPanel();
    if (imagen==null) dibujarFondoPanel();
    pushMatrix();
    translate(640,360);
    scale(escalaPanel());
    translate(-640,-360);
    if (imagen!=null) {
      noTint();
      dibujarImagenAjustada(imagen,0,0,ANCHO_JUEGO,ALTO_JUEGO);
    } else {
      fill(35,30,37,248); stroke(183,137,122); rect(145,110,990,510,12);
      fill(255,225,209); textAlign(LEFT,CENTER); textSize(30); text(titulo,180,150);
      fill(190,174,168); textSize(17);
      text("Elige la duración. El tiempo del juego avanza al terminar la actividad.",180,200);
    }
    dibujarBoton("X",xCierre(),yCierre(),45,45,false,!actividadEnCurso);
    dibujarBoton("15 MINUTOS",250,yDuracion(),340,55,duracion==15,!actividadEnCurso);
    dibujarBoton("30 MINUTOS",690,yDuracion(),340,55,duracion==30,!actividadEnCurso);
    mostrarDetalle(imagen!=null);
    fill(imagen!=null ? color(69,39,36) : color(190,174,168));
    textAlign(CENTER,CENTER); textSize(16);
    text("Hora actual: " + hud.obtenerHora() + "   |   Tiempo disponible: " + hud.tiempoDisponible() + " min",640,imagen!=null ? 520 : 460);
    if (actividadEnCurso && progresoEnPanel()) mostrarProgreso(millis());
    else {
      String motivo = bloqueo();
      if (imagen!=null) fill(motivo.length()>0 ? color(133,36,53) : color(38,91,55));
      else fill(motivo.length()>0 ? color(255,180,150) : color(170,225,185));
      textSize(16);
      text(motivo.length()>0 ? motivo : aviso,640,imagen!=null ? 555 : 495);
      dibujarBoton(accion(),420,yAccion(),440,55,false,!actividadEnCurso && motivo.length()==0);
    }
    popMatrix();
    popStyle();
  }

  void mostrarDetalle(boolean ilustrado) {
    fill(ilustrado ? color(69,39,36) : color(255,230,214));
    textAlign(CENTER,CENTER); textSize(21);
    text(detalle(),640,ilustrado ? 412 : 370);
  }

  int duracionAnimacion() { return duracion*200; }

  void actualizarActividad(int ahora) {
    if (!actividadEnCurso || ahora-inicioActividad<duracionAnimacion()) return;
    actividadEnCurso=false;
    boolean realizada=aplicar();
    aviso=realizada ? "Actividad realizada. Pasaron "+duracion+" minutos." : bloqueo();
    if (realizada) guardado.guardar();
  }

  private void mostrarProgreso(int ahora) {
    float progreso=constrain((ahora-inicioActividad)/float(duracionAnimacion()),0,1);
    textAlign(CENTER,CENTER);
    textSize(16);
    float y=yAccion();
    fill(imagenPanel()!=null ? color(69,39,36) : color(255,218,200));
    text(this==cama ? "Descansando…" : "Tomándote un rato con el celular…",640,y-28);
    stroke(218,173,157);
    strokeWeight(2);
    fill(73,54,71);
    rect(420,y-1,440,37,12);
    if (progreso>0) {
      noStroke();
      fill(165,101,127);
      rect(425,y+4,430*progreso,27,8);
    }
    fill(255,237,224);
    text(round(progreso*100)+" %",640,y+17);
  }

  void procesarClick() {
    if (actividadEnCurso) return;
    if (sobre(xCierre(),yCierre(),45,45)) { cerrarInterfaz(); return; }
    if (sobre(250,yDuracion(),340,55)) { duracion=15; aviso=""; return; }
    if (sobre(690,yDuracion(),340,55)) { duracion=30; aviso=""; return; }
    if (sobre(420,yAccion(),440,55) && bloqueo().isEmpty()) {
      inicioActividad=millis();
      actividadEnCurso=true;
      aviso="";
    }
  }
}

class Cama extends PanelActividad {
  final int MEDIO_FUNDIDO=170;
  boolean yaDurmio;

  Cama() { super("DESCANSAR",700,1160,475,640); }

  void cerrarInterfaz() {
    super.cerrarInterfaz();
    yaDurmio=false;
  }

  float escalaPanel() { return 0.88; }

  PImage imagenPanel() { return imagenInterfazDescanso; }

  void mostrarDetalle(boolean ilustrado) {
    if (!ilustrado) { super.mostrarDetalle(false); return; }
    fill(69,39,36); textAlign(LEFT,CENTER); textSize(22);
    String[] filas=split(detalle(),'\n');
    for (int i=0; i<filas.length; i++) text(filas[i],580,355+i*57);
  }

  void dibujarFondoPanel() {}

  boolean progresoEnPanel() { return false; }

  boolean mostrandoEscena(int ahora) {
    return interfazAbierta && actividadEnCurso && ahora-inicioActividad>=MEDIO_FUNDIDO;
  }

  void mostrarEscena(int ahora) {
    dibujarImagenDescanso(ahora);
    float avance=constrain((ahora-inicioActividad-MEDIO_FUNDIDO)/float(duracionAnimacion()-MEDIO_FUNDIDO),0,1);
    pushStyle();
    rectMode(CORNER);
    stroke(252,219,176);
    strokeWeight(2);
    fill(62,36,31,235);
    rect(420,625,440,45,12);
    noStroke();
    int acento=personajeSeleccionado==2 ? color(213,128,128) :
      personajeSeleccionado==3 ? color(215,139,86) : color(192,124,73);
    fill(acento);
    if (avance>0) rect(425,630,430*avance,35,8);
    fill(255,237,211);
    textAlign(CENTER,CENTER);
    textSize(17);
    text("Descansando · "+round(avance*100)+" %",640,648);
    popStyle();
    dibujarFundidoDescanso(1-(ahora-inicioActividad-MEDIO_FUNDIDO)/float(MEDIO_FUNDIDO));
  }

  void dibujarFundidoDescanso(float opacidad) {
    if (opacidad<=0) return;
    pushStyle();
    rectMode(CORNER);
    noStroke();
    fill(0,255*constrain(opacidad,0,1));
    rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    popStyle();
  }

  void mostrarSalidaDelPanel(int ahora) {
    if (interfazAbierta && actividadEnCurso && !mostrandoEscena(ahora))
      dibujarFundidoDescanso((ahora-inicioActividad)/float(MEDIO_FUNDIDO));
  }
  String accion() { return "DESCANSAR " + duracion + " MINUTOS"; }
  String detalle() {
    int recuperacion = min(100-hud.energia,duracion==15 ? 10 : 20);
    int foco = min(100-hud.concentracion,hud.recuperacionConcentracion(duracion));
    return "Energía: " + hud.energia + " → " + (hud.energia+recuperacion) + "   (+" + recuperacion + ")\n" +
           "Descanso disponible: " + (hud.limiteDescanso()-hud.descansoAcumulado) + " de " + hud.limiteDescanso() + " min\n" +
           "Concentración: " + hud.concentracion + " → " + (hud.concentracion+foco) + "   (+" + foco + ")";
  }
  String bloqueo() {
    if (hud.descansoAcumulado+duracion>hud.limiteDescanso()) return "No quedan suficientes minutos de descanso.";
    if (!hud.puedeAvanzarTiempo(duracion)) return "No queda tiempo para este descanso antes de las 9:30 p. m.";
    return "";
  }
  boolean aplicar() {
    boolean aplicado=hud.descansar(duracion);
    if (aplicado) yaDurmio=true;
    return aplicado;
  }
}

class Celular extends PanelActividad {
  Celular() { super("CELULAR · REDES SOCIALES",1120,1260,610,690); }
  PImage imagenPanel() { return imagenInterfazCelular; }

  void mostrarDetalle(boolean ilustrado) {
    if (!ilustrado) { super.mostrarDetalle(false); return; }
    fill(69,39,36); textAlign(LEFT,CENTER); textSize(22);
    String[] filas=split(detalle(),'\n');
    for (int i=0; i<filas.length; i++) text(filas[i],585,356+i*55);
  }

  String accion() { return "USAR CELULAR " + duracion + " MINUTOS"; }
  String detalle() {
    int costo = duracion==15 ? 3 : 6;
    return "Estrés: " + hud.estres + " → " + max(0,hud.estres-hud.alivioCelular(duracion)) + "\n" +
           "Energía: " + hud.energia + " → " + max(0,hud.energia-costo) + "\n" +
           "Concentración: " + hud.concentracion + " → " + max(0,hud.concentracion-costo);
  }
  String bloqueo() {
    if (!hud.puedeAvanzarTiempo(duracion)) return "No queda tiempo para este uso antes de las 9:30 p. m.";
    return hud.celularDisponible() ? "" : "Completa una actividad del computador antes de volver a usar el celular.";
  }
  boolean aplicar() { return hud.usarCelular(duracion); }
}
