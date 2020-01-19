
int n_bits = 4;
int v_size = (int)pow(2, n_bits);
float state[];
int chosen_val;
int other_val;
float mean;
int n_steps = (int)(sqrt(v_size) * PI / 4) * 2;
int current_step;
float best_diff;
int best_diff_step;

boolean started;
boolean finished;
boolean addOne;

void setup() {
  size(800, 500);
  resetState();

  println("Number of qubits: " + n_bits);
  println("Vector length: " + v_size);

  frameRate(2);
}

void resetState() {
  state = new float[v_size];
  float n = 1 / sqrt(v_size);
  for (int i = 0; i < state.length; i++) {
    state[i] = n;
  }
  mean = n;
  chosen_val = -1;
  started = false;
  finished = false;
  current_step = 0;
  addOne = false;
  best_diff = 0;
  best_diff_step = 0;
}
 
void draw() {
  background(50);
  // Draw the title
  push();
    textAlign(CENTER,CENTER);
    textSize(18);
    text("Grover's Algorithm Visualization",
      width/2,15);
    pop();
  
  // Check if making changes during this draw cycle
  // (step < suggested repetitions or user wants to go again)
  if (started && (!finished || addOne)) {
    if (current_step % 2 == 0) { // Part A: Phase Shift
      state[chosen_val] *= -1;
    } else { // Part B: Invert about the mean
      mean = getMean(state);
      for (int i = 0; i < state.length; i++) {
        state[i] = mean + mean - state[i];
      }
      // Check if the new probability difference is
      // better than previous
      float pdiff = abs(state[chosen_val]*state[chosen_val] - 
      state[other_val]*state[other_val]);
      if (pdiff > best_diff) {
        best_diff = pdiff;
        best_diff_step = current_step;
      }
    }
    // Print the current status
    String stp;
    if (current_step % 2 == 0) stp = "a – Phase Rotation";
    else stp = "b – Invert About the Mean";
    println("Step " + (int)(current_step / 2) + stp);
    System.out.printf(
      "Target (%d) squared magnitude: %.4f\n",
      chosen_val,
      state[chosen_val] * state[chosen_val]
      );
    System.out.printf(
      "Other squared magnitudes:     %.4f\n",
      state[other_val] * state[other_val]);
    if (current_step % 2 == 1) println(); // Linebreak after part b
    
    // Done with suggested repetitions?
    if (current_step > n_steps) finished = true;
    // User adds another step
    if (addOne && (current_step % 2 == 1)) addOne = false;
    // Increment the current step
    current_step++;
  }
  
  if (!started) {
    push();
    textAlign(CENTER,CENTER);
    textSize(18);
    text("Click a Column to Start",
      width/2,height-35);
    pop();
  } else {
    push();
    textAlign(LEFT,CENTER);
    textSize(15);
    // Column 1
    text("Chosen Value: "+chosen_val,10,height-45);
    text("Number of Qubits: "+n_bits,10,height-25);
    // Column 2
    text("Current Steps: "+(current_step/2),195,height-45);
    text("Suggested Repetitions: "+(n_steps/2),195,height-25);
    // Column 3
    float prob_diff = abs(state[chosen_val]*state[chosen_val] - 
      state[other_val]*state[other_val]);
    String fpdiff = String.format(java.util.Locale.US,"%.2f", prob_diff);
    String fmean = String.format(java.util.Locale.US,"%.2f", mean);
    text("Prob Difference: "+fpdiff,400,height-45);
    text("Mean: "+fmean,400,height-25);
    // Column 2
    String fbest_diff = String.format(java.util.Locale.US,"%.2f",best_diff);
    text("Best Difference: "+fbest_diff,600,height-45);
    text("from Step: "+(best_diff_step/2),600,height-25);
    pop();
  }
  
  
  push();
  stroke(200, 100, 250);
  strokeWeight(width / (state.length + 2));
  strokeCap(SQUARE);
  float x, y;
  for (int i = 0; i < state.length; i++) {
    x = map(i+0.5, 0, state.length, 0, width);
    y = mapValue(state[i]); // NOTE: Remember to show the probs, too
    if (i == chosen_val) {
      push();
      stroke(255, 130, 170);
      line(x, mapValue(0), x, y);
      pop();
    } else {
      line(x, mapValue(0), x, y);
    }
  }
  pop();

  // Draw lines at y = 0, 1, -1
  noFill();
  stroke(255, 100);
  strokeWeight(1);
  line(0, height/2, width, height/2);
  line(0, mapValue(1), width, mapValue(1));
  line(0, mapValue(-1), width, mapValue(-1));
  
  // Draw the mean
  float mapped_mean = mapValue(mean);
  dottedLine(0, mapped_mean, width, mapped_mean, 100);
  
  // Draw the text
  textSize((int)map(n_bits,2,5,12,8));
  textAlign(CENTER);
  for (int i = 0; i < state.length; i++) {
    text(
      bInt(i,n_bits),
      map(i+0.5,0,state.length,0,width), // x value
      mapValue(1) - 17  // y value
    );
    text(
      nf(state[i] * state[i],1,2),
      map(i+0.5,0,state.length,0,width), // x value
      mapValue(1) - 5  // y value
    );
  }
}

void mousePressed() {
  if (!started) {
    started = true;
    float chunks = width / state.length;
    chosen_val = (int)(mouseX / chunks);
    if (chosen_val == 0) other_val = 1;
    else other_val = 0;
    println("Chosen value: " + chosen_val);
    println();
  } else if (finished) {
    //println("\n\nResetting...\n");
    //resetState();
    addOne = true;
  }
}

void dottedLine(float x0, float y0, float x1, float y1, float n_dots) {
  float x, y, i;
  float radius = 1;
  noStroke();
  fill(255);
  for (i = 0; i < n_dots; i++) {
    x = map(i, 0, n_dots, x0, x1);
    y = map(i, 0, n_dots, y0, y1);
    ellipse(x, y, radius, radius);
  }
}

float mapValue(float n) {
  float h = height * 0.75;
  float half_h = h / 2;
  return map(
    n, 
    -1, 1, 
    height/2 + half_h, 
    height/2 - half_h
    );
}

float getMean(float arr[]) {
  float total = 0;
  for (float v : arr) {
    total += v;
  }
  return total / arr.length;
}

String bInt(int i, int len) {
  String s = Integer.toBinaryString(i);
  while (s.length() < len) {
    s = '0' + s;
  }
  return s;
}
