#include <ezButton.h>
#include <Arduino.h>
#include <Wire.h>
#include <SoftwareSerial.h>

// The amount of buttons onboard the arduino
double iButtonAmount = 8;
// A string containing and organized set of state for each button / joystick
String sPressData;
// The pins connected to the buttons
ezButton buttons[8] = {
    ezButton(9), ezButton(8),
    ezButton(7), ezButton(6),
    ezButton(5), ezButton(4),
    ezButton(3), ezButton(2)  
};
// The pins connected to the joystick's builtin buttons. Laid out as: LS, RS
int switchPins[2] = {11, 12};
// The pins that receive the x,y data from each joystick. Laid out as: LX, LY, RX, RY
int grid[4] = {A1, A0, A5, A4};
// The maximum the mouse can move at a time
int range = 40;
// Mouse stuff
int threshold = range / 4;
int center  = range / 2;


void setup(){
    // Connect to the serial port
    Serial.begin(115200);

    // Set the switch pins as input with internal resistors on
    for (int i = 0; i < 2; i++)
    {
        pinMode(switchPins[i], INPUT_PULLUP);
    }
    // Set the grid pins as input
    for (int n = 0; n < 4; n++)
    {
        pinMode(grid[n], INPUT);
    }
}

void loop(){
    // Allow ezButton to read button data
    for (int i = 0; i < iButtonAmount; i++)
        buttons[i].loop();

    // Get the button data in the form: DOWNRIGHTUPLEFT:ZXCV:
    sPressData = "";
    for (int i = 0; i < iButtonAmount; i++)
    {
        if (i == iButtonAmount / 2)
            sPressData += ":";
        sPressData = sPressData + String(buttons[i].getState() == 1? 0: 1);
    }
    sPressData += ":";

    // Get the joystick data in the form: X|Y|S:X|Y|S and append to sPressData
    sPressData += String(readAxis(grid[0])) + "|" + String(readAxis(grid[1])) + "|" + String(digitalRead(switchPins[0]) == 1? 0: 1);
    sPressData += ":";
    sPressData += String(readAxis(grid[2])) + "|" + String(readAxis(grid[3])) + "|" + String(digitalRead(switchPins[1]) == 1? 0: 1);

    // Send the state of all buttons 
    Serial.println(sPressData);
    
    // 100 is the fastest a human can press a button. This delay accurately determines how long was a button pressed
    // It allows for the software serial to keep a button pressed for exactly the same time as the physical key is pressed
    // plus minus latency.
    delay(100);
}

int readAxis(int thisAxis) {
  // read the analog input:
  int reading = analogRead(thisAxis);

  // map the reading from the analog input range to the output range:
  reading = map(reading, 0, 1023, 0, range);

  // if the output reading is outside from the rest position threshold, use it:
  int distance = reading - center;

  if (abs(distance) < threshold) {
    distance = 0;
  }

  // return the distance for this axis:
  return distance;
}
