# -*- coding: utf-8 -*-
"""
Created on Mon Oct 26 19:48:30 2020

@author: Jonas
"""

import os
import csv
import requests
import pandas as pd
from bs4 import BeautifulSoup
from urllib.request import Request, urlopen


#################################################################################
############################### Configs #########################################
#################################################################################

site = 'https://www.ibama.gov.br/manchasdeoleo-localidades-atingidas'
        
destino_output = 'Procss_IBAMA/'

#################################################################################
############################### Download arquivos ###############################
#################################################################################

def getLinks(site):
    req = Request(site)
    html_page = urlopen(req)
    
    soup = BeautifulSoup(html_page, "lxml")
    
    links = []
    for link in soup.findAll('a'):
        links.append(link.get('href'))
    
    return links

def isXlsx(arquivo):
    if arquivo.find('xlsx') != -1:
        return True
    else:
        return False

def download(url: str, dest_folder: str): 
    if not os.path.exists(dest_folder):
        os.makedirs(dest_folder)  # create folder if it does not exist

    filename = url.split('/')[-1].replace("", "")  # be careful with file names
    file_path = os.path.join(dest_folder, filename)
    

    r = requests.get(url, stream=True)
    if r.ok:
        with open(file_path, 'wb') as f:
            for chunk in r.iter_content(chunk_size=1024 * 8):
                if chunk:
                    f.write(chunk)
                    f.flush()
                    os.fsync(f.fileno())
    else:  # HTTP status code 4XX/5XX
        print("Download failed: status code {}\n{}".format(r.status_code, r.text))
  

    read_file = pd.read_excel (destino_output + filename)
    read_file.to_csv (destino_output + filename.replace('.xlsx', '.csv'), index = None, header=True)    
    os.remove(destino_output + filename)
    
    return filename


def downall(urls):
    try:
        nome_arquivos = []
        for i in range(len(urls)):
            nome_arquivos.append(download('https://www.ibama.gov.br/' + urls[i], dest_folder=destino_output))
            
        print("\n Todos os arquivos foram baixados e convertidos! \n")
    except:
        print("\n !!! ERRO NO DOWNLOAD !!! \n ")
    return nome_arquivos    
  
#######################################################################################################
############################ Renomeando Arquivos ######################################################
#######################################################################################################
links = getLinks(site)

xlsx = []
for i in range(len(links)):
    if isXlsx(links[i]):
        xlsx.append(links[i])

urls = []    
for i in range(len(xlsx)):
    if xlsx[i].find('2020') == -1:
        urls.append(xlsx[i])

nome_arquivos_csv = downall(urls)
for i in range(len(nome_arquivos_csv)):
      nome_arquivos_csv[i] = nome_arquivos_csv[i].replace('.xlsx', '.csv')

with open(destino_output + 'Nome_dos_arquivos.csv', 'w', newline='') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=',',
    quotechar='|', quoting=csv.QUOTE_MINIMAL)
    spamwriter.writerow(nome_arquivos_csv[:])
        
        
