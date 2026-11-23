// Coordina los motores de los compañeros con las reglas compartidas del día.
// Las vistas no descuentan recursos: cada resultado se liquida una sola vez aquí.
class GestorMinijuegos {
  int activo = 0; // 1 contraseña, 2 memoria, 3 verdadero/falso, 4 conectar conceptos, 5 ordenar pasos
  int resultado = 0; // 0 jugando, 1 éxito, 2 fallo ya penalizado
  boolean confirmarSalida = false;
  boolean mostrarPista = false;
  boolean mostrandoContexto;
  long inicioModal;
  String derrota = "";
  CrearContrasenaSegura contrasena;
  VistaContrasena vistaContrasena;
  VistaMemoria vistaMemoria;
  VerdaderoFalso verdaderoFalso;
  VistaVerdaderoFalso vistaVerdaderoFalso;
  ConectarConceptos conceptos;
  VistaConectarConceptos vistaConceptos;
  OrdenarPasos ordenarPasos;
  VistaOrdenarPasos vistaOrdenarPasos;
  int intentosContrasenaProcesados = 0;
  int varianteContrasena = int(random(3));

  Tarea tareaActual() {
    return escritorio.tareas.consultar(activo);
  }

  boolean abrir(int id) {
    if (activo!=0 || derrota.length()>0) return false;
    Tarea elegida=escritorio.tareas.consultar(id);
    if (elegida==null) return false;
    if (!elegida.bloqueo().isEmpty()) return false;
    activo=id;
    resultado=0;
    confirmarSalida=false;
    mostrarPista=false;
    mostrandoContexto=id!=1;
    if (!mostrandoContexto) crearIntento();
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
      verdaderoFalso.comenzar(millis());
      vistaVerdaderoFalso=new VistaVerdaderoFalso(verdaderoFalso);
    } else if (activo==4) {
      conceptos=new ConectarConceptos();
      conceptos.iniciar(millis());
      vistaConceptos=new VistaConectarConceptos(conceptos);
    } else if (activo==5) {
      ordenarPasos=new OrdenarPasos(new java.util.Random());
      ordenarPasos.iniciar((long)millis());
      vistaOrdenarPasos=new VistaOrdenarPasos(ordenarPasos);
    }
  }

  boolean puedeIntentar() {
    return activo!=0 && !mostrandoContexto && resultado==0 && derrota.length()==0 &&
      tareaActual().bloqueo().length()==0;
  }

  boolean modalAbierto() {
    return mostrandoContexto || confirmarSalida || mostrarPista || resultado!=0 || derrota.length()>0;
  }

  void sincronizar() {
    if (activo==0 || mostrandoContexto || resultado!=0 || derrota.length()>0) return;
    boolean exito=(activo==1 && contrasena.estaCompletado()) ||
      (activo==2 && vistaMemoria.memoria.completada()) ||
      (activo==3 && verdaderoFalso.completado()) ||
      (activo==4 && conceptos.estaTerminado() && conceptos.hayVictoria()) ||
      (activo==5 && ordenarPasos.hayVictoria());
    if (exito) {
      Tarea tarea=tareaActual();
      if (!tarea.estaCompletada() && tarea.bloqueo().length()==0 && hud.avanzarTiempo(tarea.minutosNecesarios)) {
        hud.modificarEnergia(-tarea.energia);
        hud.modificarEstres(tarea.estres);
        hud.modificarConcentracion(-tarea.concentracion);
        escritorio.tareas.completar(tarea.id);
        resultado=1;
        guardado.guardar();
      }
      return;
    }
    if (activo==1 && contrasena.obtenerIntentos()>intentosContrasenaProcesados) {
      intentosContrasenaProcesados=contrasena.obtenerIntentos();
      registrarFallo();
    } else if (activo==3 && verdaderoFalso.terminado()) registrarFallo();
    else if (activo==4 && conceptos.estaTerminado()) registrarFallo();
    else if (activo==5 && ordenarPasos.estaTerminado()) registrarFallo();
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
    guardado.guardar();
    return true;
  }

  void reintentar() {
    if (resultado!=2 || derrota.length()>0) return;
    if (!tareaActual().bloqueo().isEmpty()) return;
    String textoAnterior=activo==1 ? vistaContrasena.textoIngresado : "";
    resultado=0;
    crearIntento();
    if (activo==1) vistaContrasena.textoIngresado=textoAnterior;
  }

  void solicitarSalida() {
    if (mostrandoContexto) { volver(); return; }
    if (activo==0 || derrota.length()>0) return;
    if (resultado!=0) {
      volver();
      return;
    }
    mostrarPista=false;
    if (!confirmarSalida) inicioModal=millis();
    confirmarSalida=true;
    if (activo==3) vistaVerdaderoFalso.arrastrando=false;
    if (activo==4) conceptos.cancelarSeleccion();
    if (activo==5) vistaOrdenarPasos.cancelarArrastre();
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
    mostrandoContexto=false;
    activo=0;
    resultado=0;
    confirmarSalida=false;
    mostrarPista=false;
    escritorio.abrirInterfaz();
    jugador.detenerMovimiento();
  }

  void mostrarPlazoVencido(Tarea tarea) {
    String motivo=tarea.bloqueoPorTiempo();
    if (motivo.isEmpty()) return;
    derrota=tarea.nombre + "\n" + motivo;
    jugador.detenerMovimiento();
  }

  void mostrar() {
    if (derrota.length()>0) {
      mostrarDerrota();
      return;
    }
    if (activo==0) return;
    if (mostrandoContexto) { mostrarContextoTarea(activo); return; }
    if (!modalAbierto()) {
      if (activo==1) vistaContrasena.mostrar();
      else if (activo==2) vistaMemoria.mostrar();
      else if (activo==3) vistaVerdaderoFalso.mostrar();
      else if (activo==4) vistaConceptos.mostrar();
      else if (activo==5) vistaOrdenarPasos.mostrar();
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
      String bloqueo=resultado==2 ? tarea.bloqueo() : "";
      String mensaje=resultado==1 ? "Completaste " + tarea.nombre + ".\nEnergía: −" + tarea.energia +
        "   Estrés: +" + tarea.estres + "   Concentración: −" + tarea.concentracion + "\nHora actual: " + hud.obtenerHora() :
        "Este intento no superó el reto. Pasaron " + penalizacionFalloMinutos + " minutos.\nNo se descontó energía ni aumentó el estrés.\nHora actual: " + hud.obtenerHora();
      panelMensaje(resultado==1 ? "¡ACTIVIDAD COMPLETADA!" : "INTENTO NO SUPERADO", mensaje);
      if (resultado==1) {
        avisoResultado("Te quedan " + tarea.duracion() + " menos en el día.");
        botonPanel("VOLVER AL ESCRITORIO", 445, 480, 390);
      } else if (!bloqueo.isEmpty()) {
        avisoResultado(bloqueo);
        botonPanel("VOLVER AL ESCRITORIO", 445, 480, 390);
      } else {
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
    if (mostrandoContexto) {
      if (sobreCierreVentana(x,y)) volver();
      else if (sobreSeleccion(450,533,380,60)) {
        mostrandoContexto=false;
        crearIntento();
      }
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
      boolean puedeReintentar=resultado==2 && tareaActual().bloqueo().isEmpty();
      if (!puedeReintentar && dentroPanel(445, 480, 390)) volver();
      else if (puedeReintentar && dentroPanel(330, 480, 290)) reintentar();
      else if (puedeReintentar && dentroPanel(660, 480, 290)) volver();
      return;
    }
    if (activo==1) vistaContrasena.presionar(x, y);
    else if (activo==2) vistaMemoria.presionar(x, y, (long)millis());
    else if (activo==3) vistaVerdaderoFalso.presionar(x, y);
    else if (activo==4) vistaConceptos.presionar(x,y);
    else if (activo==5) vistaOrdenarPasos.presionar(x,y);
    sincronizar();
    boolean salir=activo==1 ? vistaContrasena.quiereSalir : activo==2 ? vistaMemoria.quiereSalir : activo==3 ? vistaVerdaderoFalso.quiereSalir :
      activo==4 ? vistaConceptos.quiereSalir : activo==5 && vistaOrdenarPasos.quiereSalir;
    if (salir) {
      if (activo==1) vistaContrasena.quiereSalir=false;
      else if (activo==2) vistaMemoria.quiereSalir=false;
      else if (activo==3) vistaVerdaderoFalso.quiereSalir=false;
      else if (activo==4) vistaConceptos.quiereSalir=false;
      else if (activo==5) vistaOrdenarPasos.quiereSalir=false;
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
  void avisoResultado(String mensaje) {
    pushStyle();
    fill(255,122,122);
    textAlign(CENTER,CENTER);
    textSize(21);
    text(mensaje,640,438);
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
    panelMensaje("NO COMPLETASTE EL DÍA", derrota + "\nPuedes reiniciar y probar otro orden de actividades.");
    botonPanel("REINICIAR EL DÍA", 440, 480, 400);
  }
  void clickDerrota() {
    if (dentroPanel(440, 480, 400)) {
      reiniciarDia();
      guardado.guardar();
    }
  }
}

void reiniciarDia() {
  finalDelDia.reiniciar();
  escenarios.reiniciar();
  avisosPlazo=new AvisosPlazo();
  encargoBiblioteca=new EncargoBiblioteca();
  hud=new HUD();
  escritorio=new Escritorio();
  cama=new Cama();
  celular=new Celular();
  gestorMinijuegos=new GestorMinijuegos();
  jugador.reiniciarPosicion();
  instrucciones.cerrar();
  introduccionDomingo.abierta=true;
}
