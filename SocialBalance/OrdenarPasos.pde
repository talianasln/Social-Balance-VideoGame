class OrdenarPasos extends Minijuego {
  static final int CANTIDAD_PASOS = 5;
  static final String[] TITULOS = {
    "Mensaje sospechoso", "Sesión de estudio", "Proteger una cuenta digital",
    "Hábitos de sueño", "Responder ante el ciberacoso"
  };
  static final String[][] PASOS = {
    {
      "Identificar señales sospechosas del mensaje.",
      "No abrir enlaces ni compartir información.",
      "Verificar el remitente por un canal oficial.",
      "Reportar o bloquear el mensaje sospechoso.",
      "Eliminar el mensaje."
    }, {
      "Definir qué necesitas estudiar.",
      "Preparar los materiales necesarios.",
      "Silenciar las notificaciones.",
      "Estudiar con pausas programadas.",
      "Revisar lo aprendido."
    }, {
      "Crear una contraseña larga y única.",
      "Guardar la contraseña de forma segura.",
      "Activar la verificación en dos pasos.",
      "Revisar los dispositivos con sesión iniciada.",
      "Cerrar las sesiones desconocidas."
    }, {
      "Establecer una hora fija para dormir.",
      "Programar el final del uso de pantallas.",
      "Silenciar notificaciones nocturnas.",
      "Preparar un ambiente tranquilo.",
      "Acostarse a la hora establecida."
    }, {
      "Reconocer el comportamiento de acoso.",
      "Evitar responder a las provocaciones.",
      "Guardar evidencias de lo ocurrido.",
      "Bloquear y reportar al acosador.",
      "Buscar apoyo de alguien de confianza."
    }
  };

  private final java.util.Random azar;
  private int situacion;
  private final int[] orden = {0, 1, 2, 3, 4};

  OrdenarPasos(java.util.Random azar) {
    this.azar = azar;
  }

  void iniciar(long ahora) {
    reiniciar(ahora);
  }

  void actualizar(long ahora) {
    // El intento no tiene temporizador.
  }

  void reiniciar(long ahora) {
    situacion = azar.nextInt(TITULOS.length);
    activo = true;
    terminado = false;
    victoria = false;
    do {
      for (int i=orden.length-1; i>0; i--) {
        int j = azar.nextInt(i+1);
        int paso = orden[i];
        orden[i] = orden[j];
        orden[j] = paso;
      }
    } while (ordenCorrecto());
  }

  String tituloSituacion() {
    return TITULOS[situacion];
  }

  String pasoEn(int posicion) {
    return PASOS[situacion][orden[posicion]];
  }

  void mover(int origen, int destino) {
    if (!activo || origen==destino) return;
    int paso = orden[origen];
    if (origen<destino) {
      System.arraycopy(orden, origen+1, orden, origen, destino-origen);
    } else {
      System.arraycopy(orden, destino, orden, destino+1, origen-destino);
    }
    orden[destino] = paso;
  }

  void verificar() {
    if (activo) finalizar(ordenCorrecto());
  }

  private boolean ordenCorrecto() {
    for (int i=0; i<orden.length; i++) {
      if (orden[i]!=i) return false;
    }
    return true;
  }
}