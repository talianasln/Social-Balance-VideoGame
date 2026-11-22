// Coordina los motores de los compañeros con las reglas compartidas del día.
// Las vistas no descuentan recursos: cada resultado se liquida una sola vez aquí.
class GestorMinijuegos {
  int activo = 0; // 1 contraseña, 2 memoria, 3 verdadero/falso, 4 conectar conceptos
  int resultado = 0; // 0 jugando, 1 éxito, 2 fallo ya penalizado
  boolean confirmarSalida = false;
  boolean mostrarPista = false;
  long inicioModal;
  String derrota = "";
  String avisoEscritorio = "";
  CrearContrasenaSegura contrasena;
  VistaContrasena vistaContrasena;
  VistaMemoria vistaMemoria;
  VerdaderoFalso verdaderoFalso;
  VistaVerdaderoFalso vistaVerdaderoFalso;
  ConectarConceptos conceptos;
  VistaConectarConceptos vistaConceptos;
  int intentosContrasenaProcesados = 0;
  int varianteContrasena = int(random(3));

  Tarea tareaActual() {
    for (Tarea tarea : escritorio.tareas) if (tarea.id==activo) return tarea;
    return null;
  }

  boolean abrir(int id) {
    if (activo!=0 || derrota.length()>0) return false;
    Tarea elegida=null;
    for (Tarea tarea : escritorio.tareas) if (tarea.id==id) elegida=tarea;
    if (elegida==null) return false;
    avisoEscritorio=elegida.bloqueo();
    if (avisoEscritorio.length()>0) return false;
    activo=id;
    resultado=0;
    confirmarSalida=false;
    mostrarPista=false;
    crearIntento();
    escritorio.cerrarInterfaz();
    jugador.detenerMovimiento();
    return true;
  }

  void crearIntento() {
    if (activo==1) {
      contrasena=new CrearContrasenaSegura(varianteContrasena);
      vistaContrasena=new VistaContrasena(contrasena);
      intentosContrasenaProcesados=0;
    } else if (activo==2) {
      vistaMemoria = new VistaMemoria(
        (long)millis(),
        imagenesMemoria,
        reversoMemoria
        );
    } else if (activo==3) {
      verdaderoFalso=new VerdaderoFalso();
      vistaVerdaderoFalso=new VistaVerdaderoFalso(verdaderoFalso, true);
    } else if (activo==4) {
      conceptos=new ConectarConceptos();
      conceptos.iniciar(millis());
      vistaConceptos=new VistaConectarConceptos(conceptos);
    }
  }

  boolean puedeIntentar() {
    return activo!=0 && resultado==0 && derrota.length()==0 &&
      tareaActual().bloqueo().length()==0;
  }

  boolean modalAbierto() {
    return confirmarSalida || mostrarPista || resultado!=0 || derrota.length()>0;
  }

  void sincronizar() {
    if (activo==0 || resultado!=0 || derrota.length()>0) return;
    boolean exito=(activo==1 && contrasena.estaCompletado()) ||
      (activo==2 && vistaMemoria.memoria.completada()) ||
      (activo==3 && verdaderoFalso.completado()) ||
      (activo==4 && conceptos.estaTerminado() && conceptos.hayVictoria());
    if (exito) {
      Tarea tarea=tareaActual();
      if (!tarea.completada && tarea.bloqueo().length()==0 && hud.avanzarTiempo(tarea.minutosNecesarios)) {
        hud.modificarEnergia(-tarea.energia);
        hud.modificarEstres(tarea.estres);
        hud.modificarConcentracion(-tarea.concentracion);
        tarea.completada=true;
        resultado=1;
        comprobarViabilidad();
      }
      return;
    }
    if (activo==1 && contrasena.obtenerIntentos()>intentosContrasenaProcesados) {
      intentosContrasenaProcesados=contrasena.obtenerIntentos();
      registrarFallo();
    } else if (activo==3 && verdaderoFalso.terminado()) registrarFallo();
    else if (activo==4 && conceptos.estaTerminado()) registrarFallo();
  }

  boolean registrarFallo() {
    if (resultado!=0 || activo==0) return false;
    // Se valida antes de iniciar cada intento y se comprueba otra vez al liquidar.
    if (!hud.avanzarTiempo(penalizacionFalloMinutos)) {
      derrota="No queda tiempo para asumir la penalización del intento.";
      return false;
    }
    resultado=2;
    confirmarSalida=false;
    comprobarViabilidad();
    return true;
  }

