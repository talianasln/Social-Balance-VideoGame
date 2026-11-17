// Vista del validador aprobado. NO modifica las reglas de CrearContrasenaSegura.
class VistaContrasena {
  CrearContrasenaSegura reto;
  String textoIngresado = "";
  boolean campoActivo = true;
  boolean quiereSalir = false;
  VistaContrasena(CrearContrasenaSegura reto) { this.reto = reto; }

  boolean dentro(float px,float py,float x,float y,float w,float h) {
    return px>=x && px<=x+w && py>=y && py<=y+h;
  }
  void boton(float x,float y,float w,float h,String nombre,boolean habilitado) {
    stroke(habilitado ? color(219,163,143) : color(109,98,103)); strokeWeight(2);
    if(!habilitado) fill(62,56,62);
    else if(dentro(mouseJuegoX(),mouseJuegoY(),x,y,w,h)) fill(165,108,96);
    else fill(107,72,73);
    rect(x,y,w,h,7);
    noStroke(); fill(habilitado?color(255,239,230):color(159,151,154));
    textAlign(CENTER,CENTER); textSize(16); text(nombre,x+w/2,y+h/2);
  }
  void mostrar() {
    pushStyle(); rectMode(CORNER);
    noStroke(); fill(23,22,29,250); rect(0,0,ANCHO_JUEGO,ALTO_JUEGO);
    fill(41,36,44); rect(50,42,1180,628,18);
    fill(52,46,55); rect(50,42,1180,58,18);
    fill(241,220,206); textAlign(LEFT,CENTER); textSize(23);
    text("SOCIAL BALANCE  /  CREAR CONTRASEÑA SEGURA",86,70);
    boton(1128,51,62,40,"X",true);
    fill(245,226,210); textSize(30); textAlign(LEFT,CENTER);
    text("Protege tu correo personal",93,149);
    fill(195,179,179); textSize(18);
    text("Resuelve un reto de palabras y números. No mide la seguridad real de una clave.",93,191);
    text("Usa una contraseña INVENTADA: nunca escribas una contraseña real.",93,223);
    fill(29,28,36); noStroke(); rect(91,259,1095,143,11);
    fill(231,181,161); textSize(20); text(reto.obtenerNombreReto(),115,288);
    fill(233,217,207); textSize(16);
    for(int i=0;i<3;i++) text("• " + reto.obtenerRegla(i),116,321+i*28);
    fill(225,210,204); textSize(17);
    text("Escribe tu contraseña de práctica:",95,437);
    stroke(campoActivo && !reto.estaCompletado()?color(229,185,165):color(110,99,105)); strokeWeight(2);
    fill(18,19,26); rect(91,458,1095,60,7);
    noStroke(); fill(249,239,231); textSize(24);
    String vista = textoIngresado;
    if(campoActivo && (millis()/500)%2==0 && !reto.estaCompletado()) vista += "|";
    while (textWidth(vista)>1045 && vista.length()>1) vista=vista.substring(1);
    text(vista,112,487);
    boton(91,536,240,53,"COMPROBAR",!reto.estaCompletado());
    boton(349,536,180,53,"BORRAR",!reto.estaCompletado());
    if(!reto.estaCompletado()) boton(550,536,200,53,"VER PISTA",true);
    if(reto.estaCompletado()) boton(780,536,405,53,"VOLVER AL COMPUTADOR",true);
    fill(reto.ultimoIntentoFueCorrecto() && reto.estaCompletado()?color(41,104,72):color(103,51,61));
    if(reto.obtenerIntentos()==0 && !reto.estaCompletado()) fill(51,46,56);
    noStroke(); rect(91,603,1095,44,7);
    fill(247,235,227); textSize(16); textAlign(LEFT,CENTER);
    text(reto.obtenerMensaje(),106,626);
    popStyle();
  }
  void presionar(float x,float y) {
    if(dentro(x,y,1128,51,62,40)) { quiereSalir=true; return; }
    if(reto.estaCompletado()) {
      if(dentro(x,y,780,536,405,53)) quiereSalir=true;
      return;
    }
    if(dentro(x,y,91,458,1095,60)) campoActivo=true;
    else if(dentro(x,y,91,536,240,53)) comprobar();
    else if(dentro(x,y,550,536,200,53)) { gestorMinijuegos.mostrarPista=true; }
    else if(dentro(x,y,349,536,180,53)) { textoIngresado=""; campoActivo=true; }
  }
  void comprobar() {
    if (textoIngresado.trim().length()==0) return;
    if (!gestorMinijuegos.puedeIntentar()) return;
    reto.comprobar(textoIngresado);
    if(reto.estaCompletado()) campoActivo=false;
  }
  void teclear(char tecla,int codigo) {
    if(!campoActivo || reto.estaCompletado()) return;
    if(tecla==ENTER || tecla==RETURN) { comprobar(); return; }
    if(tecla==BACKSPACE) {
      if(textoIngresado.length()>0) textoIngresado=textoIngresado.substring(0,textoIngresado.length()-1);
      return;
    }
    if(tecla==DELETE) { textoIngresado=""; return; }
    if(tecla==CODED) return;
    if(tecla>=32 && textoIngresado.length()<60) textoIngresado += tecla;
  }
}
