import java.math.BigInteger;


public class ChatUser{
   BigInteger publicKey;
   String username;
   Client networkHandle;
   
   // Constructor
   ChatUser(Client networkHandle){
     this.networkHandle = networkHandle;
     // Indlæs authentication packet
     this.setupClient();
   }
   
   void setupClient(){
     String newUserInfo[] = new String[1];
     
     // wait for input
     while(this.networkHandle.available() == 0){
     }
     
     
     // Modtag authentication packet og split
     newUserInfo = this.readMessage().split("\\|"); // Fordi SPLIT er regex skal vi escape
    
     
     // Sæt dataet i attributerne
     this.username = newUserInfo[0];
     this.publicKey = new BigInteger(newUserInfo[1]);
   }
    
   String readMessage(){
     // vent i en loop indtil dataet er 100% klar
     while(networkHandle.available() == 0){
   }
     
   String message = networkHandle.readStringUntil('\n').replace("\n", "");
     return message;
   }
    
   void sendMessage(String user, String message){
     // code for sending a message
     networkHandle.write(user + "|" + message + "\n");
   }
  
}
