# -*- coding: utf-8 -*-
"""
Created on Sun May 13 01:14:50 2018

@author: JasonLeung
"""

import pandas as pd
import time
import numpy as np
import math

print("Loading Data...")
st_time = time.time()

kdd_data = pd.read_csv(r"F:\temp_BJ_17_01_18_05-20_data_weather_75_model_full_result_new_new_with_encoding.csv")

print('Data import time[{}]'.format(time.time() - st_time))

del kdd_data['knn1_station'] 
del kdd_data['knn2_station']
del kdd_data['knn3_station']
del kdd_data['knn4_station']

#平移函数
def shift_data(df,grp_cols,shift_cols,shift_num,new_cols):
        df[new_cols] = df.groupby(grp_cols)[shift_cols].shift(shift_num)
        return( df )


#自身站点数据;（PM2.5、PM10、O3）*（t1）
dirt_zs = {
        'PM2.5' : 't1_PM2.5',
        'PM10'  : 't1_PM10',
        'O3'  : 't1_O3'
        }
#t1*(PM2.5 PM10 O3)
for i in range(0,1):
    for  key in dirt_zs:
        shift_data(kdd_data,'station_id',dirt_zs[key],-i,'{var}_t{num}'.format(num=i+1,var=key))

#PM10二阶交叉项
cox_PM10 = {'PM2.5' : 't1_PM2.5'
            ,'O3' : 't1_O3'
            }
for key in cox_PM10:
    kdd_data['{var}*PM10'.format(var=cox_PM10[key])] = kdd_data[cox_PM10[key]] * kdd_data['t1_PM10']

#PM2.5二阶交叉项
cox_PM25 = {
            'O3' : 't1_O3'
            }
for key in cox_PM25:
    kdd_data['{var}*PM2.5'.format(var=cox_PM10[key])] = kdd_data[cox_PM10[key]] * kdd_data['t1_PM2.5']

del kdd_data['t1_winddirection'] 

#4个临近点气象站数据;（PM2.5、PM10、O3）*（t1)
dirt_knn = {            
            'knn1_PM2.5'        : 'knn1_PM2.5'
            ,'knn1_PM10'         : 'knn1_PM10'
            ,'knn1_O3'           : 'knn1_O3'
            
            ,'knn2_PM2.5'        : 'knn2_PM2.5'
            ,'knn2_PM10'         : 'knn2_PM10'
            ,'knn2_O3'           : 'knn2_O3'
       
            ,'knn3_PM2.5'        : 'knn3_PM2.5'
            ,'knn3_PM10'         : 'knn3_PM10'
            ,'knn3_O3'           : 'knn3_O3'
         
           
            ,'knn4_PM2.5'        : 'knn4_PM2.5'
            ,'knn4_PM10'         : 'knn4_PM10'
            ,'knn4_O3'           : 'knn4_O3'
            }
#t1 * 临近4站点（PM2.5 PM10 O3）
for i in range(0,1):
    for  key in dirt_knn:
        shift_data(kdd_data,'station_id',dirt_knn[key],-i,'{var}_t{num}'.format(num=i+1,var=key))
        
        
#小时 hour
kdd_data['hour'] = pd.to_datetime(kdd_data.utc_time).dt.hour.astype('uint8')
kdd_data['hour_sin']=np.sin((kdd_data['hour']/24)*2*math.pi) 
kdd_data['hour_cos']=np.cos((kdd_data['hour']/24)*2*math.pi) 
del kdd_data['hour']

#取当日周几 0-6
kdd_data['week_day'] = pd.to_datetime(kdd_data.utc_time).dt.weekday.astype('uint8')
kdd_data['week_day_sin']=np.sin((kdd_data['week_day']/7)*2*math.pi) 
kdd_data['week_day_cos']=np.cos((kdd_data['week_day']/7)*2*math.pi) 
del kdd_data['week_day']

del kdd_data['t1_weather'] 
   
 #(t6-t36)*(PM2.5 PM10 O3)
#自身站点数据;（PM2.5、PM10、O3）*(t6-t36)
dirt_zs2 = {
        'PM2.5':'t1_PM2.5'
        ,'PM10':'t1_PM10'
        ,'O3':'t1_O3'
        }
        
