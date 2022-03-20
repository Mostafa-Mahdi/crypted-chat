void setup(){
  size(800, 600); 
  RSA rsa = new RSA(2048);
  rsa.lavPQ();
  rsa.setupRSA();
  println(rsa.publicKey);
  println(rsa.privateKey);
  
  String secret = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsudasdasdas ha";
  println("secret: " + secret);
  BigInteger secretNumber = rsa.stringToNumbers(secret);
  println("secretNumber: " + secretNumber);
  BigInteger[] crypted = rsa.kryptere(secret);
  println("crypted: " + crypted);
  String decrypted = rsa.dekryptere(crypted);
  println("decrypted: " + decrypted);
}


void draw(){
}
