class PresentacionInicial {
  final int NEGRO_INICIAL=350, FUNDIDO_TITULO=1500, TITULO_VISIBLE=4000;
  final int NEGRO_FINAL=2000, FUNDIDO_MENU=1500;
  final int SALE_TITULO=NEGRO_INICIAL+FUNDIDO_TITULO+TITULO_VISIBLE;
  final int ENTRA_MENU=SALE_TITULO+FUNDIDO_TITULO+NEGRO_FINAL;

  PImage titulo;
  int inicio;
  boolean activa;

  void iniciar() {
    PImage fuente=loadImage("ArteTitulo.png");
    if (fuente!=null) titulo=recortarTitulo(fuente);
    inicio=millis();
    activa=true;
  }

  boolean mostrar() {
    if (!activa) return false;
    int tiempo=millis()-inicio;
    if (tiempo>=ENTRA_MENU+FUNDIDO_MENU) {
      activa=false;
      return false;
    }
    if (tiempo>=ENTRA_MENU) {
      mostrarMenu();
      cubrirConNegro(1-suavizar((tiempo-ENTRA_MENU)/float(FUNDIDO_MENU)));
      return true;
    }

    cubrirConNegro(1);
    if (titulo!=null && tiempo>=NEGRO_INICIAL && tiempo<SALE_TITULO+FUNDIDO_TITULO) {
      float entrada=suavizar((tiempo-NEGRO_INICIAL)/float(FUNDIDO_TITULO));
      float salida=suavizar((tiempo-SALE_TITULO)/float(FUNDIDO_TITULO));
      pushStyle();
      imageMode(CENTER);
      tint(255,255*entrada*(1-salida));
      float ancho=920;
      image(titulo,ANCHO_JUEGO/2,ALTO_JUEGO/2,ancho,ancho*titulo.height/titulo.width);
      popStyle();
    }
    return true;
  }

  private float suavizar(float tiempo) {
    float t=constrain(tiempo,0,1);
    return t*t*(3-2*t);
  }

  private void cubrirConNegro(float opacidad) {
    pushStyle();
    rectMode(CORNER);
    noStroke();
    fill(0,255*opacidad);
    rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    popStyle();
  }

  PImage recortarTitulo(PImage fuente) {
    PImage recorte=fuente.get(248,197,1184,457);
    recorte.loadPixels();
    int w=recorte.width, h=recorte.height;
    for (int y=0; y<h; y++) for (int x=0; x<w; x++) {
      int sx=x+248, sy=y+197;
      // Fuera de las letras, eliminar también los adornos amarillos laterales.
      int pixel=recorte.pixels[y*w+x];
      int r=(pixel>>16)&255, g=(pixel>>8)&255, b=pixel&255;
      boolean papelEntreLetras=sy>=400 && r>222 && g>192 && b>162 && r>g && g>b;
      if (papelEntreLetras || (sx<376 && sy<398) || (sx>1296 && sy<337) || (sx>1313 && sy<393))
        recorte.pixels[y*w+x]=0;
    }
    // El relleno crema de las letras queda protegido por su contorno oscuro.
    int[] cola=new int[w*h];
    boolean[] fondo=new boolean[w*h];
    int fin=0;
    for (int y=0; y<h; y++) for (int x=0; x<w; x++) {
      if (x!=0 && x!=w-1 && y!=0 && y!=h-1) continue;
      fin=agregarFondo(y*w+x,recorte.pixels,fondo,cola,fin);
    }
    for (int comienzo=0; comienzo<fin; comienzo++) {
      int p=cola[comienzo];
      recorte.pixels[p]=0;
      if (p%w>0) fin=agregarFondo(p-1,recorte.pixels,fondo,cola,fin);
      if (p%w<w-1) fin=agregarFondo(p+1,recorte.pixels,fondo,cola,fin);
      if (p>=w) fin=agregarFondo(p-w,recorte.pixels,fondo,cola,fin);
      if (p+w<w*h) fin=agregarFondo(p+w,recorte.pixels,fondo,cola,fin);
    }
    recorte.format=ARGB;
    recorte.updatePixels();
    return recorte;
  }

  private int agregarFondo(int p,int[] pixeles,boolean[] fondo,int[] cola,int fin) {
    if (fondo[p]) return fin;
    int pixel=pixeles[p];
    int r=(pixel>>16)&255, g=(pixel>>8)&255, b=pixel&255;
    if ((pixel>>>24)==0 || (r>222 && g>192 && b>162 && r-b<83)) {
      fondo[p]=true;
      cola[fin++]=p;
    }
    return fin;
  }
}

PresentacionInicial presentacionInicial=new PresentacionInicial();
