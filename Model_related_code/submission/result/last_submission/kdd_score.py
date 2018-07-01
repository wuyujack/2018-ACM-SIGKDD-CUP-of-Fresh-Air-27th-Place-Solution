# -*- coding: utf-8 -*-
"""
Created on Sat May 12 17:43:20 2018

@author: dedekinds
"""

import numpy as np
import pandas as pd
from requests.exceptions import RequestException
import requests
import sys

import warnings
warnings.filterwarnings("ignore")

arr = []
for arg in sys.argv:  
    #print(arg)
    arr.append(arg)
    
    
stat_latlon = pd.read_csv('stat1.csv',header = None)
stat_latlon = stat_latlon[[0,1,2,3]]
stat_latlon.columns = ['dq','stationId','lat','lon']
headers = {
    'User-Agent':'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36'
}
cw = {'wanshouxig_aq':'wanshouxigong_aq', 'aotizhongx_aq':'aotizhongxin_aq', 'nongzhangu_aq':'nongzhanguan_aq', 'fengtaihua_aq':'fengtaihuayuan_aq',
       'miyunshuik_aq':'miyunshuiku_aq', 'yongdingme_aq':'yongdingmennei_aq', 'xizhimenbe_aq':'xizhimenbei_aq'}
gz = {value:key for key,value in cw.items()}
def colchuli(x):
    if x == 'time':return 'utc_time'
    if x == 'station_id':return 'stationId'
    x = str(x).replace('_Concentration','').replace('.','').upper()
    if x == 'PM25':
        return 'PM2.5'
    else:
        return x
def chulifloat(x):
    try:
        return float(x)
    except:
        return np.NaN
def get_xianshang_true(times,city):
    time_start = (pd.to_datetime(times) - pd.DateOffset(days = 1)).strftime('%Y-%m-%d-%H')
    time_end = (pd.to_datetime(times) + pd.DateOffset(days = 2)).strftime('%Y-%m-%d-%H')
    url = 'https://biendata.com/competition/airquality/%s/%s/%s/2k0d1d8'%(city,time_start,time_end)
    #print(url)
    zt = 0
    while zt == 0:
        try:
            respones= requests.get(url,headers=headers)
            zt = 1
            #print(respones.status_code)
        except RequestException:
            #print('Error')
            zt = 0
    df = pd.DataFrame([i.decode('utf8').split(',') for i in respones.content.splitlines()])
    df.columns = df.loc[0]
    df = df.shift(-1,axis = 0).dropna(axis=0,how= 'all')
    df.columns = df.columns.map(colchuli)
    df.utc_time = pd.to_datetime(df.utc_time)
    floatcl = [i for i in df.columns if i not in ['stationId', 'utc_time']]
    df.loc[:,floatcl] = df.loc[:,floatcl].applymap(chulifloat)
    return df
def get_true(times,smaplev = 'new'):
    xlj = get_xianshang_true(times,'bj')
    bjtrue = xlj[(xlj.utc_time >= times)& (xlj.utc_time < pd.to_datetime(times) + pd.DateOffset(days = 2))]
    xlj = get_xianshang_true(times,'ld')
    ldtrue = xlj[(xlj.utc_time >= times)& (xlj.utc_time < pd.to_datetime(times) + pd.DateOffset(days = 2))]
    ldtrue['O3'] = 0
    true = pd.concat([bjtrue[['stationId', 'utc_time', 'PM2.5', 'PM10','O3']]
    ,ldtrue[['stationId', 'utc_time', 'PM2.5', 'PM10','O3']]])
    true['hour'] = true.utc_time.dt.hour
    true['hour'] = true.apply(lambda x: x['hour'] + 24 if x['utc_time'] >= pd.to_datetime(times) + pd.DateOffset(days = 1) else x['hour'],axis=1)
    if smaplev == 'old':
        true['test_id'] = true.stationId.map(lambda x:gz[x] if x in gz.keys() else x )+'#'+(true.hour).astype(str)
    else:
        true['test_id'] = true.stationId+'#'+(true.hour).astype(str)
    true = true[true.stationId.isin(stat_latlon.stationId)]
    true = true.dropna()
    true = true[true['PM2.5'] >=0]
    true = true[true['PM10'] >=0]
    true = true[true['O3'] >=0]
    return true
def smape(actual, predicted):
    a = np.abs(np.array(actual) - np.array(predicted))
    b = np.array(actual) + np.array(predicted)
    return 2 * np.mean(np.divide(a, b, out=np.zeros_like(a), where=b!=0, casting='unsafe'))
def smape_pf_sub(true,sub2):
    smapedf = []
    truez = []
    predz = []    
    for label in ['PM2.5','PM10','O3']:
        ck = pd.merge(true[['test_id',label]],sub2[['test_id',label]],on = 'test_id',how = 'inner')
        ck = ck[ck['%s_x'%label].notnull()]
        if (label == 'O3') & (true.test_id.map(lambda x:x[0].upper()).values[0] == true.test_id.map(lambda x:x[0]).values[0]):continue
        print(label,len(ck))
        smapedf.append(smape(ck['%s_x'%label],ck['%s_y'%label]))
        predz.append(ck['%s_x'%label])
        truez.append(ck['%s_y'%label])
        print('%s:'%label,smape(ck['%s_x'%label],ck['%s_y'%label]))
    #smapedf = smape(truez,predz)
    return smapedf
def xsdf(true,sub2):
    true1 = true[true.test_id.map(lambda x:x[0].upper()) == true.test_id.map(lambda x:x[0])]
    true2 = true[true.test_id.map(lambda x:x[0].upper()) != true.test_id.map(lambda x:x[0])]
    jg2 = smape_pf_sub(true1,sub2)
    jg1 = smape_pf_sub(true2,sub2)
    return (np.mean(jg1) + np.mean(jg2)) / 2




true = get_true('2018-05-'+arr[1]+ ' 00:00:00')#'2018-05-07 00:00:00'
sub2 = pd.read_csv(arr[2])
print(arr[2])
print(xsdf(true,sub2))
print('\n')