/*
 * Audio plotter for Teensy Audio
 * Not yet officially released, will finalise soon.
 * Copyright (c) 2017 Damien Clarke
 * damienclarke.me | github.com/dxinteractive
 */

#ifndef output_stepper_h_
#define output_stepper_h_

#include "Arduino.h"
#include "AudioStream.h"

class AudioOutputStepper : public AudioStream
{
  public:
    AudioOutputStepper(void) : AudioStream(1, inputQueueArray) { begin(); }
    virtual void update(void) {}
    void step(void);
  private:
    audio_block_t *inputQueueArray[1];
    void begin(void);
    static bool update_responsibility;
};

#endif
