// Define the LED pin (usually pin 13 on most Arduinos)
const int ledPin = LED_BUILTIN; // Use LED_BUILTIN for portability

void setup() {
  // Initialize the LED pin as an output
  pinMode(ledPin, OUTPUT);
}

void loop() {
  // Turn the LED on
  digitalWrite(ledPin, HIGH);

  // Wait for 1 second (1000 milliseconds)
  delay(1000);

  // Turn the LED off
  digitalWrite(ledPin, LOW);

  // Wait for 1 second
  delay(1000);
}