function [ Signal , Events ,  Fs ] = data_2_eeg( fichier_events, fichier_signals  )


% Signal est une matrice avec en ligne l'acquisition des électrodes en fonction du temps. 
% Event est une matrice avec en ligne l'acquisition des évenements clavier en fonctoin du temps. 
% si l'on veut accéder à l'acquisition de la kieme électrode, on fait Signal(:,k). 

% si on a 8 electrodes elles sont ordonnées de la sorte : 
% [FP1  F3  Fz  F4 T3  C3  Cz  C4]

data_events = importdata(fichier_events);
data_signals = importdata(fichier_signals);

%% Extraction des evenements

%nombre d'evenements
nb_events = length(data_events.data)/2;

%vecteur lignes des evenements
Events = zeros(nb_events,1);

events =[data_events.data(1,1)];
for k=2:length(data_events.data)
    if (abs(data_events.data(k,1)-events(end))>2) % un event proche de 2 secondes de l'event precedent est saute
        events = [events ; data_events.data(k,1)];
    end
end

%% Extraction des signaux

%nombre d'electrodes
nb_electrodes = size(data_signals.data,2)-2;
%Fs
Fs = data_signals.data(1,end);
%times
times = data_signals.data(:,1);

Signal = zeros(nb_electrodes,length(times));

for i=1:nb_electrodes
    Signal(i,:)=data_signals.data(:,i+1); 
end 


end

