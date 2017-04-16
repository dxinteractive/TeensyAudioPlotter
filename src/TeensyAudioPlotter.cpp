/*
 * Audio plotter for Teensy Audio
 * Not yet officially released, will finalise soon.
 * Copyright (c) 2017 Damien Clarke
 * damienclarke.me | github.com/dxinteractive
 */

#include "TeensyAudioPlotter.h"
#include "analyze_logger.h"
#include "output_stepper.h"

void TeensyAudioPlotter::addLogger(AudioAnalyzeLogger &logger)
{
  if(loggersTotal >= TeensyAudioPlotter::MAX_LOGGERS) {
    return;
  }
  loggers[loggersTotal] = &logger;
  loggersTotal++;
}

void TeensyAudioPlotter::speed(int ms) {
  msDelay = ms;
  msDelayContinuous = ms / AUDIO_BLOCK_SAMPLES;
}

void TeensyAudioPlotter::step()
{
  isStepping = false;
  isNewBlock = false;
  unsigned long currentMs = millis();
  unsigned long intervalMs = logContinuous ? msDelayContinuous : msDelay;
  if(currentMs - ms < intervalMs) {
    return;
  }
  ms = currentMs;
  isStepping = true;

	if(sampleNum == 0) {
    isNewBlock = true;
    Serial.print("*block ");
    Serial.println(blockNum);
    stepper->step();
  }

  Serial.println(blockNum);

  for(int i = 0; i < loggersTotal; i++) {
    Serial.println(loggers[i]->lastBlock[sampleNum]);
  }
}

void TeensyAudioPlotter::done()
{
  if(!isStepping) return;

  Serial.print("@");

  sampleNum++;
  if(sampleNum >= AUDIO_BLOCK_SAMPLES) {
    sampleNum = 0;
    blockNum++;
  }
}
