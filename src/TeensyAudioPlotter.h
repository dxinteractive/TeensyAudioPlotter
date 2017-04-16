/*
 * Audio plotter for Teensy Audio
 * Not yet officially released, will finalise soon.
 * Copyright (c) 2017 Damien Clarke
 * damienclarke.me | github.com/dxinteractive
 */

#ifndef TEENSY_AUDIO_PLOTTER_H
#define TEENSY_AUDIO_PLOTTER_H

#include "analyze_logger.h"
#include "output_stepper.h"

class TeensyAudioPlotter
{
  public:
    static const int MAX_LOGGERS = 8;
    void setStepper(AudioOutputStepper &stepper) { this->stepper = &stepper; }
    void addLogger(AudioAnalyzeLogger &logger);
    void speed(int ms);
    void continuous(bool continuous) { logContinuous = continuous; }
    bool newBlock() { return isNewBlock; }

    void step();
    void done();

  private:
    AudioOutputStepper* stepper;
    AudioAnalyzeLogger* loggers[MAX_LOGGERS];
    int loggersTotal = 0;
    bool logContinuous = true;
    unsigned long ms = 0;
    int msDelay = 2500;
    int msDelayContinuous = 20;
    int sampleNum = 0;
    int blockNum = 0;
    bool isStepping = false;
    bool isNewBlock = false;
};

#endif
