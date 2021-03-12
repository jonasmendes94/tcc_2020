"""
Created on Thu Oct 22 14:45:26 2020

        !!! ESSE RODA !!!

@author: MstrPtsc
"""

from parcels import (FieldSet, Field, ParticleSet, Variable, JITParticle, 
                     plotTrajectoriesFile, ErrorCode, OutOfBoundsError, 
                     AdvectionRK4, AdvectionRK45, DiffusionUniformKh)

from global_land_mask import globe
from operator import attrgetter
from datetime import timedelta
import random as rndm
import netCDF4 as nc
import numpy as np
import math

#############################################################################
######################### CONFIGS ###########################################
#############################################################################

numpart = 2 # Numero de partículas
K_bar = 10 # Coeficiente de atrito
ncdf = "0SAL.nc" # input do modelo hidrodinâmico (HYCOMM no caso, U e V de superfície)
outname = "out_" + ncdf #output do modelo lagrangeano

###### Carregando Dados ######
net = nc.Dataset(ncdf)
lat = list(net.variables['Lat'][:][:])
lon =list(net.variables['Lon'][:][:])
# lat = list(lat0[:])
# lon = list(lon0[:])
# uvel = net.variables['U'][:]
# vvel = net.variables['V'][:]
# tim = net.variables['Time'][:]

#############################################################################
########################## Criando Campo ####################################
#############################################################################

#carregando variáveis#
filenames = {'U': ncdf,
             'V': ncdf,}

variables = {'U': 'U',
             'V': 'V'}

dimensions = {'lat': 'Lat',
              'lon': 'Lon',
              'time': 'Time'}


#definindo campo#
fset = FieldSet.from_netcdf(filenames, variables, dimensions)
size2D = (len(lat), len(lon))
fset.add_field(Field('Kh_meridional', data=K_bar*np.ones(size2D), lon=fset.U.grid.lon, lat=fset.U.grid.lat, mesh='spherical', allow_time_extrapolation=True))
fset.add_field(Field('Kh_zonal', data=K_bar*np.ones(size2D), lon=fset.U.grid.lon, lat=fset.U.grid.lat, mesh='spherical', allow_time_extrapolation=True))


#############################################################################
############################ Criando Partículas #############################
#############################################################################

def criaPosPartic():
    
    pospartic = np.zeros([numpart,2])
    pospartic[0,0] = -13.072
    for i in range(1, numpart):
        if numpart == 1:
            break
        pospartic[i,0] = pospartic[0,0] - i * 0.02
    pospartic[:,1] = -38.45  
        
    return pospartic
    

pospartic = criaPosPartic()
    

#definindo partículas#
pset = ParticleSet.from_list(fieldset = fset,
                              pclass=JITParticle,
                              lat = pospartic[:,0],
                              lon = pospartic[:,1],
                              repeatdt=timedelta(hours = 12))

#############################################################################
############################## Criando Output ###############################
#############################################################################

#criando o que fazer em condição de recovery#
def OutOfBounds(particle, fieldset, time):
    particle.delete()



output_file = pset.ParticleFile(name=outname, outputdt=timedelta(seconds=3600))


# mostrando partículas


#executando o modelo#
#pset.Kernel(AdvectionRK4) +
kernels = pset.Kernel(AdvectionRK4)# + DiffusionUniformKh

pset.execute(kernels,
              #runtime=timedelta(seconds=7592400),
              dt=timedelta(hours=1),
              output_file=output_file,
              recovery={ErrorCode.ErrorOutOfBounds: OutOfBounds})


#############################################################################
############################## Plotando Resultados ##########################
#############################################################################

# plotando resultados#
plotTrajectoriesFile(outname)
                      # tracerfile=ncdf,
                      # tracerlon='Lon',
                      # tracerlat='Lat',
                      # tracerfield='MAG');
