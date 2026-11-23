boolean puedeMostrarEncargo() {
  return !hayInterfazAbierta() && encargoBiblioteca.disponible();
}

class EncargoBiblioteca {
  final int HORA_ENCARGO=12*60;
  final int COSTO_BUSQUEDA=10;
  final int DESCANSO_ADICIONAL=60;
  final String[] libros={"Bienestar digital", "Fundamentos de ciberseguridad", "Hábitos de estudio"};
  // Marcadores sobre los estantes y zonas alcanzables desde el suelo.
  final float[][] estantes={
    {94,334, 158,310,255,440},
    {383,155, 338,242,492,320},
    {1018,155, 925,248,1076,275},
    {1192,335, 1112,430,1180,479},
    {520,160, 500,249,565,320},
    {750,155, 703,249,805,320}
  };
  // Los dos accesos nuevos pertenecen al mismo estante central.
  final int[] busquedaPorZona={0,1,2,3,4,4};
  final int[] libroPorEstante={0,1,2,-1,-1};
  final boolean[] revisados=new boolean[libroPorEstante.length];
  final boolean[] encontrados=new boolean[3];
  boolean abierto;
  private boolean sorteado;
  String resultado="";

  boolean disponible() { return hud.minutosDelDia()>=HORA_ENCARGO; }

  boolean completo() {
    for (boolean encontrado : encontrados) if (!encontrado) return false;
    return true;
  }

  int descansoAdicional() { return sorteado ? DESCANSO_ADICIONAL : 0; }

  int estanteCercano() {
    if (!disponible() || completo() || escenarios.actual!=escenarios.BIBLIOTECA) return -1;
    for (int i=0; i<estantes.length; i++) {
      float[] zona=estantes[i];
      float x=jugador.piesX(), y=jugador.piesY();
      int busqueda=busquedaPorZona[i];
      if (!revisados[busqueda] && x>=zona[2] && y>=zona[3] && x<=zona[4] && y<=zona[5]) return busqueda;
    }
    return -1;
  }

  private void distribuirLibros() {
    for (int i=libroPorEstante.length-1; i>0; i--) {
      int j=int(random(i+1));
      int libro=libroPorEstante[i];
      libroPorEstante[i]=libroPorEstante[j];
      libroPorEstante[j]=libro;
    }
    sorteado=true;
  }

  boolean buscarCerca() {
    int estante=estanteCercano();
    if (estante<0) return false;
    if (hud.energia<COSTO_BUSQUEDA) {
      resultado="Necesitas 10 de energía para revisar este estante.";
    } else {
      if (!sorteado) distribuirLibros();
      hud.modificarEnergia(-COSTO_BUSQUEDA);
      revisados[estante]=true;
      int libro=libroPorEstante[estante];
      if (libro<0) resultado="En este estante no está ninguno de los libros de la lista.";
      else {
        encontrados[libro]=true;
        resultado="Encontraste «"+libros[libro]+"».";
      }
      if (completo()) resultado+=" Ya tienes los tres libros.";
    }
    abierto=true;
    jugador.detenerMovimiento();
    return true;
  }

  private boolean dentro(float x,float y,float w,float h) {
    return mouseJuegoX()>=x && mouseJuegoX()<=x+w && mouseJuegoY()>=y && mouseJuegoY()<=y+h;
  }

  boolean sobreBoton() { return dentro(996,650,259,48); }

  void procesarClick() {
    if (abierto) {
      if (dentro(1000,182,45,44) || dentro(497,477,286,48)) cerrar();
    } else if (disponible() && sobreBoton()) {
      abierto=true;
      jugador.detenerMovimiento();
    }
  }

  void cerrar() {
    abierto=false;
    resultado="";
  }

  void mostrarMarcadores() {
    if (!disponible() || completo() || escenarios.actual!=escenarios.BIBLIOTECA) return;
    pushStyle();
    rectMode(CORNER);
    for (int i=0; i<estantes.length; i++) {
      if (revisados[busquedaPorZona[i]]) continue;
      float x=estantes[i][0], y=estantes[i][1]+sin(millis()*0.005+i)*5;
      fill(255,241,175);
      stroke(197,121,34);
      strokeWeight(2);
      rect(x-17,y-27,34,42,10);
      noStroke();
      fill(241,166,24);
      beginShape();
      vertex(x-5,y-20);
      vertex(x+5,y-20);
      vertex(x+2.5,y-3);
      vertex(x-2.5,y-3);
      endShape(CLOSE);
      ellipse(x,y+4,6,6);
    }
    popStyle();
  }

  void mostrar() {
    if (!disponible()) return;
    pushStyle();
    rectMode(CORNER);
    if (abierto) mostrarLista();
    else mostrarBoton();
    popStyle();
  }

  private void mostrarBoton() {
    float pulso=(sin(millis()*0.006)+1)/2;
    noStroke();
    fill(255,207,85,28+pulso*50);
    rect(992,646,267,56,12);
    fill(sobreBoton() ? color(255,233,154) : color(249,209,106));
    stroke(255,237,175);
    strokeWeight(2);
    rect(996,650,259,48,9);
    fill(85,54,42);
    textAlign(CENTER,CENTER);
    textSize(17);
    text(completo() ? "LIBROS REUNIDOS" : "¡ LIBROS PARA MAÑANA",1125,674);
  }

  private void mostrarLista() {
    noStroke();
    fill(17,11,21,205);
    rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    fill(52,34,47);
    stroke(248,202,141);
    strokeWeight(2);
    rect(216,160,848,385,14);
    fill(255,230,174);
    textAlign(LEFT,CENTER);
    textSize(28);
    text("Libros para la clase de mañana",254,205);
    textSize(18);
    fill(253,230,217);
    text("Ve a la biblioteca y pulsa E frente a un estante. Cada búsqueda cuesta 10 de energía.",254,249);
    for (int i=0; i<libros.length; i++) {
      fill(encontrados[i] ? color(166,222,167) : color(250,226,206));
      text((encontrados[i] ? "Encontrado  ·  " : "Pendiente  ·  ")+libros[i],270,293+i*36);
    }
    fill(255,207,133);
    text(resultado,254,427);
    fill(123,78,87);
    rect(1000,182,45,44,8);
    rect(497,477,286,48,8);
    fill(255,237,222);
    textAlign(CENTER,CENTER);
    text("X",1022,203);
    text("CERRAR LISTA",640,501);
  }
}
