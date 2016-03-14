
SeriesTime=200; %Total duration of the Series of trials
TrialTime = 5;%Duration of each Trial
DatasetName='C:/Users/Giwrgos/Dropbox/BCI/data/Moving/grasp'; %File to Store the Outcome
TrainedChannels=4:17;   %The channels used for training
SampFreq=128; %Epoc sampling 
Rectime = 1;  %buffer data size (in sec)

%half messages 1 (right), the other half -1 (left)
Messages=[repmat(1,SeriesTime/(TrialTime*2),1);repmat(-1,SeriesTime/(TrialTime*2),1)];
Messages= Messages(randperm(length(Messages)));

[EegMatrix Events nS] = Experiment(SeriesTime,TrialTime,TrainedChannels,Messages,SampFreq,Rectime);


csvwrite(strcat(DatasetName,'.csv'),horzcat(EegMatrix,Events));

