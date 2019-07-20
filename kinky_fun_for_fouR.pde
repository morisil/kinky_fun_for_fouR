
import SimpleOpenNI.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;

// -- Audio setup begin --

final boolean ENABLE_SOUND_LOOP = true;

// alternative would be with each hand separately
final boolean ENABLE_CONTROL_VOLUME_WITH_HEAD = false;

final String SOUND_LOOP = "sample01.mp3";

// Description: gains expressed in -dB 
//  * 0    - max volume of the sample
//  * -100 - would be complete silence
//  * -60  - almost non audible - seems like a good base level for our min volume

final float GAIN_NON_AUDIBLE = -70;
final float GAIN_LOOP = -15;

SpatialSound soundLeftHand        = new SpatialSound("sample01.mp3", GAIN_NON_AUDIBLE, 0);
SpatialSound soundRightHand       = new SpatialSound("sample01.mp3", GAIN_NON_AUDIBLE, -17); // it is too loud

SpatialSound soundSpotTopLeft     = new SpatialSound("sample01.mp3", GAIN_NON_AUDIBLE, 0);
SpatialSound soundSpotTopRight    = new SpatialSound("sample01.mp3", GAIN_NON_AUDIBLE, -10);
SpatialSound soundSpotBottomLeft  = new SpatialSound("sample01.mp3", GAIN_NON_AUDIBLE, -10);
SpatialSound soundSpotBottomRight = new SpatialSound("sample01.mp3", GAIN_NON_AUDIBLE, -20);

// -- Audio setup end --

// -- Video setup begin --

// the color is expressed in HSV / HSB model - open http://colorizer.org/
//  * first parameter degree on the color wheel from 0-360 degrees
//  * saturation 0-100 (in %)
//  * value / brightness 0-100 (in %)
void setUpColors() {
  COLOR_LEFT_PARTICLE_RANGE_START     = color(270, 100, 100);   // blue
  COLOR_LEFT_PARTICLE_RANGE_END       = color(295, 100, 100);   // purple
  COLOR_RIGHT_PARTICLE_RANGE_START    = color(0, 100, 100);     // red
  COLOR_RIGHT_PARTICLE_RANGE_END      = color(38, 100, 100);    // orange 
  
  COLOR_TOP_LEFT_SPOT_RANGE_START     = color(60, 100, 100);
  COLOR_TOP_LEFT_SPOT_RANGE_END       = color(120, 100, 100);
  COLOR_TOP_RIGHT_SPOT_RANGE_START    = color(240, 100, 100);
  COLOR_TOP_RIGHT_SPOT_RANGE_END      = color(290, 100, 100);
  COLOR_BOTTOM_LEFT_SPOT_RANGE_START  = color(180, 100, 100);
  COLOR_BOTTOM_LEFT_SPOT_RANGE_END    = color(210, 100, 100);
  COLOR_BOTTOM_RIGHT_SPOT_RANGE_START = color(0, 100, 100);
  COLOR_BOTTOM_RIGHT_SPOT_RANGE_END   = color(359, 100, 100);
}

// Description: spots are used only in patch 2 and they are defined
// as a percentage of the screen width and height
final PVector SPOT_TOP_LEFT     = new PVector(33, 33);
final PVector SPOT_TOP_RIGHT    = new PVector(66, 33);
final PVector SPOT_BOTTOM_LEFT  = new PVector(33, 66);
final PVector SPOT_BOTTOM_RIGHT = new PVector(66, 66);

// percentage from the top of the screen
final float PROPORTION_HEAD_VOLUME_MIN      = 25; 
final float PROPORTION_HEAD_VOLUME_MAX      = 60; 

final float PROPORTION_HEAD_MOTION_BLUR_MAX = 20; 
final float PROPORTION_HEAD_MOTION_BLUR_MIN = 50; 

final float PROPORTION_HAND_VOLUME_MIN      = 20; 
final float PROPORTION_HAND_VOLUME_MAX      = 100; 

final float PROPORTION_KNEE_ACTION_MIN      = 70; 
final float PROPORTION_KNEE_ACTION_MAX      = 40;

