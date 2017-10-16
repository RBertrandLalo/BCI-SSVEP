% Traitement des donn�es, extraction de caract�ristiques, apprentissage,
% classification et validation crois�e 


clear variables
close all
warning('off')
clc

% Renseigner le chemin du dossier contenant les donn�es d'acquisition
addpath('C:\Users\Timoth�\Desktop\SAUVEGARDE RAF\SSVEP\Codes matlab\Codes Matlab qui marchent')
addpath('C:\Users\Timoth�\Desktop\SAUVEGARDE RAF\SSVEP\Codes matlab\Codes Matlab qui marchent\Tom_8C\Tom_8C\Tom_vert_bleu_8C')

files = dir('C:\Users\Timoth�\Desktop\SAUVEGARDE RAF\SSVEP\Codes matlab\Codes Matlab qui marchent\Tom_8C\Tom_8C\Tom_vert_bleu_8C\*.csv');

%Initialisation des variables 
nb_events_total =0;
% Ne=..
mu_on_app = [];
mu_off_app = [];
tot_features=[];
tot_response=[];
training_features=[];
training_response=[];
evaluation_features=[];
evaluation_response=[];
perf_svm=[];

%Param�tres 
nb_cross_validation=100; 
tps_on = 5; 
tps_off = 5; 
tps_reaction = 2;
tps_fatigue = 0.5; 


%Traitement des donn�es et extraction des features

for i=1:2:length(files)-1   %Pour chaque essaie, on charge les .csv des signaux et des marqueurs, et on d�coupe selon les �v�nements 'light_on' et 'light_off'
   [data_light_on , data_light_off , Ne, nb_events,  Fs, f_etude] = decoupe2(files(i).name,files(i+1).name, tps_reaction, tps_fatigue, tps_on, tps_off  ); 
    
for j=1:nb_events      %Pour chaque �v�nement, on extrait les features gr�ce � 'compute_feature.m', qu'on range verticalement � la suite dans la matrice tot_features
                       %En parall�le, on renseigne la nature de l'�v�nement (1 pour 'light_on', -1 pour 'light_off' dans le vecteur tot_response, dont l'indice correspond � la ligne de tot_features

 % Extraction des features des �v�nements 'light_on' et renseignement du vecteur de r�ponses par ajout de +1                       
    tot_features= vertcat( tot_features,compute_feature(data_light_on(:,:,1,j), f_etude));
    tot_response= vertcat( tot_response,1);
end

 % Extraction des features des �v�nements 'light_off' et renseignement du vecteur de r�ponses par ajout de -1
for j=1:nb_events-1 
    tot_features= vertcat( tot_features, compute_feature(data_light_off(:,:,1,j), f_etude));
    tot_response=vertcat( tot_response,-1);
end

nb_events_total = nb_events_total + nb_events;     %On renseigne le nombre d'�v�nements total en ajoutant les participations de chaque essai 

end

nb_events=nb_events_total;

%Visualisation des features, comparaison des �tats stimul� et repos
%Trac� des moustaches

%On concat�ne les signaux correspondant aux �v�nements 'light_on' et
%'light_off' afin de moyenn� les puissances spectrales et d'observ� si ces
%deux �tats sont dissociables 
signal_on=[];
signal_off=[];
   Nf = 4096*4;     
   ind_f_etude = round((Nf/Fs)*f_etude);
S=size(data_light_on,4)

for i=1:S
    signal_on_conc = horzcat(signal_on,data_light_on(:,:,1,i));
    signal_on = data_light_on(:,:,1,i);
    [ DSP_on(i,:),axe_freq] = create_dsp(signal_on);
    
    signal_off_conc = horzcat(signal_off,data_light_on(:,:,1,i));
    signal_off = data_light_off(:,:,1,i);
    [ DSP_off(i,:),axe_freq] = create_dsp(signal_off);
    
end

[DSP_on_conc]=create_dsp(signal_on_conc);
[DSP_off_conc]=create_dsp(signal_off_conc);

    % Calcul des param�tres caract�ristiques 
     % DSP �cart-type
     DSP_on_std = std(DSP_on,1);
     DSP_off_std = std(DSP_off,1);

%     for i=1:S
%         figure()
%         plot(axe_freq,DSP_on(i,:),'r')
%         hold on
%         errorbar(axe_freq(ind_f_etude), DSP_on(i,ind_f_etude),DSP_on_std(ind_f_etude),'rx')
%         set(gca, 'xlim', [f_etude-5 f_etude+5]);
%         hold on
%         plot(axe_freq,DSP_off(i,:),'b')
%         hold on
%         errorbar(axe_freq(ind_f_etude), DSP_off(i,ind_f_etude), DSP_off_std(ind_f_etude),'bx')
%         set(gca, 'xlim', [f_etude-5 f_etude+5]);
%         legend('stimulation','repos')
%     end

