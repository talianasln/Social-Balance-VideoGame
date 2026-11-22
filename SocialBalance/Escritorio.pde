// El sillón del Cuarto1 ocupa más ancho que la silla del Cuarto2.
float bordeDerechoEscritorio() { return personajeSeleccionado==2 ? 430 : 355; }

class Escritorio extends ObjetoInteractivo {
  // Ordenados por plazo para comprobar la viabilidad temporal.
  Tarea[] tareas;
  int tareaSeleccionada = 0;
  int carpetaSeleccionada = -1;
  // Coordenadas en la imagen original de 1672 x 941, incluyendo las etiquetas.
  float[][] carpetas = {{90,90,170,140},{90,245,170,160},{90,410,170,140},
                        {90,550,170,140},{90,695,170,140}};
  int[] tareaPorCarpeta = {0,3,1,2,-1};
  String[] nombresCarpetas = {"MEMORIA","VERDADERO / FALSO","CREAR CONTRASEÑA",
                             "CONECTAR CONCEPTOS","ORDENAR PASOS"};

  void abrirInterfaz() {
    super.abrirInterfaz();
    carpetaSeleccionada=-1;
  }

  boolean sobreCarpeta(int indice) {
    float[] r=carpetas[indice];
    return mouseSobreBoton(r[0]*ANCHO_JUEGO/1672.0,r[1]*ALTO_JUEGO/941.0,
                          r[2]*ANCHO_JUEGO/1672.0,r[3]*ALTO_JUEGO/941.0);
  }

  Escritorio() {
    super(220, 505);
    // Zona frente al escritorio, medida en los pies del personaje.
    // Incluye el borde izquierdo y permite acercarse desde abajo.
    zonaMinY = 475;
    zonaMaxY = 615;
    tareas = new Tarea[] {
      new Tarea(2,"MEMORIA","Encuentra las seis parejas de cartas.\nPrimero tendrás unos segundos para memorizarlas.",90,25,18,12*60),
      new Tarea(1,"CREAR CONTRASEÑA","Resuelve un reto de palabras y números.\nUsa una contraseña inventada; hay una pista disponible.",120,30,22,15*60+30),
      new Tarea(4,"CONECTAR CONCEPTOS","Relaciona cinco conceptos con sus definiciones.\nPuedes deshacer conexiones antes de verificar.",60,18,12,17*60),
      new Tarea(3,"VERDADERO / FALSO","Arrastra cada afirmación a Falso o Verdadero.\nGanas con cinco aciertos; tres errores terminan el intento.",75,20,14,18*60)
    };
  }
  boolean jugadorCerca(Jugador jugador) {
    // Frente al mueble o junto al costado de la silla, según la habitación.
    float px=jugador.piesX(), py=jugador.piesY();
    float borde=bordeDerechoEscritorio();
    boolean frente=px>=zonaMinX && px<=borde+75 && py>=550 && py<=zonaMaxY;
    boolean costado=px>=borde && px<=borde+75 && py>=zonaMinY && py<=550;
    return frente || costado;
  }

  Tarea obtenerTareaSeleccionada() { return tareas[tareaSeleccionada]; }
  boolean mouseSobreBoton(float x,float y,float ancho,float alto) {
    return mouseJuegoX()>=x && mouseJuegoX()<=x+ancho && mouseJuegoY()>=y && mouseJuegoY()<=y+alto;
  }
  void mostrarInterfaz() {
    pushStyle(); rectMode(CORNER); imageMode(CORNER);
    background(48,35,65);
    if(fondoInterfazEscritorio!=null) image(fondoInterfazEscritorio,0,0,ANCHO_JUEGO,ALTO_JUEGO);
    int completadas=0;
    for(Tarea t:tareas) if(t.completada) completadas++;
    for(int i=0;i<carpetas.length;i++) {
      float[] r=carpetas[i];
      float x=r[0]*ANCHO_JUEGO/1672.0, y=r[1]*ALTO_JUEGO/941.0;
      float w=r[2]*ANCHO_JUEGO/1672.0, h=r[3]*ALTO_JUEGO/941.0;
      if(sobreCarpeta(i) || carpetaSeleccionada==i) {
        fill(255,sobreCarpeta(i) ? 65 : 30); stroke(255,180); strokeWeight(1);
        rect(x,y,w,h,3);
      }
      if(tareaPorCarpeta[i]>=0 && tareas[tareaPorCarpeta[i]].completada) {
        fill(38,110,65); stroke(220,255,230); ellipse(x+w-14,y+17,24,24);
        strokeWeight(2); line(x+w-20,y+17,x+w-15,y+22); line(x+w-15,y+22,x+w-7,y+12);
      }
    }
    noStroke(); fill(35,25,45,225); rect(265,18,850,48,9);
    fill(255); textAlign(CENTER,CENTER); textSize(16);
    text("Hora: "+hud.obtenerHora()+"   |   Energía: "+hud.energia+"   |   Estrés: "+hud.estres+
         "   |   Concentración: "+hud.concentracion+"   |   "+completadas+" / "+tareas.length+" tareas",690,42);
    dibujarBoton("X",1205,20,48,45,true);
    if(carpetaSeleccionada>=0) mostrarDetalleCarpeta();
    popStyle();
  }

