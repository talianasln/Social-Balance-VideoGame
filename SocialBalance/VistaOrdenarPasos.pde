class VistaOrdenarPasos {
  final OrdenarPasos juego;
  final float X_LISTA = 220, Y_LISTA = 203, ANCHO = 840, ALTO = 56, FILA = 71;
  final float X_BOTON = 515, Y_BOTON = 596, ANCHO_BOTON = 250, ALTO_BOTON = 50;
  boolean quiereSalir = false;
  private int arrastrada = -1;
  private float agarreX, agarreY;

  VistaOrdenarPasos(OrdenarPasos juego) {
    this.juego = juego;
  }

  void mostrar() {
    pushStyle();
    rectMode(CORNER);
    dibujarFondoMinijuego();
    dibujarCierreVentana();
    fill(255,240,225);
    textAlign(LEFT,CENTER);
    textSize(26);
    text("SOCIAL BALANCE / ORDENAR PASOS",85,65);

    fill(65,39,45);
    textAlign(CENTER,CENTER);
    textSize(29);
    text(juego.tituloSituacion(),640,124);
    textSize(18);
    text("Arrastra los pasos para ordenarlos. Luego pulsa Verificar.",640,164);

    float x = mouseJuegoX(), y = mouseJuegoY();
    int destino = arrastrada>=0 ? posicionDestino(x,y) : -1;
    int hueco = destino>=0 ? destino : arrastrada;
    for (int i=0; i<OrdenarPasos.CANTIDAD_PASOS; i++) {
      float filaY = Y_LISTA+i*FILA;
      if (i==hueco) {
        fill(i==destino ? color(247,222,208) : color(230,213,204));
        stroke(i==destino ? color(150,73,96) : color(145,112,99));
        strokeWeight(i==destino ? 3 : 1);
        rect(X_LISTA,filaY,ANCHO,ALTO,10);
      } else {
        int origen = i;
        if (i>=arrastrada && i<destino && arrastrada>=0) origen = i+1;
        else if (i>destino && i<=arrastrada && destino>=0) origen = i-1;
        tarjeta(juego.pasoEn(origen),X_LISTA,filaY,arrastrada<0 && dentro(x,y,X_LISTA,filaY,ANCHO,ALTO));
      }
    }

    boolean sobreBoton = dentro(x,y,X_BOTON,Y_BOTON,ANCHO_BOTON,ALTO_BOTON);
    fill(arrastrada<0 && sobreBoton ? color(150,73,96) : color(105,46,68));
    stroke(220,190,170);
    strokeWeight(2);
    rect(X_BOTON,Y_BOTON,ANCHO_BOTON,ALTO_BOTON,8);
    fill(255,245,230);
    textAlign(CENTER,CENTER);
    textSize(18);
    text("VERIFICAR",X_BOTON+ANCHO_BOTON/2,Y_BOTON+ALTO_BOTON/2);

    if (arrastrada>=0) {
      tarjeta(juego.pasoEn(arrastrada),constrain(x-agarreX,0,ANCHO_JUEGO-ANCHO),
        constrain(y-agarreY,0,ALTO_JUEGO-ALTO),true);
    }
    popStyle();
  }

  private void tarjeta(String paso, float x, float y, boolean resaltada) {
    fill(255,246,225);
    stroke(resaltada ? color(150,73,96) : color(145,112,99));
    strokeWeight(resaltada ? 3 : 1);
    rect(x,y,ANCHO,ALTO,10);
    stroke(145,112,99);
    strokeWeight(2);
    for (int i=-1; i<=1; i++) line(x+23,y+ALTO/2+i*6,x+41,y+ALTO/2+i*6);
    fill(55,37,40);
    textAlign(LEFT,CENTER);
    textSize(20);
    text(paso,x+61,y+ALTO/2);
  }

  void presionar(float x, float y) {
    if (sobreCierreVentana(x,y)) {
      quiereSalir = true;
      return;
    }
    if (juego.estaTerminado() || arrastrada>=0) return;
    if (dentro(x,y,X_BOTON,Y_BOTON,ANCHO_BOTON,ALTO_BOTON)) {
      juego.verificar();
      return;
    }
    int posicion = posicionDestino(x,y);
    if (posicion<0) return;
    float filaY = Y_LISTA+posicion*FILA;
    if (!dentro(x,y,X_LISTA,filaY,ANCHO,ALTO)) return;
    arrastrada = posicion;
    agarreX = x-X_LISTA;
    agarreY = y-filaY;
  }

  void soltar(float x, float y) {
    if (arrastrada<0) return;
    int destino = posicionDestino(x,y);
    if (destino>=0) juego.mover(arrastrada,destino);
    cancelarArrastre();
  }

  void cancelarArrastre() {
    arrastrada = -1;
  }

  private int posicionDestino(float x, float y) {
    float altoLista = (OrdenarPasos.CANTIDAD_PASOS-1)*FILA+ALTO;
    if (!dentro(x,y,X_LISTA,Y_LISTA,ANCHO,altoLista)) return -1;
    return int((y-Y_LISTA)/FILA);
  }

  private boolean dentro(float px, float py, float x, float y, float ancho, float alto) {
    return px>=x && px<=x+ancho && py>=y && py<=y+alto;
  }
}