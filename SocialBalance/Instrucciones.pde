class Instrucciones {
  boolean abierta = true;

  Instrucciones(PImage imagen) {
    // Se conserva la firma existente; el contenido ya no está incrustado en un PNG.
  }

  void mostrar() {
    if (!abierta) return;
    pushStyle(); rectMode(CORNER);
    dibujarVentanaEmergente();
    fill(255,240,225); textAlign(LEFT,CENTER); textSize(28);
    text("CÓMO JUGAR · SOCIAL BALANCE",85,62);
    dibujarCierreVentana();

    seccion("1. TU OBJETIVO",75,125,550,185,
      "Organiza tu día y completa las tareas antes de sus plazos. Elige el orden y cuida tu energía, estrés y concentración.");
    seccion("2. CONTROLES",655,125,550,185,
      "WASD o flechas: moverte en cuatro direcciones.\nE: interactuar cerca de un mueble.\nMouse: elegir carpetas, opciones y respuestas.");
    seccion("3. EN LA HABITACIÓN",75,335,550,225,
      "Escritorio: abrir carpetas y realizar tareas.\nCama: descansar y recuperar energía.\nCelular: usar redes para reducir el estrés.\nAcércate hasta que aparezca la indicación de E.");
    seccion("4. PLANIFICA TU TIEMPO",655,335,550,225,
      "El día comienza a las 8:00 a. m.\nEl reloj se detiene durante los minijuegos.\nCada fallo o abandono consume " + penalizacionFalloMinutos + " minutos; abandonar pide confirmación.\nDescanso máximo: " + MAX_DESCANSO + " minutos al día.");

    fill(65,39,45); textAlign(CENTER,CENTER); textSize(18);
    text("Consulta el costo y la hora límite de cada tarea antes de comenzar.",640,590);
    botonInstrucciones("ENTENDIDO · VOLVER AL JUEGO",410,625,460,48);
    popStyle();
  }

  void seccion(String titulo,float x,float y,float w,float h,String contenido) {
    fill(255,247,225,175); stroke(150,120,106); strokeWeight(1); rect(x,y,w,h,10);
    fill(104,42,62); textAlign(LEFT,TOP); textSize(23); text(titulo,x+20,y+16);
    fill(55,42,40); textSize(19); textLeading(28);
    text(contenido,x+20,y+57,w-40,h-65);
  }

  void botonInstrucciones(String etiqueta,float x,float y,float w,float h) {
    boolean encima=sobreBoton(x,y,w,h);
    fill(encima ? color(147,73,94) : color(108,48,68)); stroke(240,215,190); strokeWeight(2);
    rect(x,y,w,h,7); fill(255,245,230); textAlign(CENTER,CENTER); textSize(18);
    text(etiqueta,x+w/2,y+h/2);
  }

  boolean sobreBoton(float x,float y,float w,float h) {
    return mouseJuegoX()>=x && mouseJuegoX()<=x+w && mouseJuegoY()>=y && mouseJuegoY()<=y+h;
  }
  void abrir() { abierta=true; }
  void cerrar() { abierta=false; }
  boolean clicCerrar() {
    return sobreCierreVentana(mouseJuegoX(),mouseJuegoY()) || sobreBoton(410,625,460,48);
  }
}