// -- Video setup end --

// -- Physics setup begin --

final float PARTICLE_BOUNCE = -0.5;
final float PARTICLE_MAX_SPEED = 0.1;
final int PARTICLE_LIFESPAN = 120; // number of frames, we are displaying 60 frames per second
// this parameter is multiplied by each frame and each tracked joint
final int NUMBER_OF_ADDED_PARTICLES = 40;

// -- Physics setup end --

color COLOR_LEFT_PARTICLE_RANGE_START;
color COLOR_LEFT_PARTICLE_RANGE_END;
color COLOR_RIGHT_PARTICLE_RANGE_START;
color COLOR_RIGHT_PARTICLE_RANGE_END;

color COLOR_TOP_LEFT_SPOT_RANGE_START;
color COLOR_TOP_LEFT_SPOT_RANGE_END;
color COLOR_TOP_RIGHT_SPOT_RANGE_START;
color COLOR_TOP_RIGHT_SPOT_RANGE_END;
color COLOR_BOTTOM_LEFT_SPOT_RANGE_START;
color COLOR_BOTTOM_LEFT_SPOT_RANGE_END;
color COLOR_BOTTOM_RIGHT_SPOT_RANGE_START;
color COLOR_BOTTOM_RIGHT_SPOT_RANGE_END;
 //<>// //<>//
SimpleOpenNI  context;

float kinectWidth;
float kinectHeight;
float kinectScale;
PVector kinectOffset; //<>//

PGraphics mixer;
PShader mixerShader;
//PShader particleShader;


PVector spotTopLeft = new PVector();
PVector spotTopRight = new PVector();
PVector spotBottomLeft = new PVector();
PVector spotBottomRight = new PVector();

Personae personae = new Personae(NUMBER_OF_ADDED_PARTICLES);

// sound
Minim minim;
AudioOutput out;
FilePlayer soundLoop;

boolean firstDraw = true;

int effectNo;

void setup() {
  fullScreen(P2D);
  colorMode(HSB, 360, 100, 100);
  //size(1920, 1000, P2D);
  
  setUpController();
  setUpSimpleOpenNI();
  setUpKinect();
  setUpGraphics();
  setUpColors();
  setUpPhysics();
  resetBodyPartPositions();
  setUpSound();
  
  switchEffect(1);
}

void setUpSimpleOpenNI() {
  context = new SimpleOpenNI(this);
  if(context.isInit() == false) {
     println("Can't init SimpleOpenNI, maybe Kinect is not connected!"); 
     exit();
     return;  
  }
  context.setMirror(true);
  context.enableDepth();
  context.enableUser();
}

void setUpKinect() {
  // proportions and aspects
  kinectWidth = context.depthWidth();
  kinectHeight = context.depthHeight();
  kinectScale = float(height) / kinectHeight;
  float screenRatio = float(width) / float(height);
  float kinectRatio = kinectWidth / kinectHeight;
  float mappedKinectWidth = kinectRatio / screenRatio * width;
  float kinectOffsetX = (float(width) - mappedKinectWidth) / 2;
  kinectOffset = new PVector(kinectOffsetX, 0);  
}

void setUpGraphics() {
  noStroke();
  mixerShader = loadShader("mixer.frag");
  //particleShader = loadShader("particle.frag");
}

void setUpSound() {
  minim = new Minim(this);
  out = minim.getLineOut(Minim.STEREO);
  soundLoop = new FilePlayer(minim.loadFileStream(SOUND_LOOP));
  soundLeftHand.init(minim, out);
  soundRightHand.init(minim, out);
  soundSpotTopLeft.init(minim, out);
  soundSpotTopRight.init(minim, out);
  soundSpotBottomLeft.init(minim, out);
  soundSpotBottomRight.init(minim, out);
  
  soundSpotTopLeft.setPan(spotToPan(SPOT_TOP_LEFT));
  soundSpotTopRight.setPan(spotToPan(SPOT_TOP_RIGHT));
  soundSpotBottomLeft.setPan(spotToPan(SPOT_BOTTOM_LEFT));
  soundSpotBottomRight.setPan(spotToPan(SPOT_BOTTOM_RIGHT));

  if (ENABLE_SOUND_LOOP) {
    Gain loopGain = new Gain();
    loopGain.setValue(GAIN_LOOP);
    soundLoop.patch(loopGain).patch(out);
    soundLoop.loop();    
  }
}

