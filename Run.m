
SeriesTime=30; %Total duration of the Series of trials
TrialTime = 5;%Duration of each Trial
DatasetName='data'; %File to Store the Outcome
TrainedChannels=3:16;   %The channels used for training
SampFreq=128; %Epoc sampling 
Rectime = 1;  %buffer data size (in sec)

%half messages 1 (right), the other half -1 (left)
Messages=[repmat(1,SeriesTime/(TrialTime*2),1);repmat(-1,SeriesTime/(TrialTime*2),1)];
Messages= Messages(randperm(length(Messages)));

[Header EegMatrix Events Timepoint nS]  = Experiment(SeriesTime,TrialTime,TrainedChannels,Messages,SampFreq,Rectime);

%keep only the part of the matrix filled
%the rest are redundant zeros, signifying the samples lost 
%by epoc's variable sampling
EegMatrix=EegMatrix(1:Timepoint,:);
Events=Events(1:Timepoint,:);

data=matfile(strcat(DatasetName,'.mat'),'Writable',true);
data.eeg=EegMatrix;
data.events=Events;
data.header=Header;