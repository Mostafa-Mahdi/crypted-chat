import java.math.BigInteger;
import java.security.SecureRandom; // Vi skal bruge java's indbyggede da processingen ikke er god eller sikker nok.

public class RSA{
 
 public int bits = 1024; // længden for nøglen
 public BigInteger p;
 public BigInteger q;
 private int k = 50; // antal miller-rabin runder
 
 private BigInteger kandidat;
 private BigInteger a;
 private SecureRandom random =  new SecureRandom();
 private int[] WebsterPseudoPrimesBase = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41};
 
 
  
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


  BigInteger generateA(BigInteger n, int bits){
    SecureRandom random = new SecureRandom();
    BigInteger a;
    
    
    // Vi bliver nød til at lave en while loop, da det er besværligt at lave en random tal indenfor en range.
    do{
      a = new BigInteger(bits,  random);
      // Bøvlet da BigInteger ikke kan arbejde med int
      // Tjek om kandidaten er et lige tal, hvis ja tilføj 1.
      if(ulige(a)){
        a.add(new BigInteger("1"));
      }
      
    }while(a.compareTo(n) == 2);
    
    return a;
  }


  
  // https://www.ams.org/journals/mcom/2014-83-290/S0025-5718-2014-02830-5/
  // Vi bruger predefineret a værdier
  Boolean millerRabinTest(){
    
    // vi tester k antal gange imod (n) som er primtallet vi ønsker at teste
    // Her laver et jeg en tilfældig a værdi.
    for(int i=0;i<k;i++){
      a = generateA(kandidat, bits); // Laver en a værdi der er mindre end n.
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
    while(true){
      // Lav en 1024 bit kandidat.
      generateKandidat();
      // Hvis Miller-Rabin-testen er fuldført, så er der en høj chance for det er en primtal men aldrig 100%
      if(millerRabinTest()){
        return kandidat; 
      }
    }
  }


  // Her udfylder vi PQ værdierne med en PRP (probable prime) vha. af Miller-Rabin testen.
  public void lavPQ(){
    p = lavPrimtal();
    q = lavPrimtal();
  }

}
