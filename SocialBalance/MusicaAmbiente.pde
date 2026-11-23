class PistaMusical {
  private javax.sound.sampled.Clip clip;
  private javax.sound.sampled.FloatControl ganancia;
  private boolean sonando;

  void cargar(String nombre) {
    java.io.File archivo=new java.io.File(dataPath(nombre));
    try (javax.sound.sampled.AudioInputStream audio=javax.sound.sampled.AudioSystem.getAudioInputStream(archivo)) {
      clip=javax.sound.sampled.AudioSystem.getClip();
      clip.open(audio);
      if (clip.isControlSupported(javax.sound.sampled.FloatControl.Type.MASTER_GAIN))
        ganancia=(javax.sound.sampled.FloatControl)clip.getControl(javax.sound.sampled.FloatControl.Type.MASTER_GAIN);
    } catch (Exception error) {
      if (clip!=null) clip.close();
      clip=null;
      println("No se pudo reproducir "+nombre+": "+error.getMessage());
    }
  }

  void ajustar(float volumen) {
    if (clip==null) return;
    if (volumen<=0) {
      if (sonando) {
        clip.stop();
        clip.setFramePosition(0);
        sonando=false;
      }
      return;
    }
    if (ganancia!=null) {
      float decibeles=20*log(volumen)/log(10);
      ganancia.setValue(constrain(decibeles,ganancia.getMinimum(),ganancia.getMaximum()));
    }
    if (!sonando) {
      clip.loop(javax.sound.sampled.Clip.LOOP_CONTINUOUSLY);
      sonando=true;
    }
  }
}

class MusicaAmbiente {
  private final PistaMusical menu=new PistaMusical();
  private final PistaMusical partida=new PistaMusical();
  private boolean victoria;

  void cargar() {
    menu.cargar("AmbienteMenu.wav");
    partida.cargar("AmbienteDomingo.wav");
  }

  void actualizar(int ahora) {
    if (entradaPartida.activa) {
      int t=entradaPartida.transcurrido(ahora);
      float salida=1-entradaPartida.progreso(t,0,entradaPartida.FIN_SALIDA);
      float entrada=entradaPartida.progreso(t,entradaPartida.INICIO_ENTRADA,entradaPartida.DURACION);
      if (entradaPartida.destino==2) {
        menu.ajustar(salida*configuracionAudio.factorMenu());
        partida.ajustar(entrada*configuracionAudio.factorPartida());
      } else if (entradaPartida.origen==2) {
        partida.ajustar(victoria ? 0 : salida*configuracionAudio.factorPartida());
        menu.ajustar(entrada*configuracionAudio.factorMenu());
      }
      return;
    }
    if (pantalla==2) {
      menu.ajustar(0);
      partida.ajustar(victoria ? 0 : configuracionAudio.factorPartida());
    } else {
      victoria=false;
      partida.ajustar(0);
      float volumen=presentacionInicial.activa ?
        entradaPartida.progreso(ahora-presentacionInicial.inicio,presentacionInicial.ENTRA_MENU,
          presentacionInicial.ENTRA_MENU+presentacionInicial.FUNDIDO_MENU) : 1;
      menu.ajustar(volumen*configuracionAudio.factorMenu());
    }
  }

  void detenerPorVictoria() {
    victoria=true;
    partida.ajustar(0);
  }
}

MusicaAmbiente musicaAmbiente=new MusicaAmbiente();