for i in range(5,36):
    for  key in dirt_zs2:
        shift_data(kdd_data,'station_id',dirt_zs2[key],-i,'{var}_t{num}'.format(num=i+1,var=key))

#需要删除的key
dirt_knn_del = {'knn1_temperature'   : 'knn1_temperature'
            ,'knn1_pressure'     : 'knn1_pressure'
            ,'knn1_humidity'     : 'knn1_humidity'
            ,'knn1_windspeed'    : 'knn1_windspeed'
            ,'knn1_winddirection': 'knn1_winddirection'            
            ,'knn1_PM2.5'        : 'knn1_PM2.5'
            ,'knn1_PM10'         : 'knn1_PM10'
            ,'knn1_O3'           : 'knn1_O3'
            ,'knn1_NO2'          : 'knn1_NO2'
            ,'knn1_CO'           : 'knn1_CO'
            ,'knn1_SO2'          : 'knn1_SO2'
                        
            ,'knn2_temperature'   : 'knn2_temperature'
            ,'knn2_pressure'     : 'knn2_pressure'
            ,'knn2_humidity'     : 'knn2_humidity'
            ,'knn2_windspeed'    : 'knn2_windspeed'
            ,'knn2_winddirection': 'knn2_winddirection'            
            ,'knn2_PM2.5'        : 'knn2_PM2.5'
            ,'knn2_PM10'         : 'knn2_PM10'
            ,'knn2_O3'           : 'knn2_O3'
            ,'knn2_NO2'          : 'knn2_NO2'
            ,'knn2_CO'           : 'knn2_CO'
            ,'knn2_SO2'          : 'knn2_SO2'
                        
            ,'knn3_temperature'   : 'knn3_temperature'
            ,'knn3_pressure'     : 'knn3_pressure'
            ,'knn3_humidity'     : 'knn3_humidity'
            ,'knn3_windspeed'    : 'knn3_windspeed'
            ,'knn3_winddirection': 'knn3_winddirection'            
            ,'knn3_PM2.5'        : 'knn3_PM2.5'
            ,'knn3_PM10'         : 'knn3_PM10'
            ,'knn3_O3'           : 'knn3_O3'
            ,'knn3_NO2'          : 'knn3_NO2'
            ,'knn3_CO'           : 'knn3_CO'
            ,'knn3_SO2'          : 'knn3_SO2'
            
            ,'knn4_temperature'   : 'knn4_temperature'
            ,'knn4_pressure'     : 'knn4_pressure'
            ,'knn4_humidity'     : 'knn4_humidity'
            ,'knn4_windspeed'    : 'knn4_windspeed'
            ,'knn4_winddirection': 'knn4_winddirection'            
            ,'knn4_PM2.5'        : 'knn4_PM2.5'
            ,'knn4_PM10'         : 'knn4_PM10'
            ,'knn4_O3'           : 'knn4_O3'
            ,'knn4_NO2'          : 'knn4_NO2'
            ,'knn4_CO'           : 'knn4_CO'
            ,'knn4_SO2'          : 'knn4_SO2'
 
            }

dirt_zs_del = {'temperature' : 't1_temperature'
        ,'pressure' : 't1_pressure'
        ,'humidity' : 't1_humidity'
        ,'windspeed': 't1_windspeed'
        ,'PM2.5' : 't1_PM2.5'
        ,'PM10'  : 't1_PM10'
        ,'O3'  : 't1_O3'
        ,'NO2' : 't1_NO2'
        ,'CO'  : 't1_CO'
        ,'SO2' : 't1_SO2'
        }
#删除无用变量
for key in dirt_zs_del:
    del kdd_data[dirt_zs_del[key]] 
for key in dirt_knn_del:
    del kdd_data[dirt_knn_del[key]] 

del kdd_data['station_id']
del kdd_data['utc_time']


print('shift_time[{}]'.format(time.time() - st_time))

kdd_data.to_csv(r"F:\data_BJ_2017-01_2018-05-20_LSTM.csv",index = False,encoding = 'utf-8')#header=None, 
#temp = kdd_data.head(100)
#temp.to_csv(r"F:\temp_BJ_LSTM_sample.csv",index = False, encoding = 'utf-8')