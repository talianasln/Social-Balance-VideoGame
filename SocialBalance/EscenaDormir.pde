class EscenaDormir {
  PImage fondo;
  final PImage[] letras;
  final int[][] zonas;

  EscenaDormir(String archivo, boolean letrasOscuras, int[][] zonas) {
    fondo=loadImage(archivo);
    this.zonas=zonas;
    letras=new PImage[zonas.length];
    if (fondo==null) return;
    fondo.loadPixels();
    for (int i=0; i<zonas.length; i++) prepararLetra(i,letrasOscuras);
    fondo.updatePixels();
  }

  // Separar las letras ya dibujadas para animarlas sobre el fondo original.
  private void prepararLetra(int indice,boolean oscura) {
    int[] zona=zonas[indice];
    int x0=round(zona[0]*fondo.width/1376.0), y0=round(zona[1]*fondo.height/768.0);
    int w=round(zona[2]*fondo.width/1376.0), h=round(zona[3]*fondo.height/768.0);
    PImage letra=letras[indice]=createImage(w,h,ARGB);
    letra.loadPixels();
    boolean[] mascara=new boolean[w*h];
    for (int y=0; y<h; y++) {
      int fila=(y0+y)*fondo.width+x0;
      for (int x=0; x<w; x++) {
        int pixel=fondo.pixels[fila+x];
        if (!esLetra(pixel,oscura)) continue;
        letra.pixels[y*w+x]=pixel;
        for (int dy=-2; dy<=2; dy++) for (int dx=-2; dx<=2; dx++) {
          if (x+dx>=0 && x+dx<w && y+dy>=0 && y+dy<h) mascara[(y+dy)*w+x+dx]=true;
        }
      }
    }
    for (int y=0; y<h; y++) {
      for (int x=0; x<w; x++) {
        if (!mascara[y*w+x]) continue;
        int izquierda=x-1, derecha=x+1, arriba=y-1, abajo=y+1;
        while (izquierda>=0 && mascara[y*w+izquierda]) izquierda--;
        while (derecha<w && mascara[y*w+derecha]) derecha++;
        while (arriba>=0 && mascara[arriba*w+x]) arriba--;
        while (abajo<h && mascara[abajo*w+x]) abajo++;
        int fila=(y0+y)*fondo.width+x0;
        int a=fondo.pixels[fila+izquierda], b=fondo.pixels[fila+derecha];
        int c=fondo.pixels[(y0+arriba)*fondo.width+x0+x], d=fondo.pixels[(y0+abajo)*fondo.width+x0+x];
        fondo.pixels[fila+x]=diferenciaColor(a,b)<=diferenciaColor(c,d)
          ? lerpColor(a,b,(x-izquierda)/float(derecha-izquierda))
          : lerpColor(c,d,(y-arriba)/float(abajo-arriba));
      }
    }
    letra.updatePixels();
  }

  private int diferenciaColor(int a,int b) {
    return abs(((a>>16)&255)-((b>>16)&255))+
      abs(((a>>8)&255)-((b>>8)&255))+abs((a&255)-(b&255));
  }

  private boolean esLetra(int pixel,boolean oscura) {
    int r=(pixel>>16)&255, g=(pixel>>8)&255, b=pixel&255;
    return oscura ? r<105 && g<71 && b<63 : r>235 && g>204 && b>165;
  }

  void mostrar(int ahora) {
    if (fondo==null) return;
    pushStyle();
    imageMode(CORNER);
    noTint();
    image(fondo,0,0,ANCHO_JUEGO,ALTO_JUEGO);
    for (int i=0; i<letras.length; i++) {
      float fase=((ahora+i*320)%1600)/1600.0;
      int[] z=zonas[i];
      tint(255,255*sin(fase*PI));
      image(letras[i],z[0]*ANCHO_JUEGO/1376.0,z[1]*ALTO_JUEGO/768.0-36*fase,
        z[2]*ANCHO_JUEGO/1376.0,z[3]*ALTO_JUEGO/768.0);
    }
    popStyle();
  }
}

EscenaDormir[] escenasDormir;

void cargarEscenasDormir() {
  escenasDormir=new EscenaDormir[]{
    new EscenaDormir("DescansoChico.jpeg",false,new int[][]{
      {811,116,40,55},{854,133,32,38},{891,133,32,38},{927,157,47,15}
    }),
    new EscenaDormir("DescansoChica.jpeg",true,new int[][]{
      {305,75,85,97},{402,136,71,83},{481,199,51,59},{539,244,33,43}
    }),
    new EscenaDormir("DescansoNobin.jfif.jpeg",false,new int[][]{
      {787,243,35,37},{830,208,33,38},{876,169,34,39},{824,128,34,40}
    })
  };
}

void dibujarImagenDescanso(int ahora) {
  if (escenasDormir!=null && personajeSeleccionado>=1 && personajeSeleccionado<=escenasDormir.length)
    escenasDormir[personajeSeleccionado-1].mostrar(ahora);
}

PImage bordesEstres;

void dibujarBordesEstres(float intensidad) {
  if (bordesEstres==null) {
    bordesEstres=createImage(320,180,ARGB);
    bordesEstres.loadPixels();
    for (int y=0; y<180; y++) {
      for (int x=0; x<320; x++) {
        float dx=(x-159.5)/159.5, dy=(y-89.5)/89.5;
        float borde=constrain((sqrt(dx*dx+dy*dy)-0.46)/0.88,0,1);
        bordesEstres.pixels[y*320+x]=color(31,14,28,105*borde*borde);
      }
    }
    bordesEstres.updatePixels();
  }
  pushStyle();
  imageMode(CORNER);
  tint(255,255*intensidad);
  image(bordesEstres,0,0,ANCHO_JUEGO,ALTO_JUEGO);
  popStyle();
}
