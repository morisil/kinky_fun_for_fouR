import static SimpleOpenNI.SimpleOpenNI.*;
 
class Persona {
  
  final int personaId;
  
  PVector leftHand = new PVector();
  PVector rightHand = new PVector();
  PVector head = new PVector();
  PVector torso = new PVector();
  PVector leftKnee = new PVector();
  PVector rightKnee = new PVector();
  
 
  int numberOfAddedParticles = 0;

  Persona(int personaId) {
    this.personaId = personaId;
  }
  
  void calculateBodyPartPositions() {
    setBodyPartPosition(SKEL_LEFT_HAND, leftHand);
    setBodyPartPosition(SKEL_RIGHT_HAND, rightHand);
    setBodyPartPosition(SKEL_HEAD, head);
    setBodyPartPosition(SKEL_TORSO, torso);
    setBodyPartPosition(SKEL_LEFT_KNEE, leftKnee);
    setBodyPartPosition(SKEL_RIGHT_KNEE, rightKnee);
  }  
  
  private void setBodyPartPosition(int partId, PVector coord) {
    PVector partRawCoord = new PVector();
    PVector partKinectCoord = new PVector();
    context.getJointPositionSkeleton(personaId, partId, partRawCoord);
    context.convertRealWorldToProjective(partRawCoord, partKinectCoord);
    if (!Float.isNaN(partKinectCoord.x) && !Float.isNaN(partKinectCoord.y)) {
      clampCoord(partKinectCoord);
      coord = coord.set(
        partKinectCoord.mult(kinectScale).add(kinectOffset)
      );     
    }
  }

}
