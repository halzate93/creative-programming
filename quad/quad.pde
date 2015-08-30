import ddf.minim.*;
import ddf.minim.analysis.*;

boolean white;

Minim minim;
AudioPlayer song;
FFT fft;
BeatDetect beat;

int dotDistance = 50, dotStart = 200;
int lineStart = 10;

int waveX, waveY, waveWidth = 300;

int coolDown;

void setup() {
  waveX = width/2 - waveWidth/2;
  waveY = height/2;
  size(1000, 600);
  background(0);

  stroke(255);
  noCursor();

  minim = new Minim(this);

  song = minim.loadFile("summit.mp3");
  song.play();

  fft = new FFT(song.bufferSize(), song.sampleRate());
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  beat.detectMode(BeatDetect.FREQ_ENERGY);
}

void drawDots() {
  if(beat.isHat()){
    coolDown = 60;
  }
  
  if(coolDown > 0) {
    dotStart = (int)map(coolDown, 0, 60, 200, 210);
    coolDown --;
  }else{
    coolDown = 0;
    dotStart = 200;
  }
  
  pushMatrix();
  translate(width/2, height/2);
  rotate(radians(180));
  for (int i=0; i<fft.specSize(); i++) {
    /*strokeWeight(5);
    stroke(0);
    line(0, 200, 0, 300);*/
    strokeWeight(1);
    stroke(255);
    float n = norm(fft.getBand(i), 0, 50);
    if (n > 1) n = 1;
    line(0, dotStart, 0, dotStart + n * dotDistance);
    rotate(radians(1800f/fft.specSize()));
  }
  popMatrix();
}

void drawWave() {
  stroke(255);
  
  int dX = song.left.size()/waveWidth;
  for (int i = 0; i < waveWidth; i++)
  {
    float exp1 = map(waveWidth/2 - abs(waveWidth/2 - i), 0, waveWidth/2, 0, 3.5);
    float exp2 = map(waveWidth/2 - abs(waveWidth/2 - (i+1)), 0, waveWidth/2, 0, 3.5);
    line(waveX + i, waveY + song.left.get(i*dX)*50 * exp1, waveX + i + 1, waveY + song.left.get((i+1)*dX)*50*exp2);
    line(waveX + i, waveY + song.right.get(i*dX)*50 * exp1, waveX + i + 1, waveY + song.right.get((i+1)*dX)*50*exp2);
  }
}

void clean(){
  pushMatrix();
  translate(width/2, height/2);
  ellipseMode(CENTER);
  fill(0, 10);
  stroke(0);
  ellipse(0, 0, 400, 400);
  popMatrix();
  
  pushMatrix();
  translate(width/2, height/2);
  rotate(radians(45));
  if(white){
    fill(255);
    stroke(255);
  }else{
    fill(0);
    stroke(0);
  }
  rectMode(CORNER);
  
  for(int i=0; i<4; i++){
    pushMatrix();
    translate(0, 130);
    rect(-width/2, 0, width, width);
    popMatrix();
    rotate(radians(90));
  }
  popMatrix();
}

void draw() {
  clean();
  
  fft.forward(song.mix);
  beat.detect(song.mix);

  drawDots();

  drawWave();
}

void mouseClicked(){
  white = !white;
}