  void reintentar() {
    if (resultado!=2 || derrota.length()>0) return;
    String bloqueo=tareaActual().bloqueo();
    if (bloqueo.length()>0) {
      avisoEscritorio=bloqueo;
      volver();
      return;
    }
    String textoAnterior=activo==1 ? vistaContrasena.textoIngresado : "";
    resultado=0;
    crearIntento();
    if (activo==1) vistaContrasena.textoIngresado=textoAnterior;
  }

  void solicitarSalida() {
    if (activo==0 || derrota.length()>0) return;
    if (resultado!=0) {
      volver();
      return;
    }
    mostrarPista=false;
    if (!confirmarSalida) inicioModal=millis();
    confirmarSalida=true;
    if (activo==3) vistaVerdaderoFalso.arrastrando=false;
  }

  void cancelarSalida() {
    if (activo==2) {
      long pausa=millis()-inicioModal;
      vistaMemoria.memoria.inicioEstado+=pausa;
      if (vistaMemoria.memoria.inicioJuego!=0) vistaMemoria.memoria.inicioJuego+=pausa;
      if (vistaMemoria.memoria.inicioError!=0) vistaMemoria.memoria.inicioError+=pausa;
    }
    confirmarSalida=false;
  }

  void volver() {
    activo=0;
    resultado=0;
    confirmarSalida=false;
    mostrarPista=false;
    escritorio.abrirInterfaz();
    jugador.detenerMovimiento();
  }

  void comprobarViabilidad() {
    // Orden de plazos: con duraciones fijas, comprobar el orden más temprano
    // detecta imposibilidad por tiempo sin inferir derrotas por recursos.
    int finPosible=hud.minutosDelDia();
    for (Tarea tarea : escritorio.tareas) {
      if (tarea.completada) continue;
      finPosible+=tarea.minutosNecesarios;
      if (finPosible>tarea.limite || finPosible>FIN_DIA) {
        derrota="Ya no alcanza el tiempo para terminar " + tarea.nombre + " dentro de su plazo.";
        jugador.detenerMovimiento();
        return;
      }
    }
  }

  void mostrar() {
    if (derrota.length()>0) {
      mostrarDerrota();
      return;
    }
    if (activo==0) return;
    if (!modalAbierto()) {
      if (activo==1) vistaContrasena.mostrar();
      else if (activo==2) vistaMemoria.mostrar();
      else if (activo==3) vistaVerdaderoFalso.mostrar();
      else if (activo==4) vistaConceptos.mostrar();
      sincronizar();
    }
    if (derrota.length()>0) {
      mostrarDerrota();
      return;
    }
    if (confirmarSalida) {
      panelMensaje("¿ABANDONAR ESTE INTENTO?", "Se perderá el avance de este intento y pasarán " + penalizacionFalloMinutos +
        " minutos.\nLa energía y el estrés no cambiarán.");
      botonPanel("SEGUIR JUGANDO", 330, 460, 290);
      botonPanel("ABANDONAR", 660, 460, 290);
    } else if (mostrarPista) {
      String pista=varianteContrasena==0 ? "Busca tres palabras con la misma inicial e igual cantidad de vocales.\nPor ejemplo, 'casa' tiene dos vocales.\nUn producto impar necesita dos dígitos impares: 1, 3, 5, 7 o 9." :
        varianteContrasena==1 ? "Cuenta vocales, no sílabas: necesitas 2, luego 3 y luego 4.\nPor ejemplo, 'camino' tiene tres vocales.\nEntre palabras puedes usar parejas como 18, 27 o 36: suman 9." :
        "Busca palabras que terminen en la misma letra.\nLa primera y la tercera llevan 3 vocales; la segunda, 2.\nLos dígitos pueden ser 26, 62, 34 o 43: su producto es 12.";
      panelMensaje("PISTA · CONTRASEÑA DE PRÁCTICA", pista);
      botonPanel("VOLVER AL RETO", 480, 490, 320);
    } else if (resultado!=0) {
      Tarea tarea=tareaActual();
      String mensaje=resultado==1 ? "Completaste " + tarea.nombre + ".\nTiempo: +" + tarea.minutosNecesarios + " min   Energía: −" + tarea.energia +
        "   Estrés: +" + tarea.estres + "\nHora actual: " + hud.obtenerHora() :
        "Este intento no superó el reto. Pasaron " + penalizacionFalloMinutos + " minutos.\nNo se descontó energía ni aumentó el estrés.\nHora actual: " + hud.obtenerHora();
      panelMensaje(resultado==1 ? "¡ACTIVIDAD COMPLETADA!" : "INTENTO NO SUPERADO", mensaje);
      if (resultado==1) botonPanel("VOLVER AL ESCRITORIO", 445, 480, 390);
      else {
        botonPanel("REINTENTAR", 330, 480, 290);
        botonPanel("VOLVER AL ESCRITORIO", 660, 480, 290);
      }
    }
  }

