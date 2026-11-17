
class Memoria extends Minijuego {

  static final long DEMORA_INICIAL = 700L;
  static final long MEMORIZACION = 4000L;
  static final long LIMITE = 50000L;
  static final long MOSTRAR_ERROR = 900L;
  static final long PAUSA_DERROTA = 2200L;
  static final long DURACION_MENSAJE = 4500L;

  final int[] cartas = new int[12];
  final boolean[] acertadas = new boolean[12];
  final java.util.Random azar;

  EstadoMemoria estadoActual;

  int primera = -1;
  int segunda = -1;
  int paresResueltos = 0;
  int ronda = 0;
  int segundosVictoria = 0;

  int ultimoParEncontrado = -1;
  boolean mensajeActivo = false;
  long inicioMensaje = 0L;
  long tiempoPausadoAcumulado = 0L;

  long inicioEstado = 0L;
  long inicioJuego = 0L;
  long inicioError = 0L;

  Memoria(long ahora) {
    this(ahora, new java.util.Random());
  }

  Memoria(long ahora, java.util.Random azar) {
    super();
    this.azar = azar;
    iniciar(ahora);
  }

  @Override
  void iniciar(long ahora) {
    activo = true;
    terminado = false;
    victoria = false;
    iniciarRonda(ahora);
  }

  @Override
  void actualizar(long ahora) {

    if (!activo || estadoActual == null) return;

    // Mientras aparece el mensaje, el juego queda pausado.
    if (mensajeActivo) {

      if (ahora - inicioMensaje >= DURACION_MENSAJE) {

        tiempoPausadoAcumulado += DURACION_MENSAJE;
        mensajeActivo = false;

        // La victoria se confirma DESPUÉS del último mensaje.
        if (paresResueltos == 6) {
          segundosVictoria = segundosRestantes(ahora);
          cambiarEstado(new EstadoVictoria(), ahora);
          finalizar(true);
        }

      } else {
        return;
      }
    }

    if (activo && estadoActual != null) {
      estadoActual.actualizar(this, ahora);
    }
  }

  @Override
  void reiniciar(long ahora) {
    iniciar(ahora);
  }

  void cambiarEstado(EstadoMemoria nuevoEstado, long ahora) {
    estadoActual = nuevoEstado;
    inicioEstado = ahora;
  }

  void iniciarRonda(long ahora) {

    int[] anterior = java.util.Arrays.copyOf(cartas, cartas.length);
    boolean hayAnterior = ronda > 0;

    for (int i = 0; i < cartas.length; i++) {
      cartas[i] = i / 2;
    }

    int intentos = 0;

    do {
      for (int i = cartas.length - 1; i > 0; i--) {
        int j = azar.nextInt(i + 1);
        int aux = cartas[i];
        cartas[i] = cartas[j];
        cartas[j] = aux;
      }

      intentos++;

    } while (
      hayAnterior &&
      java.util.Arrays.equals(anterior, cartas) &&
      intentos < 100
    );

    if (hayAnterior && java.util.Arrays.equals(anterior, cartas)) {
      int primero = cartas[0];

      for (int i = 0; i < 11; i++) {
        cartas[i] = cartas[i + 1];
      }

      cartas[11] = primero;
    }

    java.util.Arrays.fill(acertadas, false);

    primera = -1;
    segunda = -1;
    paresResueltos = 0;
    segundosVictoria = 0;

    ultimoParEncontrado = -1;
    mensajeActivo = false;
    inicioMensaje = 0L;
    tiempoPausadoAcumulado = 0L;

    inicioError = 0L;
    inicioJuego = 0L;

    activo = true;
    terminado = false;
    victoria = false;

    cambiarEstado(new EstadoTapadas(), ahora);

    ronda++;
  }

  boolean elegir(int indice, long ahora) {

    actualizar(ahora);

    if (!activo || estadoActual == null || mensajeActivo) {
      return false;
    }

    return estadoActual.elegir(this, indice, ahora);
  }

  boolean seleccionValida(int indice) {
    return indice >= 0 &&
      indice < cartas.length &&
      !acertadas[indice] &&
      segunda == -1 &&
      indice != primera;
  }

  void comprobarPareja(long ahora) {

    if (cartas[primera] == cartas[segunda]) {

      int idEncontrado = cartas[primera];

      acertadas[primera] = true;
      acertadas[segunda] = true;

      paresResueltos++;

      primera = -1;
      segunda = -1;

      // Guardar el hábito que corresponde a la pareja.
      ultimoParEncontrado = idEncontrado;
      mensajeActivo = true;
      inicioMensaje = ahora;

    } else {

      inicioError = ahora;
      cambiarEstado(new EstadoError(), ahora);
    }
  }

