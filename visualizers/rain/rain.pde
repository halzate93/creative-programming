import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import java.util.ArrayList;

ArrayList<PVector> drops;
Minim minim;
AudioPlayer song;
FFT fft;
BeatDetect beat;

int dropsPerFrame = 10;
int speed = 10;
int maxSize = 50, minSize = 5;

int radius = 200;
int degrees = 180;
int amp = 50;

int specWidth = 200;
int specHeight = 180;
int specBase = 20;

int cooldown = 60;
int t;

void setup(){
  
  minim = new Minim(this);
  song = minim.loadFile("houston.mp3");
  song.pause();
  song.loop();
  fft = new FFT(song.bufferSize(), song.sampleRate());
  fft.logAverages(22, 3);
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  beat.detectMode(BeatDetect.SOUND_ENERGY);
  beat.setSensitivity(500);
  
  drops = new ArrayList<PVector>();
  size(1000, 600);  
  background(0);
  noCursor();
}

void addDrops(){
  for(int i=0; i<dropsPerFrame; i++){
    int x = (int)random(0, width);
    drops.add(new PVector(x, 0, (int)random(minSize, maxSize)));
  }
}

void updateDrops(){
  if(beat.isOnset()){
    t = cooldown;
  }
  stroke(map(t, 0, cooldown, 50, 255));
  strokeWeight(1);
  for(int i=0; i<drops.size(); i++){
    PVector drop = drops.get(i);
    drop.add(0, speed, 0);
    if(drop.y > height) {
      drops.remove(i);
      i--;
    }else{
      line(drop.x, drop.y, drop.x, drop.y - drop.z);
    }
  }
  
  if(t > 0) t--;
}

void drawWaveForm(){
  ellipseMode(CENTER);
  stroke(0);
  fill(0);
  ellipse(width/2, height/2, 2*(radius-1), 2*(radius-1));
  
  int d = song.left.size()/degrees ;
  
  //println(song.left.size());
  //println(d);
  
  stroke(255);
  pushMatrix();
  translate(width/2, height/2);
  for(int i = 0; i < degrees; i++)
  {
    strokeWeight(2);
    point(0, radius + song.left.get(i * d) * amp);
    point(0, -radius - song.left.get(song.left.size() - i * d - 1) * amp);
    point(0, radius + song.right.get(i * d) * amp);
    point(0, -radius - song.right.get(song.right.size() - i * d - 1) * amp);
    
    strokeWeight(1);
    line(0, radius + song.left.get(i * d) * amp, 0, radius + song.right.get(i * d) * amp);
    line(0, -radius - song.left.get(i * d) * amp, 0, -radius - song.right.get(i * d) * amp);
    rotate(radians(1));
  }
  popMatrix();
   
  /*stroke(255); 
  for(int i = 0; i < song.left.size() - 1; i++)
  {
    line(i, 50 + song.left.get(i)*50, i+1, 50 + song.left.get(i+1)*50);
    line(i, 150 + song.right.get(i)*50, i+1, 150 + song.right.get(i+1)*50);
  }*/
}

void drawSpectrum(){
  int specX = width/2 - specWidth/2;
  int specY = height/2 + (specHeight + specBase)/2;
  
  //println(specX);
  //println(specY);
  
  stroke(255);
  fill(255, 255, 255);
  //println(fft.avgSize());
   
  int dx = (specWidth - (fft.avgSize()+2)) / fft.avgSize();
  
  //println(dx);
   
  for(int i = 0; i < fft.avgSize(); i++)
  {
    int x = specX + i * (dx+2);
    int h = specBase + (int)map(log(fft.getAvg(i) + 1), 0, 6, 0, specHeight);
    //println(fft.getAvg(i));
    if(h > specHeight + specBase) h = specHeight + specBase;
    rect(x, specY - h, dx, h);
    //line(i, height, i, height - fft.getAvg(i)*4);
  }
}

void draw(){
  stroke(0);
  fill(0, 100);
  rect(0, 0, width, height);
  fft.forward(song.mix);
  beat.detect(song.mix);
  
  addDrops();
  updateDrops();
  
  drawWaveForm();
  drawSpectrum();
}

void keyPressed(){
  if (key == ' ') {
    if(song.isPlaying()) song.pause();
    else song.play();
  }
}