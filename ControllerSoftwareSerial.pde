import processing.serial.*;
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.Point;
import java.awt.MouseInfo;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import javax.swing.KeyStroke;

Serial MyPort;
// The COM Port to listen for incoming data
String COM_PORT = "COM4";
int BAUD_RATE = 115_200;

void setup() {
    // Create a new Serial object listening at COM_PORT with baudrate BAUD_RATE
    MyPort = new Serial(this, COM_PORT, BAUD_RATE);
    MyPort.bufferUntil('\n');
    
    // Hide the window created. TODO: Remappable Buttons GUI
    //surface.setLocation(-200,-200);
    //surface.setVisible(false);
}

void draw() {
    background(0);
}

void serialEvent(Serial MyPort) throws Exception {
    try {
        // Split data into arrpwkeys, buttons, leftjoystick and rightjoystick
        String[] serialData = MyPort.readStringUntil('\n').split(":", 0);
      
        // Create a new Robot object
        Robot Arduino = new Robot();
      
        // Call the respective functions that use the data to perform the actions
        handleRightJoystick(Arduino, serialData);
        handleLeftJoystick(Arduino, serialData);
        pressButtons(Arduino, serialData[0] + serialData[1]);
        
    } catch (RuntimeException e) {
        e.printStackTrace();
    }
}

/**
Either presses a `key` or releases it, depending on `state` via Robot `r`
*/
void setKeyAs(int key, boolean state, Robot r) {
    if (state) r.keyPress(key);
    else r.keyRelease(key);
}

/**
Matches a button byte and presses and release the correct buttons
*/
void pressButtons(Robot Arduino, String KeyString) {
    // Look at each bit of the button byte and press or release according to bit value
    for (int i = 0; i < KeyString.length(); i++) {
        boolean On = KeyString.charAt(i) == '1';
        switch (i) {
            case 0:
                setKeyAs(KeyEvent.VK_UP, On, Arduino);
                break; 
            case 1:
                setKeyAs(KeyEvent.VK_RIGHT, On, Arduino);
                break; 
            case 2:
                setKeyAs(KeyEvent.VK_DOWN, On, Arduino);
                break; 
            case 3:
                setKeyAs(KeyEvent.VK_LEFT, On, Arduino);
                break; 
            case 4:
                setKeyAs(KeyEvent.VK_Z, On, Arduino);
                break; 
            case 5:
                setKeyAs(KeyEvent.VK_X, On, Arduino);
                break; 
            case 6:
                setKeyAs(KeyEvent.VK_C, On, Arduino);
                break; 
            case 7:
                setKeyAs(KeyEvent.VK_V, On, Arduino);
                break; 
        }
    }
}

/**
Simulates mouse movement from incoming data of a joystick
*/
void handleLeftJoystick(Robot Arduino, String[] serialData) {
    // Get x, y and switchPressed
    String[] leftAnalogValues = serialData[2].split("\\|", 0);
    
    // Parse the x and y values, and invert their signs
    int ly = (Integer.parseInt(leftAnalogValues[0])) * -1;
    int lx = (Integer.parseInt(leftAnalogValues[1])) * -1;
    // convert string switchpressed value to boolean
    boolean leftSwitchPressed = leftAnalogValues[2] == "1";
    
    // Get the current x, y location of the mouse 
    Point mouse = MouseInfo.getPointerInfo().getLocation();
    int curX = mouse.x;
    int curY = mouse.y;
    
    // As long as the joystick was moved, move the mouse
    if (lx != 0 || ly != 0) Arduino.mouseMove(curX + lx, curY - ly);
    
    // Press or release left mouse button. NOTE: Broken
    if (leftSwitchPressed) Arduino.mousePress(InputEvent.BUTTON1_DOWN_MASK);
    else Arduino.mouseRelease(InputEvent.BUTTON1_DOWN_MASK);
}

/**
Simulates a dpad from incoming data from right joystick
*/
void handleRightJoystick(Robot Arduino, String[] serialData) {
    // Split data into x, y and switchpressed
    String[] rightAnalogValues = serialData[3].split("\\|", 0);
    
    // invert signs and parse to int
    int ry = (Integer.parseInt(rightAnalogValues[0])) * -1;
    int rx = (Integer.parseInt(rightAnalogValues[1])) * -1;
    // convert to bool
    boolean rightSwitchPressed = rightAnalogValues[2] == "1";
    
    // As long as joystick was moved...
    if (rx != 0 || ry != 0) {
        // Convert analog value to digital and press or release arrow keys
        if (rx > 0) Arduino.keyPress(KeyEvent.VK_RIGHT);
        else Arduino.keyRelease(KeyEvent.VK_RIGHT);
      
        if (rx < 0) Arduino.keyPress(KeyEvent.VK_LEFT);
        else Arduino.keyRelease(KeyEvent.VK_LEFT);
      
        if (ry > 0) Arduino.keyPress(KeyEvent.VK_UP);
        else Arduino.keyRelease(KeyEvent.VK_UP);
      
        if (ry < 0) Arduino.keyPress(KeyEvent.VK_DOWN);
        else Arduino.keyRelease(KeyEvent.VK_DOWN);
    }
 
    // Press or release right mouse button. NOTE: Broken
    if (rightSwitchPressed) Arduino.mousePress(InputEvent.BUTTON2_DOWN_MASK);
    else Arduino.mouseRelease(InputEvent.BUTTON2_DOWN_MASK);
}
