class VerdaderoFalso {

  String[] preguntas = {
    "Pasar muchas horas en el celular puede quitarte tiempo\npara estudiar y descansar.",

    "Puedes silenciar las notificaciones para concentrarte\nmejor en una tarea.",

    "Los videojuegos y las redes sociales pueden formar parte\ndel entretenimiento si se usan con equilibrio.",

    "Debes responder todos los mensajes inmediatamente,\naunque estés estudiando.",

    "Usar el celular hasta muy tarde nunca afecta el descanso.",

    "Descansar es una pérdida de tiempo cuando tienes muchas\ntareas pendientes."
  };


  boolean[] respuestas = {
    true,
    true,
    true,
    false,
    false,
    false
  };


  String[] explicaciones = {
    "El tiempo dedicado a las redes puede reducir el disponible\npara otras actividades.",

    "Reducir las interrupciones puede facilitar la concentración.",

    "La idea no es eliminarlos, sino equilibrarlos con otras\nresponsabilidades.",

    "Puedes responder después de terminar una actividad importante.",

    "El uso nocturno puede dificultar dormir bien y retrasar\nla hora de acostarse.",

    "El descanso también es necesario para el bienestar y\nel rendimiento."
  };


  int[] orden = {0, 1, 2, 3, 4, 5};

  int preguntaActual = 0;
  int aciertos = 0;

  boolean activa = false;
  boolean respondida = false;
  boolean respuestaCorrecta = false;
  boolean terminado = false;
  boolean aprobado = false;


  // ================= INICIAR =================

  void iniciar() {

    activa = true;

    preguntaActual = 0;
    aciertos = 0;

    respondida = false;
    terminado = false;
    aprobado = false;

    mezclarPreguntas();
  }


  // ================= ALEATORIEDAD =================

  void mezclarPreguntas() {

    // Reiniciar orden
    for (int i = 0; i < orden.length; i++) {
      orden[i] = i;
    }


    // Mezclar
    for (int i = orden.length - 1; i > 0; i--) {

      int posicionAleatoria =
        int(random(i + 1));

      int temporal = orden[i];

      orden[i] = orden[posicionAleatoria];

      orden[posicionAleatoria] = temporal;
    }
  }


  // ================= MOSTRAR =================

  void mostrar() {

    if (!activa) {
      return;
    }


    pushStyle();


    // Oscurecer fondo
    fill(0, 170);
    noStroke();

    rect(0, 0, width, height);


    // ================= PANEL =================

    float panelX = 190;
    float panelY = 90;

    float panelW = 900;
    float panelH = 540;


    fill(25, 27, 35, 250);
    stroke(255);
    strokeWeight(2);

    rect(
      panelX,
      panelY,
      panelW,
      panelH,
      18
    );


    // ================= TÍTULO =================

    fill(255);
    textAlign(LEFT, CENTER);
    textSize(30);

    text(
      "TAREA 1 - VERDADERO O FALSO",
      panelX + 40,
      panelY + 45
    );


    // ================= X =================

    dibujarCerrar();


    // ================= RESULTADO FINAL =================

    if (terminado) {

      mostrarResultadoFinal();

      popStyle();

      return;
    }


    // ================= PREGUNTA =================

    int indice =
      orden[preguntaActual];


    fill(180);
    textAlign(CENTER, CENTER);
    textSize(17);

    text(
      "PREGUNTA " +
      (preguntaActual + 1) +
      " / 6",
      width/2,
      185
    );


    fill(255);
    textSize(23);

    text(
      preguntas[indice],
      width/2,
      265
    );


    // ================= SIN RESPONDER =================

    if (!respondida) {

      botonRespuesta(
        "VERDADERO",
        330,
        370,
        true
      );

      botonRespuesta(
        "FALSO",
        680,
        370,
        false
      );
    }


    // ================= RESPONDIDA =================

    else {

      if (respuestaCorrecta) {

        fill(255);
        textSize(25);

        text(
          "¡CORRECTO!",
          width/2,
          370
        );
      }

      else {

        fill(255);
        textSize(25);

        text(
          "INCORRECTO",
          width/2,
          370
        );
      }


      // Explicación
      fill(190);
      textSize(17);

      text(
        explicaciones[indice],
        width/2,
        430
      );


      botonSiguiente();
    }


    // ================= ACIERTOS =================

    fill(170);
    textAlign(LEFT, CENTER);
    textSize(16);

    text(
      "Aciertos: " + aciertos,
      panelX + 40,
      panelY + panelH - 30
    );


    popStyle();
  }


