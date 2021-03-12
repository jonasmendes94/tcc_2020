clc
clear all

cmode = netcdf.getConstant('NETCDF4');

%%%%%%%%%%%%%%%%%%%%%%%%%

NOME_OUT = '10SAL.nc';

%%%%%%%%%%%%%%%%%%%%%%%%%

lati = -13.1796;
latf = -12.5991;
loni = -38.8185;
lonf = -38.4360;
tam_cel = 0.0045;

% loni = 360 - loni;
% lonf = 360 - lonf;

LON = (loni:tam_cel:lonf)';
%LON = flip(LON, 1);
% LON = 360 + LON;
LAT = (lati:tam_cel:latf)';

TIME = load('MOD_T.mat');
TIME = TIME.time3;

clear lati latf loni lonf tam_cel lat lon

%% Importando U / LAT / LON / Z

DATA = load('MOD_U.mat');
MOD_U = DATA.data.Val;
MOD_U = MOD_U (:, 2:87, 2:131);
MOD_U = permute(MOD_U, [2 3 1]);
%MOD_U = flip(MOD_U, 1);
MOD_U(MOD_U==0) = NaN;

DATA = load('MOD_V.mat');
MOD_V = DATA.data.Val;
MOD_V = MOD_V (:, 2:87, 2:131);
MOD_V = permute(MOD_V, [2 3 1]);
%MOD_V = flip(MOD_V, 1);
MOD_V(MOD_V==0) = NaN;

DATA = load('MOD_MAG.mat');
MOD_MAG = DATA.data.Val;
MOD_MAG = MOD_MAG (:, 2:87, 2:131);
MOD_MAG = permute(MOD_MAG, [2 3 1]);
%MOD_MAG = flip(MOD_MAG, 1);
MOD_MAG(MOD_MAG==0) = NaN;

clear DATA

ncid = netcdf.create(NOME_OUT ,cmode);

londim = netcdf.defDim(ncid,'Lon',length(LON));
latdim = netcdf.defDim(ncid,'Lat',length(LAT));
tdim = netcdf.defDim(ncid,'Time',length(TIME));

lonID = netcdf.defVar(ncid,'Lon','double',londim);
latID = netcdf.defVar(ncid,'Lat','double',latdim);
tID = netcdf.defVar(ncid,'Time','double',tdim);
xID = netcdf.defVar(ncid,'U','double',([londim, latdim, tdim]));
vID = netcdf.defVar(ncid,'V','double',([londim, latdim, tdim]));
magID = netcdf.defVar(ncid,'MAG','double',([londim, latdim, tdim]));

netcdf.endDef(ncid);

netcdf.putVar(ncid,lonID,LON);
netcdf.putVar(ncid,latID,LAT);
netcdf.putVar(ncid,tID,TIME);
netcdf.putVar(ncid,xID,MOD_U);
netcdf.putVar(ncid,vID,MOD_V);
netcdf.putVar(ncid,magID,MOD_MAG);


netcdf.close(ncid);

ncwriteatt(NOME_OUT,'Lon','units','degrees_east');
ncwriteatt(NOME_OUT,'Lat','units','degrees_north');
ncwriteatt(NOME_OUT,'Time','units','seconds since 2019-10-01 00:00:00');
ncwriteatt(NOME_OUT,'Time','time_origin','2019-10-01 00:00:00');
ncwriteatt(NOME_OUT,'Time','calendar','gregorian');
ncwriteatt(NOME_OUT,'U','units','m/s');
ncwriteatt(NOME_OUT,'V','units','m/s');
ncwriteatt(NOME_OUT,'MAG','units','m/s');

ncdisp(NOME_OUT)

clear all

