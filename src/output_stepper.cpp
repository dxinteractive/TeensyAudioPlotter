/*
 * Audio plotter for Teensy Audio
 * Not yet officially released, will finalise soon.
 * Copyright (c) 2017 Damien Clarke
 * damienclarke.me | github.com/dxinteractive
 */

#include "output_stepper.h"

bool AudioOutputStepper::update_responsibility = false;

void AudioOutputStepper::begin(void)
{
  update_responsibility = update_setup();
}

void AudioOutputStepper::step(void)
{
  if (AudioOutputStepper::update_responsibility) {
    AudioStream::update_all();
  }
}
