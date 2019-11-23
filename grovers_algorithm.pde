
int n_bits = 4;
int v_size = (int)pow(2, n_bits);
float state[];
int chosen_val;
float mean;
int n_steps = (int)(sqrt(v_size) * PI / 4) * 2;
int current_step;

boolean started;
boolean finished;

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
  
  //noLoop();
  //redraw();
}

void draw() {
  background(50);

  if (started && current_step < n_steps) {
    if ((current_step & 1) == 0) { // Phase Shift
      state[chosen_val] *= -1;
    } else { // Invert about the mean
      mean = getMean(state);
      for (int i = 0; i < state.length; i++) {
        state[i] = mean + mean - state[i];
      }
    }
    // Print the current status
    char stp;
    if (current_step % 2 == 0) stp = 'a';
    else stp = 'b';
    println("Step " + (int)(current_step / 2) + stp);
    int i;
    if (chosen_val == 0) i = 1;
    else i = 0;
    System.out.printf(
      "Target (%d) squared magnitude: %.4f\n",
      chosen_val,
      state[chosen_val] * state[chosen_val]
      );
    System.out.printf(
      "Other squared magnitudes:     %.4f\n",
      state[i] * state[i]
      );
    if (current_step % 2 == 0) println();


    // Increment the step
    current_step++;
  }

  // Draw the magnitudes
  //float x_start = width * 0.05;
  //float x_end = width - x_start;
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
      mapValue(1) - 20  // y value
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
    println("Chosen value: " + chosen_val);
    println();
    //loop();
  //} else if (finished) {
  } else {
    println("\n\nResetting...\n");
    resetState();
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
