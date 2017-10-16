clear variables
close all
warning('off')
clc

nb_events_total =0;
nb_electrodes = 8;
mu_on_app = [];
mu_off_app = [];
tot_features=[];
tot_response=[];
training_features=[];
training_response=[];
evaluation_features=[];
evaluation_response=[];
perf_svm=[];
nb_cross_validation=10

addpath('C:\Users\Timothé\Desktop\SAUVEGARDE RAF\SSVEP\Tom_8C\Tom_8C\Tom_vert_bleu_8C\');
files = dir('C:\Users\Timothé\Desktop\SAUVEGARDE RAF\SSVEP\Tom_8C\Tom_8C\Tom_vert_bleu_8C\*.csv');

% DONNEES TOTALES
for i=1:2:length(files)-1
    [data_light_on , data_light_off , nb_electrodes, nb_events,  Fs, f_etude] = decoupe2(files(i).name,files(i+1).name,0.5,1,5,5 );
% tps_on = 5; tps_off = 5; tps_reaction =1; tps_fatigue = 0.5;

for j=1:nb_events
    %mu_on_app = vertcat(mu_on_app,compute_feature(data_light_on(:,:,1,j), f_etude));
    tot_features= vertcat( tot_features,compute_feature(data_light_on(:,:,1,j), f_etude));
    tot_response=vertcat( tot_response,1);
end
for j=1:nb_events-1 
    %mu_off_app = vertcat(mu_off_app,compute_feature(data_light_off(:,:,1,j), f_etude));
    tot_features= vertcat( tot_features, compute_feature(data_light_off(:,:,1,j), f_etude));
    tot_response=vertcat( tot_response,-1);
end

nb_events_total = nb_events_total + nb_events;

end

%Acquisition pseudo en ligne
addpath('C:\Users\Timothé\Desktop\SAUVEGARDE RAF\SSVEP\Tom_8C\Tom_8C\Tom_vert_bleu_pseudo_online')
testdata= importdata('2016.03.01-16.47.08-signals.csv');

svmStruct = svmtrain(tot_features,tot_response,'ShowPlot',true);

for j=1:nb_electrodes
    data_online(j,:) = testdata.data(:,j+1);
end
Nt=size(data_online,2)
window=floor(3*Fs)
Step = floor(0.1*Fs);
index = 1:Step:Nt-window-1
I=length(index)

for i=1:I
    for j=1:nb_electrodes
        online_signal_temp(j,:)=data_online(index(i):index(i)+window);
        online_features_temp=compute_feature(online_signal_temp,f_etude);
    end
     estimation_evaluation_response(i) = svmclassify(svmStruct, online_features_temp,'ShowPlot',true);
end

estimation_evaluation_response





