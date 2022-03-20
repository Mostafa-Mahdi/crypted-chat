import java.math.BigInteger;
import java.security.SecureRandom; // Vi skal bruge java's indbyggede da processingen ikke er god eller sikker nok.

public class RSA{
 
   public int bits; // længden for nøglen
   public BigInteger p;
   public BigInteger q;
   public BigInteger n;
   public BigInteger phi;
   public BigInteger publicKey; // e
   public BigInteger privateKey; // d
   private int k = 50; // antal miller-rabin runder, jo flere, jo bedre, men tager længere tid
   private BigInteger kandidat;
   private BigInteger a;
   private SecureRandom random =  new SecureRandom();
   private int[] WebsterPseudoPrimesBase = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41}; // https://www.ams.org/journals/mcom/2014-83-290/S0025-5718-2014-02830-5/
   private String delimiter = "524"; // en delimiter der er udenfor ASCII
   public int maxLengthOfMessage;
   public BigInteger serverPublicKey;
   public BigInteger serverN;
 
  
   // konstruktør
   RSA(int bits){
      this.bits = bits / 2;
   }
 
 
  Boolean enkelMillerRabinTest(){
    BigInteger m = kandidat.subtract(new BigInteger("1"));
    
    while(ulige(m)){
      m = m.divide(BigInteger.TWO);
    }
    
    if(a.modPow(m, kandidat).equals(BigInteger.ONE)){
      return true;
    }
    
    // Er m exponenten større end primtallets kandidat?
    while(m.compareTo(kandidat.subtract(BigInteger.ONE)) == 1){
      if(a.modPow(m, kandidat).equals(kandidat.subtract(BigInteger.ONE))){
        return true;
      }
      m = m.multiply(BigInteger.TWO);
    }
    
    return false;
  }


  // Generere et random ulige tal der er antal "bits" lang
  BigInteger generateKandidat(){
    kandidat = new BigInteger(bits, random);
    
    // Bøvlet da BigInteger ikke kan arbejde med int
    // Tjek om kandidaten er et lige tal, hvis ja tilføj 1.
    if(ulige(kandidat)){
      kandidat.add(new BigInteger("1"));
    }
      
    return kandidat;
  }


  BigInteger generateA(BigInteger n){
    SecureRandom random = new SecureRandom();
    BigInteger a;
    
    
    // Vi bliver nød til at lave en while loop, da det er besværligt at lave en random tal indenfor en range.
    do{
      a = new BigInteger(n.bitLength(),  random);
      // Bøvlet da BigInteger ikke kan arbejde med int
      // Tjek om kandidaten er et lige tal, hvis ja tilføj 1.
      if(ulige(a)){
        a.add(new BigInteger("1"));
      }
      
    }while(a.compareTo(n) == 2);
    
    return a;
  }


 
  // Vi bruger predefineret a værdier
  Boolean millerRabinTest(){
    
    // vi tester k antal gange imod (n) som er primtallet vi ønsker at teste
    // Her laver et jeg en tilfældig a værdi.
    for(int i=0;i<k;i++){
      a = generateA(kandidat); // Laver en a værdi der er mindre end n.
      Boolean er_primtal = enkelMillerRabinTest();
      if(!er_primtal){
        return false;
      }
    }
    
    // Vi bruger også webster/sorensen a-værdier da de har bevist at der høj success med at bruge disse a-værdier for at verificere primtallet
    for(int i=0;i<WebsterPseudoPrimesBase.length;i++){
      a = new BigInteger(str(WebsterPseudoPrimesBase[i]));
      Boolean er_primtal = enkelMillerRabinTest();
      if(!er_primtal){
        return false;
      }
    }
    
    // kun hvis alle testene er gået igennem så returnere vi sand
    return true;
  }


  // Her tester vi om en BigInteger er ulige, som den kun er hvis n mod 2 = 0
  // Alle primtaller er ulige, derfor giver det god mening at filtre de lige tal ud.
  Boolean ulige(BigInteger tal) {
      if(!tal.mod(BigInteger.TWO).equals(BigInteger.ZERO)){
          return true;
      }
      return false;
  }


  // En løkke der kun bliver brudt ud via. af en return statement
  // Forsætter med at lave kandidater til Miller-Rabin testen indtil en af dem fuldføre alle testene.
  // Jeg benytter mig af Miller-Rabin testen da den også indebærer Fermat-testen og er specificeret i FIPS-186-4 som krav
  private BigInteger lavPrimtal(){
    do{
      // Lav en 1024 bit kandidat.
      generateKandidat();
    }while(!millerRabinTest()); // Hvis Miller-Rabin-testen er fuldført, så er der en høj chance for det er en primtal men aldrig 100%
    return kandidat;
  }


  void savePublicKey(){
    String[] tekst = {publicKey.toString(), n.toString()};
    saveStrings("PublicKey.txt", tekst);
  }
  
  
 public void loadServerKey(){
    String[] linjer = loadStrings("PublicKey.txt");
    this.serverPublicKey = new BigInteger(linjer[0]);
    this.serverN = new BigInteger(linjer[1]);
  }


  public Boolean serverKeyExists(){
    File f = dataFile("PublicKey.txt");
    return f.isFile();
  }


  void savePQ(){
    String[] tekst = {p.toString(), q.toString()};
    saveStrings("pq.txt", tekst);
  }
  
  
  // Her udfylder vi PQ værdierne med en PRP (probable prime) vha. af Miller-Rabin testen.
  public void lavPQ(){
    p = lavPrimtal();
    q = lavPrimtal();
  }
  
  
  public Boolean pqExists(){
    File f = dataFile("pq.txt");
    return f.isFile();
  }


  public void loadPQ(){
    String[] linjer = loadStrings("pq.txt");
    this.p = new BigInteger(linjer[0]);
    this.q = new BigInteger(linjer[1]);
  }


  public void setupRSA(){
    n = p.multiply(q); // find modulus
    phi = p.subtract(BigInteger.ONE).multiply(q.subtract(BigInteger.ONE)); //φ(n)=(p−1)(q−1)
    
    /* public key har 2 kriteriere
    1.  1 < e < φ(n)
    2. coprime med φ(n)
    */
    
    // Implementereing af de tidiligere nævnte kriteriere
    do{
      publicKey = new BigInteger(phi.bitLength(), random);
    }while(publicKey.compareTo(phi) >= 0 || !publicKey.gcd(phi).equals(BigInteger.ONE)); 
    
    privateKey = publicKey.modInverse(phi); // find private key
    this.maxLengthOfMessage = ((n.toString().length()) - 4) / 6; // Her beregner jeg den maksimale længde af krypteret besked med padding og en masse mere.
    
  }
  
  
  // Bruges til at kryptere besked med en vilkårlig public key
  public BigInteger[] andenKeyKryptere(BigInteger andenPublicKey, BigInteger andenN, String besked){
    String[] beskedSplittet = besked.split("(?<=\\G.{" + this.maxLengthOfMessage + "})");
    BigInteger beskedTalSplittet[] = new BigInteger[beskedSplittet.length];
    for(int i = 0; i < beskedSplittet.length; i++){
      BigInteger beskedTal = stringToNumbers(beskedSplittet[i]); // Laver string om til tal vha. ASCII
      beskedTal = addPadding(beskedTal); // Tilføjer random padding i slutning
      beskedTal = beskedTal.modPow(andenPublicKey,andenN);  // besked^publickey mod n
      beskedTalSplittet[i] = beskedTal;
    }
    return beskedTalSplittet;
  }
  
  
  // Kryptere med eget key
  public BigInteger[] kryptere(String besked){
    String[] beskedSplittet = besked.split("(?<=\\G.{" + this.maxLengthOfMessage + "})"); // regex til at splitte
    BigInteger beskedTalSplittet[] = new BigInteger[beskedSplittet.length];
    for(int i = 0; i < beskedSplittet.length; i++){
      BigInteger beskedTal = stringToNumbers(beskedSplittet[i]); // Laver string om til tal vha. ASCII
      beskedTal = addPadding(beskedTal); // Tilføjer random padding i slutning
      beskedTal = beskedTal.modPow(publicKey, n);  // besked^publickey mod n
      beskedTalSplittet[i] = beskedTal;
    }
    return beskedTalSplittet;
  }
  
  
  // Dekryptere med eget key
  public String dekryptere(BigInteger[] besked){
    String[] tekstSplit = new String[besked.length];
    for(int i = 0; i < tekstSplit.length; i++){
      BigInteger dekrypteret = besked[i].modPow(privateKey, n);  // besked^privatekey mod n
      dekrypteret = removePadding(dekrypteret); // Fjern padding altså de 5 sidste tal
      String dekrypteretTekst = numbersToString(dekrypteret);
      tekstSplit[i] = dekrypteretTekst;
    }
    return String.join("", tekstSplit);
  }
  
  
  // Implementering af en simpel padding
  public BigInteger addPadding(BigInteger besked){
     // Vi laver padding, så hver besked er ny og dermed svære at knække
     // Vi ved at padding er 5 tal i slutning, så dem fjerner vi bare nå vi skal dekryptere
     BigInteger randomPadding = new BigInteger(str(int(random(10000, 99999))));
     String beskedString = "" + besked + randomPadding;
     return new BigInteger(beskedString);
  }
  
  
  public BigInteger removePadding(BigInteger besked){
      String beskedString = "" + besked;
      beskedString = beskedString.substring(0, beskedString.length() - 5);
      return new BigInteger(beskedString);
  }

  
  public BigInteger stringToNumbers(String besked){
      // opret en ascii bogstav array med tal repræsenteret i bogstaver.
      String[] ch = new String[besked.length()];
  
      // Konvertere bogstaverne til tal (ascii) i en string array.
      for (int i = 0; i < besked.length(); i++) {
          int character = besked.charAt(i);
          ch[i] = str(character);
      }
     // Konvertere arrayen om til en BigInteger
     return new BigInteger(String.join(delimiter, ch));
  }
  
  
  public String numbersToString(BigInteger besked){
      String beskedString = "" + besked;
      // split
      String[] ch = beskedString.split(delimiter);
      String beskedDone = "";
 
      for (int i = 0; i < ch.length; i++) {
          char character = (char) int(ch[i]);
          beskedDone += character;
      }
    
      return beskedDone;
  }
  

}
