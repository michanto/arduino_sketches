const int ledPin = LED_BUILTIN;
const int buttonPin = 2; // Choose a digital pin for the button
bool blinkingEnabled = true; // Start with blinking enabled
bool buttonState;
bool lastButtonState = HIGH; // Initialize to HIGH for pull-up resistor (or LOW for pull-down)
unsigned long lastDebounceTime = 0;
unsigned long debounceDelay = 50;

void setup() {
  pinMode(ledPin, OUTPUT);
  pinMode(buttonPin, INPUT_PULLUP); // Use internal pull-up resistor (or INPUT and external resistor)
}

void loop() {
  int reading = digitalRead(buttonPin);

  if (reading != lastButtonState) {
    lastDebounceTime = millis();
  }

  if ((millis() - lastDebounceTime) > debounceDelay) {
    if (reading != buttonState) {
      buttonState = reading;
      if (buttonState == LOW) { // Button pressed (LOW with pull-up)
        blinkingEnabled = !blinkingEnabled; // Toggle blinking state
      }
    }
  }

  lastButtonState = reading;

  if (blinkingEnabled) {
    digitalWrite(ledPin, HIGH);
    delay(500); // Shorter delay for faster blinking
    digitalWrite(ledPin, LOW);
    delay(500);
  } else {
    digitalWrite(ledPin, LOW); // LED off when blinking is disabled
  }
}