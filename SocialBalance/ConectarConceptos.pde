// Motor sin dibujo, reloj ni cobros. GestorMinijuegos liquidará el resultado.
class ConectarConceptos extends Minijuego {
  final int PAREJAS = 5;
  private final String[] conceptos = {
    "Huella digital", "Ciberacoso", "Privacidad digital", "Tiempo de pantalla",
    "Contraseña segura", "Desinformación", "Bienestar digital", "Autenticación",
    "Sedentarismo", "Descanso digital"
  };
  private final String[] definiciones = {
    "Rastro de información que dejamos en internet.",
    "Acoso realizado mediante medios digitales.",
    "Control de nuestra información personal en internet.",
    "Tiempo que pasamos utilizando dispositivos digitales.",
    "Clave difícil de adivinar que protege nuestras cuentas.",
    "Información falsa o engañosa que se difunde.",
    "Uso saludable y equilibrado de la tecnología.",
    "Proceso para comprobar la identidad de un usuario.",
    "Hábito de permanecer mucho tiempo sin actividad física.",
    "Pausa voluntaria del uso de dispositivos electrónicos."
  };
  private final java.util.Random azar;
  private final PilaConexiones historial = new PilaConexiones();
  private final int[] idsConceptos = new int[PAREJAS];
  private final int[] idsDefiniciones = new int[PAREJAS];
  private final int[] destinos = new int[PAREJAS];
  private final boolean[] definicionOcupada = new boolean[PAREJAS];
  private int seleccionado = -1;

  ConectarConceptos() { this(new java.util.Random()); }

  // Permite reproducir un intento en pruebas sin cambiar el azar del juego.
  ConectarConceptos(java.util.Random azar) {
    if (azar == null) throw new IllegalArgumentException("Generador nulo");
    this.azar = azar;
    java.util.Arrays.fill(destinos, -1);
  }

  void iniciar(long ahora) { reiniciar(ahora); }

  void reiniciar(long ahora) {
    int[] banco = new int[conceptos.length];
    for (int i = 0; i < banco.length; i++) banco[i] = i;
    barajar(banco);
    for (int i = 0; i < PAREJAS; i++) {
      idsConceptos[i] = banco[i];
      idsDefiniciones[i] = banco[i];
    }
    barajar(idsDefiniciones);
    java.util.Arrays.fill(destinos, -1);
    java.util.Arrays.fill(definicionOcupada, false);
    historial.vaciar();
    seleccionado = -1;
    terminado = false;
    victoria = false;
    activo = true;
  }

  private void barajar(int[] valores) {
    for (int i = valores.length - 1; i > 0; i--) {
      int j = azar.nextInt(i + 1);
      int temporal = valores[i]; valores[i] = valores[j]; valores[j] = temporal;
    }
  }

  void actualizar(long ahora) {
    // No hay temporizador interno: el tiempo transcurrido no cambia el intento.
  }

  private boolean indiceValido(int indice) { return indice >= 0 && indice < PAREJAS; }

  boolean seleccionarConcepto(int indice) {
    if (!activo || !indiceValido(indice) || destinos[indice] != -1) return false;
    seleccionado = indice;
    return true;
  }

  boolean seleccionarDefinicion(int indice) {
    if (!activo || seleccionado == -1 || !indiceValido(indice) || definicionOcupada[indice]) return false;
    destinos[seleccionado] = indice;
    definicionOcupada[indice] = true;
    historial.apilar(new ConexionConceptos(seleccionado, indice));
    seleccionado = -1;
    return true;
  }

  boolean deshacer() {
    if (!activo || historial.estaVacia()) return false;
    ConexionConceptos ultima = historial.desapilar();
    destinos[ultima.concepto] = -1;
    definicionOcupada[ultima.definicion] = false;
    seleccionado = -1;
    return true;
  }

  boolean puedeVerificar() { return activo && historial.cantidad() == PAREJAS; }

  // true significa que se procesó la verificación; hayVictoria() indica el resultado.
  boolean verificar() {
    if (!puedeVerificar()) return false;
    boolean correcto = true;
    for (int i = 0; i < PAREJAS; i++) {
      if (idsConceptos[i] != idsDefiniciones[destinos[i]]) correcto = false;
    }
    finalizar(correcto);
    seleccionado = -1;
    return true;
  }

  int cantidadConexiones() { return historial.cantidad(); }
  int conceptoSeleccionado() { return seleccionado; }
  int definicionConectada(int concepto) { return destinos[concepto]; }
  boolean estaDefinicionOcupada(int definicion) { return definicionOcupada[definicion]; }
  String textoConcepto(int indice) { return conceptos[idsConceptos[indice]]; }
  String textoDefinicion(int indice) { return definiciones[idsDefiniciones[indice]]; }
}
