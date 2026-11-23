// SocialBalance - Crear contraseña segura
// MOLDE DE LOGICA: independiente del escenario y de los botones finales.
// No usa listas ni colecciones de Java. Las 3 palabras se guardan
// temporalmente en un arreglo fijo para verificar el patrón.
// IMPORTANTE: son retos de lógica; NO equivalen a seguridad real de contraseñas.
class CrearContrasenaSegura {

  private final EstrategiaContrasena[] estrategias = {
    new EstrategiaVocalesIguales(),
    new EstrategiaVocalesEscalera(),
    new EstrategiaPatronInverso()
  };
  private EstrategiaContrasena estrategia;
  private boolean completado;
  private int intentos;
  private String mensaje;
  private boolean exitoUltimoIntento;

  CrearContrasenaSegura(int varianteInicial) {
    iniciarNuevaPartida(varianteInicial);
  }

  // Llamar UNA SOLA VEZ cuando el jugador pulse NUEVA PARTIDA.
  void iniciarNuevaPartida(int nuevaVariante) {
    if (nuevaVariante < 0 || nuevaVariante >= estrategias.length) {
      nuevaVariante = 0;
    }
    estrategia = estrategias[nuevaVariante];
    completado = false;
    intentos = 0;
    mensaje = "Escribe una contraseña ficticia que siga las reglas.";
    exitoUltimoIntento = false;
  }

  boolean estaCompletado() { return completado; }
  int obtenerIntentos() { return intentos; }
  String obtenerMensaje() { return mensaje; }
  boolean ultimoIntentoFueCorrecto() { return exitoUltimoIntento; }

  String obtenerNombreReto() { return estrategia.nombreReto(); }

  // Cada línea se dibuja por separado en la interfaz provisional.
  String obtenerRegla(int indice) {
    if (indice == 0) return "Usa tres palabras distintas, sin espacios. Cada una debe tener al menos una vocal y una consonante.";
    if (indice == 1) return estrategia.reglaPalabras();
    if (indice == 2) return "Separa las palabras con parejas de dígitos, sin poner números al principio ni al final.";
    return estrategia.reglaDigitos();
  }

  // El jugador puede reintentar hasta acertar; tras aprobar, no se repite.
  boolean comprobar(String entrada) {
    if (completado) {
      mensaje = "Este desafío ya fue completado en esta partida.";
      // El desafío sigue completado, pero un nuevo intento no se acepta.
      // No incrementamos intentos ni modificamos el éxito ya registrado.
      return false;
    }
    intentos++;
    boolean valido = validarPatron(entrada);
    exitoUltimoIntento = valido;
    if (valido) {
      completado = true;
      mensaje = "Tu contraseña cumple el reto. ¡Cambio de contraseña simulado!";
    } else {
      mensaje = "La contraseña no cumple las condiciones solicitadas. Inténtalo otra vez.";
    }
    return valido;
  }

  // Sólo evalúa el patrón del reto. No verifica si una palabra existe
  // en el diccionario. Acepta letras españolas, incluidas tildes y ñ.
  boolean validarPatron(String entrada) {
    if (entrada == null) return false;

    // La interfaz de prueba permite 60 caracteres; la clase debe imponer
    // el mismo límite, incluso si es invocada desde otro componente.
    entrada = java.text.Normalizer.normalize(
      entrada, java.text.Normalizer.Form.NFC
    );
    if (entrada.length() < 10 || entrada.length() > 60) return false;

    String[] palabras = new String[3];
    int[] primerosDigitos = new int[2];
    int[] segundosDigitos = new int[2];
    int pos = 0;

    for (int i = 0; i < 3; i++) {
      int inicio = pos;
      while (pos < entrada.length() && esLetraEspanola(entrada.charAt(pos))) {
        pos++;
      }
      if (pos == inicio) return false; // Debe haber una palabra no vacía
      palabras[i] = entrada.substring(inicio, pos);

      if (i < 2) {
        // Exactamente dos dígitos (0..9) antes de la siguiente palabra.
        if (pos + 1 >= entrada.length()) return false;
        char c1 = entrada.charAt(pos);
        char c2 = entrada.charAt(pos + 1);
        if (!esDigito(c1) || !esDigito(c2)) return false;
        primerosDigitos[i] = c1 - '0';
        segundosDigitos[i] = c2 - '0';
        pos += 2;
      }
    }
    if (pos != entrada.length()) return false; // Nada sobrante

    // Antitrampas: cada segmento debe parecer una palabra y no una
    // secuencia de vocales. Ninguna palabra puede repetirse (ignorando
    // mayúsculas/minúsculas), ni ser un único carácter.
    if (!esPalabraEstructuralmenteValida(palabras[0]) ||
        !esPalabraEstructuralmenteValida(palabras[1]) ||
        !esPalabraEstructuralmenteValida(palabras[2])) return false;
    if (palabras[0].equalsIgnoreCase(palabras[1]) ||
        palabras[0].equalsIgnoreCase(palabras[2]) ||
        palabras[1].equalsIgnoreCase(palabras[2])) return false;

    int[] vocales = {contarVocales(palabras[0]), contarVocales(palabras[1]), contarVocales(palabras[2])};
    return estrategia.validar(palabras, vocales, primerosDigitos, segundosDigitos);
  }

  // Esto NO comprueba si una palabra existe en el diccionario.
  // Sólo descarta cadenas demasiado cortas o compuestas de puras vocales.
  private boolean esPalabraEstructuralmenteValida(String palabra) {
    if (palabra.length() < 2) return false;
    boolean tieneVocal = false;
    boolean tieneConsonante = false;
    for (int i = 0; i < palabra.length(); i++) {
      char c = palabra.charAt(i);
      if (!esLetraEspanola(c)) return false;
      if (esVocal(c)) tieneVocal = true;
      else tieneConsonante = true;
    }
    return tieneVocal && tieneConsonante;
  }

  private boolean esDigito(char c) {
    return c >= '0' && c <= '9';
  }

  private boolean esLetraEspanola(char c) {
    char x = Character.toLowerCase(c);
    return (x >= 'a' && x <= 'z') || x == 'ñ' ||
           x == 'á' || x == 'é' || x == 'í' || x == 'ó' ||
           x == 'ú' || x == 'ü';
  }

  private boolean esVocal(char c) {
    char x = Character.toLowerCase(c);
    return x == 'a' || x == 'e' || x == 'i' || x == 'o' || x == 'u' ||
           x == 'á' || x == 'é' || x == 'í' || x == 'ó' || x == 'ú' || x == 'ü';
  }

  private int contarVocales(String palabra) {
    int total = 0;
    for (int i = 0; i < palabra.length(); i++) {
      if (esVocal(palabra.charAt(i))) total++;
    }
    return total;
  }
}
