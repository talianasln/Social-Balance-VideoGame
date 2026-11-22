PImage recuadroConcepto, recuadroRespuesta;
boolean recuadrosConceptosCargados = false;

PImage cargarRecuadroConceptos(String nombre) {
  // Aceptar también la extensión .PNG de los recursos actuales.
  for (String extension : new String[]{".png", ".PNG"}) {
    if (new java.io.File(dataPath(nombre+extension)).isFile()) return loadImage(nombre+extension);
  }
  return null;
}

class VistaConectarConceptos {
  ConectarConceptos juego;
  boolean quiereSalir = false;
  final float X_CONCEPTO=80, ANCHO_CONCEPTO=310;
  final float X_RESPUESTA=720, ANCHO_RESPUESTA=480;
  final float Y_INICIO=180, PASO=84, ALTO=70;
  int[] colores = {color(45,100,180),color(167,65,117),color(32,123,98),
                   color(179,105,22),color(112,66,168)};

  VistaConectarConceptos(ConectarConceptos juego) {
    this.juego=juego;
    if (!recuadrosConceptosCargados) {
      recuadroConcepto=cargarRecuadroConceptos("RecuadroConcepto");
      recuadroRespuesta=cargarRecuadroConceptos("RecuadroRespuesta");
      recuadrosConceptosCargados=true;
    }
  }

  boolean dentro(float px,float py,float x,float y,float w,float h) {
    return px>=x && px<=x+w && py>=y && py<=y+h;
  }

  void mostrar() {
    pushStyle(); rectMode(CORNER); imageMode(CORNER);
    dibujarFondoMinijuego(); dibujarCierreVentana();
    fill(255,240,225); textAlign(LEFT,CENTER); textSize(26);
    text("SOCIAL BALANCE / CONECTAR CONCEPTOS",85,65);
    fill(65,39,45); textSize(18);
    text("Elige un concepto y luego su definición. Puedes deshacer antes de verificar.",80,125);
    textSize(16); text("CONCEPTOS",80,158); text("DEFINICIONES",720,158);
    textAlign(CENTER,CENTER); text("Conexiones: "+juego.cantidadConexiones()+" / 5",555,158);

    // Las líneas solo recorren el espacio entre tarjetas; pueden cruzarse.
    for(int i=0;i<juego.PAREJAS;i++) {
      int destino=juego.definicionConectada(i);
      if(destino<0) continue;
      float y1=Y_INICIO+i*PASO+(recuadroConcepto!=null ? 30 : ALTO/2);
      float y2=Y_INICIO+destino*PASO+(recuadroRespuesta!=null ? 39 : ALTO/2);
      stroke(colores[i]); strokeWeight(4); line(405,y1,705,y2);
      fill(colores[i]); noStroke(); ellipse(405,y1,12,12); ellipse(705,y2,12,12);
    }
    for(int i=0;i<juego.PAREJAS;i++) {
      tarjeta(recuadroConcepto,juego.textoConcepto(i),X_CONCEPTO,Y_INICIO+i*PASO,ANCHO_CONCEPTO,
        juego.conceptoSeleccionado()==i,juego.definicionConectada(i)>=0);
      tarjeta(recuadroRespuesta,juego.textoDefinicion(i),X_RESPUESTA,Y_INICIO+i*PASO,ANCHO_RESPUESTA,
        false,juego.estaDefinicionOcupada(i));
    }
    boton("DESHACER",350,juego.cantidadConexiones()>0);
    boton("VERIFICAR",680,juego.puedeVerificar());
    popStyle();
  }

  void tarjeta(PImage fondo,String texto,float x,float y,float w,boolean seleccionada,boolean ocupada) {
    if(fondo!=null) image(fondo,x,y,w,ALTO);
    else { fill(255,246,225); stroke(145,112,99); strokeWeight(2); rect(x,y,w,ALTO,10); }
    boolean encima=dentro(mouseJuegoX(),mouseJuegoY(),x,y,w,ALTO);
    if(seleccionada || (encima && !ocupada)) {
      fill(255,255,255,50); stroke(107,49,73); strokeWeight(seleccionada ? 3 : 1);
      if(fondo!=null && fondo==recuadroConcepto) rect(x+11,y+2,w-13,57,8);
      else rect(x,y,w,fondo!=null ? 68 : ALTO,8);
    }
    fill(55,37,40); textAlign(CENTER,CENTER); textSize(18); textLeading(22);
    // El concepto tiene margen transparente abajo; la respuesta tiene pestaña arriba.
    float textoY=fondo==null ? 8 : fondo==recuadroConcepto ? 8 : 17;
    float textoAlto=fondo==null ? ALTO-16 : 44;
    text(texto,x+24,y+textoY,w-48,textoAlto);
  }

  void boton(String texto,float x,boolean habilitado) {
    boolean encima=dentro(mouseJuegoX(),mouseJuegoY(),x,620,250,48);
    fill(!habilitado ? color(150,140,132) : encima ? color(150,73,96) : color(105,46,68));
    stroke(220,190,170); strokeWeight(2); rect(x,620,250,48,8);
    fill(255,245,230); textAlign(CENTER,CENTER); textSize(18); text(texto,x+125,644);
  }

  void presionar(float x,float y) {
    if(sobreCierreVentana(x,y)) { quiereSalir=true; return; }
    if(juego.estaTerminado()) return;
    if(dentro(x,y,350,620,250,48)) { juego.deshacer(); return; }
    if(dentro(x,y,680,620,250,48)) { juego.verificar(); return; }
    for(int i=0;i<juego.PAREJAS;i++) {
      if(dentro(x,y,X_CONCEPTO,Y_INICIO+i*PASO,ANCHO_CONCEPTO,ALTO)) { juego.seleccionarConcepto(i); return; }
      if(dentro(x,y,X_RESPUESTA,Y_INICIO+i*PASO,ANCHO_RESPUESTA,ALTO)) { juego.seleccionarDefinicion(i); return; }
    }
  }
}
