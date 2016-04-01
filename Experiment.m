function [Header EegMatrix Events Timepoint nS]= Experiment(ExperimentTime, TrialTime,TrainedChannels,Messages,SampFreq,Rectime)

    EegMatrix = zeros(ExperimentTime*SampFreq,length(TrainedChannels));
    nS = zeros(ExperimentTime*SampFreq,1); %the number of samples acquired 
    
    Channels = {'ED_COUNTER','ED_INTERPOLATED','ED_RAW_CQ','ED_AF3','ED_F7','ED_F3','ED_FC5','ED_T7','ED_P7','ED_O1','ED_O2','ED_P8','ED_T8','ED_FC6','ED_F4','ED_F8','ED_AF4','ED_GYROX','ED_GYROY','ED_TIMESTAMP','ED_ES_TIMESTAMP','ED_FUNC_ID','ED_FUNC_VALUE','ED_MARKER','ED_SYNC_SIGNAL'};
    lib_flag_popup = 1;

    %%
    % Check to see if library was already loaded
    if ~libisloaded('edk')    
        [nf, w] = loadlibrary('edk','edk',  'addheader', 'EmoStateDLL', 'addheader', 'edkErrorCode'); 
        disp(['EDK library loaded']);
        if( lib_flag_popup )
            libfunctionsview('edk')
            nf % these should be empty if all went well
            w
        end
    else
        disp(['EDK library already loaded']);
    end

    %%
    %Connect with emoEngine (emotiv's epoc api)
    AllOK = calllib('edk','EE_EngineConnect','Emotiv Systems-5'); % success means this value is 0
    if (not(AllOK==0))
       msgbox('Something is wrong with the connection of EPOC') 
    end
    
    hData = calllib('edk','EE_DataCreate');
    calllib('edk','EE_DataSetBufferSizeInSec',Rectime);
    eEvent = calllib('edk','EE_EmoEngineEventCreate');
    readytocollect = false;


    Header=strcat(strjoin(Channels(TrainedChannels+1),','),',Label');
  
    Events=zeros(ExperimentTime*SampFreq,1);
    Index=1;
    
	%timepoint resemples the time index of the recording in EegMatrix
	%it can't get bigger than ExperimentTime*SampFreq
    Timepoint=0;
    Exper = tic; 
    while(toc(Exper) < ExperimentTime)
        
		%Change the stimuli here
        Trial = tic; 
		%ShowImage(Messages(Index))
        if(Messages(Index)>0)
            han=msgbox('Right');
        else
            han=msgbox('Left');
        end;
        
        %keep a vector of events with the same timepoint as the EEG recording
        %to correspond the EEG activity with each event
        Events(Timepoint+1)=Messages(Index);
        
        while(toc(Trial) < TrialTime)
            %check if you can collect
            state = calllib('edk','EE_EngineGetNextEvent',eEvent); % state = 0 if everything's OK
            eventType = calllib('edk','EE_EmoEngineEventGetType',eEvent);
            userID=libpointer('uint32Ptr',0);

            if strcmp(eventType,'EE_UserAdded') == true
                userID_value = get(userID,'value');
                calllib('edk','EE_DataAcquisitionEnable',userID_value,true);
                readytocollect = true;
            end

            %collect the data from dongle
            if (readytocollect) 
                calllib('edk','EE_DataUpdateHandle', 0, hData);
                nSamples = libpointer('uint32Ptr',0);
                calllib('edk','EE_DataGetNumberOfSample',hData,nSamples);
                nSamplesTaken = get(nSamples,'value') ;
                if (nSamplesTaken ~= 0)
                    data = libpointer('doublePtr',zeros(1,nSamplesTaken));
                        %take the specified channels used for training
                        for (i = TrainedChannels)
                            calllib('edk','EE_DataGet',hData, i, data, uint32(nSamplesTaken));
                            DataValue = get(data,'value'); 
                            %store the data in EegMatrix
                            EegMatrix(Timepoint+1:Timepoint+length(DataValue),i) = DataValue;                    
                        end	     
                        %update timepoint for the next store in EegMatrix
                        nS(Timepoint+1) = nSamplesTaken;
                        Timepoint = Timepoint + length(DataValue);
                end
            end
            
            if(toc(Trial)>TrialTime-2) %rest for 2 sec
                if ishandle(han)
                    delete(han);
                end
				%close(gcf) %close the White\Black image
            end
        end
        Index=Index+1;
    end
    
    calllib('edk','EE_EngineDisconnect');
    
end