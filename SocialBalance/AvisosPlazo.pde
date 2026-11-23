class AvisosPlazo {
  final java.util.ArrayDeque<Tarea> pendientes=new java.util.ArrayDeque<Tarea>();
  Tarea visible;
  int tiempoVisible;
  int ultimaActualizacion;
  boolean fueVisible;

  private boolean puedeMostrar() {
    return gestorMinijuegos.activo==0 && gestorMinijuegos.derrota.isEmpty() &&
      !escenarios.cambiando() &&
      (!escritorio.interfazAbierta || escritorio.carpetaSeleccionada<0);
  }

  void actualizar(int ahora) {
    if (!gestorMinijuegos.derrota.isEmpty()) return;
    for (Tarea tarea : escritorio.tareas) {
      if (!tarea.estaCompletada() && tarea.minutosParaEmpezar()<0) {
        gestorMinijuegos.mostrarPlazoVencido(tarea);
        return;
      }
    }
    for (Tarea tarea : escritorio.tareas) {
      if (!tarea.estaCompletada() && !tarea.avisoPlazoEnviado && tarea.minutosParaEmpezar()<=30) {
        tarea.avisoPlazoEnviado=true;
        pendientes.addLast(tarea);
      }
    }
    boolean mostrar=puedeMostrar();
    if (visible!=null && mostrar && fueVisible) tiempoVisible+=ahora-ultimaActualizacion;
    ultimaActualizacion=ahora;
    fueVisible=mostrar;
    if (visible!=null && (visible.estaCompletada() || tiempoVisible>=8000)) visible=null;
    if (visible!=null || escenarios.cambiando()) return;
    while (!pendientes.isEmpty()) {
      Tarea tarea=pendientes.removeFirst();
      if (tarea.estaCompletada()) continue;
      visible=tarea;
      tiempoVisible=0;
      vibrarCelular();
      break;
    }
  }

  void mostrar(int ahora) {
    if (visible==null || !puedeMostrar()) return;
    if (escritorio.interfazAbierta) {
      mostrarEnComputador();
      return;
    }
    float telefonoX=personajeSeleccionado==2 ? 1207 : 1234;
    float telefonoY=personajeSeleccionado==2 ? 475 : 480;
    if (cama.interfazAbierta && (cama.yaDurmio || cama.mostrandoEscena(ahora))) {
      telefonoX=personajeSeleccionado==2 ? 1134 : personajeSeleccionado==3 ? 1150 : 1080;
      telefonoY=personajeSeleccionado==2 ? 325 : personajeSeleccionado==3 ? 250 : 277;
    }
    float x=constrain(telefonoX-360,18,ANCHO_JUEGO-411);
    float y=telefonoY-117+sin(tiempoVisible*0.009)*6;
    float puntaY=telefonoY-9;
    float colaX=constrain(telefonoX-19,x+45,x+372);
    pushStyle();
    rectMode(CORNER);
    stroke(166,107,46);
    strokeWeight(3);
    fill(255,242,179);
    rect(x,y,399,78,24);
    noStroke();
    triangle(colaX-21,y+72,colaX+12,y+70,telefonoX,puntaY);
    stroke(166,107,46);
    line(colaX-17,y+77,telefonoX,puntaY);
    line(telefonoX,puntaY,colaX+12,y+77);
    noStroke();
    fill(113,57,31);
    textAlign(CENTER,CENTER);
    textSize(16);
    text(mensajeParaEmpezar(),x+199,y+25);
    textSize(19);
    text(visible.nombre,x+199,y+52);
    popStyle();
  }
  private String mensajeParaEmpezar() {
    int minutos=visible.minutosParaEmpezar();
    if (minutos<=0) return "¡Empieza ahora para llegar a tiempo!";
    return "Te quedan "+minutos+" min para empezar.";
  }

  private void mostrarEnComputador() {
    pushStyle();
    rectMode(CORNER);
    stroke(238,191,151);
    strokeWeight(2);
    fill(54,36,54,248);
    rect(1027,548,239,107,11);
    noStroke();
    fill(255,216,153);
    textAlign(LEFT,TOP);
    textSize(14);
    text("Aviso de plazo",1040,558);
    fill(255,238,224);
    textSize(13);
    textLeading(16);
    text(mensajeParaEmpezar(),1040,580,212,36);
    textSize(14);
    text(visible.nombre,1040,621);
    popStyle();
  }
}

AvisosPlazo avisosPlazo=new AvisosPlazo();

void vibrarCelular() {
  Thread audio=new Thread(() -> {
    try {
      int frecuencia=16000;
      byte[] muestras=new byte[6400];
      for (int i=0; i<muestras.length; i++) {
        int pulso=i<2560 ? i : (i>=3840 ? i-3840 : -1);
        if (pulso<0) continue;
        double t=i/(double)frecuencia;
        double envolvente=Math.min(1,Math.min(pulso,2559-pulso)/180.0);
        muestras[i]=(byte)(envolvente*(29*Math.sin(2*Math.PI*145*t)+12*Math.sin(2*Math.PI*290*t)));
      }
      javax.sound.sampled.Clip clip=javax.sound.sampled.AudioSystem.getClip();
      clip.addLineListener(evento -> {
        if (evento.getType()==javax.sound.sampled.LineEvent.Type.STOP) clip.close();
      });
      try {
        clip.open(new javax.sound.sampled.AudioFormat(frecuencia,8,1,true,false),muestras,0,muestras.length);
        clip.start();
      } catch (Exception fallo) {
        clip.close();
      }
    } catch (Exception sinAudio) {
      // El aviso visual sigue disponible si el equipo no tiene salida de audio.
    }
  },"Aviso del celular");
  audio.setDaemon(true);
  audio.start();
}
