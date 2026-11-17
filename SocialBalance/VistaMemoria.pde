// Adaptacion grafica del prototipo de Memoria aprobado.
// Sin derrota por tiempo: se conserva la presentación y el juego de parejas.
class VistaMemoria {
  Memoria memoria;
  boolean quiereSalir = false;
  final float CARTA_ANCHO = 160;
  final float CARTA_ALTO = 124;
  final float CARTA_ESPACIO_X = 22;
  final float CARTA_ESPACIO_Y = 16;
  final float CARTA_INICIO_X = 287;
  final float CARTA_INICIO_Y = 205;
  final String[] temas = {"PRIVACIDAD", "VERIFICAR", "DESCANSO", "RESPETO", "TIEMPO", "SEGURIDAD"};

  VistaMemoria(long ahora) {
    memoria = new Memoria(ahora);
  }
  void mostrar() {
    long ahora = (long)millis();
    memoria.actualizar(ahora);
    pushStyle();
    rectMode(CORNER);
    fill(15,13,22,245); noStroke(); rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    fill(37,32,45); rect(75,44,1130,632,18);
    fill(240,212,197); textAlign(LEFT,CENTER); textSize(30);
    text("SOCIAL BALANCE  /  MEMORIA",120,95);
    fill(187,174,186); textSize(15);
    text("Asocia 6 hábitos que ayudan a usar las redes de forma responsable.",122,129);
    fill(61,42,61); stroke(228,178,159); rect(1147,57,41,35,6);
    fill(255); noStroke(); textAlign(CENTER,CENTER); textSize(19); text("X",1167,74);
    fill(58,48,62); rect(962,98,187,47,12);
    fill(246,218,202); textSize(14); text("TIEMPO REAL",1055,111);
    textSize(25); text((memoria.inicioJuego == 0 ? 0 : (ahora-memoria.inicioJuego)/1000) + " s",1055,132);
    String aviso = "";
    if (memoria.estado == Memoria.TAPADAS) aviso="Prepárate: las 12 cartas se mostrarán en un momento.";
    else if (memoria.estado == Memoria.MEMORIZAR) {
      long restante = Memoria.MEMORIZACION - (ahora-memoria.inicioEstado);
      aviso="¡MEMORIZA! Se ocultarán en " + (int)Math.max(1,(restante+999)/1000) + " s.";
    }
    else if (memoria.estado == Memoria.JUGANDO) aviso="Selecciona dos cartas iguales. Parejas: " + memoria.paresResueltos + " / 6.";
    else if (memoria.estado == Memoria.DERROTA) aviso="Se agotó el tiempo. La ronda se reiniciará con las cartas mezcladas.";
    else if (memoria.estado == Memoria.VICTORIA) aviso="¡LOGRADO! Descubriste las seis parejas. Actividad completada.";
    textAlign(CENTER,CENTER); textSize(18);
    if (memoria.estado == Memoria.DERROTA) fill(255,149,149);
    else if (memoria.estado == Memoria.VICTORIA) fill(156,238,173);
    else fill(226,205,195);
    text(aviso,ANCHO_JUEGO/2,169);
    for (int i=0;i<12;i++) {
      float x=CARTA_INICIO_X+(i%4)*(CARTA_ANCHO+CARTA_ESPACIO_X);
      float y=CARTA_INICIO_Y+(i/4)*(CARTA_ALTO+CARTA_ESPACIO_Y);
      dibujarCarta(i,x,y,CARTA_ANCHO,CARTA_ALTO);
    }
    fill(166,147,161); textSize(14); textAlign(CENTER,CENTER);
    text("Sin límite de tiempo real. El reloj del día avanza al finalizar o abandonar.",640,639);
    if (memoria.estado == Memoria.VICTORIA) {
      fill(102,73,84); stroke(226,176,153); strokeWeight(2);
      rect(486,653,308,40,8);
      fill(255,239,228); noStroke(); textSize(15);
      text("VOLVER AL COMPUTADOR",640,673);
    }
    popStyle();
  }
  void presionar(float px,float py,long ahora) {
    memoria.actualizar(ahora);
    if(px>=1147 && px<=1188 && py>=57 && py<=92) { quiereSalir=true; return; }
    if(memoria.estado == Memoria.VICTORIA && px>=486 && px<=794 && py>=653 && py<=693) {
      quiereSalir=true; return;
    }
    if(memoria.estado != Memoria.JUGANDO) return;
    for(int i=0;i<12;i++) {
      float x=CARTA_INICIO_X+(i%4)*(CARTA_ANCHO+CARTA_ESPACIO_X);
      float y=CARTA_INICIO_Y+(i/4)*(CARTA_ALTO+CARTA_ESPACIO_Y);
      if(px>=x && px<x+CARTA_ANCHO && py>=y && py<y+CARTA_ALTO) {
        memoria.elegir(i,ahora); return;
      }
    }
  }
void dibujarCarta(int indice, float x, float y, float w, float h) {
  boolean visible = memoria.visible(indice);
  boolean yaAcertada = memoria.acertadas[indice];

  pushStyle();
  rectMode(CORNER);
  strokeWeight(2);
  stroke(visible ? color(222, 185, 162) : color(124, 100, 121));

  if (!visible) fill(73, 55, 78);
  else if (yaAcertada) fill(59, 93, 80);
  else fill(225, 203, 189);

  rect(x, y, w, h, 12);

  textAlign(CENTER, CENTER);
  if (visible) {
    pushMatrix();
    translate(x + w/2, y + 48);
    dibujarSimbolo(memoria.cartas[indice]);
    popMatrix();
    fill(44, 38, 48);
    textSize(13);
    text(temas[memoria.cartas[indice]], x+w/2, y + h - 26);
  } else {
    fill(228, 193, 180);
    textSize(54);
    text("?", x+w/2, y + h/2);
  }
  popStyle();
}

void dibujarSimbolo(int tipo) {
  pushStyle();
  noFill();
  stroke(74, 54, 75);
  strokeWeight(4);
  strokeCap(ROUND);
  strokeJoin(ROUND);

  if (tipo == 0) { // Escudo: privacidad
    beginShape();
    vertex(0, -28); vertex(25, -17); vertex(21, 16);
    vertex(0, 31); vertex(-21, 16); vertex(-25, -17);
    endShape(CLOSE);
    line(-9, 1, -1, 9);
    line(-1, 9, 12, -8);
  } else if (tipo == 1) { // Lupa: verificar
    ellipse(-7, -7, 37, 37);
    line(7, 9, 28, 30);
    line(-14, -6, -4, 4);
  } else if (tipo == 2) { // Luna: descanso
    beginShape();
    vertex(-6, -26); bezierVertex(-26, -2, -5, 26, 17, 21);
    bezierVertex(8, 10, 9, -8, -6, -26);
    endShape(CLOSE);
    line(25, -26, 25, -15);
    line(19, -20, 31, -20);
  } else if (tipo == 3) { // Diálogo: respeto
    rect(-29, -24, 58, 41, 9);
    line(-12, 17, -20, 28);
    line(-20, 28, 2, 17);
    line(-16, -8, 17, -8);
    line(-16, 3, 10, 3);
  } else if (tipo == 4) { // Reloj: tiempo
    ellipse(0, 0, 59, 59);
    line(0, 0, 0, -19);
    line(0, 0, 14, 8);
    point(0, -23);
  } else { // Candado: seguridad
    arc(0, -9, 42, 44, PI, TWO_PI);
    rect(-24, -11, 48, 39, 6);
    ellipse(0, 4, 4, 4);
    line(0, 7, 0, 16);
  }
  popStyle();
}


}
