class Escritorio extends ObjetoInteractivo {
  // Ordenados por plazo para comprobar la viabilidad temporal.
  Tarea[] tareas;
  int tareaSeleccionada = 0;

  Escritorio(float zonaMinX,float zonaMaxX) {
    super(zonaMinX,zonaMaxX);
    tareas = new Tarea[] {
      new Tarea(2,"MEMORIA","Encuentra las seis parejas de cartas.\nPrimero tendrás unos segundos para memorizarlas.",90,25,18,12*60),
      new Tarea(1,"CREAR CONTRASEÑA","Resuelve un reto de palabras y números.\nUsa una contraseña inventada; hay una pista disponible.",120,30,22,15*60+30),
      new Tarea(3,"VERDADERO / FALSO","Arrastra cada afirmación a Falso o Verdadero.\nGanas con cinco aciertos; tres errores terminan el intento.",75,20,14,18*60)
    };
  }
  Tarea obtenerTareaSeleccionada() { return tareas[tareaSeleccionada]; }
  boolean mouseSobreBoton(float x,float y,float ancho,float alto) {
    return mouseJuegoX()>=x && mouseJuegoX()<=x+ancho && mouseJuegoY()>=y && mouseJuegoY()<=y+alto;
  }
  void mostrarInterfaz() {
    pushStyle(); rectMode(CORNER); imageMode(CORNER);
    noStroke(); fill(0,185); rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    if(fondoInterfazEscritorio!=null) image(fondoInterfazEscritorio,20,15,1240,690);
    fill(245,213,195); textAlign(LEFT,CENTER); textSize(29);
    text("ACTIVIDADES ACADÉMICAS",155,143);
    fill(185,167,160); textSize(16);
    text("Elige tu orden. Los costos se aplican al completar cada actividad.",155,181);
    dibujarBoton("X",1110,115,45,45,true);
    int completadas=0;
    for(int i=0;i<tareas.length;i++) {
      Tarea t=tareas[i]; if(t.completada) completadas++;
      float y=230+i*104;
      fill(i==tareaSeleccionada ? color(78,56,63) : color(36,32,39));
      stroke(i==tareaSeleccionada ? color(230,178,155) : color(100,78,82)); strokeWeight(2);
      rect(155,y,355,90,9);
      fill(255,227,215); textAlign(LEFT,CENTER); textSize(18); text(t.nombre,175,y+23);
      fill(190,174,168); textSize(14); text(t.duracion()+" · Hasta "+t.horaLimite(),175,y+49);
      fill(t.completada ? color(151,218,166) : t.bloqueo().length()==0 ? color(235,185,159) : color(190,150,150));
      text(t.completada ? "COMPLETADA" : t.bloqueo().length()==0 ? "DISPONIBLE" : "NO DISPONIBLE",175,y+72);
    }
    Tarea actual=obtenerTareaSeleccionada();
    fill(35,30,37,248); stroke(183,137,122); rect(545,230,580,385,12);
    fill(255,225,209); textAlign(LEFT,CENTER); textSize(23); text(actual.nombre,570,268);
    fill(205,185,177); textSize(16); text(actual.descripcion,570,300,530,75);
    text("DURACIÓN: "+actual.duracion()+"   |   LÍMITE: "+actual.horaLimite(),570,392);
    text("ENERGÍA: −"+actual.energia+"   |   ESTRÉS: +"+actual.estres,570,425);
    textSize(14); text("Fallar o abandonar: +"+penalizacionFalloMinutos+" min. Sin límite de tiempo real.",570,460);
    String motivo=actual.bloqueo();
    fill(actual.completada ? color(151,218,166) : color(240,185,160));
    textAlign(CENTER,CENTER); textSize(15);
    text(motivo.length()>0 ? motivo : "Necesitas energía suficiente, estrés ≤ 75 y concentración ≥ 20.",565,480,540,55);
    dibujarBoton(actual.completada ? "ACTIVIDAD COMPLETADA" : "COMENZAR ACTIVIDAD",590,550,490,48,motivo.length()==0);
    fill(185,167,160); textAlign(LEFT,CENTER); textSize(15);
    text(completadas+" / 3 actividades completadas",155,560);
    textSize(13); text("Próximamente: Conectar conceptos\ny Ordenar pasos.",155,602);
    if(completadas==3) { fill(151,218,166); textAlign(CENTER,CENTER); textSize(17); text("¡Completaste las tres actividades de esta versión!",640,650); }
    popStyle();
  }
  void dibujarBoton(String nombre,float x,float y,float ancho,float alto,boolean habilitado) {
    fill(!habilitado ? color(65,57,63) : mouseSobreBoton(x,y,ancho,alto) ? color(177,126,111) : color(133,91,83));
    stroke(213,164,145); strokeWeight(2); rect(x,y,ancho,alto,7);
    fill(habilitado ? color(255,237,224) : color(180)); textAlign(CENTER,CENTER); textSize(18);
    text(nombre,x+ancho/2,y+alto/2);
  }
  void procesarClick() {
    if(mouseSobreBoton(1110,115,45,45)) { cerrarInterfaz(); return; }
    for(int i=0;i<tareas.length;i++) if(mouseSobreBoton(155,230+i*104,355,90)) { tareaSeleccionada=i; return; }
    if(mouseSobreBoton(590,550,490,48)) gestorMinijuegos.abrir(obtenerTareaSeleccionada().id);
  }
}
