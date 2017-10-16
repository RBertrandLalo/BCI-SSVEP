function [ data_light_on , data_light_off , Ne, nb_events,  Fs, f_etude] = decoupe2( fichier_events, fichier_signals, tps_reaction, tps_fatigue, tps_on, tps_off  )
% fonction de découpe du signal comportant une succession de stimulation de
% duree tps_on et repos de duree tps_off

% data_lights_on et data_light_off sont des matrices de
% dimensions(Ne, tps*Fs , 2, nb_events) où tps =
% (tps_on-tps_reaction-tps_fatigue) //ou// (tps_off-securite)

% si l'on veut accéder à la stimulation (les données) de la jème electrode au kème evenement
% on appelle data_light_on(j,:,1,k)

% si l'on veut accéder à la stimulation (le temps) de la jème electrode au kème evenement
% on appelle data_light_on(j,:,2,k)

% si on a 8 electrodes elles sont ordonnées de la sorte : 
% [FP1  F3  Fz  F4 T3  C3  Cz  C4]

% ***************************  ATTENTION *********************************
% souvent on ne prend pas en compte le DERNIER REPOS. 
% Ainsi, data_light_off(j,:,1,DERNIER EVENT)= [0 0 0 0 0 ... 0 0 0]


data_events = importdata(fichier_events);
data_signals = importdata(fichier_signals);

%% Extraction des evenements

%nombre d'evenements
nb_events = length(data_events.data)/2;

%vecteur lignes des evenements
events = zeros(nb_events,1);

events =[data_events.data(1,1)];
for k=2:length(data_events.data)
    if (abs(data_events.data(k,1)-events(end))>2) % un event proche de 2 secondes de l'event precedent est saute afin de se débarasser des erreurs éventuelles d'acquisition
        events = [events ; data_events.data(k,1)];
    end
end

%% Extraction des signaux

%nombre d'electrodes
Ne = size(data_signals.data,2)-2;
%Fs
Fs = data_signals.data(1,end);
%times
times = data_signals.data(:,1);
%f_etude
f_etude = str2double(fichier_signals(32:33)); %pour bleu vert
% f_etude = str2double(fichier_signals(35:36));   %pour blanc noir

%tenseur de signal on
data_light_on = zeros(Ne, (tps_on-tps_reaction-tps_fatigue)*Fs, 2, nb_events);

%tenseur de signal off
securite = 1; %marge de securite pour ne pas enregistrer du 'off' alors que l'on commencé une nouvelle phase de stimulation
data_light_off = zeros(Ne, (tps_off-securite)*Fs, 2, nb_events);

% Decoupe du signal
for k=1:nb_events
    
    %Découpe 'on'
    debut_on=(events(k)+tps_reaction)*Fs;
    fin_on=(events(k)+tps_on-tps_fatigue)*Fs;
    
    for j=1:Ne
        if (fin_on<=Fs*times(end))
            data_light_on(j,:,1,k) =data_signals.data(debut_on:fin_on-1,j+1);
            data_light_on(j,:,2,k) =times(debut_on:fin_on-1);
        end
    end
    
    % Découpe 'off'
    debut_off = (events(k)+tps_on)*Fs;
    fin_off = (events(k)+tps_on+tps_off-securite)*Fs;
    
    for j=1:Ne
        if (fin_off<=Fs*times(end))
            data_light_off(j,:,1,k) =data_signals.data(debut_off:fin_off-1,j+1);
            data_light_off(j,:,2,k) =times(debut_off:fin_off-1);
        end
    end
      
end
end

