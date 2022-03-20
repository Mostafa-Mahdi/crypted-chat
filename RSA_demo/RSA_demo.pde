import java.math.BigInteger;
import java.security.SecureRandom; // Vi skal bruge java's indbyggede da processingen ikke er god eller sikker nok.

void setup(){
  size(800, 600); 
  println(lavPrimtal(1024));
}


void draw(){
}


Boolean enkelMillerRabinTest(BigInteger n, BigInteger a){
  BigInteger m = n.subtract(new BigInteger("1"));
  
  while(ulige(m)){
    m = m.divide(BigInteger.TWO);
  }
  
  if(a.modPow(m, n).equals(BigInteger.ONE)){
    return true;
  }
  
  // Er m exponenten større end primtallets kandidat?
  while(m.compareTo(n.subtract(BigInteger.ONE)) == 1){
    if(a.modPow(m, n).equals(n.subtract(BigInteger.ONE))){
      return true;
  }
    m = m.multiply(BigInteger.TWO);
  }
  
  return false;
}


BigInteger generateKandidat(int bits){
  BigInteger kandidat = new BigInteger(bits,  new SecureRandom());
  
  // Bøvlet da BigInteger ikke kan arbejde med int
  // Tjek om kandidaten er et lige tal, hvis ja tilføj 1.
  if(ulige(kandidat)){
    kandidat.add(new BigInteger("1"));
  }
    
  
  return kandidat;
}


// https://www.ams.org/journals/mcom/2014-83-290/S0025-5718-2014-02830-5/
// Vi bruger predefineret a værdier
Boolean millerRabinTest(BigInteger n, int k, int bits){
  
  // vi tester k antal gange imod (n) som er primtallet vi ønsker at teste
  // Her laver et jeg en tilfældig a værdi.
  for(int i=0;i<k;i++){
    BigInteger a = generateKandidat(bits);
    Boolean er_primtal = enkelMillerRabinTest(n, a);
    if(!er_primtal){
      return false;
    }
  }
  
  // Vi bruger også webster/sorensen a-værdier da de har bevist at der høj success med at bruge disse a-værdier for at verificere primtallet
  int[] WebsterPseudoPrimesBase = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41};
  for(int i=0;i<WebsterPseudoPrimesBase.length;i++){
    BigInteger a = new BigInteger(str(WebsterPseudoPrimesBase[i]));
    Boolean er_primtal = enkelMillerRabinTest(n, a);
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
BigInteger lavPrimtal(int bits){
  while(true){
    BigInteger kandidat = generateKandidat(bits);
    if(millerRabinTest(kandidat, 50, bits)){
      return kandidat; 
    }
  }
}
