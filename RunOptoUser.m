clc
clear all

%% Access USB-TTL board
a = arduino('COM4','Uno');
configurePin(a,'D13','DigitalOutput'); 
writeDigitalPin(a,'D13',1);
pause(1)
%%
writeDigitalPin(a,'D13',0);

%% Initialize global variables
global gLCApp;
global gChans;
global gLCDoc;
global gLatestBlock;
global gChans;


% Get a handle to COM server
gLCApp = actxGetRunningServer('ADIChart.Application');

% Get the document (running channels and recordings) associated with COM server
doc1 = RunningLCDoc(); 

% 
if not(isempty(gLCDoc)) && gLCDoc.isinterface && not(isempty(gLCDoc.eventlisteners))
    gLCDoc.unregisterallevents;
end
gLCDoc = doc1;

% Specify which channel you want  for online SZ detection
gChans = [1]; % collect sampling data from channels 2

% 
gLatestBlock = gLCDoc.NumberOfRecords
secsPerTick = gLCDoc.GetRecordSecsPerTick(gLatestBlock)

% Load the Seizure Net
load newnet_v4
clear YTrain YValid YPredicted XValid XTrain x validationFrequency miniBatchSize list_files k ans A folder_path Ypsm options

%% Lock onto the last block 

sz_thresh = 0.2;
dataLen = 16384;  %IF THIS PARAMETER IS CHANGED, MAKE SURE THE NEURAL NET INPUT DIMENSION IS CHANGED TOO
blockLen = doc1.GetRecordLength(gLatestBlock);
pause(2)  % to generate 2000 ms of data
prevData = gLCDoc.GetChannelData (1, gChans, gLatestBlock, blockLen, -1);
prevData = prevData(1:dataLen);
length(prevData)

%%
%for x = 1:20
while 1  
    blockLen = doc1.GetRecordLength(gLatestBlock);
    pause(.1)  % to generate 100 ms of data :: 
    currData = gLCDoc.GetChannelData (1, gChans, gLatestBlock, blockLen, -1);
    datapadded = [prevData currData];%16384+2000 (variable length)
    prevData = datapadded(1,end-dataLen+1:end);
    
    lfp_new = wdenoise(prevData', 4, 'Wavelet','coif2' , 'DenoisingMethod','Minimax'); %wdenoise opeartes columnwise
    lfp_new = lowpass(lfp_new,100,10000,'ImpulseResponse','iir','Steepness',0.95);
    lfp_new = smoothdata(lfp_new, 1,'gaussian',100);  %
    if length(lfp_new)<dataLen
       lfp_new = [lfp_new;zeros(dataLen-length(lfp_new),1)]; 
    else 
        lfp_new = lfp_new(1:dataLen,1); %% take consecutive samples to maitain integrity of the signal
    end    
    
    g = predict(net,lfp_new);   % Deep net prediction    
    if double(g) > sz_thresh
        for k = 1:11
            writeDigitalPin(a,'D13',mod(k,2));      
            pause(1/50)
        end
        writeDigitalPin(a,'D13',mod(0,2));
    end    
end

%% For continuous light pulse delivery

% while 1
%     for k = 1:11
%         writeDigitalPin(a,'D13',mod(k,2));      
%         pause(1/50)
%     end
%     writeDigitalPin(a,'D13',mod(0,2));    
% end
%     
    
