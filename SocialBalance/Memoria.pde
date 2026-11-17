// MOTOR INDEPENDIENTE - MEMORIA
// No depende de sprites, coordenadas, mouse ni de otras clases del videojuego.
// Las duraciones se expresan en milisegundos y las administra el reloj de Processing.

class Memoria {
  static final int TAPADAS = 0;
  static final int MEMORIZAR = 1;
  static final int JUGANDO = 2;
  static final int DERROTA = 3;
  static final int VICTORIA = 4;

  static final long DEMORA_INICIAL = 700L;
  static final long MEMORIZACION = 4000L;
  static final long LIMITE = 50000L;
  static final long MOSTRAR_ERROR = 900L;
  static final long PAUSA_DERROTA = 2200L;

  final int[] cartas = new int[12]; // Identificadores 0..5 (dos por cada uno)
  final boolean[] acertadas = new boolean[12];
  final java.util.Random azar;
  int estado;
  int primera = -1;
  int segunda = -1;
  int paresResueltos = 0;
  int ronda = 0;
  int segundosVictoria = 0;
  long inicioEstado = 0L;
  long inicioJuego = 0L;
  long inicioError = 0L;

  Memoria(long ahora) {
    this(ahora, new java.util.Random());
  }

  // Sobrecarga para pruebas automatizadas repetibles.
  Memoria(long ahora, java.util.Random azar) {
    this.azar = azar;
    iniciarRonda(ahora);
  }

  void iniciarRonda(long ahora) {
    int[] anterior = java.util.Arrays.copyOf(cartas, cartas.length);
    boolean hayAnterior = ronda > 0;
    for (int i = 0; i < 12; i++) cartas[i] = i / 2;

    // Fisher-Yates. Garantizamos que una nueva ronda no tenga el mismo orden.
    int intentos = 0;
    do {
      for (int i = cartas.length - 1; i > 0; i--) {
        int j = azar.nextInt(i + 1);
        int aux = cartas[i];
        cartas[i] = cartas[j];
        cartas[j] = aux;
      }
      intentos++;
    } while (hayAnterior && java.util.Arrays.equals(anterior, cartas) && intentos < 100);
    if (hayAnterior && java.util.Arrays.equals(anterior, cartas)) {
      int primero = cartas[0];
      for (int i = 0; i < 11; i++) cartas[i] = cartas[i + 1];
      cartas[11] = primero;
    }

    java.util.Arrays.fill(acertadas, false);
    primera = -1;
    segunda = -1;
    paresResueltos = 0;
    segundosVictoria = 0;
    inicioError = 0L;
    inicioJuego = 0L;
    inicioEstado = ahora;
    estado = TAPADAS;
    ronda++;
  }

  void actualizar(long ahora) {
    if (estado == TAPADAS && ahora - inicioEstado >= DEMORA_INICIAL) {
      estado = MEMORIZAR;
      inicioEstado = ahora;
    } else if (estado == MEMORIZAR && ahora - inicioEstado >= MEMORIZACION) {
      estado = JUGANDO;
      inicioJuego = ahora; // El reloj SOLO arranca al ocultar todas las cartas.
      inicioEstado = ahora;
    } else if (estado == JUGANDO) {
      if (segunda != -1 && cartas[primera] != cartas[segunda]
          && ahora - inicioError >= MOSTRAR_ERROR) {
        primera = -1;
        segunda = -1;
      }
    } else if (estado == DERROTA && ahora - inicioEstado >= PAUSA_DERROTA) {
      iniciarRonda(ahora);
    }
  }

  // Retorna true solo si el clic eligió una carta permitida.
  boolean elegir(int indice, long ahora) {
    actualizar(ahora);
    if (estado != JUGANDO || indice < 0 || indice >= 12 ||
        acertadas[indice] || segunda != -1 || indice == primera) {
      return false;
    }

    if (primera == -1) {
      primera = indice;
      return true;
    }

    segunda = indice;
    if (cartas[primera] == cartas[segunda]) {
      acertadas[primera] = true;
      acertadas[segunda] = true;
      paresResueltos++;
      primera = -1;
      segunda = -1;
      if (paresResueltos == 6) {
        segundosVictoria = segundosRestantes(ahora);
        estado = VICTORIA;
        inicioEstado = ahora;
      }
    } else {
      inicioError = ahora;
    }
    return true;
  }

  boolean visible(int indice) {
    if (indice < 0 || indice >= 12) return false;
    return estado == MEMORIZAR || estado == VICTORIA ||
           acertadas[indice] || indice == primera || indice == segunda;
  }

  int segundosRestantes(long ahora) {
    if (estado == VICTORIA) return segundosVictoria;
    if (estado == DERROTA) return 0;
    if (estado != JUGANDO) return 50;
    long restantes = LIMITE - (ahora - inicioJuego);
    return (int)Math.max(0L, (restantes + 999L) / 1000L);
  }

  boolean completada() {
    return estado == VICTORIA && paresResueltos == 6;
  }
}