float spotToPan(PVector spot) {
  float value = map(spot.x, 0, 100, -1, 1);
  return value;
}

void setUpPhysics() {
  setUpSpot(SPOT_TOP_LEFT, spotTopLeft);
  setUpSpot(SPOT_TOP_RIGHT, spotTopRight);
  setUpSpot(SPOT_BOTTOM_LEFT, spotBottomLeft);
  setUpSpot(SPOT_BOTTOM_RIGHT, spotBottomRight);
}

void setUpSpot(PVector ratio, PVector spot) {
  spot.set(width * ratio.x, height * ratio.y).div(100);
}

void stop() {
  soundLoop.close();
  soundLeftHand.close();
  soundRightHand.close();
  soundSpotTopLeft.close();
  soundSpotTopRight.close();
  soundSpotBottomLeft.close();
  soundSpotBottomRight.close();
  out.close();
}

void draw() {
  
  if (firstDraw) { // annoying bug in Processin which is giving different width and height in setup method
    mixer = createGraphics(width, height, P2D);
    mixer.noStroke();
    mixerShader.set("mixer", mixer);
    firstDraw = false;
    return;
  }

  context.update();

  int[] userList = context.getUsers();
  if (userList.length > 0) { // only if we are tracking someone
    personae.calculateBodyPartPositions();
  }  

  updateMotionBlurFactor();
  updateBackgroundLevel();

  mixer.beginDraw();
  mixer.shader(mixerShader);
  mixer.rect(0, 0, width, height);
  mixer.resetShader();
  mixer.noStroke();

  Persona persona = personae.personaInControl;
  if (persona == null) {
    return;
  } else {
    mixer.circle(persona.leftHand.x, persona.leftHand.y, 10);    
  }

  personae.updateParticles();
  
  mixer.endDraw();

  image(mixer, 0, 0);

  switch (effectNo) {
    case 1: updateEffect1Sound(); break;
    case 2: updateEffect2Sound(); break;
  }
}

void updateEffect1Sound() {
  float leftGain;
  float rightGain;
  Persona persona = personae.personaInControl;
  if (persona == null) {
    return;
  }
  if (ENABLE_CONTROL_VOLUME_WITH_HEAD) {
    leftGain = map(
      persona.head.y,
      height * PROPORTION_HEAD_VOLUME_MIN / 100,
      height * PROPORTION_HEAD_VOLUME_MAX / 100,
      0,
      GAIN_NON_AUDIBLE
    );
    rightGain = leftGain;    
  } else {
    leftGain = map(
      persona.leftHand.y,
      height * PROPORTION_HAND_VOLUME_MIN / 100,
      height * PROPORTION_HAND_VOLUME_MAX / 100,
      0,
      GAIN_NON_AUDIBLE
    );
    rightGain = map(
      persona.rightHand.y,
      height * PROPORTION_HAND_VOLUME_MIN / 100,
      height * PROPORTION_HAND_VOLUME_MAX / 100,
      0,
      GAIN_NON_AUDIBLE
    );    
  }
  soundLeftHand.setGain(leftGain);
  soundRightHand.setGain(rightGain);
  float leftPan = map(persona.leftHand.x, 0, width, -1, 1);
  float rightPan = map(persona.rightHand.x, 0, width, -1, 1);
  soundLeftHand.setPan(leftPan);
  soundRightHand.setPan(rightPan);
}

void updateMotionBlurFactor() {
  if (personae.noOneInControl()) {
    return;
  }
  Persona persona = personae.personaInControl;  
  float motionBlurFactor = map(
    persona.head.y,
    height * PROPORTION_HEAD_MOTION_BLUR_MIN / 100,
    height * PROPORTION_HEAD_MOTION_BLUR_MAX / 100,
    1,
    0
  );
  // TODO what if you don't constrain? What happens with colors?
  motionBlurFactor = constrain(motionBlurFactor, 0, 1);
  mixerShader.set("motionBlurFactor", motionBlurFactor);    
}

