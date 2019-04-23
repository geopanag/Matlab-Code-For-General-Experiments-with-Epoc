Code to run basic experiments based on visual stimuli with emotiv epoc using matlab.
The files produced include the channel and the event timeseries in synchrony, to make up for epoc's occasional variable sampling rate.
The variables of the experiment are defined in Run.m and include:
SeriesTime
TrialTime 
DatasetName
TrainedChannels
SampFreq
Rectime

The stimuli is by default a message for the subject to move Right or Left Arm.
It can be changed to any visual or auditory stimuli, an example given in comments where left and right are substituted with a black and white image.
