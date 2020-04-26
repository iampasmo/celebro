import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer jingle;
FFT fft;

float specSize = 129;

//int rr = 50;
int existingCellCount=0;
int t=0;
float diceBreeding = 0.005;
//int branchLength = 100;
float freq = 0.1;
int numberOfCells=255;
char button=0;
int cColor;
float nuclearR=0;
int scaleSwitch=0;
int rotateSwitch=0;
int sizeSwitch=0;
int nuclearSwitch=0;


Cell[] cell = new Cell[numberOfCells];

void setup(){
  size(1200,800);
  background(cColor);
  frameRate(60);
  noStroke();
  fill(0,120,240);
  smooth();
  textAlign(LEFT);
  textSize(20);
  rectMode(RADIUS);
 
   cell[0] = new Cell(width/2, height/2); 
   
   
  minim = new Minim(this);
  jingle = minim.loadFile("beat.wav",1024);
  jingle.loop();
  fft = new FFT(jingle.bufferSize(),jingle.sampleRate());
  fft.logAverages(60,22);
 
 

}

void draw(){
  
  t++;
  background(cColor);
  
  
    fill(250,250,200);
  text("Cell Count = " + existingCellCount,50,100);
  text("Frame = " + t,50,120);
  text("Button = " + button, 50,140);
  
  text("Cerebro",1000,700);
  text("2016.6.6.",1000,720);
   text("Pasmo",1000,740);
  
  
  
  if(scaleSwitch==1){
   translate(width*0.25,height*0.25);
   scale(0.5); 
  }
  
  if(button=='b'||button=='n'){
   translate(width/2,height/2);
   rotate(t/180.0);
   translate(-width/2,-height/2);
  }
  
  for(int i=0;i<existingCellCount;i++){
   cell[i].paint(); 
   if(existingCellCount<numberOfCells-120 && (button=='c'||button=='m')) cell[i].breed();
  }
  
  if(button=='v'||button=='n'||button=='m'){
   cColor=color(230+15*sin(t/70.0),225+25*sin(t/80.0),215+15*cos(t/60.0));
  } else cColor=0;
  
  fill(250,250,200);
  text("Cell Count = " + existingCellCount,50,100);
  text("Frame = " + t,50,120);
  text("Button = " + button, 50,140);
  
  text("Cerebro",1000,700);
  text("2016.6.6.",1000,720);
   text("Pasmo",1000,740);
  
   fft.forward(jingle.mix);
   
   if(keyPressed){
     button = key;
     if(key=='0')scaleSwitch=0;
     else if(key=='9')scaleSwitch=1;
     else if(key=='p')rotateSwitch=0;
     else if(key=='o')rotateSwitch=1;
     else if(key=='l')sizeSwitch=0;
     else if(key=='k')sizeSwitch=1;
     else if(key=='j')nuclearSwitch=0;
     else if(key=='h')nuclearSwitch=1;
     else if(key=='q'){
      scaleSwitch=1;
      rotateSwitch=0;
      sizeSwitch=0;
      nuclearSwitch=0;
     }
   }
}


///////////// Objects from here.

class Cell{
  
  int x;
  int y;
  float rr = 40;
  float rrFinal = 40 + (int)random(20);
  float[] branchAngle = new float[2];
  int[] branchLength = new int[2];
  int countBreeded = 0;
  int countBranchBreeded = 0;
  float dice=random(1);
  float diceRed;
  int cellIndex;
  int size=0;
  
  Branch[] branch= new Branch[2];
  
 Cell(int x, int y){
   this.x = x;
   this.y = y;
   branchAngle[0] = random(1)*TWO_PI;
   branchAngle[1] = random(1)*TWO_PI;
   //branchAngle[2] = random(1)*TWO_PI;
   branchLength[0] = (int)random(200)+50;
   branchLength[1] = (int)random(200)+50;
   cellIndex=existingCellCount++;
   
 }
  
 void paint(){
   
   pushMatrix();
   translate(x,y);
   if(rotateSwitch==1)rotate(t/210.0);
   
   // drawing branchs
   fill(150*diceRed,120,140+100*dice,150);
   for(int i=0;i<countBranchBreeded;i++){
    branch[i].grow();
    if(branch[i].l == branch[i].lFinal-3){
       cell[existingCellCount] = new Cell((int)(x + branchLength[countBreeded] * cos(branchAngle[countBreeded])), y+(int) (branchLength[countBreeded] * sin(branchAngle[countBreeded])));
       countBreeded++;
    }
    
    pushMatrix();
    rotate(branchAngle[i]);
    branch[i].branchPaint();
    popMatrix();
  }
    
   // drawing a cell
   if(rr<rrFinal) rr+= 0.2;    //cell growing
   fill(150*diceRed,120,140+100*dice);
   if(sizeSwitch==1)size+=(fft.getAvg(5)-size)*0.1;
   else size=0;
   ellipse(0,0,rr+size*0.1,rr+size*0.1);
   diceRed= sin(t/250.0 + (float)cellIndex/10)    ;              //+=(random(1)-diceRed)*0.2;
   if(nuclearSwitch==1) {                                         // nuclear drawing
     //nuclearR += (5*log(fft.getAvg(cellIndex)+1)+14-nuclearR)*0.1;
     nuclearR += (5*log(fft.getAvg(100)+1)+14-nuclearR)*0.1;
     fill(200,150,140+100*dice,100);
     ellipse(0,0,nuclearR,nuclearR);
   }
   
 //  fill(250);
 //  text(cellIndex,0,0);
  
   popMatrix();
 }
 
 void breed(){
   if(random(1)<diceBreeding && countBranchBreeded < 2){
     //cell[existingCellCount] = new Cell((int)(x + branchLength[countBranchBreeded] * cos(branchAngle[countBranchBreeded])), y+(int) (branchLength[countBranchBreeded] * sin(branchAngle[countBranchBreeded]))); 
     branch[countBranchBreeded]= new Branch(branchLength[countBranchBreeded],5+(int)random(5)); 
     
     countBranchBreeded++;
   }
 }
}

class Branch{
  
 int l;
 int lFinal;
 int w;
 float[] amp=new float[(int)specSize];
 
 Branch(int lFinal, int w){
  this.lFinal = lFinal;
  this.w = w;
  l=0;
 }
 
 void grow(){
  if(l<lFinal){
   l++; 
  }
 }
 
 void branchPaint(){
    if(button=='z') {rect(0,-0.5*w,l,w);}
    else{
    for(int i=0;i<specSize*l/lFinal*1.0;i++){
      amp[i] = (log(fft.getAvg(i+30)+1)-amp[i])*0.1;
      rect(lFinal/specSize*i,0,l/specSize,20*amp[i]+1);
    }
    }
 }
  
  
}