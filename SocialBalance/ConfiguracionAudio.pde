class ConfiguracionAudio {
  boolean abierta;
  int controlArrastrado=-1;
  final int[] volumen={75,75};
  final int[] volumenAnterior={75,75};
  final float INICIO=400, ANCHO=425;

  float factorMenu() { return volumen[0]/75.0; }
  float factorPartida() { return volumen[1]/75.0; }

  void cerrar() { abierta=false; controlArrastrado=-1; }

  void presionar() {
    if (sobreSeleccion(920,177,45,42) || sobreSeleccion(535,525,210,45)) {
      cerrar();
      return;
    }
    for (int i=0; i<volumen.length; i++) {
      float y=300+i*104;
      if (sobreSeleccion(INICIO-8,y-16,ANCHO+16,32)) {
        controlArrastrado=i;
        arrastrar();
        return;
      }
      if (sobreSeleccion(852,y-19,105,38)) {
        if (volumen[i]>0) {
          volumenAnterior[i]=volumen[i];
          volumen[i]=0;
        } else volumen[i]=volumenAnterior[i];
        return;
      }
    }
  }

  void arrastrar() {
    if (controlArrastrado<0) return;
    volumen[controlArrastrado]=round(constrain((mouseJuegoX()-INICIO)/ANCHO,0,1)*100);
  }

  void soltar() { controlArrastrado=-1; }

  void mostrar() {
    pushStyle(); rectMode(CORNER);
    noStroke(); fill(38,23,36,186);
    rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    fill(251,235,214); stroke(145,70,83); strokeWeight(2);
    rect(300,159,680,433,17);
    fill(250,219,198); noStroke();
    rect(321,175,638,62,10);
    fill(106,42,56); textAlign(LEFT,CENTER); textSize(30);
    text("Configuración de audio",350,205);
    botonAudio("X",920,177,45,42);
    fila(0,"Música del menú",300);
    fila(1,"Música de la partida",404);
    botonAudio("VOLVER AL MENÚ",535,525,210,45);
    popStyle();
  }

  private void fila(int indice,String titulo,float y) {
    fill(77,44,54); textAlign(LEFT,CENTER); textSize(19);
    text(titulo,400,y-39);
    textAlign(RIGHT,CENTER); textSize(16);
    text(volumen[indice]+" %",825,y-39);
    noStroke(); fill(223,191,186);
    rect(INICIO,y-5,ANCHO,10,5);
    float avance=ANCHO*volumen[indice]/100.0;
    if (avance>0) {
      fill(180,105,127);
      rect(INICIO,y-5,avance,10,5);
    }
    stroke(133,65,78); strokeWeight(2); fill(255,237,216);
    ellipse(INICIO+avance,y,21,21);
    botonAudio(volumen[indice]==0 ? "Activar" : "Silenciar",852,y-19,105,38);
  }

  private void botonAudio(String texto,float x,float y,float w,float h) {
    noStroke();
    fill(sobreSeleccion(x,y,w,h) ? color(160,71,92) : color(111,43,64));
    rect(x,y,w,h,8);
    fill(255,239,219); textAlign(CENTER,CENTER); textSize(15);
    text(texto,x+w/2,y+h/2);
  }
}

ConfiguracionAudio configuracionAudio=new ConfiguracionAudio();
