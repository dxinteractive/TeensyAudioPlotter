# TeensyAudioPlotter

Plots Teensy Audio input and output values in a streaming graph. Audio is not processed in real time, instead it is stepped through very slowly sample by sample, block by block so the plot can be analyzed as it runs. For this reason it won't work with live input audio, but using something predictable like `synth_waveform` will probably be better anyway.

**Not officially "released" yet!** Very loose right now, but you're welcome to use it.

![Waveshaper input vs output](https://github.com/dxinteractive/TeensyAudioWaveshaper/blob/master/docs/example2.gif)

It consists of 4 main parts:
- C++
  - TeensyAudioPlotter
  - AudioAnalyzeLogger
  - AudioOutputStepper
- Java / Processing executable
  - Plotter GUI

### 1. TeensyAudioPlotter

C++ class. This is the main object used to control plotting. It provides simulation controls and outputs data via `Serial` for the plotter GUI to consume.

#### `void step()`

Call this once at the start of each loop to step to the next sample.

#### `void done()`

Call this once at the end of each loop to mark the current loop as complete and send the data through `Serial`.
#### `void setStepper(AudioOutputStepper &stepper)`

Adds a stepper to this `plotter`, and subsequently controls it

#### `void addLogger(AudioAnalyzeLogger &logger);`

Adds a `logger`. Up to 8 may be added.

#### `void speed(int ms);`

Sets the speed of the simulation, the length of time in milliseconds it'll take to step through one block of audio.

#### `bool newBlock()`

Returns true for one cycle when a new block has begun being processed.

### 2. AudioAnalyzeLogger

C++ class. An Audio effect that simply logs out values via `Serial`. Add these in your effects chain at the points where you want to plot the values.

### 3. AudioOutputStepper

C++ class. An Audio effect to use as the output of the audio chain.

### 4. Plotter GUI

Java / Processing executable. A graphical plotter hastily written in Processing. Plots one line per `logger`, and displays block boundaries, raw `Serial` data and timestamped `Serial` data.

You'll need Processing to dev this, or if you have Windows and Java 8 you can run one of the exported executables.

## Guidelines for Serial output

Plotter GUI expects a very specific Serial output in order to work, most of which is provided automatically by `TeensyAudioPlotter`. Each step it consumes all `Serial` output since the last step, and splits it on new lines, so each call to `Serial.println()` will be treated as a separate item.

- Items which are numbers will be treated as through they are audio values and will be plotted on the graph
- Items which begin with a `*` character will be timestamped. Timestamped items will be rendered on the graph itself at the point in time that they are output.
- Items which are in brackets followed by a value (like `Serial.println("(key) value");`) will be treated as "named values". These appear on the right and do not disappear like normal `Serial` output, but instead each value persists on screen until it is updated at a later point in time.
- The `@` character should not be used in any `Serial.print()` or `Serial.println()` calls! (10 points if you can guess why)


## Example usage

```c++
#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>
#include <TeensyAudioPlotter.h>
#include "your_effect.h"

AudioSynthWaveform waveform;
AudioAnalyzeLogger dryLogger;
AudioEffectYourEffect yourEffect;
AudioAnalyzeLogger wetLogger;
AudioOutputStepper stepper;

AudioConnection patchCord1(waveform, 0, dryLogger, 0);
AudioConnection patchCord2(dryLogger, 0, yourEffect, 0);
AudioConnection patchCord3(yourEffect, 0, wetLogger, 0);
AudioConnection patchCord4(wetLogger, 0, stepper, 0);

TeensyAudioPlotter plotter;

void setup() {
  Serial.begin(9600);
  AudioMemory(40);

  plotter.setStepper(stepper);
  plotter.addLogger(dryLogger);
  plotter.addLogger(wetLogger);

  waveform.begin(1.0, 200.0, WAVEFORM_SINE);
  yourEffect.doSomething(true);
}

void loop() {
  plotter.step();
  if(plotter.newBlock()) {
    // the actual processorUsage() call may or may not be accurate
    // this is just an example of logging arbitrary data when a new audio block is processed
    Serial.print("(processorUsage)");
    Serial.println(yourEffect.processorUsage());
  }
  plotter.done();
}

```
