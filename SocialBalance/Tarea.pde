class Tarea {
  int id;
  String nombre;
  String descripcion;
  int minutosNecesarios;
  int energia;
  int estres;
  int concentracion;
  int limite;
  private boolean completada;
  boolean estaCompletada() { return completada; }
  boolean marcarCompletada() {
    if (completada) return false;
    completada=true;
    return true;
  }
  boolean avisoPlazoEnviado;

  Tarea(int id, String nombre, String descripcion, int minutosNecesarios, int energia, int estres, int concentracion, int limite) {
    this.id=id; this.nombre=nombre; this.descripcion=descripcion;
    this.minutosNecesarios=minutosNecesarios; this.energia=energia; this.estres=estres; this.concentracion=concentracion; this.limite=limite;
  }
  String duracion() {
    return (minutosNecesarios/60) + " h" + (minutosNecesarios%60==0 ? "" : " " + minutosNecesarios%60 + " min");
  }
  String horaLimite() { return formatoHora(limite); }
  String ultimaHoraDeInicio() { return formatoHora(min(limite,FIN_DIA)-minutosNecesarios); }

  private String formatoHora(int horaEnMinutos) {
    int h=horaEnMinutos/60;
    return (h>12 ? h-12 : h) + ":" + nf(horaEnMinutos%60,2) + (h>=12 ? " PM" : " AM");
  }
  int minutosParaEmpezar() {
    return min(limite,FIN_DIA)-minutosNecesarios-hud.minutosDelDia();
  }

  String bloqueoPorTiempo() {
    int ahora=hud.minutosDelDia();
    if (ahora>=limite) return "La hora límite de esta actividad ya pasó.";
    if (minutosParaEmpezar()<0)
      return "No tienes suficiente tiempo para completar esta actividad.";
    return "";
  }

  String bloqueo() {
    if (completada) return "Actividad completada";
    String motivoTiempo=bloqueoPorTiempo();
    if (!motivoTiempo.isEmpty()) return motivoTiempo;
    if (!hud.puedeAvanzarTiempo(penalizacionFalloMinutos)) return "No queda tiempo para asumir un intento fallido.";
    if (hud.concentracion<MIN_CONCENTRACION_PARA_TAREA) return "No tienes suficiente concentración. Descansa en la cama hasta tener al menos " + MIN_CONCENTRACION_PARA_TAREA + ".";
    if (hud.energia<energia) return "Necesitas " + energia + " de energía. Descansa en la cama.";
    if (hud.estres>MAX_ESTRES_PARA_TAREA) return "Reduce el estrés a " + MAX_ESTRES_PARA_TAREA + " o menos usando el celular.";
    return "";
  }
}