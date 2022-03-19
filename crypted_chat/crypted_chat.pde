import controlP5.*;
import processing.net.Client; 


//camelCase
ControlP5 cp5;
Textarea chatArea;
Textfield chatInput;
Client chatClient; 



// Konfiguration
float textFieldSize = 15; // Hvor stor skal chat input feltet være i procent ift til højden af programmet   

// Konfiguration af selve udseendet.
int textSize = 20;
int lineHeight = 25;
String font = "arial";


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
  

  
  writeMessage("Server", "CryptedChat client started!");
  writeMessage("Server", "Indtast dit navn:");
  
  
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



// Event når brugeren trykker enter
public void input(String msg) {
  println("Data modtaget fra client : "+msg);
  // Tjek om user er tom
  if(user.equals("")){
    user = msg;
    forbindTilServer();
    writeMessage("Server", "Du er nu logget ind som " + user);
  } else{
    writeMessage(user, msg);
  }
}


void forbindTilServer(){
    chatClient = new Client(this, "127.0.0.1", 1234); 
    chatClient.write(user + "|" + "23989"  + "\n"); // send user info.
}

void draw(){
  background(0);
  // Ingen da programmet blot køre på events :)
}
