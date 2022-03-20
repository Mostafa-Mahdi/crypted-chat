void setup(){
  size(800, 600); 
  RSA rsa = new RSA(2048);
  rsa.lavPQ();
  rsa.setupRSA();
  println(rsa.publicKey);
  println(rsa.privateKey);
  
  String secret = "Hej med dig min søde ven :)";
  println("Secret: " + secret);
  BigInteger[] crypted = rsa.kryptere(secret);
  String decrypted = rsa.dekryptere(crypted);
  println("decrypted: " + decrypted);
}


void draw(){
  
}
