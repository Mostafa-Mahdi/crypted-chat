import java.math.BigInteger;


public class ChatUser{
   BigInteger publicKey;
   String username;
   String IP;
   Client networkHandle;
   
   // Constructor
   ChatUser(String username, BigInteger publicKey, Client networkHandle){
     this.username = username;
     this.publicKey = publicKey;
     this.networkHandle = networkHandle;
     
   }
    
    
   void sendMessage(String message){
     // code for sending a message
     
   }
  
}
