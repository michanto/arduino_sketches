const int ledPin = LED_BUILTIN;
bool blinkingEnabled = false;

void setup() {
  pinMode(ledPin, OUTPUT);
  Serial.begin(9600); // Initialize serial communication at 9600 baud
}

void loop() {
  if (Serial.available() > 0) {
    char command = Serial.read();
    if (command == '1') {
      blinkingEnabled = true;
    } else if (command == '0') {
      blinkingEnabled = false;
      digitalWrite(ledPin, LOW); // Turn LED off immediately
    }
  }

  if (blinkingEnabled) {
    digitalWrite(ledPin, HIGH);
    delay(500);
    digitalWrite(ledPin, LOW);
    delay(500);
  }
}