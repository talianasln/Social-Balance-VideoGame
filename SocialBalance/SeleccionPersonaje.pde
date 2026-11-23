final float VOLVER_SELECCION_X = 145, VOLVER_SELECCION_Y = 605;

float tarjetaPersonajeX(int indice) { return 145 + indice*340; }
boolean sobreSeleccion(float x,float y,float w,float h) {
  return mouseJuegoX()>=x && mouseJuegoX()<=x+w && mouseJuegoY()>=y && mouseJuegoY()<=y+h;
}
void mostrarSeleccionPersonaje() {
  pushStyle(); rectMode(CORNER); imageMode(CORNER);
  image(fondoInicio,0,0,ANCHO_JUEGO,ALTO_JUEGO);
  noStroke(); fill(0,180); rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
  fill(255,230,215); textAlign(CENTER,CENTER); textSize(32);
  text("ELIGE TU PERSONAJE",640,90);
  textSize(17); text("Selecciona una opción para comenzar el día",640,135);
  for(int i=0;i<personajes.length;i++) {
    float x=tarjetaPersonajeX(i);
    boolean elegido=personajeSeleccionado==i+1;
    fill(elegido ? color(99,69,78,245) : color(32,29,38,235));
    stroke(elegido ? color(255,217,185) : color(155,123,133)); strokeWeight(elegido ? 4 : 2);
    rect(x,190,310,360,14);
    PersonajeConfig p=personajes[i];
    if(p.preview!=null) dibujarImagenAjustada(p.preview,x+25,205,260,270);
    else {
      noStroke(); fill(186,158,170); ellipse(x+155,280,75,75);
      rect(x+100,330,110,125,35);
    }
    fill(255,230,215); textAlign(CENTER,CENTER); textSize(24);
    text(p.nombre,x+155,505);
  }
  boton("VOLVER AL MENÚ",VOLVER_SELECCION_X,VOLVER_SELECCION_Y);
  textAlign(CENTER,CENTER);
  boolean listo=personajeSeleccionado>=1 && personajeSeleccionado<=personajes.length;
  stroke(213,164,145); strokeWeight(2);
  fill(listo ? color(133,91,83) : color(55,49,56)); rect(490,605,300,60,9);
  fill(listo ? color(255,237,224) : color(155)); textSize(20);
  text("COMENZAR",640,635);
  popStyle();
}
void seleccionarPersonajeConClick() {
  if (sobreSeleccion(VOLVER_SELECCION_X,VOLVER_SELECCION_Y,240,60)) {
    personajeSeleccionado=0;
    pantalla=0;
    return;
  }
  for(int i=0;i<personajes.length;i++) {
    if(sobreSeleccion(tarjetaPersonajeX(i),190,310,360)) { personajeSeleccionado=i+1; return; }
  }
  if(personajeSeleccionado>=1 && personajeSeleccionado<=personajes.length && sobreSeleccion(490,605,300,60)) {
    jugador.cargarPersonaje(personajeSeleccionado);
    pantalla=2;
  }
}