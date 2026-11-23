// Nombres de los PNG en data. Cambiar aquí si se renombran los recursos.
class PersonajeConfig {
  String nombre, seleccion, descansoHabitacion, descansoExterior, movimientosHabitacion, movimientosExterior;
  PImage preview;
  PersonajeConfig(String nombre,String seleccion,String descansoHabitacion,String descansoExterior,
                  String movimientosHabitacion,String movimientosExterior) {
    this.nombre=nombre; this.seleccion=seleccion;
    this.descansoHabitacion=descansoHabitacion; this.descansoExterior=descansoExterior;
    this.movimientosHabitacion=movimientosHabitacion;
    this.movimientosExterior=movimientosExterior;
  }
}
PersonajeConfig[] personajes;

void prepararPersonajes() {
  personajes = new PersonajeConfig[] {
    new PersonajeConfig("Chico","ChicoEstatico.png","ChicoNivel1Descanso.png","ChicoNivel2Descanso.png",
                        "ChicoNivel1Movimientos.png","ChicoNivel2Movimientos.png"),
    new PersonajeConfig("Chica","ChicaEstatica.png","ChicaNivel1Descanso.png","ChicaNivel2Descanso.png",
                        "ChicaNivel1Movimientos.png","ChicaNivel2Movimientos.png"),
    new PersonajeConfig("NoBin","NoBinEstatica.png","NoBinNivel1Descanso.png","NoBinNivel2Descanso.png",
                        "NoBinNivel1Movimientos.png","NoBinNivel2Movimientos.png")
  };
  for (PersonajeConfig p : personajes) p.preview=cargarImagenPersonaje(p.seleccion,resolucionSprite(330),false);
}

PImage cargarImagenPersonaje(String nombre,int maximo,boolean hoja) {
  return cargarImagenPersonaje(nombre,maximo,hoja ? 4 : 1,hoja ? 4 : 1);
}

PImage cargarImagenPersonaje(String nombre,int maximo,int columnas,int filas) {
  if (nombre==null) return null;
  java.io.File archivo=new java.io.File(dataPath(nombre));
  if (!archivo.isFile()) return null;
  javax.imageio.ImageReader lector=null;
  try (javax.imageio.stream.ImageInputStream entrada=javax.imageio.ImageIO.createImageInputStream(archivo)) {
    if (entrada==null) return null;
    java.util.Iterator<javax.imageio.ImageReader> lectores=javax.imageio.ImageIO.getImageReaders(entrada);
    if (!lectores.hasNext()) return null;
    lector=lectores.next(); lector.setInput(entrada);
    int w=lector.getWidth(0), h=lector.getHeight(0);
    if (w<=0 || h<=0 || (columnas>1 && (w%columnas!=0 || h%filas!=0 || w/columnas!=h/filas))) {
      println("Revisar " + nombre + ": se esperan " + columnas + " columnas y " + filas + " filas de cuadros cuadrados.");
      return null;
    }
    int celdaW=w/columnas, celdaH=h/filas;
    float factor=min(1.0, maximo/(float)max(w,h));
    int destinoW=max(1,round(celdaW*factor));
    int destinoH=max(1,round(celdaH*factor));
    java.awt.image.BufferedImage atlas=new java.awt.image.BufferedImage(
      destinoW*columnas,destinoH*filas,java.awt.image.BufferedImage.TYPE_INT_ARGB);
    // Decodificar una sola vez evita releer el PNG grande por cada frame.
    java.awt.image.BufferedImage original=lector.read(0);
    java.awt.Graphics2D dibujo=atlas.createGraphics();
    try {
      // Reducir cada frame directamente del original, sin muestreo previo ni
      // interpolación entre celdas. Vecino más cercano conserva el pixel art.
      dibujo.setRenderingHint(java.awt.RenderingHints.KEY_INTERPOLATION,
        java.awt.RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR);
      dibujo.setComposite(java.awt.AlphaComposite.Src);
      for(int fila=0;fila<filas;fila++) for(int columna=0;columna<columnas;columna++) {
        dibujo.drawImage(original,
          columna*destinoW,fila*destinoH,(columna+1)*destinoW,(fila+1)*destinoH,
          columna*celdaW,fila*celdaH,(columna+1)*celdaW,(fila+1)*celdaH,null);
      }
    } finally { dibujo.dispose(); original.flush(); }
    PImage imagen=new PImage(atlas);
    atlas.flush();
    return imagen;
  } catch (Exception error) {
    println("No se pudo cargar " + nombre + ": " + error.getMessage());
    return null;
  } finally { if (lector!=null) lector.dispose(); }
}

void dibujarImagenAjustada(PImage imagen,float x,float y,float w,float h) {
  if (imagen==null) return;
  float escala=min(w/imagen.width,h/imagen.height);
  float ancho=imagen.width*escala, alto=imagen.height*escala;
  dibujarSpriteNitido(imagen,x+(w-ancho)/2,y+(h-alto)/2,ancho,alto,0,0,imagen.width,imagen.height);
}
// Resolución física necesaria, sin agrandar más allá del PNG original.
int resolucionSprite(float ladoVirtual) {
  return max(1,ceil(ladoVirtual*escalaJuego()*max(1,pixelDensity)));
}

void dibujarSpriteNitido(PImage imagen,float x,float y,float w,float h,int sx,int sy,int ex,int ey) {
  float densidad=max(1,pixelDensity);
  float escala=max(0.001,escalaJuego());
  // Alinear solamente el dibujo: movimiento y colisiones conservan sus decimales.
  float dx=(round((margenJuegoX()+x*escala)*densidad)/densidad-margenJuegoX())/escala;
  float dy=(round((margenJuegoY()+y*escala)*densidad)/densidad-margenJuegoY())/escala;
  float dw=max(1,round(w*escala*densidad))/(escala*densidad);
  float dh=max(1,round(h*escala*densidad))/(escala*densidad);
  image(imagen,dx,dy,dw,dh,sx,sy,ex,ey);
}
