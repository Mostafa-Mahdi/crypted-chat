import controlP5.*;
import processing.net.Server;
import processing.net.Client;
import java.util.ArrayList;

//camelCase
ControlP5 cp5;
Textarea chatArea;
Server chatServer;
ArrayList<ChatUser> chatUsers = new ArrayList<ChatUser>();



// Konfiguration af selve udseendet.
int textSize = 20;
int lineHeight = 25;
String font = "arial";
int port = 1234;


void setup(){
  // Opsæt canvas og CP5
  size(800, 600);
  surface.setTitle("Crypted Chat by Mostafa Mahdi");
  cp5 = new ControlP5(this);

  
  // Opsæt chat felt
  chatArea = cp5.addTextarea("txt")
                  .setSize(width, height)
                  .setFont(createFont(font, textSize))
                  .setLineHeight(lineHeight)
                  .setColor(color(255))
                  .setColorBackground(color(255,100))
                  .setColorForeground(color(255,100))
                  ;
   
   
  // Opsæt server
  chatServer = new Server(this, port);
  writeMessage("Server", "Hoster chat server på port -> " + port);
  
}

public void writeMessage(String user, String message){
  // Hvis textfield area var tom
   if(message.equals("")){
     println("Sender ikke besked da text feltet er tomt");
     return;
   }
   // Append ny chat besked
   chatArea.append(String.format("%s: %s\n", user, message));
}



void serverEvent(Server chatServer, Client newClient) {
  String newUserInfo[] = new String[1];
  // wait for input
  while(newClient.available() == 0){
  }
  //
  
  // ■  / halv kasse betyder split her
  // ▀ / fuld kasse betyder stop transmission 
  newUserInfo = newClient.readStringUntil('\n').replaceAll("\n", "").split("\\|"); // Fordi SPLIT er regex skal vi escape
  //Parse public key
  BigInteger userPublicKey = new BigInteger(newUserInfo[1]);
  
  // Create new ChatUser object and add it to the list
  ChatUser cu = new ChatUser(newUserInfo[0], userPublicKey, newClient);
  chatUsers.add(cu);
  writeMessage("Server", cu.username + " har forbundet sig til serveren");
}


// Når en disconnecter fra serveren
void disconnectEvent(Client disconnectedClient) {
  // Søg efter brugeren der disconnectede
  for(ChatUser cu: chatUsers){
   if(cu.networkHandle == disconnectedClient ){
     // Broadcast at han er logget ud
     println(cu.username + " disconnected from server");
     // Fjern fra listen.
     chatUsers.remove(cu);
   }
  }
}



void draw(){
  background(0);
}
