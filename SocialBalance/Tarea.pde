class Tarea {
  int id;
  String nombre;
  String descripcion;
  int minutosNecesarios;
  int energia;
  int estres;
  // No se acordó un costo de concentración para las tareas. Se mantiene en cero.
  int concentracion = 0;
  int limite;
  boolean completada = false;

  Tarea(int id, String nombre, String descripcion, int minutosNecesarios, int energia, int estres, int limite) {
    this.id=id; this.nombre=nombre; this.descripcion=descripcion;
    this.minutosNecesarios=minutosNecesarios; this.energia=energia; this.estres=estres; this.limite=limite;
  }
  String duracion() {
    return (minutosNecesarios/60) + " h" + (minutosNecesarios%60==0 ? "" : " " + minutosNecesarios%60 + " min");
  }
  String horaLimite() {
    int h=limite/60;
    return (h>12 ? h-12 : h) + ":" + nf(limite%60,2) + (h>=12 ? " PM" : " AM");
  }
  String bloqueo() {
    if (completada) return "Actividad completada";
    if (!hud.puedeAvanzarTiempo(minutosNecesarios) || hud.minutosDelDia()+minutosNecesarios>limite)
      return "Ya no puedes terminar dentro de su plazo.";
    if (!hud.puedeAvanzarTiempo(penalizacionFalloMinutos)) return "No queda tiempo para asumir un intento fallido.";
    if (hud.energia<energia) return "Necesitas " + energia + " de energía. Descansa en la cama.";
    if (hud.estres>75) return "Reduce el estrés a 75 o menos usando el celular.";
    if (hud.concentracion<20) return "Necesitas al menos 20 de concentración.";
    return "";
  }
}