  // ================= BOTONES RESPUESTA =================

  void botonRespuesta(
    String texto,
    float x,
    float y,
    boolean respuesta
  ) {

    float ancho = 270;
    float alto = 65;


    boolean encima =
      mouseX >= x &&
      mouseX <= x + ancho &&
      mouseY >= y &&
      mouseY <= y + alto;


    if (encima) {
      fill(255, 200);
    }

    else {
      fill(230);
    }


    stroke(255);
    strokeWeight(2);

    rect(
      x,
      y,
      ancho,
      alto,
      10
    );


    fill(20);
    textAlign(CENTER, CENTER);
    textSize(19);

    text(
      texto,
      x + ancho/2,
      y + alto/2
    );
  }


  // ================= RESPONDER =================

  void responder(boolean respuestaJugador) {

    if (respondida || terminado) {
      return;
    }


    int indice =
      orden[preguntaActual];


    respuestaCorrecta =
      respuestaJugador == respuestas[indice];


    if (respuestaCorrecta) {
      aciertos++;
    }


    respondida = true;
  }


  // ================= SIGUIENTE =================

  void siguientePregunta() {

    if (!respondida) {
      return;
    }


    preguntaActual++;


    if (preguntaActual >= 6) {

      terminado = true;

      aprobado = aciertos >= 5;

      return;
    }


    respondida = false;
  }


  void botonSiguiente() {

    float x = 490;
    float y = 500;

    float ancho = 300;
    float alto = 55;


    boolean encima =
      mouseX >= x &&
      mouseX <= x + ancho &&
      mouseY >= y &&
      mouseY <= y + alto;


    if (encima) {
      fill(255, 200);
    }

    else {
      fill(230);
    }


    stroke(255);

    rect(
      x,
      y,
      ancho,
      alto,
      8
    );


    fill(20);
    textAlign(CENTER, CENTER);
    textSize(18);

    text(
      "SIGUIENTE",
      x + ancho/2,
      y + alto/2
    );
  }


  // ================= RESULTADO =================

  void mostrarResultadoFinal() {

    fill(255);
    textAlign(CENTER, CENTER);


    if (aprobado) {

      textSize(30);

      text(
        "¡TAREA COMPLETADA!",
        width/2,
        270
      );


      textSize(21);

      text(
        "Resultado: " +
        aciertos +
        " / 6",
        width/2,
        325
      );


      botonFinal(
        "CONTINUAR"
      );
    }

    else {

      textSize(30);

      text(
        "INTÉNTALO DE NUEVO",
        width/2,
        270
      );


      textSize(21);

      text(
        "Resultado: " +
        aciertos +
        " / 6",
        width/2,
        325
      );


      fill(180);
      textSize(16);

      text(
        "Necesitas al menos 5 respuestas correctas.",
        width/2,
        365
      );


      botonFinal(
        "REINTENTAR"
      );
    }
  }


  void botonFinal(String texto) {

    float x = 490;
    float y = 430;

    float ancho = 300;
    float alto = 60;


    boolean encima =
      mouseX >= x &&
      mouseX <= x + ancho &&
      mouseY >= y &&
      mouseY <= y + alto;


    if (encima) {
      fill(255, 200);
    }

    else {
      fill(230);
    }


    stroke(255);

    rect(
      x,
      y,
      ancho,
      alto,
      8
    );


    fill(20);
    textAlign(CENTER, CENTER);
    textSize(18);

    text(
      texto,
      x + ancho/2,
      y + alto/2
    );
  }


  // ================= CERRAR =================

  void dibujarCerrar() {

    fill(255, 30);
    noStroke();

    rect(
      1020,
      110,
      40,
      40,
      8
    );


    fill(255);
    textAlign(CENTER, CENTER);
    textSize(23);

    text(
      "X",
      1040,
      128
    );
  }


  boolean clicCerrar() {

    return mouseX >= 1020 &&
           mouseX <= 1060 &&
           mouseY >= 110 &&
           mouseY <= 150;
  }
}
