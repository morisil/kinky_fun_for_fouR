class Personae {

  List<Persona> personae = new ArrayList();

  final int numberOfAddedParticles;

  Persona personaInControl;

  Personae(int numberOfAddedParticles) {
    this.numberOfAddedParticles = numberOfAddedParticles;
  }

  boolean noOneInControl() {
    return personaInControl == null;
  }

  void addPersona(int personaId) {
    Persona persona = new Persona(personaId);
    personae.add(persona);
    personaInControl = persona;
    balanceParticles();
  }
  
  void removePersona(int personaId) {
    for (Iterator<Persona> iter = personae.iterator(); iter.hasNext();) {
      Persona persona = iter.next();
      if (persona.personaId == personaId) {
        iter.remove();
        break;
      }
    }
    if (personae.isEmpty()) {
      personaInControl = null;
    }
    balanceParticles();
  }

  void calculateBodyPartPositions() {
    for (Persona persona : personae) {
      persona.calculateBodyPartPositions();
    }
  }

  void updateParticles() {
    for (Persona persona : personae) {
      if (context.isTrackingSkeleton(persona.personaId)) {
        personaInControl = persona;
      }
    }    
  }

  private void balanceParticles() {
    int particleCountPerPersona = numberOfAddedParticles / personae.size();
    for (Persona persona : personae) {
      persona.numberOfAddedParticles = particleCountPerPersona;
    }
  }

}