  void mostrarDetalleCarpeta() {
    fill(37,29,49,248); stroke(223,191,225); strokeWeight(2); rect(340,170,800,450,12);
    fill(255,235,245); textAlign(LEFT,CENTER); textSize(25);
    text(nombresCarpetas[carpetaSeleccionada],370,210);
    dibujarBoton("X",1075,185,42,40,true);
    int indice=tareaPorCarpeta[carpetaSeleccionada];
    if(indice<0) {
      fill(240,220,240); textAlign(CENTER,CENTER); textSize(22);
      text("Esta tarea todavía no está disponible.",740,355);
      textSize(17); text("La añadiremos en una próxima versión.",740,400);
      dibujarBoton("VOLVER AL ESCRITORIO",470,545,540,48,true);
      return;
    }
    Tarea actual=tareas[indice];
    if(actual.completada) {
      fill(170,245,190); textAlign(CENTER,CENTER); textSize(28);
      text("¡Ya has terminado esta tarea!",740,345);
      fill(240,220,240); textSize(18); text("Tu progreso está registrado en esta partida.",740,395);
      dibujarBoton("VOLVER AL ESCRITORIO",470,545,540,48,true);
      return;
    }
    fill(240,220,240); textAlign(LEFT,TOP); textSize(18);
    text(actual.descripcion,370,265,730,80);
    text("Duración: "+actual.duracion()+"   |   Terminar antes de: "+actual.horaLimite(),370,365);
    text("Energía: −"+actual.energia+"   |   Estrés: +"+actual.estres,370,405);
    textSize(16); text("Fallar o abandonar consume "+penalizacionFalloMinutos+" minutos virtuales.",370,447);
    String motivo=actual.bloqueo();
    fill(255,210,180); textAlign(CENTER,CENTER); textSize(16);
    text(motivo.length()>0 ? motivo : "El reloj se detiene mientras resuelves el minijuego.",365,480,750,45);
    dibujarBoton("COMENZAR ACTIVIDAD",470,545,540,48,motivo.length()==0);
  }
  void dibujarBoton(String nombre,float x,float y,float ancho,float alto,boolean habilitado) {
    fill(!habilitado ? color(65,57,63) : mouseSobreBoton(x,y,ancho,alto) ? color(177,126,111) : color(133,91,83));
    stroke(213,164,145); strokeWeight(2); rect(x,y,ancho,alto,7);
    fill(habilitado ? color(255,237,224) : color(180)); textAlign(CENTER,CENTER); textSize(18);
    text(nombre,x+ancho/2,y+alto/2);
  }
  void procesarClick() {
    if(mouseSobreBoton(1205,20,48,45)) { cerrarInterfaz(); return; }
    for(int i=0;i<carpetas.length;i++) if(sobreCarpeta(i)) {
      carpetaSeleccionada=i;
      if(tareaPorCarpeta[i]>=0) tareaSeleccionada=tareaPorCarpeta[i];
      return;
    }
    if(carpetaSeleccionada<0) return;
    if(mouseSobreBoton(1075,185,42,40)) { carpetaSeleccionada=-1; return; }
    if(mouseSobreBoton(470,545,540,48)) {
      int indice=tareaPorCarpeta[carpetaSeleccionada];
      if(indice<0 || tareas[indice].completada) { carpetaSeleccionada=-1; return; }
      if(tareas[indice].bloqueo().length()==0) gestorMinijuegos.abrir(tareas[indice].id);
    }
  }
}
