# -*- coding: utf-8 -*-
"""
Created on Mon Nov 16 00:34:55 2020

@author: Jonas
"""

import csv
import datetime
import numpy as np
import os
import matplotlib.pyplot as plt

from cartopy import config
import cartopy.crs as ccrs

ordem = ['Latitude', 'Longitude', 'Data_Avist', 'Data_Revis', 'Status']

def carregarCSV(nome_arquivo):
    with open(nome_arquivo, 'r', encoding='utf-8') as f_input:
        csv_input = csv.reader(f_input, quoting=csv.QUOTE_ALL)
        data = list(csv_input)
    return data

def lerMaster():
    csv = carregarCSV('IBAMA_MASTER_FINAL.csv')
    
    lon = np.zeros(len(csv))
    lat = np.zeros(len(csv))
    avist = np.zeros(len(csv))
    status = np.zeros(len(csv))
    
    
    for i in range(len(csv)):
        dado = csv[i]
        lat[i] = dado[0]
        lon[i] = dado[1]
        avist[i] = dado[2]
        status[i] = dado[3]
            
    lon = np.array(lon)
    lat = np.array(lat)
    avist = np.array(avist)
    status = np.array(status)
    
    out = np.zeros([len(avist),4])
    
    for i in range(len(out)):
        out[i,0] = lat[i]
        out[i,1] = lon[i]
        out[i,2] = avist[i]
        out[i,3] = status[i]
    

    return out
    
master = lerMaster()

latlon = np.zeros([len(master), 2])

latlon[:,0] = master[:,0]
latlon[:,1] = master[:,1]-360

ini = datetime.datetime(year =2000, month = 1, day = 1)
data = []
for i in range(len(master)):
    fmt = '%Y-%m-%d'
    data1 = ini + datetime.timedelta(hours = master[i,2])
    data1 = datetime.datetime.strftime(data1, fmt)
    data.append(data1)

master_n = np.zeros([60,4])

for i in range(len(master)):
    for j in range(i, len(master)):
        if i == j and j == len(master):
            j = j + 1
        if master[i,0] != master [j,0] and master[i,1] != master [j,1] and master[i,2] != master [j,2]: 
            master_n[i,:] = master[j,:]
            
fig = plt.figure(figsize=(8, 12))

# get the path of the file. It can be found in the repo data directory.
fname = os.path.join(config["repo_data_dir"],
                     'raster', 'sample', 'BTS.jpg'
                     )
img_extent = (-38.82, -38.433, -13.181, -12.596)
img = plt.imread(fname)

ax = plt.axes(projection=ccrs.PlateCarree())
plt.title('')

# set a margin around the data
ax.set_xmargin(0.05)
ax.set_ymargin(0.10)

# add the image. Because this image was a tif, the "origin" of the image is in the
# upper left corner
ax.imshow(img, origin='upper', extent=img_extent, transform=ccrs.PlateCarree())
# ax.coastlines(resolution='10m', color='black', linewidth=1)

# mark a known place to help us geo-locate ourselves
ax.text(-38.5, -12.98, 'Salvador', size = 'xx-large', transform=ccrs.Geodetic())
ax.text(-38.67, -12.98, 'Ilha de \n Itaparica', size = 'xx-large', transform=ccrs.Geodetic())
ax.plot(latlon[:,1], latlon[:,0], 'ro', markersize=10, transform=ccrs.Geodetic())

plt.show()