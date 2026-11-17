// Parámetros configurables compartidos por las actividades y los minijuegos.
final int FIN_DIA = 21 * 60 + 30;
final int MAX_DESCANSO = 90;
int penalizacionFalloMinutos = 15;

boolean hayInterfazAbierta() {
  return escritorio.interfazAbierta || cama.interfazAbierta || celular.interfazAbierta ||
         instrucciones.abierta || gestorMinijuegos.activo != 0 || gestorMinijuegos.derrota.length()>0;
}

ObjetoInteractivo objetoCercano() {
  if (celular.jugadorCerca(jugador)) return celular;
  if (cama.jugadorCerca(jugador)) return cama;
  if (escritorio.jugadorCerca(jugador)) return escritorio;
  return null;
}

void mostrarAyudaRecorrido() {
  ObjetoInteractivo objeto = objetoCercano();
  String mensaje = "WASD / Flechas: moverte";
  if (objeto == cama) mensaje = "E: descansar en la cama";
  else if (objeto == celular) mensaje = "E: usar el celular";
  else if (objeto == escritorio) mensaje = "E: actividades académicas";
  pushStyle();
  rectMode(CORNER);
  fill(22, 19, 24, 230); stroke(206, 165, 150);
  rect(430, 665, 420, 40, 9);
  fill(255, 225, 210); textSize(18); textAlign(CENTER, CENTER);
  text(mensaje, 640, 685);
  popStyle();
}

// Panel compartido: evita duplicar botones, selección y cierre.
abstract class PanelActividad extends ObjetoInteractivo {
  int duracion = 15;
  String titulo;
  String aviso = "";

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
    return mouseJuegoX() >= x && mouseJuegoX() <= x+w &&
           mouseJuegoY() >= y && mouseJuegoY() <= y+h;
  }

  void dibujarBoton(String texto, float x, float y, float w, float h, boolean seleccionado, boolean habilitado) {
    fill(!habilitado ? color(65,57,63) : seleccionado || sobre(x,y,w,h) ? color(133,91,83) : color(54,43,49));
    stroke(218,173,157); strokeWeight(seleccionado ? 3 : 1);
    rect(x,y,w,h,8);
    fill(habilitado ? color(255,237,224) : color(165));
    textAlign(CENTER,CENTER); textSize(19);
    text(texto,x+w/2,y+h/2);
  }

  void mostrar() {
    if (!interfazAbierta) return;
    pushStyle(); rectMode(CORNER); imageMode(CORNER);
    noStroke(); fill(0,185); rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    if (fondoInterfazEscritorio != null) image(fondoInterfazEscritorio,20,15,1240,690);
    fill(35,30,37,248); stroke(183,137,122); rect(145,110,990,510,12);
    fill(255,225,209); textAlign(LEFT,CENTER); textSize(30); text(titulo,180,150);
    dibujarBoton("X",1060,125,45,45,false,true);
    fill(190,174,168); textAlign(LEFT,CENTER); textSize(17);
    text("Elige la duración. El tiempo avanza al confirmar.",180,200);
    dibujarBoton("15 MINUTOS",250,235,340,55,duracion==15,true);
    dibujarBoton("30 MINUTOS",690,235,340,55,duracion==30,true);
    fill(255,230,214); textAlign(CENTER,CENTER); textSize(21);
    text(detalle(),640,370);
    fill(190,174,168); textSize(16);
    text("Hora actual: " + hud.obtenerHora() + "   |   Tiempo disponible: " + hud.tiempoDisponible() + " min",640,460);
    String motivo = bloqueo();
    fill(motivo.length()>0 ? color(255,180,150) : color(170,225,185)); textSize(16);
    text(motivo.length()>0 ? motivo : aviso,640,495);
    dibujarBoton(accion(),420,535,440,55,false,motivo.length()==0);
    popStyle();
  }

  void procesarClick() {
    if (sobre(1060,125,45,45)) { cerrarInterfaz(); return; }
    if (sobre(250,235,340,55)) { duracion=15; aviso=""; return; }
    if (sobre(690,235,340,55)) { duracion=30; aviso=""; return; }
    if (sobre(420,535,440,55) && bloqueo().length()==0 && aplicar()) {
      aviso = "Acción realizada: avanzaron " + duracion + " minutos.";
      gestorMinijuegos.comprobarViabilidad();
    }
  }
}

class Cama extends PanelActividad {
  Cama() { super("DESCANSAR",745,1160,475,625); }
  String accion() { return "DESCANSAR " + duracion + " MINUTOS"; }
  String detalle() {
    int recuperacion = min(100-hud.energia,duracion==15 ? 10 : 20);
    return "Energía: " + hud.energia + " → " + (hud.energia+recuperacion) + "   (+" + recuperacion + ")\n" +
           "Descanso disponible: " + (MAX_DESCANSO-hud.descansoAcumulado) + " de 90 min\n" +
           "Estrés y concentración sin cambios";
  }
  String bloqueo() {
    if (hud.descansoAcumulado+duracion>MAX_DESCANSO) return "No quedan suficientes minutos de descanso.";
    if (!hud.puedeAvanzarTiempo(duracion)) return "No queda tiempo para este descanso antes de las 9:30 p. m.";
    return "";
  }
  boolean aplicar() { return hud.descansar(duracion); }
}

class Celular extends PanelActividad {
  Celular() { super("CELULAR · REDES SOCIALES",1145,1260,620,690); }
  String accion() { return "USAR CELULAR " + duracion + " MINUTOS"; }
  String detalle() {
    int costo = duracion==15 ? 3 : 6;
    return "Estrés: " + hud.estres + " → " + max(0,hud.estres-(duracion==15 ? 12 : 20)) + "\n" +
           "Energía: " + hud.energia + " → " + max(0,hud.energia-costo) + "\n" +
           "Concentración: " + hud.concentracion + " → " + max(0,hud.concentracion-costo);
  }
  String bloqueo() {
    return hud.puedeAvanzarTiempo(duracion) ? "" : "No queda tiempo para este uso antes de las 9:30 p. m.";
  }
  boolean aplicar() { return hud.usarCelular(duracion); }
}
