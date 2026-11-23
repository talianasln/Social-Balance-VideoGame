// Recibe palabras y dígitos cuyo formato ya validó el contexto.
interface EstrategiaContrasena {
  boolean validar(String[] palabras, int[] vocales, int[] primerosDigitos, int[] segundosDigitos);
  String nombreReto();
  String reglaPalabras();
  String reglaDigitos();
}

class EstrategiaVocalesIguales implements EstrategiaContrasena {
  public boolean validar(String[] palabras, int[] vocales, int[] primerosDigitos, int[] segundosDigitos) {
    char inicial = Character.toLowerCase(palabras[0].charAt(0));
    return Character.toLowerCase(palabras[1].charAt(0)) == inicial &&
           Character.toLowerCase(palabras[2].charAt(0)) == inicial &&
           vocales[0] == vocales[1] && vocales[1] == vocales[2] && vocales[0] > 0 &&
           (primerosDigitos[0] * segundosDigitos[0]) % 2 == 1 &&
           (primerosDigitos[1] * segundosDigitos[1]) % 2 == 1;
  }

  public String nombreReto() { return "RETO 1 - VOCALES IGUALES"; }
  public String reglaPalabras() {
    return "Las tres palabras deben empezar con la misma letra y tener la misma cantidad de vocales.";
  }
  public String reglaDigitos() {
    return "Al multiplicar los dos dígitos de cada pareja, el resultado debe ser impar.";
  }
}

class EstrategiaVocalesEscalera implements EstrategiaContrasena {
  public boolean validar(String[] palabras, int[] vocales, int[] primerosDigitos, int[] segundosDigitos) {
    return vocales[0] == 2 && vocales[1] == 3 && vocales[2] == 4 &&
           primerosDigitos[0] + segundosDigitos[0] == 9 &&
           primerosDigitos[1] + segundosDigitos[1] == 9;
  }

  public String nombreReto() { return "RETO 2 - VOCALES EN ESCALERA"; }
  public String reglaPalabras() {
    return "La primera palabra debe tener 2 vocales, la segunda 3 y la tercera 4.";
  }
  public String reglaDigitos() { return "Los dos dígitos de cada pareja deben sumar 9."; }
}

class EstrategiaPatronInverso implements EstrategiaContrasena {
  public boolean validar(String[] palabras, int[] vocales, int[] primerosDigitos, int[] segundosDigitos) {
    char ultima = ultimaLetra(palabras[0]);
    return ultimaLetra(palabras[1]) == ultima && ultimaLetra(palabras[2]) == ultima &&
           vocales[0] == 3 && vocales[1] == 2 && vocales[2] == 3 &&
           primerosDigitos[0] * segundosDigitos[0] == 12 &&
           primerosDigitos[1] * segundosDigitos[1] == 12;
  }

  private char ultimaLetra(String palabra) {
    return Character.toLowerCase(palabra.charAt(palabra.length() - 1));
  }

  public String nombreReto() { return "RETO 3 - PATRON INVERSO"; }
  public String reglaPalabras() {
    return "La primera y la tercera palabra deben tener 3 vocales cada una; la segunda, 2. Las tres terminan con la misma letra.";
  }
  public String reglaDigitos() {
    return "Al multiplicar los dos dígitos de cada pareja, el resultado debe ser 12.";
  }
}
