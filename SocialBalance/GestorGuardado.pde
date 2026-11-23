final GestorGuardado guardado=new GestorGuardado(
  java.nio.file.Paths.get(System.getProperty("user.home"),".socialbalance","partida.txt"));

class GestorGuardado {
  private final java.nio.file.Path archivo;
  private final String FORMATO="SOCIALBALANCE 2";
  String avisoMenu="";

  GestorGuardado(java.nio.file.Path archivo) { this.archivo=archivo; }

  void guardar() {
    if (pantalla!=2 || personajeSeleccionado<1) return;
    java.nio.file.Path temporal=null;
    try {
      java.nio.file.Files.createDirectories(archivo.getParent());
      temporal=java.nio.file.Files.createTempFile(archivo.getParent(),"partida-",".tmp");
      try (java.io.BufferedWriter salida=java.nio.file.Files.newBufferedWriter(temporal)) {
        linea(salida,FORMATO);
        linea(salida,"jugador "+personajeSeleccionado+" "+escenarios.actual+" "+jugador.direccion+
          " "+jugador.piesX()+" "+jugador.piesY());
        linea(salida,"hud "+hud.minutosDelDia()+" "+hud.energia+" "+hud.estres+" "+hud.concentracion+
          " "+hud.descansoAcumulado+" "+hud.ultimoUsoCelular());
        linea(salida,"dia "+gestorMinijuegos.varianteContrasena+" "+(introduccionDomingo.abierta ? 1 : 0));
        for (Tarea tarea : escritorio.tareas)
          linea(salida,"tarea "+tarea.id+" "+(tarea.estaCompletada() ? 1 : 0));
        linea(salida,"biblioteca "+(encargoBiblioteca.estaSorteado() ? 1 : 0));
        for (int i=0; i<encargoBiblioteca.libroPorEstante.length; i++)
          linea(salida,"estante "+encargoBiblioteca.libroPorEstante[i]+" "+(encargoBiblioteca.revisados[i] ? 1 : 0));
        linea(salida,"FIN");
      }
      try {
        java.nio.file.Files.move(temporal,archivo,java.nio.file.StandardCopyOption.ATOMIC_MOVE,
          java.nio.file.StandardCopyOption.REPLACE_EXISTING);
      } catch (java.nio.file.AtomicMoveNotSupportedException e) {
        java.nio.file.Files.move(temporal,archivo,java.nio.file.StandardCopyOption.REPLACE_EXISTING);
      }
    } catch (java.io.IOException e) {
      println("No se pudo guardar la partida: "+e.getMessage());
    } finally {
      if (temporal!=null) {
        try { java.nio.file.Files.deleteIfExists(temporal); }
        catch (java.io.IOException e) { println("No se pudo retirar el archivo temporal: "+e.getMessage()); }
      }
    }
  }

  private void linea(java.io.BufferedWriter salida,String texto) throws java.io.IOException {
    salida.write(texto);
    salida.newLine();
  }

  boolean continuar() {
    EstadoPartida estado;
    try (java.io.BufferedReader entrada=java.nio.file.Files.newBufferedReader(archivo)) {
      estado=leer(entrada);
    } catch (java.nio.file.NoSuchFileException e) {
      avisoMenu="Todavía no hay una partida guardada.";
      return false;
    } catch (java.io.IOException | IllegalArgumentException e) {
      avisoMenu="No se pudo recuperar la partida guardada.";
      return false;
    }

    reiniciarDia();
    personajeSeleccionado=estado.personaje;
    jugador.cargarPersonaje(personajeSeleccionado);
    escenarios.actual=estado.escena;
    jugador.colocarPies(estado.piesX,estado.piesY);
    jugador.direccion=estado.direccion;
    hud.hora=estado.minutos/60;
    hud.minutos=estado.minutos%60;
    hud.energia=estado.energia;
    hud.estres=estado.estres;
    hud.concentracion=estado.concentracion;
    hud.descansoAcumulado=estado.descanso;
    hud.restaurarUltimoUsoCelular(estado.ultimoUsoCelular);
    gestorMinijuegos.varianteContrasena=estado.varianteContrasena;
    for (int id : estado.completadas) escritorio.tareas.completar(id);
    encargoBiblioteca.restaurar(estado.bibliotecaSorteada,estado.libros,estado.estantesRevisados);
    introduccionDomingo.abierta=estado.introduccion;
    avisoMenu="";
    pantalla=2;
    return true;
  }

