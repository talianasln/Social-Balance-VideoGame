class Instrucciones {
  boolean abierta = true;
  PImage imagen;
  final PFont tituloGuia = new PFont(new java.awt.Font("Arial Rounded MT Bold",java.awt.Font.BOLD,24),false);
  final float CIERRE_X=1210, CIERRE_Y=24, CIERRE_LADO=42;

  Instrucciones(PImage imagen) { this.imagen=imagen; }

  void mostrar() {
    if (!abierta) return;
    pushStyle(); rectMode(CORNER); imageMode(CORNER); noTint();
    dibujarImagenAjustada(imagen,0,0,ANCHO_JUEGO,ALTO_JUEGO);
    mostrarGuiaDeEstados();
    fill(clicCerrar() ? color(155,49,76) : color(108,25,49));
    stroke(255,235,200); strokeWeight(2);
    rect(CIERRE_X,CIERRE_Y,CIERRE_LADO,CIERRE_LADO,7);
    stroke(255,245,225); strokeWeight(3);
    line(CIERRE_X+13,CIERRE_Y+13,CIERRE_X+29,CIERRE_Y+29);
    line(CIERRE_X+29,CIERRE_Y+13,CIERRE_X+13,CIERRE_Y+29);
    popStyle();
  }

  private void mostrarGuiaDeEstados() {
    if (imagen==null) return;
    float escala=min(ANCHO_JUEGO/float(imagen.width),ALTO_JUEGO/float(imagen.height));
    float w=imagen.width*escala, h=imagen.height*escala;
    float x=(ANCHO_JUEGO-w)/2+w*0.186, y=(ALTO_JUEGO-h)/2+h*0.242;
    noStroke();
    fill(250,239,217);
    rect(x,y,w*0.300,h*0.226,6);
    textAlign(LEFT,TOP);
    fill(133,13,52);
    textFont(tituloGuia);
    textSize(24);
    text("1. TUS BARRAS DE ESTADO",x+7,y+4);
    fill(67,35,33);
    textFont(tituloGuia);
    textSize(19);
    String[] lineas={
      "Energía baja: impide iniciar tareas.",
      "La cama la recupera.",
      "Estrés mayor a 60: impide iniciar.",
      "Usa el celular para bajarlo.",
      "Concentración menor a 30: impide",
      "iniciar tareas. La cama la recupera."
    };
    for (int i=0; i<lineas.length; i++) text(lineas[i],x+7,y+34+i*21);
  }

  void abrir() { abierta=true; }
  void cerrar() { abierta=false; }
  boolean clicCerrar() {
    return mouseJuegoX()>=CIERRE_X && mouseJuegoX()<=CIERRE_X+CIERRE_LADO &&
           mouseJuegoY()>=CIERRE_Y && mouseJuegoY()<=CIERRE_Y+CIERRE_LADO;
  }
}
