// Motor Control Pins
int in1 = 8;
int in2 = 9;
int ena = 5;
int in3 = 10;
int in4 = 11;
int enb = 6;

void setup() {
  Serial.begin(9600);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  pinMode(ena, OUTPUT);
  pinMode(in3, OUTPUT);
  pinMode(in4, OUTPUT);
  pinMode(enb, OUTPUT);
  // Stop motors initially
  analogWrite(ena, 0);
  analogWrite(enb, 0);
}

void loop() {
  if (Serial.available() >= 2) { // Ensure at least 2 bytes are available
    char command = Serial.read();
    char speedChar = Serial.read();
    int speed = (speedChar - '0') * 25; // Scale to PWM (0-255)

    if (command == 'F') {
      // Forward
      digitalWrite(in1, HIGH);
      digitalWrite(in2, LOW);
      digitalWrite(in3, HIGH);
      digitalWrite(in4, LOW);
      analogWrite(ena, speed);
      analogWrite(enb, speed);
    } else if (command == 'B') {
      // Backward
      digitalWrite(in1, LOW);
      digitalWrite(in2, HIGH);
      digitalWrite(in3, LOW);
      digitalWrite(in4, HIGH);
      analogWrite(ena, speed);
      analogWrite(enb, speed);
    } else if (command == 'L') {
      // Left
      digitalWrite(in1, LOW);
      digitalWrite(in2, HIGH);
      digitalWrite(in3, HIGH);
      digitalWrite(in4, LOW);
      analogWrite(ena, speed);
      analogWrite(enb, speed);
    } else if (command == 'R') {
      // Right
      digitalWrite(in1, HIGH);
      digitalWrite(in2, LOW);
      digitalWrite(in3, LOW);
      digitalWrite(in4, HIGH);
      analogWrite(ena, speed);
      analogWrite(enb, speed);
    } else if (command == 'S') {
      // Stop
      analogWrite(ena, 0);
      analogWrite(enb, 0);
    }
  }
}