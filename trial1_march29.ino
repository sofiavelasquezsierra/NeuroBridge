#if defined(ARDUINO) && ARDUINO >= 100
#include "Arduino.h"
#else
#include "WProgram.h"
#endif

#include "EMGFilters.h"

#define TIMING_DEBUG 1

#define SensorInputPin1 A0
#define SensorInputPin2 A1

EMGFilters myFilter1;
EMGFilters myFilter2;

int sampleRate = SAMPLE_FREQ_1000HZ;
int humFreq = NOTCH_FREQ_50HZ;

// You may need different thresholds for each sensor
static int Threshold1 = 3500;
static int Threshold2 = 3500;

unsigned long timeStamp;
unsigned long timeBudget;

void setup() {
    myFilter1.init(sampleRate, humFreq, true, true, true);
    myFilter2.init(sampleRate, humFreq, true, true, true);

    Serial.begin(115200);

    timeBudget = 1e6 / sampleRate;
}

void loop() {
    timeStamp = micros();

    // Read both sensors
    int value1 = analogRead(SensorInputPin1);
    int value2 = analogRead(SensorInputPin2);

    // Filter both signals
    int filtered1 = myFilter1.update(value1);
    int filtered2 = myFilter2.update(value2);

    // Envelope for both
    int envelope1 = sq(filtered1);
    int envelope2 = sq(filtered2);

    // Thresholding
    envelope1 = (envelope1 > Threshold1) ? envelope1 : 0;
    envelope2 = (envelope2 > Threshold2) ? envelope2 : 0;

    timeStamp = micros() - timeStamp;

    if (TIMING_DEBUG) {
        // Print both on one line, separated by comma or space
        Serial.print(envelope1);
        Serial.print(",");
        Serial.println(envelope2);
    }

    delayMicroseconds(500);
}
