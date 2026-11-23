void reproducirEfecto(String nombre) {
  java.io.File archivo=new java.io.File(dataPath(nombre));
  Thread hilo=new Thread(() -> {
    try (javax.sound.sampled.AudioInputStream audio=javax.sound.sampled.AudioSystem.getAudioInputStream(archivo)) {
      javax.sound.sampled.Clip clip=javax.sound.sampled.AudioSystem.getClip();
      try {
        clip.open(audio);
        clip.addLineListener(evento -> {
          if (evento.getType()==javax.sound.sampled.LineEvent.Type.STOP) clip.close();
        });
        clip.start();
      } catch (Exception fallo) { clip.close(); }
    } catch (Exception sinAudio) {
      // El juego continúa aunque no se pueda abrir la salida de audio.
    }
  },"Efecto de sonido");
  hilo.setDaemon(true);
  hilo.start();
}
