/* Internet Volume Knob
 * powered by a potentiometer, update an adafruit feed.
 * 
 * Marc Dougherty <muncus@gmail.com>
 * 
 */

// Include per-instance config
// be sure to #define MY_AIO_KEY in here.
// also AIO_FEED_KEY
// AIO_USER
#include "config.h"

// Server address/port.
const char* SERVER_ADDR = "io.adafruit.com";
const int SERVER_PORT = 80;

TCPClient client;

// minimum delta to be considered 'significant'. out of 4k.
const int analog_epsilon = 10;

// last value read from potentiometer.
int last_reading = 0;
unsigned long last_report = 0;
const int PIN_POT = A0;

bool should_report = false;

void setup(){
  Serial.begin(9600);

  pinMode(PIN_POT, INPUT_PULLDOWN);
}

void loop(){

  int reading = analogRead(PIN_POT);
  Serial.printlnf("reading: %d", reading);
  // full range is 0-4096, but we leave a little slack.
  //Serial.printlnf("Volume: %d", vol);
  // we've moved.
  delay(30);
  if(abs(reading-analogRead(PIN_POT)) > analog_epsilon){
    Serial.println("moved!");
    reading = analogRead(PIN_POT);
    should_report = true;
  }
  else {
    Serial.print(".");
    //not moved.
    // want to only report when we've stopped moving.
    if(should_report && (millis() - last_report) > 2000){
      int vol = map(reading, 0, 4090, 0, 10);
      Serial.printlnf("Setting volume: %d", vol);
      //position has changed
      updateAdafruitData(AIO_FEED_KEY, vol);
      last_report = millis();
      should_report = false;
    }
  }
  last_reading = reading;
  delay(100);
}

int updateAdafruitData(String feed_key, int value){
  if(!client.connect(SERVER_ADDR, SERVER_PORT)){
    Serial.println("connect failure");
    return -1;
  }
  String body = " { \"value\": " + String(value) + " }";
  client.println("POST /api/feeds/" + feed_key + "/data HTTP/1.0");
  client.println("Host: " + String(SERVER_ADDR));
  //client.println("Connection: close");
  client.println("Content-type: application/json");
  client.println("x-aio-key: " + String(MY_AIO_KEY));
  client.println("Accept: */*");
  client.println("User-Agent: particle/1.0");
  client.println("Content-Length: " + String(body.length()));
  client.println();
  client.println(body);
  client.println();
  delay(600);
  while (client.available() > 0){
    Serial.print((char)client.read());
  }
  // Just throw away the result.
  client.stop();
  return 1;
}

