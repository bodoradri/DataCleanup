String dataPath = "/Users/hellobodoradri/Documents/ZhDK/3rd semester/2.Physical computing/SensorDataProcessor/";
String inputFile = "8.csv";
String outputFile = "hb_ju.csv";
float pulseTreshold = 555;
float minPulseBPM = 60;
float maxPulseBPM = 95;

void setup () {
  // Open and read input file.
  String[] lines = loadStrings(dataPath + "/" + inputFile);
  float prevPulseTime = -1;
  float prevPulse = pulseTreshold;
  float[] averages = {0, 0, 0, 0, 0};
  float counter = 0;
  // Open output file.
  PrintWriter output = createWriter(dataPath + "/" + outputFile);
  for (int i = 0; i < lines.length; i++) {
    // Split input data line into array of float values.
    float[] columns = float(split(lines[i], ','));
    // Time is the 0. and pulse is the 6. element.
    float time = columns[0];
    float pulse = columns[6];
    counter += 1;
    // Aggregate values excluding the 0. index (time).
    for (int j = 0; j < averages.length; j++) {
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
    float pulseBPM = 60000 / (time - prevPulseTime);
    prevPulseTime = time;
    if (pulseBPM < minPulseBPM || pulseBPM > maxPulseBPM) {
       // Sanity check if pulseBPM is too low or too high.
       continue;
    }
    for (int j = 0; j < averages.length; j++) {
      // Calculate and write averages to file.
      averages[j] /= counter;
      output.print(averages[j]);
      output.write(",");
      averages[j] = 0;
    }
    counter = 0;
    // Write pulseBPM to file.
    output.println(pulseBPM);
  }
  output.flush();
  output.close();
}