void updateEffect2Sound() {
  if (personae.noOneInControl()) {
    return;
  }
  soundSpotTopLeft.setGain(getSpotGain(spotTopLeft));
  soundSpotTopRight.setGain(getSpotGain(spotTopRight));
  soundSpotBottomLeft.setGain(getSpotGain(spotBottomLeft));
  soundSpotBottomRight.setGain(getSpotGain(spotBottomRight));
}

float getSpotGain(PVector spot) {
  Persona persona = personae.personaInControl;
  float value = min(spot.dist(persona.leftHand), spot.dist(persona.rightHand));
  value = map(value, 0, height * .5, 0, -100); // TODO it should be parametrized
  return value;
}

void drawEffect1() {
  for (Persona persona : personae.personae) {
    if (!context.isTrackingSkeleton(persona.personaId)) {
      continue;
    }
    float sat = map(persona.leftHand.y, 0, height, 1, 0);
    sat = map(persona.rightHand.y, 0, height, 1, 0);
  }
}

void clampCoord(PVector coord) {
  coord.x = constrain(coord.x, 0, kinectWidth - 1);
  coord.y = constrain(coord.y, 0, kinectHeight - 1);
  coord.z = 0;
}

void updateBackgroundLevel() {
  Persona persona = personae.personaInControl;
  float backgroundLevel = 0;
  if (persona != null) {
    float left = map(
      persona.leftKnee.y,
      height * PROPORTION_KNEE_ACTION_MIN / 100,
      height * PROPORTION_KNEE_ACTION_MAX / 100,
      0,
      1
    );
    float right = map(
      persona.rightKnee.y,
      height * PROPORTION_KNEE_ACTION_MIN / 100,
      height * PROPORTION_KNEE_ACTION_MAX / 100,
      0,
      1
    );  
    left = constrain(left, 0, 1);
    right = constrain(right, 0, 1);
    backgroundLevel = max(left, right);    
  }
  mixerShader.set("backgroundLevel", backgroundLevel);
}

void resetBodyPartPositions() {
  Persona persona = personae.personaInControl;
  if (persona == null) {
    return;
  }
  float x = float(width) / 2;
  float y = height - 1;
  persona.leftHand.set(x, y);
  persona.rightHand.set(x, y);
  persona.head.set(x, y);
  persona.torso.set(x, y);
  persona.leftKnee.set(x, y);
  persona.rightKnee.set(x, y);
}

color desaturate(color col, float factor) {
  float sat = saturation(col) * factor;
  return color(
    hue(col),
    sat,
    brightness(col)
  );
}

void switchEffect(int effectNo) {
  this.effectNo = effectNo;
  switchEffectSound(effectNo);
}

void switchEffectSound(int effectNo) {
  switch (effectNo) {
    case 1: pauseEffect2Sound(); playEffect1Sound(); break;
    case 2: pauseEffect1Sound(); playEffect2Sound(); break;
  }
}

void pauseEffect1Sound() {
  soundLeftHand.pause();
  soundRightHand.pause();
}

void pauseEffect2Sound() {
  soundSpotTopLeft.pause();
  soundSpotTopRight.pause();
  soundSpotBottomLeft.pause();
  soundSpotBottomRight.pause();
}

void playEffect1Sound() {
  soundLeftHand.play();
  soundRightHand.play();
}

void playEffect2Sound() {
  soundSpotTopLeft.play();
  soundSpotTopRight.play();
  soundSpotBottomLeft.play();
  soundSpotBottomRight.play();
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId) {
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  curContext.startTrackingSkeleton(userId);
  personae.addPersona(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
  personae.removePersona(userId);
}

//void onVisibleUser(SimpleOpenNI curContext, int userId) {
//  println("onVisibleUser - userId: " + userId);
//}

void keyPressed() {
  switch (key) {
    case '1': switchEffect(1); break;
    case '2': switchEffect(2); break;
  }
}
