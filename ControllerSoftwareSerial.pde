import processing.serial.*;
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.MouseInfo;
import java.awt.event.KeyEvent;
import java.awt.event.InputEvent;
import javax.swing.KeyStroke;
import java.awt.Point;

Serial MyPort;
// The COM Port to listen for incoming data
String COM_PORT = "COM4";
int BAUD_RATE = 115_200;
//Robot robot;
Robot robot;

void setup() {
    // Create a new Serial object listening at COM_PORT with baudrate BAUD_RATE
    MyPort = new Serial(this, COM_PORT, BAUD_RATE);
    MyPort.bufferUntil('\n');
    //robot = new Robot();
    try {
      robot = new Robot();
    } catch (AWTException e) {
      e.printStackTrace();
    }
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
      
        // Call the respective functions that use the data to perform the actions
        handleRightJoystick(robot, serialData);
        
        pressButtons(robot, serialData[0] + serialData[1]);
        
        handleLeftJoystick(robot, serialData);
        
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
void pressButtons(Robot robot, String KeyString) {
    println(KeyString);
    // Look at each bit of the button byte and press or release according to bit value
    for (int i = 0; i < KeyString.length(); i++) {
        boolean On = KeyString.charAt(i) == '1';
        switch (i) {
            case 0:
                setKeyAs(KeyEvent.VK_UP, On, robot);
                break; 
            case 1:
                setKeyAs(KeyEvent.VK_RIGHT, On, robot);
                break; 
            case 2:
                setKeyAs(KeyEvent.VK_DOWN, On, robot);
                break; 
            case 3:
                setKeyAs(KeyEvent.VK_LEFT, On, robot);
                break; 
            case 4:
                setKeyAs(KeyEvent.VK_Z, On, robot);
                break; 
            case 5:
                setKeyAs(KeyEvent.VK_X, On, robot);
                break; 
            case 6:
                setKeyAs(KeyEvent.VK_C, On, robot);
                break; 
            case 7:
                setKeyAs(KeyEvent.VK_V, On, robot);
                break; 
        }
    }
}

/**
Simulates mouse movement from incoming data of a joystick
*/
void handleRightJoystick(Robot robot, String[] serialData) {
    // Get x, y and switchPressed
    String[] leftAnalogValues = serialData[3].split("\\|", 0);
    
    // Parse the x and y values, and invert their signs
    int ly = (Integer.parseInt(leftAnalogValues[0])) * -1;
    int lx = (Integer.parseInt(leftAnalogValues[1])) * -1;
    // convert string switchpressed value to booleanee
    
    boolean rightSwitchPressed = leftAnalogValues[2].trim().substring(0, 1).equals("1");
    
    // Get the curreeent x, y location of the mouse 
    Point mouse = MouseInfo.getPointerInfo().getLocation();
    int curX = mouse.x;
    int curY = mouse.y;
    
    // As long as the joystick was moved, move the mouse
    if (lx != 0 || ly != 0) robot.mouseMove(curX + lx, curY - ly);

    // Press or release left mouse button. NOTE: Broken
    setKeyAs(KeyEvent.VK_E, rightSwitchPressed, robot);
}

/**
Simulates a dpad from incoming data from right joystick
*/
void handleLeftJoystick(Robot robot, String[] serialData) {
    // Split data into x, y and switchpressed
    String[] rightAnalogValues = serialData[2].split("\\|", 0);
    
    // invert signs and parse to int
    int ry = (Integer.parseInt(rightAnalogValues[0])) * -1;
    int rx = (Integer.parseInt(rightAnalogValues[1])) * -1;
    
    // convert to bool
    boolean leftSwitchPressed = rightAnalogValues[2].equals("1");
    boolean onRight = rx > 0;
    
    // As long as joystick was moved...
    if ((rx != 0 || ry != 0)) {
        // Convert analog value to digital and press or release arrow keys
        if (rx > 0) { setKeyAs(KeyEvent.VK_RIGHT, rx > 0, robot); }
        if (rx < 0) { setKeyAs(KeyEvent.VK_LEFT, rx < 0, robot); }
        if (ry > 0) { setKeyAs(KeyEvent.VK_UP, ry > 0, robot); }
        if (ry < 0) { setKeyAs(KeyEvent.VK_DOWN, ry < 0, robot); }
        //setKeyAs(KeyEvent.VK_RIGHT, rx > 0, robot);
        //setKeyAs(KeyEvent.VK_LEFT, rx < 0, robot);
        //setKeyAs(KeyEvent.VK_UP, ry > 0, robot);
        //setKeyAs(KeyEvent.VK_DOWN, ry < 0, robot);
    }
 
    // Press or release right mouse button. NOTE: Broken
    setKeyAs(KeyEvent.VK_Q, leftSwitchPressed, robot);
}
