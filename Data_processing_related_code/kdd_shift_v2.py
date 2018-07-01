# -*- coding: utf-8 -*-
"""
Created on Thu May  3 21:16:11 2018

@author: jyt

@describe：KDD数据按列平移
"""


#import numpy as np
import pandas as pd
import time

print("Loading Data...")
st_time = time.time()

kdd_data = pd.read_csv(r"F:\temp_BJ_17_01_18_05-20_data_weather_75_model_full_result_new_new_with_encoding_without_NO2.csv")

print('Data import time[{}]'.format(time.time() - st_time))

#按站点及时间排序，必须排序
#kdd_data = pd.DataFrame(kdd_data).sort_values(['station_id','utc_time']).reset_index(drop=True)
del kdd_data['knn1_station'] 
del kdd_data['knn2_station']
del kdd_data['knn3_station']
del kdd_data['knn4_station']

def shift_data(df,grp_cols,shift_cols,shift_num,new_cols):
        df[new_cols] = df.groupby(grp_cols)[shift_cols].shift(shift_num)
        return( df )


#自身站点数据;（温度、压强、湿度、风速、PM2.5、PM10、O3）*（t1到t9）+ t1到t9)*风向
dirt_zs = {'temperature':'t1_temperature'
        ,'pressure':'t1_pressure'
        ,'humidity':'t1_humidity'
        ,'windspeed':'t1_windspeed'
        ,'PM2.5':'t1_PM2.5'
        ,'PM10':'t1_PM10'
        ,'O3':'t1_O3'
        }

for i in range(0,9):
    for  key in dirt_zs:
        shift_data(kdd_data,'station_id',dirt_zs[key],-i,'{var}_t{num}'.format(num=i+1,var=key))
 #       del kdd_data[dirt_zs[key]] 

#风向
dirt_win ={'winddirection':'t1_winddirection'}

for  key in dirt_win:
    for i in range(0,9):
        shift_data(kdd_data,'station_id',dirt_win[key],-i,'{var}_t{num}'.format(num=i+1,var=key))
    del kdd_data[dirt_win[key]] 

#4个临近点气象站数据;（对应的PM10，O3，风向，风速，PM2.5）*（t5到t9）
dirt_knn = {'knn1_PM10':'knn1_PM10'
            ,'knn1_O3':'knn1_O3'
            ,'knn1_winddirection':'knn1_winddirection'
            ,'knn1_windspeed':'knn1_windspeed'
            ,'knn1_PM2.5':'knn1_PM2.5'
           
            ,'knn2_PM10':'knn2_PM10'
            ,'knn2_O3':'knn2_O3'
            ,'knn2_winddirection':'knn2_winddirection'
            ,'knn2_windspeed':'knn2_windspeed'
            ,'knn2_PM2.5':'knn2_PM2.5'
                        
            ,'knn3_PM10':'knn3_PM10'
            ,'knn3_O3':'knn3_O3'
            ,'knn3_winddirection':'knn3_winddirection'
            ,'knn3_windspeed':'knn3_windspeed'
            ,'knn3_PM2.5':'knn3_PM2.5'
            
            ,'knn4_PM10':'knn4_PM10'
            ,'knn4_O3':'knn4_O3'
            ,'knn4_winddirection':'knn4_winddirection'
            ,'knn4_windspeed':'knn4_windspeed'
            ,'knn4_PM2.5':'knn4_PM2.5'
            }

for i in range(4,9):
    for  key in dirt_knn:
        shift_data(kdd_data,'station_id',dirt_knn[key],-i,'{var}_t{num}'.format(num=i+1,var=key))
       # del kdd_data[dirt_knn[key]]
       
       
#自身天气 t1_weather *（t9-t10）
#shift_data(kdd_data,'station_id','t1_weather',-8,'weather_t9')
#shift_data(kdd_data,'station_id','t1_weather',-9,'weather_t10')
#del kdd_data['t1_weather'] 
    
#自身站点数据;（PM2.5、PM10、O3）*(t10-t70)
dirt_zs2 = {
        'PM2.5':'t1_PM2.5'
        ,'PM10':'t1_PM10'
        ,'O3':'t1_O3'
        }
        
for i in range(9,69):
    for  key in dirt_zs2:
        shift_data(kdd_data,'station_id',dirt_zs2[key],-i,'{var}_t{num}'.format(num=i+1,var=key))
  #      del kdd_data[dirt_zs2[key]] 



for key in dirt_zs:
    del kdd_data[dirt_zs[key]] 
for key in dirt_knn:
    del kdd_data[dirt_knn[key]] 
 
 
    
del kdd_data['station_id']
del kdd_data['utc_time']

print('shift_time[{}]'.format(time.time() - st_time))


kdd_data.to_csv(r'F:\BJ_train_data_set_2017-01_2018-05-20_without_NO2_without_weather.csv',index=False,encoding='utf-8')