  boolean visible(int indice) {

    if (indice < 0 || indice >= cartas.length) {
      return false;
    }

    return estadoActual instanceof EstadoMemorizar ||
      estadoActual instanceof EstadoVictoria ||
      acertadas[indice] ||
      indice == primera ||
      indice == segunda;
  }

  boolean hayMensajeActivo() {
    return mensajeActivo;
  }

  int obtenerIdMensaje() {
    return ultimoParEncontrado;
  }

  int segundosRestantes(long ahora) {

    if (estadoActual instanceof EstadoVictoria) {
      return segundosVictoria;
    }

    if (estadoActual instanceof EstadoDerrota) {
      return 0;
    }

    if (!(estadoActual instanceof EstadoJugando)) {
      return 50;
    }

    long tiempoJugado =
      ahora - inicioJuego - tiempoPausadoAcumulado;

    if (mensajeActivo) {
      tiempoJugado -= ahora - inicioMensaje;
    }

    long restantes = LIMITE - tiempoJugado;

    return (int)Math.max(
      0L,
      (restantes + 999L) / 1000L
    );
  }

  boolean completada() {
    return estadoActual instanceof EstadoVictoria &&
      paresResueltos == 6 &&
      !mensajeActivo;
  }

  boolean estaEnDerrota() {
    return estadoActual instanceof EstadoDerrota;
  }

  boolean estaTapadas() {
    return estadoActual instanceof EstadoTapadas;
  }

  boolean estaMemorizando() {
    return estadoActual instanceof EstadoMemorizar;
  }

  boolean estaJugando() {
    return estadoActual instanceof EstadoJugando &&
      !mensajeActivo;
  }

  boolean estaEnVictoria() {
    return estadoActual instanceof EstadoVictoria;
  }
}


// =============================================
// INTERFAZ DE LOS ESTADOS
// =============================================

interface EstadoMemoria {
  void actualizar(Memoria memoria, long ahora);
  boolean elegir(Memoria memoria, int indice, long ahora);
}


// =============================================
// ESTADO: CARTAS TAPADAS
// =============================================

class EstadoTapadas implements EstadoMemoria {

  public void actualizar(Memoria memoria, long ahora) {
    if (ahora - memoria.inicioEstado >= Memoria.DEMORA_INICIAL) {
      memoria.cambiarEstado(new EstadoMemorizar(), ahora);
    }
  }

  public boolean elegir(Memoria memoria, int indice, long ahora) {
    return false;
  }
}


// =============================================
// ESTADO: MEMORIZAR
// =============================================

class EstadoMemorizar implements EstadoMemoria {

  public void actualizar(Memoria memoria, long ahora) {
    if (ahora - memoria.inicioEstado >= Memoria.MEMORIZACION) {
      memoria.inicioJuego = ahora;
      memoria.cambiarEstado(new EstadoJugando(), ahora);
    }
  }

  public boolean elegir(Memoria memoria, int indice, long ahora) {
    return false;
  }
}


// =============================================
// ESTADO: JUGANDO
// =============================================

class EstadoJugando implements EstadoMemoria {

  public void actualizar(Memoria memoria, long ahora) {
    if (ahora - memoria.inicioJuego -
        memoria.tiempoPausadoAcumulado >= Memoria.LIMITE) {
      memoria.cambiarEstado(new EstadoDerrota(), ahora);
    }
  }

  public boolean elegir(Memoria memoria, int indice, long ahora) {

    if (!memoria.seleccionValida(indice)) {
      return false;
    }

    if (memoria.primera == -1) {
      memoria.primera = indice;
      return true;
    }

    memoria.segunda = indice;
    memoria.comprobarPareja(ahora);

    return true;
  }
}


// =============================================
// ESTADO: ERROR
// =============================================

class EstadoError implements EstadoMemoria {

  public void actualizar(Memoria memoria, long ahora) {
    if (ahora - memoria.inicioError >= Memoria.MOSTRAR_ERROR) {
      memoria.primera = -1;
      memoria.segunda = -1;
      memoria.cambiarEstado(new EstadoJugando(), ahora);
    }
  }

  public boolean elegir(Memoria memoria, int indice, long ahora) {
    return false;
  }
}


// =============================================
// ESTADO: DERROTA
// =============================================

class EstadoDerrota implements EstadoMemoria {

  public void actualizar(Memoria memoria, long ahora) {
    if (ahora - memoria.inicioEstado >= Memoria.PAUSA_DERROTA) {
      memoria.iniciarRonda(ahora);
    }
  }

  public boolean elegir(Memoria memoria, int indice, long ahora) {
    return false;
  }
}


// =============================================
// ESTADO: VICTORIA
// =============================================

class EstadoVictoria implements EstadoMemoria {

  public void actualizar(Memoria memoria, long ahora) {
  }

  public boolean elegir(Memoria memoria, int indice, long ahora) {
    return false;
  }
}
