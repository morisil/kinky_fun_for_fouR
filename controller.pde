import controlP5.*;
import processing.serial.*;
import java.util.*;
import java.io.*;

Serial serial;

int sleepMessage = 15;
char type = 'a';
int time = 90;

final char LASER = 'a';
final char LIGHT = 'b';

void setUpController() {  
  String portName = Serial.list()[0];
  printArray(Serial.list());
  serial = new Serial(this, portName, 9600);
}

void sendSerialMessage(char type, int duration, int id) {
  println(type+" "+duration+" "+id);
  serial.write(type+","+duration+","+id+";");
  delay(sleepMessage); // wait for serial
} 
