import java.math.BigInteger;
import java.security.SecureRandom; // Vi skal bruge java's indbyggede da processingen ikke er god eller sikker nok.

void setup(){
  size(800, 600); 
  println(LavPrimtal(1024));
}


void draw(){
  generateKandidat(1024);
}


Boolean enkelMillerRabinTest(BigInteger n, BigInteger a){
  BigInteger m = n.subtract(new BigInteger("1"));
  
  while(ulige(m)){
    m = n.divide(BigInteger.TWO);
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

Boolean millerRabinTest(BigInteger n, int k, int bits){
  for(int i=0;i<k;i++){
    BigInteger a = new BigInteger(bits, new SecureRandom());
    Boolean er_primtal = enkelMillerRabinTest(n, a);
    if(!er_primtal){
      return false;
    }
  }
  return true;
}


Boolean ulige(BigInteger tal) {
    if(!tal.mod(BigInteger.TWO).equals(BigInteger.ZERO)){
        return true;
    }
    
    return false;
}

BigInteger LavPrimtal(int bits){
  while(true){
    BigInteger kandidat = generateKandidat(bits);
    if(millerRabinTest(kandidat, 50, bits)){
      return kandidat; 
    }
  }
}