  void presionar() {
    float x=mouseJuegoX(), y=mouseJuegoY();
    if (derrota.length()>0) {
      clickDerrota();
      return;
    }
    if (confirmarSalida) {
      if (dentroPanel(330, 460, 290)) cancelarSalida();
      else if (dentroPanel(660, 460, 290)) {
        registrarFallo();
        if (derrota.length()==0) volver();
      }
      return;
    }
    if (mostrarPista) {
      if (dentroPanel(480, 490, 320)) mostrarPista=false;
      return;
    }
    if (resultado!=0) {
      if (resultado==1 && dentroPanel(445, 480, 390)) volver();
      else if (resultado==2 && dentroPanel(330, 480, 290)) reintentar();
      else if (resultado==2 && dentroPanel(660, 480, 290)) volver();
      return;
    }
    if (activo==1) vistaContrasena.presionar(x, y);
    else if (activo==2) vistaMemoria.presionar(x, y, (long)millis());
    else if (activo==3) vistaVerdaderoFalso.presionar(x, y, (long)millis());
    else if (activo==4) vistaConceptos.presionar(x,y);
    sincronizar();
    boolean salir=activo==1 ? vistaContrasena.quiereSalir : activo==2 ? vistaMemoria.quiereSalir : activo==3 ? vistaVerdaderoFalso.quiereSalir : activo==4 && vistaConceptos.quiereSalir;
    if (salir) {
      if (activo==1) vistaContrasena.quiereSalir=false;
      else if (activo==2) vistaMemoria.quiereSalir=false;
      else if (activo==3) vistaVerdaderoFalso.quiereSalir=false;
      else if (activo==4) vistaConceptos.quiereSalir=false;
      solicitarSalida();
    }
  }

  void teclear(char tecla, int codigo) {
    if (activo==1 && !modalAbierto()) {
      vistaContrasena.teclear(tecla, codigo);
      sincronizar();
    }
  }

  void panelMensaje(String titulo, String mensaje) {
    pushStyle();
    rectMode(CORNER);
    noStroke();
    fill(13, 13, 22, 245);
    rect(0, 0, ANCHO_JUEGO, ALTO_JUEGO);
    fill(38, 34, 46);
    stroke(226, 176, 153);
    rect(180, 170, 920, 405, 18);
    textAlign(CENTER, CENTER);
    fill(255, 223, 209);
    textSize(28);
    text(titulo, 640, 230);
    fill(235, 218, 211);
    textSize(18);
    text(mensaje, 220, 280, 840, 155);
    popStyle();
  }
  void botonPanel(String nombre, float x, float y, float ancho) {
    pushStyle();
    rectMode(CORNER);
    stroke(226, 176, 153);
    fill(dentroPanel(x, y, ancho) ? color(155, 107, 100) : color(102, 73, 84));
    rect(x, y, ancho, 55, 8);
    textAlign(CENTER, CENTER);
    fill(255, 239, 228);
    textSize(17);
    text(nombre, x+ancho/2, y+27);
    popStyle();
  }
  boolean dentroPanel(float x, float y, float ancho) {
    return mouseJuegoX()>=x && mouseJuegoX()<=x+ancho && mouseJuegoY()>=y && mouseJuegoY()<=y+55;
  }
  void mostrarDerrota() {
    panelMensaje("VOLVAMOS A PLANEAR EL DÍA", derrota + "\nPuedes reiniciar y probar otro orden de actividades.");
    botonPanel("REINICIAR EL DÍA", 440, 480, 400);
  }
  void clickDerrota() {
    if (dentroPanel(440, 480, 400)) reiniciarDia();
  }
}

void reiniciarDia() {
  hud=new HUD();
  escritorio=new Escritorio();
  cama=new Cama();
  celular=new Celular();
  gestorMinijuegos=new GestorMinijuegos();
  jugador.reiniciarPosicion();
  instrucciones.abrir();
}
