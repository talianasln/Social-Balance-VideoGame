PImage resplandorInteraccion;

void dibujarBrillosHabitacion(int ahora) {
  if (resplandorInteraccion==null) {
    int lado=72;
    resplandorInteraccion=createImage(lado,lado,ARGB);
    resplandorInteraccion.loadPixels();
    for (int y=0; y<lado; y++) for (int x=0; x<lado; x++) {
      float radio=dist(x,y,35.5,35.5)/35.5;
      float fuerza=max(0,1-radio*radio);
      resplandorInteraccion.pixels[y*lado+x]=color(255,208,124,116*fuerza*fuerza*fuerza);
    }
    resplandorInteraccion.updatePixels();
  }
  pushStyle();
  imageMode(CENTER);
  float pulso=0.75+0.25*sin(ahora*0.003);
  if (personajeSeleccionado==2) {
    brilloInteractuable(216,351,90,62,pulso);
    brilloInteractuable(968,450,157,85,pulso);
    brilloInteractuable(1207,475,67,43,pulso);
  } else {
    brilloInteractuable(216,354,90,62,pulso);
    brilloInteractuable(965,455,157,85,pulso);
    brilloInteractuable(1234,480,67,43,pulso);
  }
  brilloInteractuable(698,321,54,63,pulso);
  popStyle();
}

void brilloInteractuable(float x,float y,float ancho,float alto,float pulso) {
  tint(255,255*pulso);
  image(resplandorInteraccion,x,y,ancho,alto);
}
