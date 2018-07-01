# -*- coding: utf-8 -*-
"""
Created on Thu May 17 22:39:47 2018

@author: jyt
"""

import pandas as pd
import time


print("Loading Data...")
st_time = time.time()

kdd_data = pd.read_csv(r"F:\temp_BJ_17_01_18_05-20_data_weather_75_model_full_result_new_new_with_encoding.csv")
print('Data import time[{}]'.format(time.time() - st_time))

#按站点及时间排序，必须排序
#kdd_data = pd.DataFrame(kdd_data).sort_values(['station_id','utc_time']).reset_index(drop=True)
del kdd_data['knn1_station'] 
del kdd_data['knn2_station']
del kdd_data['knn3_station']
del kdd_data['knn4_station']


#二阶交叉项
kdd_data['t1_PM2.5*PM10'] = kdd_data['t1_PM2.5'] * kdd_data['t1_PM10']
kdd_data['t1_PM2.5*O3'] = kdd_data['t1_PM2.5'] * kdd_data['t1_O3']
kdd_data['t1_PM10*O3'] = kdd_data['t1_PM10'] * kdd_data['t1_O3']

'''
item = {'PM2.5' : 't1_PM2.5'
        ,'PM10' : 't1_PM10'
        ,'O3' : 't1_O3'
        }

for key1 in item:
    for key2 in item:
        kdd_data['%s*%s'%(item[key1],key2)] = kdd_data[item[key1]] * kdd_data[item[key2]]
        
del kdd_data['t1_PM2.5*PM2.5'] 
del kdd_data['t1_PM10*PM10']
del kdd_data['t1_O3*O3']       
'''       

#平移函数
def shift_data(df,grp_cols,shift_cols,shift_num,new_cols):
        df[new_cols] = df.groupby(grp_cols)[shift_cols].shift(shift_num)
        return( df )


#PM2.5、PM10、O3 *（t1到t5）
dirt_zs = {'PM2.5' : 't1_PM2.5'
        ,'PM10'  : 't1_PM10'
        ,'O3'  : 't1_O3'
        }
for i in range(0,5):
    for  key in dirt_zs:
        shift_data(kdd_data,'station_id',dirt_zs[key],-i,'{var}_t{num}'.format(num=i+1,var=key))

dict_c = {'PM2.5*PM10':'t1_PM2.5*PM10'
          ,'PM2.5*O3' :'t1_PM2.5*O3'
          ,'PM10*O3' : 't1_PM10*O3'
            }       

for i in range(3,5):
    for  key in dict_c:
        shift_data(kdd_data,'station_id',dict_c[key],-i,'{var}_t{num}'.format(num=i+1,var=key))        


#4个临近点气象站数据;（PM2.5、PM10、O3）*（t4到t5)
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

for i in range(3,5):
    for  key in dirt_knn:
        shift_data(kdd_data,'station_id',dirt_knn[key],-i,'{var}_t{num}'.format(num=i+1,var=key))        


#小时 hour
kdd_data['hour'] = pd.to_datetime(kdd_data.utc_time).dt.hour.astype('uint8')
#取当日周几 0-6
kdd_data['week_day'] = pd.to_datetime(kdd_data.utc_time).dt.weekday.astype('uint8')

for i in range(5,36):
    for  key in dirt_zs:
        shift_data(kdd_data,'station_id',dirt_zs[key],-i,'{var}_t{num}'.format(num=i+1,var=key))




#删除无用变量

dirt1 = {'temperature' : 't1_temperature'
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
dirt2 = {'knn1_temperature'   : 'knn1_temperature'
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

for key in dirt1:
    del kdd_data[dirt1[key]] 
for key in dirt2:
    del kdd_data[dirt2[key]] 
for key in dict_c:
    del kdd_data[dict_c[key]]

del kdd_data['station_id']
del kdd_data['utc_time']
del kdd_data['t1_weather']
del kdd_data['t1_winddirection']


kdd_data.to_csv(r"F:\data_BJ_2017-01_2018-05-20_LGBM.csv",index = False,  encoding = 'utf-8')
#temp = kdd_data.head(100)
#temp.to_csv(r"F:\temp_BJ_2017-01_2018-05-20-LGBM_sample.csv",index = False, encoding = 'utf-8')