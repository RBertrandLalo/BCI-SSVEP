% Traitement des données, extraction de caractéristiques, apprentissage,
% classification et validation croisée 


clear variables
close all
warning('off')
clc

% Renseigner le chemin du dossier contenant les données d'acquisition
addpath('C:\Users\Timothé\Desktop\SAUVEGARDE RAF\SSVEP')
files = dir('C:\Users\Timothé\Desktop\SAUVEGARDE RAF\SSVEP\Tom_8C\Tom_8C\Tom_vert_bleu_8C\*.csv');

%Initialisation des variables 
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

%Paramètres 
nb_cross_validation=100; 
tps_on = 5; 
tps_off = 5; 
tps_reaction = 2;
tps_fatigue = 0.5; 


%Traitement des données 
for i=1:2:length(files)-1   %Pour chaque essaie, on charge les .csv des signaux et des marqueurs, et on découpe selon les évènements 'light_on' et 'light_off'
   [data_light_on , data_light_off , nb_electrodes, nb_events,  Fs, f_etude] = decoupe2(files(i).name,files(i+1).name, tps_reaction, tps_fatigue, tps_on, tps_off  ); 

for j=1:nb_events           %Pour chaque évènement, on extrait les features grâce à 'compute_feature.m', qu'on range verticalement à la suite dans la matrice tot_features
                            %En parallèle, on renseigne la nature de
                            %l'évènement (1 pour 'light_on', -1 pour 'light_off' dans le vecteur tot_response, dont
                            %l'indice correspond à la ligne de tot_features
                       
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

% % UNE DONNEE TEST AU HASARD
% [data_light_on , data_light_off , nb_electrodes, nb_events,  Fs, f_etude] = decoupe2('2016.03.01-16.35.52-events_bv_20Hz.csv','2016.03.01-16.35.52-signals_bv_20Hz.csv', 1,1,5,5  );
% for i=1:2:length(files)-1
% [data_light_on , data_light_off , nb_electrodes, nb_events,  Fs, f_etude] = decoupe2(files(i).name,files(i+1).name,0.5,1,5,5 );
% % tps_on = 5; tps_off = 5; tps_reaction =1; tps_fatigue = 0.5;
% 
% for j=1:nb_events
%     %mu_on_app = vertcat(mu_on_app,compute_feature(data_light_on(:,:,1,j), f_etude));
%     evaluation_features= vertcat( evaluation_features,compute_feature(data_light_on(:,:,1,j), f_etude));
%     evaluation_response=vertcat( evaluation_response,1);
% end
% for j=1:nb_events-1 
%     %mu_off_app = vertcat(mu_off_app,compute_feature(data_light_off(:,:,1,j), f_etude));
%     evaluation_features= vertcat( evaluation_features, compute_feature(data_light_off(:,:,1,j), f_etude));
%     evaluation_response=vertcat( evaluation_response,-1);
% end
% nb_events_total = nb_events_total + nb_events;
% end

% nb_test DONNEES AU HASARD EN VUE D'UNE VALISATION CROISEE 


% Validation croisée
for indice_tirage=1:nb_cross_validation
    
    % Sélection des indices des données test 
    Indice_test=[];
    Indice_train=[];
    nb_events=size(tot_features,1);
    nb_test=floor(nb_events/8);
    while length(Indice_test)<nb_test
        deja_tire=0;
        temp=floor(rand*(nb_events))+1;
        for i=1:length(Indice_test)
            if temp==Indice_test(i)
                deja_tire=1;
            end
        end
        if deja_tire==0
            Indice_test=vertcat(Indice_test,temp);
            evaluation_features=vertcat(evaluation_features,tot_features(temp,:));
            evaluation_response=vertcat( evaluation_response,tot_response(temp));
        end
    end

    %Fabrication de training_features et de evaluation_features 
    for i=1:nb_events
        indice_eval=0;
        for k=1:length(Indice_test)
            if i==k
                indice_eval=1;
            end
        end
        if indice_eval==0
            Indice_train=vertcat(Indice_train,i);
            training_features=vertcat(training_features,tot_features(i,:));
            training_response=vertcat(training_response,tot_response(i));
        end
    end



    % Essai classif SVM 

    svmStruct = svmtrain(training_features,training_response,'ShowPlot',true);
    estimation_evaluation_response = svmclassify(svmStruct,evaluation_features,'ShowPlot',true);

    DIFF=(estimation_evaluation_response==evaluation_response);

    perf_svm(indice_tirage)=sum(DIFF)/length(evaluation_response)*100; 

end

perf_cross_val=mean(perf_svm)




