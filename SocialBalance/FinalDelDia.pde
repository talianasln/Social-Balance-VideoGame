class FinalDelDia {
  final int FUNDIDO_INICIAL=1500, VICTORIA_MS=10000, PUNTAJE_MS=10000, CONSEJO_MS=7000;
  final int ENTRE_TARJETAS=3000, HACIA_LOGO=5000;
  final int INICIO_PUNTAJE=FUNDIDO_INICIAL+VICTORIA_MS+ENTRE_TARJETAS;
  final int INICIO_CONSEJO=INICIO_PUNTAJE+PUNTAJE_MS+ENTRE_TARJETAS;
  final int INICIO_LOGO=INICIO_CONSEJO+CONSEJO_MS+HACIA_LOGO;
  final int REVELAR_ESTRES=3300, RESTAR_ESTRES=3800, FIN_RESTA=5500;

  PImage imagenVictoria, imagenConsejo, imagenLogo;
  PFont tipografia;
  boolean activo, saliendo, reproducidaSuma, reproducidaResta;
  int inicio, energia, concentracion, estres;

  void cargar() {
    imagenVictoria=loadImage("VictoriaFinal.png");
    imagenConsejo=loadImage("ConsejoFinal.png");
    imagenLogo=loadImage("ArteTitulo.png");
    tipografia=new PFont(new java.awt.Font("SansSerif",java.awt.Font.BOLD,24),false);
  }

  void reiniciar() {
    activo=false;
    saliendo=false;
    reproducidaSuma=false;
    reproducidaResta=false;
  }

  boolean objetivosCumplidos() {
    return escritorio.cantidadCompletadas()==escritorio.tareas.cantidad() && encargoBiblioteca.completo();
  }

  void actualizar(int ahora) {
    if (saliendo && pantalla==0) reiniciar();
    if (!activo && pantalla==2 && !entradaPartida.activa && !menuPausaAbierto &&
        gestorMinijuegos.derrota.isEmpty() && objetivosCumplidos()) {
      activo=true;
      inicio=ahora;
      energia=hud.energia;
      concentracion=hud.concentracion;
      estres=hud.estres;
      jugador.detenerMovimiento();
      musicaAmbiente.detenerPorVictoria();
    }
    if (!activo) return;
    int t=ahora-inicio-INICIO_PUNTAJE;
    if (!reproducidaSuma && t>=0) {
      reproducidaSuma=true;
      reproducirEfecto("PuntajeSuma.wav");
    }
    if (!reproducidaResta && t>=RESTAR_ESTRES) {
      reproducidaResta=true;
      reproducirEfecto("PuntajeResta.wav");
    }
  }

  boolean cubreJuego(int ahora) { return activo && ahora-inicio>=FUNDIDO_INICIAL/2; }

  void procesarClick(int ahora) {
    if (saliendo || ahora-inicio<INICIO_LOGO || !sobreSeleccion(490,582,300,54)) return;
    saliendo=true;
    entradaPartida.iniciar(0);
  }

  int energiaEn(int t) { return round(energia*progreso(t,0,1500)); }
  int concentracionEn(int t) { return round(concentracion*progreso(t,1500,3100)); }
  int estresEn(int t) { return round(estres*progreso(t,RESTAR_ESTRES,FIN_RESTA)); }

  private float progreso(int t,int desde,int hasta) { return constrain((t-desde)/float(hasta-desde),0,1); }

  void mostrar(int ahora) {
    if (!activo) return;
    int t=ahora-inicio;
    if (t<FUNDIDO_INICIAL/2) {
      negro(t/float(FUNDIDO_INICIAL/2));
      return;
    }
    if (t<INICIO_PUNTAJE-1000) {
      victoria();
      cubrirEntre(t,FUNDIDO_INICIAL,VICTORIA_MS);
    } else if (t<INICIO_CONSEJO-1000) {
      puntaje(t-INICIO_PUNTAJE);
      cubrirEntre(t,INICIO_PUNTAJE,PUNTAJE_MS);
    } else if (t<INICIO_LOGO-1000) {
      pushStyle();
      imageMode(CORNER); noTint();
      image(imagenConsejo,0,0,ANCHO_JUEGO,ALTO_JUEGO);
      popStyle();
      cubrirEntre(t,INICIO_CONSEJO,CONSEJO_MS);
    } else {
      logo(t);
      negro(1-entradaPartida.progreso(t,INICIO_LOGO-1000,INICIO_LOGO));
    }
  }

  private void cubrirEntre(int t,int inicioEscena,int duracion) {
    int fundidoEntrada=inicioEscena==FUNDIDO_INICIAL ? FUNDIDO_INICIAL/2 : 1000;
    float entra=entradaPartida.progreso(t,inicioEscena-fundidoEntrada,inicioEscena);
    float sale=entradaPartida.progreso(t,inicioEscena+duracion,inicioEscena+duracion+1000);
    negro(max(1-entra,sale));
  }

  private void negro(float opacidad) {
    if (opacidad<=0) return;
    pushStyle();
    rectMode(CORNER); noStroke();
    fill(0,255*opacidad);
    rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    popStyle();
  }

  private void franja(int origenY,int finY,float y,float alto) {
    image(imagenVictoria,0,y,ANCHO_JUEGO,alto,0,origenY,imagenVictoria.width,finY);
  }

  private void victoria() {
    pushStyle();
    imageMode(CORNER); noTint();
    // Abrir espacio para la felicitación entre el título y el texto ilustrado.
    franja(0,542,0,367);
    franja(536,552,367,83);
    franja(548,768,450,164);
    franja(768,imagenVictoria.height,614,106);
    textFont(tipografia);
    textAlign(CENTER,CENTER);
    fill(73,38,30); textSize(23);
    text("Felicidades, completaste todas las tareas con éxito",640,393);
    text("evitando quedarte sin energía y manteniendo un nivel de estrés saludable",640,426);
    popStyle();
  }

  private void puntaje(int t) {
    pushStyle();
    rectMode(CORNER); imageMode(CORNER); noTint();
    franja(0,200,0,152);
    franja(536,552,152,439);
    franja(770,imagenVictoria.height,591,129);
    fill(252,231,213); stroke(120,47,59); strokeWeight(3);
    rect(283,167,714,393,13);
    noFill(); stroke(192,125,121); strokeWeight(1);
    rect(295,179,690,369,8);
    textFont(tipografia);
    textAlign(CENTER,CENTER);
    fill(120,47,59); textSize(50);
    text("Tu puntaje",640,222);
    filaPuntaje("Energía","+"+energiaEn(t),305,color(78,103,62));
    if (t>=1500) filaPuntaje("Concentración","+"+concentracionEn(t),352,color(78,103,62));
    if (t>=REVELAR_ESTRES) filaPuntaje("Estrés","−"+estresEn(t),399,color(156,53,64));
    stroke(184,118,112); line(405,447,875,447);
    fill(105,42,58); textSize(40);
    text("Total  "+(energiaEn(t)+concentracionEn(t)-estresEn(t)),640,500);
    popStyle();
  }

  private void filaPuntaje(String nombre,String valor,float y,int colorValor) {
    textAlign(LEFT,CENTER); textSize(26); fill(73,38,30);
    text(nombre,410,y);
    textAlign(RIGHT,CENTER); fill(colorValor);
    text(valor,870,y);
  }

  private void logo(int t) {
    pushStyle();
    rectMode(CORNER); imageMode(CORNER); noTint();
    noStroke();
    if (imagenLogo!=null) image(imagenLogo,0,0,ANCHO_JUEGO,ALTO_JUEGO);
    if (t>=INICIO_LOGO) {
      fill(sobreSeleccion(490,582,300,54) ? color(147,59,75) : color(104,37,53));
      rect(490,582,300,54,9);
      fill(255,240,222); textFont(tipografia); textSize(19); textAlign(CENTER,CENTER);
      text("VOLVER AL MENÚ",640,609);
    }
    popStyle();
  }

}

FinalDelDia finalDelDia=new FinalDelDia();
