function [ online_features ] = online_compute_feature( data_online, Fs, window, step, f_etude )
%Cette fonction permet de traiter des données en continue
%A partir d'un signal temporel, sous la forme d'une matrice de taille 
%nb_temp x nb_electrodes, on extrait les puissances spectrale dans la bande
%de fréquence étudiée calculuée sur une fenêtre temporelle glissante par
%la fonction compute_feature. 
%Cette fonction renvoie une matrice de taille (nb_fenêtres x
%nb_eleectrodes) contenant les features de chaque électrodes sur chaque
%fenêtre temporelle. 
%window (donné en s) = taille de la fenêtre 
%Nt= nombre d'instants temporels du signal reçu 
%Ne= nombre d'électrodes utilisées pour l'enregistrement
%Step (donné en s)= window - overlap = pas d'avancement de la fenêtre glissante

Ne=size(data_online,1); 
Nt=size(data_online,2); 
Window=floor(window*Fs);
Step = floor(step*Fs);
index = 1:Step:Nt-Window-1; %indice des début de fenêtre de découpe temporelle
Nf=length(index); %Nombre de fenêtres

%Initialisation des variables 
online_signal_temp=zeros(Window,Ne);
evaluation_features=zeros(Nf,Ne);

for i=1:Nf
    for j=1:Ne
        online_signal_temp(:,j)=data_online(index(i):index(i)+Window);
        online_features_temp=compute_feature(online_signal_temp,f_etude);
    end
   online_features=vertcat(online_features,online_features_temp);
end

end

