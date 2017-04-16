import processing.serial.*;
import java.util.Map;

int MAX_COLUMNS = 8;
int MAX_LOG_LINES = 4;
int SERIAL_CHECK_INTERVAL = 1000;
int ACTIVITY_CHECK_INTERVAL = 5000;
int FAKE_NULL_VALUE = 99999; // an arbitrary number outside of 16bit int range

Serial myPort;
int lastActivity = 0;
ArrayList<String> lines = new ArrayList<String>();
ArrayList<int[]> data = new ArrayList<int[]>();
ArrayList<String> comments = new ArrayList<String>();
HashMap<String, String> namedValues = new HashMap<String, String>();

boolean follow = true;
int start = 0;
int scroll = 0;

void consoleLog(String str) {
  println(str);
  lines.add(str);
}

void checkSerial () {
  consoleLog("checking serial...");
  String[] ports = Serial.list();
  printArray(ports);
  if(ports.length == 0) {
    consoleLog("port not found");
    return;
  }
  
  try {
    myPort = new Serial(this, Serial.list()[0], 9600);
  } catch (RuntimeException e) {
    return;
  }
  
  lines = new ArrayList<String>();
  data = new ArrayList<int[]>();
  comments = new ArrayList<String>();
  follow = true;
  start = 0;
  scroll = 0;
  
  consoleLog("connection found");
  myPort.bufferUntil('\n');
}

void setup () {
  size(800, 400);
  noSmooth();
}

void draw () {
  background(40);
  textAlign(LEFT);
  
  int dataSize = data.size() - 1;
  if(follow) {
    start = dataSize - width;
    scroll = start;
  }
  
  if(start < 0) {
    start = 0;
  }
  
  for(int i = start; i < dataSize; i++) {
    int[] thisData = data.get(i);
    int[] nextData = data.get(i+1);
    
    if(thisData[0] % 2 == 0) {
      stroke(45);
      line(
        i - scroll,
        0,
        i - scroll,
        height
      );
    }
    
    for(int j = 1; j < MAX_COLUMNS; j++) {
      if(thisData[j] == FAKE_NULL_VALUE) {
        continue;
      }
      
      if(j == 1) {
        stroke(104, 157, 106);
      } else if(j == 2) {
        stroke(254, 194, 114);
      } else if(j == 3) {
        stroke(251, 74, 51);
      } else if(j == 4) {
        stroke(167, 187, 38);
      }
      
      line(
        i - scroll,
        int(map(float(thisData[j]), 32767, -32768, 10, height - 20)),
        i - scroll,
        int(map(float(nextData[j]), 32767, -32768, 10, height - 20))
      );
    }
  }
  
  int commentsSize = comments.size();
  for(int i = start; i < commentsSize; i++) {
    String comment = comments.get(i);
    if(comment != "") {
      text(comment, i - scroll, 15);
    }
  }
  
  int linesSize = lines.size();
  for(int i = 1; i < 1 + MAX_LOG_LINES; i++) {
    int lineNum = linesSize - i;
    if(lineNum >= 0) {
      int y = height - (15 * i) + 5;
      text(lineNum, 5, y);
      text(lines.get(lineNum).replaceAll("\t", "   "), 80, y);
    }
  }
   
  if(!follow) {
    text("follow off", 5, height - (15 * (MAX_LOG_LINES + 1)) + 5);
  }
   
  textAlign(RIGHT);
  int i = 1;
  for (Map.Entry me : namedValues.entrySet()) {
    text(me.getKey() + ": " + me.getValue(), width - 5, height - (15 * i) + 5);
    i++;
  }

  int ms = millis();
  if(myPort == null) {
    if(ms > lastActivity + SERIAL_CHECK_INTERVAL) {
      lastActivity = ms;
      checkSerial();
    }
  } else {
    if(ms > lastActivity + ACTIVITY_CHECK_INTERVAL) {
      consoleLog("connection lost, stopping port");
      myPort.stop();
      myPort = null;
    }
  }
}


void serialEvent (Serial myPort) {
  lastActivity = millis();
  String inString = myPort.readStringUntil('@');
  if (inString == null) {
    return;
  }
  
  lines.add(inString.replace("@", "").replace("\n", "\t"));
  
  println(inString.replace("@", "").replace("\n", "\t"));
  
  String[] words = split(inString, '\n');
  int[] values = new int[MAX_COLUMNS];
  for(int i = 0; i < MAX_COLUMNS; i++) {
    values[i] = FAKE_NULL_VALUE;
  }
  String comment = "";
  int a = 0;
  for(int i = 0; i < words.length; i++) {
    String trimmed = trim(words[i]);
    
    float floated = float(trimmed);
    if(Float.isNaN(floated)) {
      if(trimmed.length() > 1 && trimmed.charAt(0) == '*') {
        comment += trimmed.substring(1) + "\n";
      }
      if(trimmed.length() > 1 && trimmed.charAt(0) == '(') {
        int nameEndIndex = trimmed.indexOf(')');
        if(nameEndIndex != -1) {
          String name = trimmed.substring(1, nameEndIndex);
          String value = trimmed.substring(nameEndIndex + 1);
          namedValues.put(name, value);
        }
      }
    } else {
      values[a] = int(trimmed);
      a++;
    }
  }
  comments.add(comment);
  data.add(values);
}

void mouseClicked () {
  //follow = !follow;
}