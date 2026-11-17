abstract class Minijuego {

  protected boolean activo;
  protected boolean terminado;
  protected boolean victoria;

  Minijuego() {
    activo = false;
    terminado = false;
    victoria = false;
  }

  abstract void iniciar(long ahora);

  abstract void actualizar(long ahora);

  abstract void reiniciar(long ahora);

  boolean estaTerminado() {
    return terminado;
  }

  boolean hayVictoria() {
    return victoria;
  }

  protected void finalizar(boolean gano) {
    terminado = true;
    victoria = gano;
    activo = false;
  }
}
