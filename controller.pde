import controlP5.*;
import processing.serial.*;
import java.util.*;
import java.io.*;

Serial serial;

int sleepMessage = 15;
char type = 'a';
int time = 90;


void setup() {
  size(600, 300);
  
  String portName = Serial.list()[0];
  
  printArray(Serial.list());
  serial = new Serial(this, portName, 9600);
}


void draw() {
  background(0);
  //for(int i = 0; i < 10; i++) {
  //  sendSerialMessage('b', 200, 1);
  //  delay(300);
  //}
  //sendSerialMessage('a', 200, 1);
  //delay(3000);
}

void keyPressed() {
  //if (key == 'a') {
  //  sendSerialMessage('a', 80, 2);
  //  delay (20);
  //} else if (key == 'b') {
  //  sendSerialMessage('b', 100, 2);
  //  delay (20);
  //}
  int ikey = parseInt(key) - 48;
  if (ikey >= 0 && ikey <= 9) {
    sendSerialMessage(type, time, ikey);
  }
  
  if (key == 'a') { type = 'a'; time = 90;}
  if (key == 'b') { type = 'b'; time = 300; }
}

void sendSerialMessage(char type, int duration, int id) {
  println(type+" "+duration+" "+id);
  serial.write(type+","+duration+","+id+";");
  delay(sleepMessage); // wait for serial
} 