  private EstadoPartida leer(java.io.BufferedReader entrada) throws java.io.IOException {
    String cabecera=entrada.readLine();
    boolean formatoAnterior="SOCIALBALANCE 1".equals(cabecera);
    exigir(formatoAnterior || FORMATO.equals(cabecera));
    EstadoPartida estado=new EstadoPartida();
    String[] datos=registro(entrada,"jugador",5);
    estado.personaje=entero(datos[1],1,personajes.length);
    estado.escena=entero(datos[2],escenarios.HABITACION,escenarios.BIBLIOTECA);
    estado.direccion=entero(datos[3],0,3);
    estado.piesX=coordenada(datos[4],ANCHO_JUEGO);
    estado.piesY=coordenada(datos[5],ALTO_JUEGO);

    datos=registro(entrada,"hud",6);
    estado.minutos=entero(datos[1],8*60,FIN_DIA);
    estado.energia=entero(datos[2],0,100);
    estado.estres=entero(datos[3],0,100);
    estado.concentracion=entero(datos[4],0,100);
    estado.descanso=entero(datos[5],0,MAX_DESCANSO+encargoBiblioteca.DESCANSO_ADICIONAL);
    estado.ultimoUsoCelular=entero(datos[6],-1,escritorio.tareas.cantidad());

    datos=registro(entrada,"dia",2);
    estado.varianteContrasena=entero(datos[1],0,2);
    estado.introduccion=entero(datos[2],0,1)==1;
    // Validar cada ID antes de sustituir el estado de la partida en memoria.
    java.util.HashSet<Integer> ids=new java.util.HashSet<Integer>();
    for (int i=0; i<escritorio.tareas.cantidad(); i++) {
      datos=registro(entrada,"tarea",2);
      int id=Integer.parseInt(datos[1]);
      exigir(escritorio.tareas.consultar(id)!=null && ids.add(id));
      if (entero(datos[2],0,1)==1) estado.completadas.add(id);
    }
    exigir(estado.ultimoUsoCelular<=estado.completadas.size());

    estado.bibliotecaSorteada=entero(registro(entrada,"biblioteca",1)[1],0,1)==1;
    if (!estado.bibliotecaSorteada) exigir(estado.descanso<=MAX_DESCANSO);
    int estantes=encargoBiblioteca.libroPorEstante.length;
    estado.libros=new int[estantes];
    estado.estantesRevisados=new boolean[estantes];
    java.util.HashSet<Integer> libros=new java.util.HashSet<Integer>();
    // Las partidas anteriores comparten los dos accesos centrales. El sexto queda vacío.
    java.util.Arrays.fill(estado.libros,-1);
    int estantesGuardados=formatoAnterior ? 5 : estantes;
    for (int i=0; i<estantesGuardados; i++) {
      datos=registro(entrada,"estante",2);
      int libro=entero(datos[1],-1,encargoBiblioteca.libros.length-1);
      exigir(libro==-1 || libros.add(libro));
      estado.libros[i]=libro;
      estado.estantesRevisados[i]=entero(datos[2],0,1)==1;
      exigir(estado.bibliotecaSorteada || !estado.estantesRevisados[i]);
    }
    exigir(libros.size()==encargoBiblioteca.libros.length);
    exigir("FIN".equals(entrada.readLine()) && entrada.readLine()==null);
    return estado;
  }

  private String[] registro(java.io.BufferedReader entrada,String clave,int cantidad) throws java.io.IOException {
    String linea=entrada.readLine();
    if (linea==null) throw new java.io.IOException("Archivo incompleto");
    String[] datos=linea.split(" ");
    exigir(datos.length==cantidad+1 && clave.equals(datos[0]));
    return datos;
  }

  private int entero(String texto,int minimo,int maximo) throws java.io.IOException {
    int valor=Integer.parseInt(texto);
    exigir(valor>=minimo && valor<=maximo);
    return valor;
  }

  private float coordenada(String texto,int maximo) throws java.io.IOException {
    float valor=Float.parseFloat(texto);
    exigir(Float.isFinite(valor) && valor>=0 && valor<=maximo);
    return valor;
  }

  private void exigir(boolean condicion) throws java.io.IOException {
    if (!condicion) throw new java.io.IOException("Registro de guardado inválido");
  }
}
