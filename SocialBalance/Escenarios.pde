class Escenarios {
  final int HABITACION=0, PASILLO=1, BIBLIOTECA=2;
  final int FUNDIDO_MS=1500;
  int actual=HABITACION;
  private int inicioFundido, destino;
  private boolean enTransicion, cambioAplicado;
  private float entradaX, entradaY;
  PImage pasillo, biblioteca;

  // Coordenadas trazadas sobre las dos imágenes de referencia.
  final float[] sueloPasillo={129,0, 219,0, 236,40, 270,89, 290,114, 334,185, 16,185, 55,108, 58,81, 88,44};
  final float[] sueloBiblioteca={137,0, 219,0, 298,58, 308,108, 344,216, 348,245, 8,245, 11,221, 43,119, 51,65};
  final float[][] obstaculosPasillo={
    {0,32,56,185}, {289,31,350,185}, {60,53,86,93},
    {82,42,110,67}, {235,68,260,94}
  };
  final float[][] obstaculosBiblioteca={
    {52,10,132,82}, {224,10,300,82}, {130,0,226,82},
    {227,95,311,145}, {27,161,122,223}, {237,168,334,229}
  };

  void cargar() {
    pasillo=loadImage("Pasillo.png");
    biblioteca=loadImage("Biblioteca.png");
  }

  void dibujarEstanteCentral() {
    if (actual!=BIBLIOTECA || biblioteca==null) return;
    pushStyle();
    imageMode(CORNER);
    noTint();
    // Tres módulos recortados del propio estante del fondo.
    for (int modulo=0; modulo<3; modulo++) {
      float x=(130+modulo*32)*ANCHO_JUEGO/355.0;
      image(biblioteca,x,11*ALTO_JUEGO/245.0,32*ANCHO_JUEGO/355.0,70*ALTO_JUEGO/245.0,
        98,11,130,81);
    }
    popStyle();
  }

  void reiniciar() {
    actual=HABITACION;
    enTransicion=false;
  }

  boolean enHabitacion() { return actual==HABITACION; }
  boolean cambiando() { return enTransicion; }

  PImage fondo() {
    if (actual==PASILLO) return pasillo;
    if (actual==BIBLIOTECA) return biblioteca;
    return personajeSeleccionado==2 ? cuarto1 : cuarto2;
  }

  boolean cercaPuerta() {
    float x=jugador.piesX(), y=jugador.piesY();
    if (actual==HABITACION) return x>=565 && x<=720 && y>=475 && y<=510;
    if (actual==PASILLO) return x>=947 && x<=1030 && y>=404 && y<=480;
    return false;
  }

  boolean usarPuerta() {
    if (enTransicion || !cercaPuerta()) return false;
    if (actual==HABITACION) cambiar(PASILLO,974,446,millis());
    else cambiar(HABITACION,640,520,millis());
    reproducirEfecto("PuertaAbriendo.wav");
    return true;
  }

  void comprobarSalida() {
    if (enTransicion) return;
    float x=jugador.piesX(), y=jugador.piesY();
    if (x<525 || x>755) return;
    if (actual==PASILLO && jugador.moviendoArriba && y<=24) cambiar(BIBLIOTECA,640,674,millis());
    else if (actual==BIBLIOTECA && jugador.moviendoAbajo && y>=690) cambiar(PASILLO,640,55,millis());
  }

  private void cambiar(int escena,float x,float y,int ahora) {
    destino=escena;
    entradaX=x;
    entradaY=y;
    inicioFundido=ahora;
    cambioAplicado=false;
    enTransicion=true;
    jugador.detenerMovimiento();
  }

  void actualizar(int ahora) {
    if (!enTransicion) return;
    int tiempo=ahora-inicioFundido;
    if (!cambioAplicado && tiempo>=FUNDIDO_MS/2) {
      actual=destino;
      jugador.colocarPies(entradaX,entradaY);
      cambioAplicado=true;
    }
    if (tiempo>=FUNDIDO_MS) {
      enTransicion=false;
      guardado.guardar();
    }
  }

  void mostrarFundido(int ahora) {
    if (!enTransicion) return;
    float avance=constrain((ahora-inicioFundido)/float(FUNDIDO_MS),0,1);
    pushStyle();
    rectMode(CORNER);
    noStroke();
    fill(0,255*(1-abs(2*avance-1)));
    rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    popStyle();
  }

  boolean permitePies(float x,float y) {
    float ancho=actual==PASILLO ? 350 : 355;
    float alto=actual==PASILLO ? 185 : 245;
    float sx=x*ancho/ANCHO_JUEGO, sy=y*alto/ALTO_JUEGO;
    float margenX=18*ancho/ANCHO_JUEGO, margenY=8*alto/ALTO_JUEGO;
    float[] suelo=actual==PASILLO ? sueloPasillo : sueloBiblioteca;
    if (!dentro(suelo,sx-margenX,sy-margenY) || !dentro(suelo,sx+margenX,sy-margenY) ||
        !dentro(suelo,sx-margenX,sy+margenY) || !dentro(suelo,sx+margenX,sy+margenY)) return false;
    float[][] obstaculos=actual==PASILLO ? obstaculosPasillo : obstaculosBiblioteca;
    for (float[] m : obstaculos) {
      if (sx+margenX>m[0] && sy+margenY>m[1] && sx-margenX<m[2] && sy-margenY<m[3]) return false;
    }
    return true;
  }

  private boolean dentro(float[] poligono,float x,float y) {
    boolean dentro=false;
    for (int i=0,j=poligono.length-2; i<poligono.length; j=i,i+=2) {
      float ay=poligono[i+1], by=poligono[j+1];
      if ((ay>y)!=(by>y) && x<(poligono[j]-poligono[i])*(y-ay)/(by-ay)+poligono[i]) dentro=!dentro;
    }
    return dentro;
  }
}
