class Instrucciones {
  boolean abierta = true;
  PImage imagen;
  final int DURACION_PAGINA=620;
  private int pagina;
  private int inicioPagina=-1;
  final float PESTANA_Y=611, PESTANA_ANCHO=174, PESTANA_ALTO=36;
  final PFont tituloGuia = new PFont(new java.awt.Font("Arial Rounded MT Bold",java.awt.Font.BOLD,24),false);
  final float CIERRE_X=1210, CIERRE_Y=24, CIERRE_LADO=42;

  Instrucciones(PImage imagen) { this.imagen=imagen; }

  void mostrar() {
    if (!abierta) return;
    pushStyle(); rectMode(CORNER); imageMode(CORNER); noTint();
    mostrarHojas();
    fill(clicCerrar() ? color(155,49,76) : color(108,25,49));
    stroke(255,235,200); strokeWeight(2);
    rect(CIERRE_X,CIERRE_Y,CIERRE_LADO,CIERRE_LADO,7);
    stroke(255,245,225); strokeWeight(3);
    line(CIERRE_X+13,CIERRE_Y+13,CIERRE_X+29,CIERRE_Y+29);
    line(CIERRE_X+29,CIERRE_Y+13,CIERRE_X+13,CIERRE_Y+29);
    popStyle();
  }

  private void mostrarHojas() {
    if (inicioPagina<0) {
      dibujarPagina(pagina);
      return;
    }
    int tiempo=millis()-inicioPagina;
    if (tiempo>=DURACION_PAGINA) {
      pagina=1-pagina;
      inicioPagina=-1;
      dibujarPagina(pagina);
      return;
    }

    dibujarPagina(1-pagina);
    float avance=entradaPartida.progreso(tiempo,0,DURACION_PAGINA);
    float borde=pagina==0 ? lerp(1260,20,avance) : lerp(20,1260,avance);
    float inicio=pagina==0 ? 20 : borde;
    float ancho=pagina==0 ? borde-20 : 1260-borde;
    if (ancho>0) {
      clip(inicio,25,ancho,670);
      dibujarPagina(pagina);
      noClip();
    }

    float sentido=pagina==0 ? 1 : -1;
    float doblez=90*sin(PI*avance);
    noStroke();
    fill(72,34,21,65*sin(PI*avance));
    quad(borde,25,borde+sentido*doblez,55,borde+sentido*(doblez+22),666,borde,695);
    fill(242,211,174);
    quad(borde,25,borde+sentido*doblez,58,borde+sentido*doblez*0.65,666,borde,695);
    fill(255,238,208);
    quad(borde,25,borde+sentido*doblez*0.45,48,borde+sentido*doblez*0.30,677,borde,695);
  }

  private void dibujarPagina(int numero) {
    dibujarImagenAjustada(imagen,0,0,ANCHO_JUEGO,ALTO_JUEGO);
    if (numero==0) mostrarGuiaDeEstados();
    else mostrarObjetivo();
    float x=xPestana(numero);
    boolean encima=inicioPagina<0 && sobreSeleccion(x,PESTANA_Y,PESTANA_ANCHO,PESTANA_ALTO);
    fill(encima ? color(155,49,76) : color(108,25,49));
    stroke(255,229,190); strokeWeight(2);
    rect(x,PESTANA_Y,PESTANA_ANCHO,PESTANA_ALTO,7);
    fill(255,242,214);
    textFont(tituloGuia); textSize(16); textAlign(CENTER,CENTER);
    text(numero==0 ? "Objetivo  2/2  >" : "<  Cómo jugar  1/2",x+PESTANA_ANCHO/2,PESTANA_Y+PESTANA_ALTO/2);
  }

  private void mostrarObjetivo() {
    noStroke(); fill(249,234,211);
    rect(40,154,1200,447);
    textFont(tituloGuia); textAlign(CENTER,CENTER); textSize(32);
    fill(133,13,52);
    text("TU OBJETIVO",640,185);
    fill(67,35,33); textSize(21);
    text("Organiza tu domingo para cumplir tus tareas a tiempo y cuidar tu bienestar.",640,221);
    seccionObjetivo(245,"1. Completa las cinco tareas del computador",
      "Elige qué actividad hacer y consulta en el calendario a qué hora debes empezarla.",
      "Descansa en la cama para recuperar energía y concentración. Usa el celular para bajar el estrés.");
    seccionObjetivo(354,"2. Encuentra los tres libros de la biblioteca",
      "Desde las 12:00 p. m., sal del cuarto y cruza el pasillo hasta la biblioteca.",
      "Acércate a los puntos señalados y pulsa E para buscar los libros.");
    seccionObjetivo(463,"3. Gana el día",
      "Completa las cinco tareas y el encargo de la biblioteca para ganar.",
      "Si una tarea sigue pendiente y pasa su última hora de inicio, tendrás que reiniciar el día.");
  }

  private void seccionObjetivo(float y,String titulo,String primera,String segunda) {
    stroke(187,150,120); strokeWeight(2); fill(255,246,226);
    rect(83,y,1114,99,12);
    textAlign(LEFT,CENTER); fill(133,13,52); textSize(23);
    text(titulo,111,y+23);
    fill(67,35,33); textSize(19);
    text(primera,111,y+52);
    text(segunda,111,y+76);
  }

  private float xPestana(int numero) { return numero==0 ? 1054 : 54; }

  void procesarClick() {
    if (clicCerrar()) {
      cerrar();
      jugador.detenerMovimiento();
    } else if (inicioPagina<0 && sobreSeleccion(xPestana(pagina),PESTANA_Y,PESTANA_ANCHO,PESTANA_ALTO)) {
      inicioPagina=millis();
    }
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

  void abrir() { abierta=true; pagina=0; inicioPagina=-1; }
  void cerrar() { abierta=false; inicioPagina=-1; }
  private boolean clicCerrar() {
    return mouseJuegoX()>=CIERRE_X && mouseJuegoX()<=CIERRE_X+CIERRE_LADO &&
           mouseJuegoY()>=CIERRE_Y && mouseJuegoY()<=CIERRE_Y+CIERRE_LADO;
  }
}
