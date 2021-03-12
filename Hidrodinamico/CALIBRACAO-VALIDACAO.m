clear all clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CALIBRACAO = CAL (15 dias) (set)
% PRE_MODELO = PRE (30 dias) (set/out)
% MODELO_FINAL = FINAL (88 dias) (out/dez)
% MASTER = MASTER (128 dias) (set/dez)

%Prefixo do arquivo de calibração para utilizado
nome_arquivo = "FINAL";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% CARREGANDO ARQUIVOS %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% GERADOS AUTOMAGICAMENTE %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%  CALIBRAÇÃO

opts = delimitedTextImportOptions("NumVariables", 5);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["T", "WL", "U", "V", "Mg"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "T", "InputFormat", "");

% Import the data
CALIBRACAUM = readtable("C:\Users\Jonas\Desktop\HIDRO\Estatisicas\Arq_Cal\CALIBRACAO_" + nome_arquivo + ".csv", opts);
CAL_T = CALIBRACAUM.T;
CAL_U = CALIBRACAUM.U;
CAL_V = CALIBRACAUM.V;
CAL_WL = CALIBRACAUM.WL;
CAL_MAG = CALIBRACAUM.Mg;

clear opts CALIBRACAUM nome_arquivo

%%%   MODELO

opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["dateandtime", "xcomponentofdepthaveragedvelocityms", "ycomponentofdepthaveragedvelocityms"];
opts.VariableTypes = ["datetime", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "dateandtime", "InputFormat", "yyyy-MM-dd HH:mm:ss");

% Import the data
MODUV = readtable("C:\Users\Jonas\Desktop\HIDRO\Estatisicas\MOD_UV.csv", opts);

MOD_U = MODUV.xcomponentofdepthaveragedvelocityms;
MOD_V = MODUV.ycomponentofdepthaveragedvelocityms;
MOD_T = MODUV.dateandtime;

clear opts MODUV

filename = 'C:\Users\Jonas\Desktop\HIDRO\Estatisicas\MOD_WL.csv';
startRow = 2;
formatSpec = '%*20s%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
MOD_WL = [dataArray{1:end-1}];
clearvars filename startRow formatSpec fileID dataArray ans;

filename = 'C:\Users\Jonas\Desktop\HIDRO\Estatisicas\MOD_MAG.csv';
startRow = 2;
formatSpec = '%*20s%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
MOD_MAG = [dataArray{1:end-1}];
clearvars filename startRow formatSpec fileID dataArray ans;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%   CORTANDO DATAS IGUAIS %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MOD_Uf = [];
MOD_Vf = [];
MOD_MAGf = [];
MOD_WLf = [];
k = 1;
for i =1:length(MOD_T)
    for j=1:length(CAL_T)
        if MOD_T(i)==CAL_T(j)
            MOD_Uf(k) = MOD_U(i);
            MOD_Vf(k) = MOD_V(i);
            MOD_MAGf(k) = MOD_MAG(i);
            MOD_WLf(k) = MOD_WL(i);
            k = k + 1;
            break
        end
    end
end

MOD_U = MOD_Uf.';
MOD_V = MOD_Vf.';
MOD_MAG = MOD_MAGf.';
MOD_WL = MOD_WLf.';
TEMPO = CAL_T;

clear MOD_Uf MOD_Vf MOD_MAGf MOD_WLf i j k MOD_T CAL_T

%%% caso tenha mais valores de calibração que de modelo, isso vai corrigir
%%% OBS: MODELO E CALIBRAÇÃO TEM QUE COMEÇAR NA MESMA DATA
TEMPO = TEMPO(1:length(MOD_U));
CAL_U = CAL_U(1:length(MOD_U));
CAL_V = CAL_V(1:length(MOD_U));
CAL_WL = CAL_WL(1:length(MOD_U));
CAL_MAG = CAL_MAG(1:length(MOD_U));


%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% VISUALIZAÇÃO VISUAL %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)
plot(TEMPO, CAL_WL)
hold on
plot(TEMPO, MOD_WL)
title('WATER LEVEL - MAREGRAFO')
xlabel('TEMPO')
ylabel('WATER LEVEL')
legend('MAREGRAFO', 'MODELO')
hold off

figure(2)
subplot(3,1,1)
plot(TEMPO, CAL_U)
hold on
plot(TEMPO, MOD_U)
title('COMPONENTE U - BOIA')
xlabel('TEMPO')
ylabel('COMPONENTE U')
legend('BOIA', 'MODELO')
hold off

subplot(3,1,2)
plot(TEMPO, CAL_V)
hold on
plot(TEMPO, MOD_V)
title('COMPONENTE V - BOIA')
xlabel('TEMPO')
ylabel('COMPONENTE V')
legend('BOIA', 'MODELO')
hold off

subplot(3,1,3)
plot(TEMPO, CAL_MAG)
hold on
plot(TEMPO, MOD_MAG)
title('MAGNITUDE DA VELOCIDADE - BOIA')
xlabel('TEMPO')
ylabel('MAGNITUDE')
legend('BOIA', 'MODELO')
hold off

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% TESTES ESTATISTICOS %%%%%%%%%%%
%%%%%%%% ERRO MÉDIO DA MÉDIA MÓVEL %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% WATER LEVEL

modulo = abs(MOD_WL-CAL_WL);
mediamodulo = mean(modulo);
absmed = abs(MOD_WL);
media = mean(absmed);
C_RMAE_WL = mediamodulo/media;

% COMPONENTE U

modulo = abs(MOD_U-CAL_U);
mediamodulo = mean(modulo);
absmed = abs(MOD_U);
media = mean(absmed);
A_RMAE_U = mediamodulo/media;

% COMPONENTE V

modulo = abs(MOD_V-CAL_V);
mediamodulo = mean(modulo);
absmed = abs(MOD_V);
media = mean(absmed);
B_RMAE_V = mediamodulo/media;

% MAGNITUDE

modulo = abs(MOD_MAG-CAL_MAG);
mediamodulo = mean(modulo);
absmed = abs(MOD_MAG);
media = mean(absmed);
C_RMAE_MAG = mediamodulo/media;

%g = 9.834;

clear modulo mediamodulo absmed media

clear TEMPO 
clear CAL_MAG CAL_U CAL_V CAL_WL
clear MOD_MAG MOD_U MOD_V MOD_WL