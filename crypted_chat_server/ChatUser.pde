import java.math.BigInteger;


public class ChatUser{
   BigInteger publicKey;
   BigInteger n;
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
     newUserInfo = this.readMessage().split("\\|"); // Fordi SPLIT er regex så skal vi escape
    
     // Sæt dataet i attributerne
     this.username = newUserInfo[0];
     this.publicKey = new BigInteger(newUserInfo[1]);
     this.n = new BigInteger(newUserInfo[2]);
   }
   
    
   String readMessage(){
     // vent i en loop indtil dataet er 100% klar
     while(networkHandle.available() == 0){
   }
     
     String message = networkHandle.readStringUntil('\n').replace("\n", "");
     return dekryptere(message);
   }
   
   String dekryptere(String besked){
      String[] krypteretTalString = besked.split(",");
      BigInteger[] krypteretTal = new BigInteger[krypteretTalString.length];
      for(int i = 0; i<krypteretTalString.length;i++){
        krypteretTal[i] = new BigInteger(krypteretTalString[i]);
      }
      return rsa.dekryptere(krypteretTal);
   }
   
   // Kryptere beskeden og laver det til om til en joined BigInteger string klar til at blive sendt over nettet.
   String kryptere(String besked){
       BigInteger[] krypteretBeskedTal = rsa.kryptereMedEnhverKey(publicKey, n, besked);
       String[] krypteretBesked = new String[krypteretBeskedTal.length];
       for(int i = 0; i<krypteretBeskedTal.length;i++){
          krypteretBesked[i] = krypteretBeskedTal.toString(); 
       }
       return String.join(",", krypteretBesked);
   }
    
   void sendMessage(String user, String message){
     // code for sending a message
     networkHandle.write(user + "|" + kryptere(message) + "\n");
   }
   
}
