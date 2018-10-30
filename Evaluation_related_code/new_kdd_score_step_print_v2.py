# -*- coding: utf-8 -*-
"""
Created on Wed May 16 21:08:47 2018

@author: JasonLeung
"""

import pandas as pd
import numpy as np
from requests.exceptions import RequestException
import requests
stat_latlon = pd.read_csv(r'F:\stat1.csv',header = None)
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
    print(url)
    zt = 0
    while zt == 0:
        try:
            respones= requests.get(url,headers=headers)
            zt = 1
            print(respones.status_code)
        except RequestException:
            print('Error')
            zt = 0
    df = pd.DataFrame([i.decode('utf8').split(',') for i in respones.content.splitlines()])
    df.columns = df.loc[0]
    #df_origin=df
    df = df.shift(-1,axis = 0).dropna(axis=0,how= 'all')
    df.columns = df.columns.map(colchuli)
    df.utc_time = pd.to_datetime(df.utc_time)
    floatcl = [i for i in df.columns if i not in ['stationId', 'utc_time']]
    df.loc[:,floatcl] = df.loc[:,floatcl].applymap(chulifloat)
    return df#,df_origin
def get_true(times,smaplev = 'new'):
    xlj = get_xianshang_true(times,'bj')
    bjtrue = xlj[(xlj.utc_time >= times)& (xlj.utc_time < pd.to_datetime(times) + pd.DateOffset(days = 2))]
    bjtrue['city']= 'bj'
    xlj = get_xianshang_true(times,'ld')
    ldtrue = xlj[(xlj.utc_time >= times)& (xlj.utc_time < pd.to_datetime(times) + pd.DateOffset(days = 2))]
    ldtrue['O3'] = 0
    ldtrue['city'] = 'ld'
    true = pd.concat([bjtrue[['stationId', 'utc_time', 'PM2.5', 'PM10','O3','city']]
    ,ldtrue[['stationId', 'utc_time', 'PM2.5', 'PM10','O3','city']]])
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
    smapedf.append(len(ck))
    return smapedf
def xsdf(true,sub2):
    true1 = true[true.test_id.map(lambda x:x[0].upper()) == true.test_id.map(lambda x:x[0])]
    true2 = true[true.test_id.map(lambda x:x[0].upper()) != true.test_id.map(lambda x:x[0])]
    jg2 = smape_pf_sub(true1,sub2)
    jg1 = smape_pf_sub(true2,sub2)
    return (np.mean(jg1) + np.mean(jg2)) / 2

true = get_true('2018-06-01 00:00:00')
sub2 = pd.read_csv(r'F:\6_1_6\result_total_feature_pinjie.csv')

# 添加hour列
# Add hour column
sub2['hour']=0
for i in range(0,48):
    for j in range(0,48):
        sub2.ix[[i*48+j],['hour']]=j

# 添加city列
# Add city column
sub2['city']='bj'
for i in range(1680,2304):
    sub2.ix[[i],['city']]='ld'

f = open(r'F:\6_1_6\result_total_feature_pinjie.txt','w')

# 按小时输出结果（i代表前i小时）
# print the prediction result according to the hour, here i represents first i hours.

print('hour,','result_item,','PM2.5(/total_result),','PM10,','O3(/len),','len',file=f)
for i in range(0,48):
    true_bj=true[(true['hour'] <= i) & (true['city']=='bj')]
    smape_pf_sub(true_bj,sub2)
    print('hour %s,'%i,'%s,'%'bj',smape_pf_sub(true_bj,sub2)[0],',',smape_pf_sub(true_bj,sub2)[1],',',smape_pf_sub(true_bj,sub2)[2],',',smape_pf_sub(true_bj,sub2)[3],',',file=f)
    true_ld=true[(true['hour'] <= i) & (true['city']=='ld')]
    smape_pf_sub(true_ld,sub2)
    print('hour %s,'%i,'%s,'%'ld',smape_pf_sub(true_ld,sub2)[0],',',smape_pf_sub(true_ld,sub2)[1],',',smape_pf_sub(true_ld,sub2)[2],',',file=f)
    jg2 = smape_pf_sub(true_bj,sub2)[0:3]
    jg1 = smape_pf_sub(true_ld,sub2)[0:2]
    print('hour %s,'%i,'Total Result,',(np.mean(jg1) + np.mean(jg2)) / 2,',',file=f)

f.close()
#xsdf(true,sub2)
