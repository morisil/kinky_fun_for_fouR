class SpatialSound {
  
  String file;
  FilePlayer player;
  float minGain;
  float maxGain;
  Gain gain;
  Pan pan = new Pan(0);

  SpatialSound(String file, float minGain, float maxGain) {
    this.file = file;
    this.minGain = minGain;
    this.maxGain = maxGain;
    gain = new Gain(minGain); // we are starting quiet
  }

  void init(Minim minim, AudioOutput out) {
    player = new FilePlayer(minim.loadFileStream(file));
    player.patch(gain).patch(pan).patch(out);
    player.loop();
  }

  void play() {
    player.loop();
  }

  void pause() {
    player.pause();
  }

  void setPan(float value) {
    value = constrain(value, -1, 1);
    pan.setPan(value);
  }

  void setGain(float value) {
    float mapped = map(value, -100, 0, minGain, maxGain);
    mapped = constrain(mapped, -100, 0);
    gain.setValue(mapped);
  }

  void close() {
    player.close();
  }
  
}
