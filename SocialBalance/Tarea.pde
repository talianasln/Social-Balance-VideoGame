class Tarea {

  String nombre;
  String duracion;
  int energia;
  int estres;
  String horaLimite;

  boolean bloqueada;
  boolean completada;


  Tarea(String nombre, String duracion, int energia,
        int estres, String horaLimite, boolean bloqueada) {

    this.nombre = nombre;
    this.duracion = duracion;
    this.energia = energia;
    this.estres = estres;
    this.horaLimite = horaLimite;

    this.bloqueada = bloqueada;
    this.completada = false;
  }
}
