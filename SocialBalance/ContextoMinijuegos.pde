void mostrarContextoTarea(int id) {
  String titulo, situacion, objetivo;
  if (id==2) {
    titulo="Repasa antes de clase";
    situacion="Mañana toca repasar los hábitos de bienestar digital en clase. Preparaste tarjetas de estudio, pero al guardarlas se mezclaron.";
    objetivo="Observa las tarjetas antes de que se tapen y luego encuentra las seis parejas.";
  } else if (id==3) {
    titulo="Antes de compartir";
    situacion="En el chat de tu curso circularon afirmaciones sobre redes sociales. Tu grupo quiere revisar cuáles son confiables antes de compartirlas en clase.";
    objetivo="Arrastra cada tarjeta hacia Falso o Verdadero según lo que afirme.";
  } else if (id==4) {
    titulo="Completa tu guía de repaso";
    situacion="Estás organizando los apuntes de la próxima clase. Al pasar tus notas a una guía, las definiciones quedaron separadas de sus conceptos.";
    objetivo="Une cada concepto con su definición arrastrando el hilo. Puedes deshacer antes de verificar.";
  } else {
    titulo="Pon en orden las instrucciones";
    situacion="Tu grupo va a llevar a clase una guía de hábitos y seguridad digital. Las instrucciones de una de las situaciones quedaron mezcladas.";
    objetivo="Arrastra las cinco tarjetas para ordenar los pasos y verifica la secuencia cuando esté lista.";
  }

  pushStyle();
  rectMode(CORNER);
  dibujarFondoMinijuego();
  dibujarCierreVentana();
  textAlign(LEFT,CENTER);
  textSize(23);
  fill(241,220,206);
  text("SOCIAL BALANCE  /  "+gestorMinijuegos.tareaActual().nombre,86,70);
  fill(65,39,45);
  textSize(30);
  text(titulo,93,149);
  textAlign(LEFT,TOP);
  textSize(21);
  textLeading(29);
  text(situacion,93,195,1080,115);
  fill(29,28,36);
  noStroke();
  rect(91,323,1095,131,11);
  fill(231,181,161);
  textSize(20);
  text("TU OBJETIVO",115,342);
  fill(233,217,207);
  textSize(19);
  text(objetivo,115,382,1020,54);
  fill(sobreSeleccion(450,533,380,60) ? color(165,108,96) : color(107,72,73));
  stroke(219,163,143);
  strokeWeight(2);
  rect(450,533,380,60,9);
  fill(255,239,230);
  textAlign(CENTER,CENTER);
  textSize(20);
  text("COMENZAR ACTIVIDAD",640,563);
  popStyle();
}
