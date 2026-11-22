// SOCIAL BALANCE - MOTOR PURO DEL MINIJUEGO VERDADERO/FALSO
// Adaptado para jugar sin derrota por tiempo y leer las explicaciones con calma.
// No depende de la interfaz, el raton, imagenes ni Processing.
class VerdaderoFalso {
  static final int INTRO = 0;
  static final int JUGANDO = 1;
  static final int EXPLICACION = 2;
  static final int VICTORIA = 3;
  static final int DERROTA_ERRORES = 4;
  static final int DERROTA_TIEMPO = 5;

  static final long LIMITE_MS = 90000L;
  static final long EXPLICACION_MS = 2600L;
  static final int META_ACIERTOS = 5;
  static final int MAX_ERRORES = 3;

  final String[] afirmaciones = {
    "Un perfil privado impide que sus seguidores compartan capturas de tus publicaciones.",
    "Un sitio con candado HTTPS cifra la conexión, pero eso no garantiza que sea confiable.",
    "Un mensaje que viene de la cuenta auténtica de un amigo podría ser una estafa.",
    "Si desactivas la ubicación, nadie puede deducir dónde estás por una foto que publiques.",
    "Incluso una aplicación descargada de una tienda oficial puede solicitar permisos innecesarios.",
    "Borrar una historia pocos minutos despues asegura que nadie conserve una copia.",
    "Activar la verificación en dos pasos agrega protección incluso con una clave larga."
  };
  final boolean[] respuestas = { false, true, true, false, true, false, true };
  final String[] explicaciones = {
    "Tus seguidores pueden capturar o reenviar el contenido que ven.",
    "El candado indica cifrado de conexión, no que el sitio sea legítimo.",
    "La cuenta de tu amigo podría haber sido robada o suplantada.",
    "El fondo y otros detalles pueden revelar dónde estás.",
    "Conviene revisar los permisos de cualquier aplicación.",
    "Alguien pudo guardar una captura antes de que la borraras.",
    "Un segundo factor dificulta el acceso con una clave robada."
  };

  final int[] orden = new int[7];
  final java.util.Random azar;
  int estado = INTRO;
  int posicion = 0;
  int aciertos = 0;
  int errores = 0;
  int ronda = 0;
  boolean ultimaCorrecta = false;
  long inicioReloj = -1;
  long inicioExplicacion = -1;

  VerdaderoFalso() { this(new java.util.Random()); }
  VerdaderoFalso(java.util.Random azar) {
    if (azar == null) throw new IllegalArgumentException("Se necesita un generador aleatorio.");
    this.azar = azar;
    reiniciar(0L);
  }

  void reiniciar(long ahora) {
    int[] anterior = java.util.Arrays.copyOf(orden, orden.length);
    boolean habiaRonda = ronda > 0;
    for (int i = 0; i < 7; i++) orden[i] = i;
    for (int i = orden.length - 1; i > 0; i--) {
      int j = azar.nextInt(i + 1);
      int auxiliar = orden[i];
      orden[i] = orden[j];
      orden[j] = auxiliar;
    }
    // Al reiniciar se conserva el banco, pero se garantiza un orden diferente.
    if (habiaRonda && java.util.Arrays.equals(anterior, orden)) {
      int temp = orden[0]; orden[0] = orden[1]; orden[1] = temp;
    }
    ronda++;
    estado = INTRO;
    posicion = aciertos = errores = 0;
    inicioReloj = inicioExplicacion = -1;
    ultimaCorrecta = false;
  }

  boolean comenzar(long ahora) {
    if (estado != INTRO) return false;
    estado = JUGANDO;
    inicioReloj = ahora;
    return true;
  }

  void actualizar(long ahora) {
    if (estado != JUGANDO && estado != EXPLICACION) return;
  }

  void siguiente() {
    if (estado != EXPLICACION) return;
    posicion++;
    if (posicion < afirmaciones.length) estado = JUGANDO;
  }

  boolean responder(boolean elegidoVerdadero, long ahora) {
    actualizar(ahora);
    // Antidoble clic: solo se puede responder una vez por afirmacion.
    if (estado != JUGANDO || posicion >= afirmaciones.length) return false;
    ultimaCorrecta = (elegidoVerdadero == respuestas[orden[posicion]]);
    if (ultimaCorrecta) aciertos++;
    else errores++;
    if (aciertos >= META_ACIERTOS) estado = VICTORIA;
    else if (errores >= MAX_ERRORES) estado = DERROTA_ERRORES;
    else {
      estado = EXPLICACION;
      inicioExplicacion = ahora;
    }
    return true;
  }

  int segundosRestantes(long ahora) {
    if (estado == INTRO) return 90;
    if (estado == DERROTA_TIEMPO) return 0;
    long restante = Math.max(0L, LIMITE_MS - (ahora - inicioReloj));
    return (int)((restante + 999L) / 1000L);
  }

  boolean completado() { return estado == VICTORIA; }
  boolean terminado() {
    return estado == VICTORIA || estado == DERROTA_ERRORES || estado == DERROTA_TIEMPO;
  }
  String afirmacionActual() { return afirmaciones[orden[posicion]]; }
  String explicacionActual() { return explicaciones[orden[posicion]]; }
  int preguntasContestadas() { return aciertos + errores; }
}
