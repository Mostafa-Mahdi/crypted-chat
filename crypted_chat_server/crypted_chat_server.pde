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
RSA rsa;

void setup(){
  // Opsæt canvas og CP5
  size(800, 600);
  surface.setTitle("Crypted Chat by Mostafa Mahdi");
  cp5 = new ControlP5(this);
  
  // opsæt rsa kryptering
  rsa = new RSA(2048);
  
  if(rsa.rsaExists()){
    println("RSA loaded rsa.txt");
    rsa.loadRSA();
  }else{
   println("Opretter en ny RSA nøglering, husk at sende den til klienten!");
   rsa.lavPQ();
   rsa.setupRSA();
   rsa.saveRSA();
   rsa.savePublicKey();
  }
  
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
  ChatUser cu = new ChatUser(newClient);
  chatUsers.add(cu);
  writeMessage("Server", cu.username + " har sluttet sig til serveren");
  broadcastMessage("Server", cu.username + " har sluttet sig til serveren");
}


// Når en disconnecter fra serveren
void disconnectEvent(Client disconnectedClient) {
  ChatUser disconnectedUser = findUser(disconnectedClient);
  // Brugeren har endnu ikke sendt authentication packet
  if(disconnectedUser == null){
    return; 
  }
  writeMessage("Server", disconnectedUser.username + " har forladt chatten");
  broadcastMessage("Server", disconnectedUser.username + " har forladt chat");
  chatUsers.remove(disconnectedUser);
  
}

void clientEvent(Client clientSender) {
  ChatUser sender = findUser(clientSender);
  
  // Brugeren har endnu ikke sendt authentication packet
  if(sender == null){
    return; 
  }
  String message = sender.readMessage();
  writeMessage(sender.username, message);
  broadcastMessage(sender.username, message);
}

void broadcastMessage(String user, String message){
   for(ChatUser cu: chatUsers){
     if(cu.username != user){
       // så vi ikke broadcaster til afsenderen
       cu.sendMessage(user, message);
     }
   }
}


ChatUser findUser(Client networkClient){
    for(ChatUser cu: chatUsers){
     if(cu.networkHandle == networkClient ){
       return cu;
    }
  }
  return null;
}

void draw(){
  background(0);
}