figure()
    plot(axe_freq,DSP_on_conc,'r')
    hold on
    plot(axe_freq,DSP_off_conc,'b')
    legend('stimulation','repos')
    hold on
    errorbar(axe_freq(ind_f_etude), DSP_on_conc(ind_f_etude),DSP_on_std(ind_f_etude),'rx')
    set(gca, 'xlim', [f_etude-5 f_etude+5]);
    hold on
    errorbar(axe_freq(ind_f_etude), DSP_off_conc(ind_f_etude), DSP_off_std(ind_f_etude),'bx')
    set(gca, 'xlim', [f_etude-5 f_etude+5]);
    
 

    
    

%Calcul des features sur les signaux concat�n�s 'on' et 'off'
   Nf = 4096*4;     
   ind_f_etude = round((Nf/Fs)*f_etude);
   [ DSP_on,axe_freq] = create_dsp(signal_on) 
   [ DSP_off,axe_freq] = create_dsp(signal_off)
       
 

% Visualisation en 2D des features, recherche de clusters 
% Ici, on choisit de ne tenir compte que de C2 et CZ
on=[];
off=[];
for i=1:length(tot_response)
        if tot_response(i)==1
            on=vertcat(on,[tot_features(i,6),tot_features(i,7)]);
        else 
            off=vertcat(off,[tot_features(i,6),tot_features(i,7)]);
        end
end

figure()
scatter(on(:,1),on(:,2),'b*');
hold on 
scatter(off(:,1),off(:,2),'r*');

for indice_tirage=1:nb_cross_validation
       
    % S�lection des indices des donn�es d'�valuation
    Indice_test=[];
    Indice_test(1)=floor(rand*(nb_events))+1;
    Indice_train=[];
    nb_events_total=size(tot_features,1);
    nb_test=floor(nb_events/16);      %On choisit de faire l'apprentissage sur 7/8 �me des donn�es et de tester sur le 1/8 �me restant 
    while length(Indice_test)<nb_test      %On tire au hasard les incides des essais � mettre de c�t�, pour le test. On v�rifie � chaque tirage qu'il n'y a pas de doublons gr�ce � la variable deja_tire
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
   
             
    % Apprentissage et classification 

    svmStruct = svmtrain(training_features,training_response,'ShowPlot',true);
    estimation_evaluation_response = svmclassify(svmStruct,evaluation_features,'ShowPlot',true);
    DIFF=(estimation_evaluation_response==evaluation_response);
    perf_svm(indice_tirage)=sum(DIFF)/length(evaluation_response)*100;
    
    [COEFF,SCORE] = princomp(training_features);
    estimation_evaluation_response = classify(evaluation_features,training_features,training_response,'linear');
    DIFF=(estimation_evaluation_response==evaluation_response);
    perf_linear(indice_tirage)=sum(DIFF)/length(evaluation_response)*100;

    estimation_evaluation_response = classify(evaluation_features,training_features,training_response,'quadratic');
    DIFF=(estimation_evaluation_response==evaluation_response);
    perf_quadr(indice_tirage)=sum(DIFF)/length(evaluation_response)*100;
    
    estimation_evaluation_response = classify(evaluation_features,training_features,training_response,'mahalanobis');
    DIFF=(estimation_evaluation_response==evaluation_response);
    perf_mahalonobis(indice_tirage)=sum(DIFF)/length(evaluation_response)*100;
    
    
    estimation_evaluation_response = classify(evaluation_features,training_features,training_response,'diagquadratic');
    DIFF=(estimation_evaluation_response==evaluation_response);
    perf_diagquadratic(indice_tirage)=sum(DIFF)/length(evaluation_response)*100;
    
    estimation_evaluation_response = classify(evaluation_features,training_features,training_response,'diaglinear');
    DIFF=(estimation_evaluation_response==evaluation_response);
    perf_diaglinar(indice_tirage)=sum(DIFF)/length(evaluation_response)*100;

end

perf_cross_val_svm=mean(perf_svm)
perf_cross_val_linear=mean(perf_linear)
perf_cross_val_quadr=mean(perf_quadr)
perf_cross_val_mahalonobis=mean(perf_mahalonobis)
perf_cross_val_diagquadratic=mean(perf_diagquadratic)
perf_cross_val_diaglinar=mean(perf_diaglinar)





