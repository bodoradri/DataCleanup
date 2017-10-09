String dataPath = "/Users/hellobodoradri/Documents/Arduino";
String inputFile = "input.csv";
String outputFile = "output.csv";
float pulseTreshold = 555;
float minPulseBPM = 50;
float maxPulseBPM = 100;

void setup () {
  // Open and read input file.
  String[] lines = loadStrings(dataPath + "/" + inputFile);
  float prevPulseTime = -1;
  float prevPulse = pulseTreshold;
  float[] averages = new float[5];
  float counter;
  // Open output file.
  output = createWriter(dataPath + outputFile);
  for (int i = 0; i < lines.length; i++) {
    // Split input data line into array of float values.
    float[] columns = float(split(lines[i], ','));
    // Time is the 0. and pulse is the 6. element.
    float time = columns[0];
    float pulse = columns[6];
    counter += 1;
    // Aggregate values excluding the 0. index (time).
    for (int j = 0; j < averages.length(); j++) {
      averages[j] += columns[j + 1];
    }
    if (prevPulse >= pulseTreshold || pulse < pulseTreshold) {
      // No treshold "crossing", no heartbeat.
      prevPulse = pulse;
      continue;
    }
    prevPulse = pulse;
    if (prevPulseTime < 0) {
      // This is the first heartbeat, can't calculate BPM yet.
      prevPulseTime = time;
      continue;
    }
    prevPulseTime = time;
    float pulseBPM = 60000 / (time - prevPulseTime);
    if (pulseBPM < minPulseBPM || pulseBPM > maxPulseBPM) {
       // Sanity check if pulseBPM is too low or too high.
       continue;
    }
    for (int j = 0; j < averages.length(); j++) {
      // Calculate and write averages to file.
      averages[j] /= counter;
      output.write(averages[j]);
      output.write(",");
      averages[j] = 0;
    }
    counter = 0;
    // Write pulseBPM to file.
    output.writeln(pulseBPM);
  }
}
