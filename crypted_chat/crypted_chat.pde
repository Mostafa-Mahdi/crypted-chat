import controlP5.*;
import processing.net.Client; 


//camelCase
ControlP5 cp5;
Textarea chatArea;
Textfield chatInput;
Client chatClient; 
RSA rsa;


// Konfiguration af selve udseendet.
int textSize = 20;
int lineHeight = 25;
String font = "arial";
float textFieldSize = 15; // Hvor stor skal chat input feltet være i procent ift til højden af programmet   
// Variabler
String user = "";



void setup(){
  // Opsæt canvas og CP5
  size(800, 600);
  surface.setTitle("Crypted Chat by Mostafa Mahdi");
  cp5 = new ControlP5(this);
  int textFieldHeight = int(height*(textFieldSize/100)); // setSize acceptere kun int


  // Opsæt chat felt
  chatArea = cp5.addTextarea("txt")
                  .setSize(width, height-textFieldHeight)
                  .setFont(createFont(font, textSize))
                  .setLineHeight(lineHeight)
                  .setColor(color(255))
                  .setColorBackground(color(255,100))
                  .setColorForeground(color(255,100))
                  ;
  
  // Opsæt chat input
  chatInput = cp5.addTextfield("input")
     .setPosition(0,height-textFieldHeight)
     .setSize(width,textFieldHeight)
     .setFont(createFont(font, textSize))
     .setFocus(true)
     .setColor(color(0,255,0))
     ;
     
  writeMessageToGui("Server", "CryptedChat client started!");
  
  // opsætning af rsa
  rsa = new RSA(2048);
  if(!rsa.serverKeyExists()){
    writeMessageToGui("Server", "Fejl, du mangler public key for at kunne forbinde til severen!");
  }else{
   rsa.lavPQ();
   rsa.setupRSA();
   rsa.loadServerKey();
  }
  
  writeMessageToGui("Server", "Indtast dit navn:");
  
  
}


public void writeMessageToGui(String user, String message){
   // Append ny chat besked
   chatArea.append(String.format("%s: %s\n", user, message));
}


// Kryptere beskeden og laver det til om til en joined BigInteger string klar til at blive sendt over nettet.
String kryptere(String besked){
   BigInteger[] krypteretBeskedTal = rsa.serverKryptere(besked);
   String[] krypteretBesked = new String[krypteretBeskedTal.length];
   for(int i = 0; i<krypteretBeskedTal.length;i++){
      krypteretBesked[i] = krypteretBeskedTal[i].toString(); 
   }
   return String.join(",", krypteretBesked);
}

String dekryptere(String besked){
   String[] krypteretTalString = besked.split(",");
   BigInteger[] krypteretTal = new BigInteger[krypteretTalString.length];
   for(int i = 0; i<krypteretTalString.length;i++){
     krypteretTal[i] = new BigInteger(krypteretTalString[i]);
   }
   return rsa.dekryptere(krypteretTal);
}


void transmitMessage(String message){
   chatClient.write(kryptere(message) + "\n");
}


void clientEvent(Client clientSender) {
  String[] messageRaw = new String[1];
  messageRaw = clientSender.readStringUntil('\n').replace("\n", "").split("\\|"); // fordi regex skal vi escape
  String username = messageRaw[0];
  String message = dekryptere(messageRaw[1]);
  
  writeMessageToGui(username, message);
}



// Event når brugeren trykker enter
public void input(String msg) {
  println("Data modtaget fra tekstfelt: " + msg);
  // Tjek om user er tom
  if(user.equals("")){
    user = msg;
    writeMessageToGui("Server", "Du er nu logget ind som " + user);
    forbindTilServer();
   } // Hvis textfield area er  tom
   else if(msg.equals("")){
     println("Sender ikke besked da text feltet er tomt");
     return;
   }
   else {
    writeMessageToGui(user, msg);
    transmitMessage(msg);
  }
}


void forbindTilServer(){
    chatClient = new Client(this, "127.0.0.1", 1234); 
    chatClient.write(user + "|" + rsa.publicKey + "|" + rsa.n  + "\n"); // send user info.
}

void draw(){
  background(0);
  // Ingen da programmet blot køre på events :)
}
