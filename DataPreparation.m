clear all
clc
%% RUN Section

%% reading directories  :: CHANGE THIS FOR WINDOWS
root_path = 'DATA Folder PATH';
list_files = dir(root_path);
write_path = strsplit(root_path,'/');
write_path = strjoin(write_path(1:end-1),'/');
write_path = strcat(write_path,'/','Matrix_data'); % A file in Matrix_data: data dim = no-of-blocks*16384 

if ~isfolder(write_path)
    mkdir(write_path)
end

%% For ploting data (verification)
ff = list_files(40).name;
filename = strcat(root_path,'/',ff);

transL = 200;
seq_length = 4096*4; %16384 : User parameter. 

% if txt file
[timep,lfp] = textread(filename,'%f %f',-1); % file containing time and LFP of one channel
figure, plot(lfp)


%% Remove NaN values
y = isnan(lfp);
y = find(y==1);
lfp(y)=[];
timep(y)=[];

%% 
figure,plot(1:length(lfp),lfp,'-k'); hold on;
pvt = 1:transL:length(lfp)-seq_length;

%% Labeling :: Control data (tS=1, tE=length(lfp)), SZ data (ts = SZ onset time, tE=SZ end time)
opLabel = zeros(length(lfp),1);
tS = 1;
tE = length(lfp);

%% SZ
opLabel(1:tS) = -1;
opLabel(tS:tE)= -1; % for control : -1, for SZ : -1
opLabel(tE:end)=-1;

%%
plot(1:length(lfp),opLabel)
hold off

%% Label [time intensive]
label = [];
for k = 1:length(pvt)   
   label = [label;mean(opLabel(pvt(k):pvt(k)+seq_length-1,1)')];    
end

%%
p = floor(numel(lfp)/transL);
lfpm = lfp(1:transL*p);
A = reshape(lfpm,[transL,p]);
A = A';

%% Faster concatenation
zdim = ceil(seq_length/transL);
a = zeros(numel(pvt),transL,zdim);
for k = 1:zdim
   a(:,:,k) = A(k:numel(pvt)+k-1,:); 
end
seq_stack = reshape(a,[numel(pvt) transL*zdim]);
seq_stack = seq_stack(:,1:seq_length);


%% Preprocesing on the stack
lfp_new = wdenoise(seq_stack', 4, 'Wavelet','coif2' , 'DenoisingMethod','Minimax'); 
lfp_new = smoothdata(lfp_new, 1,'gaussian',100); %% (LFP acquisition rate: 10kHz => Gaussian length 100ms)
lfp_new = lfp_new';

%% 
dataSave = [lfp_new label];
writefilename = strcat(write_path,'/','FILE-NAME.txt');
writematrix(dataSave,writefilename, 'Delimiter','tab')

