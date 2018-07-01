# -*- coding: utf-8 -*-
"""
Created on Sun May 13 01:14:50 2018

@author: JasonLeung
"""

import pandas as pd
import time


print("Loading Data...")
st_time = time.time()

kdd_data = pd.read_csv(r"F:\temp_BJ_17_01_18_05-20_data_weather_75_model_full_result_new_new_with_encoding.csv")
#kdd_data['hour'] = pd.to_datetime(kdd_data.utc_time).dt.hour.astype('uint8')
#kdd_data=kdd_data[(kdd_data.hour == 13)|(kdd_data.hour == 12)|(kdd_data.hour == 14)]
#del kdd_data['hour']
print('Data import time[{}]'.format(time.time() - st_time))

#t1风向编码
kdd_data['t1_winddirection'][(kdd_data['t1_winddirection']<=45) & (kdd_data['t1_winddirection']>=0)]=1
kdd_data['t1_winddirection'][(kdd_data['t1_winddirection']>45) & (kdd_data['t1_winddirection']<=90)]=2
kdd_data['t1_winddirection'][(kdd_data['t1_winddirection']>90) & (kdd_data['t1_winddirection']<=135)]=3
kdd_data['t1_winddirection'][(kdd_data['t1_winddirection']>135) & (kdd_data['t1_winddirection']<=180)]=4
kdd_data['t1_winddirection'][(kdd_data['t1_winddirection']>180) & (kdd_data['t1_winddirection']<=225)]=5
kdd_data['t1_winddirection'][(kdd_data['t1_winddirection']>225) & (kdd_data['t1_winddirection']<=270)]=6
kdd_data['t1_winddirection'][(kdd_data['t1_winddirection']>270) & (kdd_data['t1_winddirection']<=315)]=7
kdd_data['t1_winddirection'][(kdd_data['t1_winddirection']>315) & (kdd_data['t1_winddirection']<=360)]=8

#knn1风向编码
kdd_data['knn1_winddirection'][(kdd_data['knn1_winddirection']<=45) & (kdd_data['knn1_winddirection']>=0)]=1
kdd_data['knn1_winddirection'][(kdd_data['knn1_winddirection']>45) & (kdd_data['knn1_winddirection']<=90)]=2
kdd_data['knn1_winddirection'][(kdd_data['knn1_winddirection']>90) & (kdd_data['knn1_winddirection']<=135)]=3
kdd_data['knn1_winddirection'][(kdd_data['knn1_winddirection']>135) & (kdd_data['knn1_winddirection']<=180)]=4
kdd_data['knn1_winddirection'][(kdd_data['knn1_winddirection']>180) & (kdd_data['knn1_winddirection']<=225)]=5
kdd_data['knn1_winddirection'][(kdd_data['knn1_winddirection']>225) & (kdd_data['knn1_winddirection']<=270)]=6
kdd_data['knn1_winddirection'][(kdd_data['knn1_winddirection']>270) & (kdd_data['knn1_winddirection']<=315)]=7
kdd_data['knn1_winddirection'][(kdd_data['knn1_winddirection']>315) & (kdd_data['knn1_winddirection']<=360)]=8

#knn2风向编码
kdd_data['knn2_winddirection'][(kdd_data['knn2_winddirection']<=45) & (kdd_data['knn2_winddirection']>=0)]=1
kdd_data['knn2_winddirection'][(kdd_data['knn2_winddirection']>45) & (kdd_data['knn2_winddirection']<=90)]=2
kdd_data['knn2_winddirection'][(kdd_data['knn2_winddirection']>90) & (kdd_data['knn2_winddirection']<=135)]=3
kdd_data['knn2_winddirection'][(kdd_data['knn2_winddirection']>135) & (kdd_data['knn2_winddirection']<=180)]=4
kdd_data['knn2_winddirection'][(kdd_data['knn2_winddirection']>180) & (kdd_data['knn2_winddirection']<=225)]=5
kdd_data['knn2_winddirection'][(kdd_data['knn2_winddirection']>225) & (kdd_data['knn2_winddirection']<=270)]=6
kdd_data['knn2_winddirection'][(kdd_data['knn2_winddirection']>270) & (kdd_data['knn2_winddirection']<=315)]=7
kdd_data['knn2_winddirection'][(kdd_data['knn2_winddirection']>315) & (kdd_data['knn2_winddirection']<=360)]=8

#knn3风向编码
kdd_data['knn3_winddirection'][(kdd_data['knn3_winddirection']<=45) & (kdd_data['knn3_winddirection']>=0)]=1
kdd_data['knn3_winddirection'][(kdd_data['knn3_winddirection']>45) & (kdd_data['knn3_winddirection']<=90)]=2
kdd_data['knn3_winddirection'][(kdd_data['knn3_winddirection']>90) & (kdd_data['knn3_winddirection']<=135)]=3
kdd_data['knn3_winddirection'][(kdd_data['knn3_winddirection']>135) & (kdd_data['knn3_winddirection']<=180)]=4
kdd_data['knn3_winddirection'][(kdd_data['knn3_winddirection']>180) & (kdd_data['knn3_winddirection']<=225)]=5
kdd_data['knn3_winddirection'][(kdd_data['knn3_winddirection']>225) & (kdd_data['knn3_winddirection']<=270)]=6
kdd_data['knn3_winddirection'][(kdd_data['knn3_winddirection']>270) & (kdd_data['knn3_winddirection']<=315)]=7
kdd_data['knn3_winddirection'][(kdd_data['knn3_winddirection']>315) & (kdd_data['knn3_winddirection']<=360)]=8

#knn3风向编码
kdd_data['knn4_winddirection'][(kdd_data['knn4_winddirection']<=45) & (kdd_data['knn4_winddirection']>=0)]=1
kdd_data['knn4_winddirection'][(kdd_data['knn4_winddirection']>45) & (kdd_data['knn4_winddirection']<=90)]=2
kdd_data['knn4_winddirection'][(kdd_data['knn4_winddirection']>90) & (kdd_data['knn4_winddirection']<=135)]=3
kdd_data['knn4_winddirection'][(kdd_data['knn4_winddirection']>135) & (kdd_data['knn4_winddirection']<=180)]=4
kdd_data['knn4_winddirection'][(kdd_data['knn4_winddirection']>180) & (kdd_data['knn4_winddirection']<=225)]=5
kdd_data['knn4_winddirection'][(kdd_data['knn4_winddirection']>225) & (kdd_data['knn4_winddirection']<=270)]=6
kdd_data['knn4_winddirection'][(kdd_data['knn4_winddirection']>270) & (kdd_data['knn4_winddirection']<=315)]=7
kdd_data['knn4_winddirection'][(kdd_data['knn4_winddirection']>315) & (kdd_data['knn4_winddirection']<=360)]=8

#kdd_data.to_csv(r"F:/temp_BJ_winddirection_encoding.csv",index = False,encoding = 'utf-8')
#按站点及时间排序，必须排序
#kdd_data = pd.DataFrame(kdd_data).sort_values(['station_id','utc_time']).reset_index(drop=True)
del kdd_data['knn1_station'] 
del kdd_data['knn2_station']
del kdd_data['knn3_station']
del kdd_data['knn4_station']

#PM10二阶交叉项
cox_PM10 = {'SO2' : 't1_SO2'
            ,'RH' : 't1_humidity'
            ,'P'  : 't1_pressure'
            ,'O3' : 't1_O3'
            ,'CO' : 't1_CO'
            }
for key in cox_PM10:
    kdd_data['{var}*PM10'.format(var=cox_PM10[key])] = kdd_data[cox_PM10[key]] * kdd_data['t1_PM10']


#其他交叉项
kdd_data['t1_NO2*RH'] = kdd_data['t1_NO2'] * kdd_data['t1_humidity']
kdd_data['t1_O3*T'] = kdd_data['t1_O3'] * kdd_data['t1_temperature']



#平移函数
def shift_data(df,grp_cols,shift_cols,shift_num,new_cols):
        df[new_cols] = df.groupby(grp_cols)[shift_cols].shift(shift_num)
        return( df )


#自身站点数据;（温度、压强、湿度、风速、PM2.5、PM10、O3、NO2、CO、SO2）*（t1到t9）
dirt_zs = {'temperature' : 't1_temperature'
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
for i in range(0,9):
    for  key in dirt_zs:
        shift_data(kdd_data,'station_id',dirt_zs[key],-i,'{var}_t{num}'.format(num=i+1,var=key))

#风向 *（t1到t9）
for i in range(0,9):
    shift_data(kdd_data,'station_id','t1_winddirection',-i,'winddirection_t{num}'.format(num=i+1))
del kdd_data['t1_winddirection'] 

#4个临近点气象站数据;（对应的温度、压强、湿度、风速、风向、PM2.5、PM10、O3、NO2、CO、SO2）*（t7到t9)
dirt_knn = {'knn1_temperature'   : 'knn1_temperature'
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

for i in range(6,9):
    for  key in dirt_knn:
        shift_data(kdd_data,'station_id',dirt_knn[key],-i,'{var}_t{num}'.format(num=i+1,var=key))
     
 
#取当日周几 0-6
kdd_data['week_day'] = pd.to_datetime(kdd_data.utc_time).dt.weekday.astype('uint8')
#取月份month
kdd_data['month'] = pd.to_datetime(kdd_data.utc_time).dt.month.astype('uint8') 

cox_PM10 = {'SO2' : 't1_SO2'
            ,'RH' : 't1_humidity'
            ,'P'  : 't1_pressure'
            ,'O3' : 't1_O3'
            ,'CO' : 't1_CO'
            }

#t8-t9 * 各种交互特征
cox_item = {'NO2*RH'    : 't1_NO2*RH'
            ,'O3*T'     : 't1_O3*T'
            ,'SO2*PM10' : 't1_SO2*PM10'
            ,'humidity*PM10' : 't1_humidity*PM10'
            ,'pressure*PM10' : 't1_pressure*PM10'
            ,'O3*PM10' : 't1_O3*PM10'
            ,'CO*PM10' : 't1_CO*PM10'
            ,
            }
for i in range(7,9):
    for key in cox_item:
        shift_data(kdd_data,'station_id',cox_item[key],-i,'{var}_t{num}'.format(num=i+1,var=key))

#circle
#kdd_data['circle']=0
#kdd_data['circle'][(kdd_data['station_id']=='dongsi_aq') | (kdd_data['station_id']=='tiantan_aq')| (kdd_data['station_id']=='guanyuan_aq')|(kdd_data['station_id']=='wanshouxigong_aq')|(kdd_data['station_id']=='qianmen_aq')|(kdd_data['station_id']=='yongdingmennei_aq')|(kdd_data['station_id']=='xizhimenbei_aq')]=1
#kdd_data['circle'][(kdd_data['station_id']=='aotizhongxin_aq') | (kdd_data['station_id']=='nongzhanguan_aq')| (kdd_data['station_id']=='nansanhuan_aq')]=2
#kdd_data['circle'][(kdd_data['station_id']=='wanliu_aq') | (kdd_data['station_id']=='fengtaihuayuan_aq')| (kdd_data['station_id']=='dongsihuan_aq')]=3
#kdd_data['circle'][(kdd_data['station_id']=='zhiwuyuan_aq') | (kdd_data['station_id']=='gucheng_aq')| (kdd_data['station_id']=='yizhuang_aq')]=4
#kdd_data['circle'][(kdd_data['station_id']=='beibuxinqu_aq') | (kdd_data['station_id']=='yungang_aq')| (kdd_data['station_id']=='fangshan_aq')|(kdd_data['station_id']=='daxing_aq')|(kdd_data['station_id']=='tongzhou_aq')|(kdd_data['station_id']=='shunyi_aq')|(kdd_data['station_id']=='pingchang_aq')|(kdd_data['station_id']=='mentougou_aq')]=5
#kdd_data['circle'][(kdd_data['station_id']=='huairou_aq') | (kdd_data['station_id']=='miyun_aq')| (kdd_data['station_id']=='dingling_aq')|(kdd_data['station_id']=='badaling_aq')|(kdd_data['station_id']=='yongledian_aq')|(kdd_data['station_id']=='yufa_aq')|(kdd_data['station_id']=='liulihe_aq')]=6
#kdd_data['circle'][(kdd_data['station_id']=='pinggu_aq') | (kdd_data['station_id']=='yanqin_aq')| (kdd_data['station_id']=='miyunshuiku_aq')| (kdd_data['station_id']=='donggaocun_aq')]=7

#小时 hour
kdd_data['hour'] = pd.to_datetime(kdd_data.utc_time).dt.hour.astype('uint8')
        
#自身天气 t1_weather *（t9-t10）
shift_data(kdd_data,'station_id','t1_weather',-8,'weather_t9')
shift_data(kdd_data,'station_id','t1_weather',-9,'weather_t10')
del kdd_data['t1_weather'] 
   
 #(t10-t69)*(PM2.5 PM10 O3)
#自身站点数据;（PM2.5、PM10、O3）*(t10-t70)
dirt_zs2 = {
        'PM2.5':'t1_PM2.5'
        ,'PM10':'t1_PM10'
        ,'O3':'t1_O3'
        }
        
for i in range(9,69):
    for  key in dirt_zs2:
        shift_data(kdd_data,'station_id',dirt_zs2[key],-i,'{var}_t{num}'.format(num=i+1,var=key))

##只保留hour为12 13 14的记录
#kdd_data=kdd_data[(kdd_data.hour == 12)|(kdd_data.hour == 13)|(kdd_data.hour == 14)]

#删除无用变量
for key in dirt_zs:
    del kdd_data[dirt_zs[key]] 
for key in dirt_knn:
    del kdd_data[dirt_knn[key]] 
for key in cox_item:
    del kdd_data[cox_item[key]]

#del kdd_data['station_id']
#del kdd_data['utc_time']
#del kdd_data['week_day']

print('shift_time[{}]'.format(time.time() - st_time))

kdd_data.to_csv(r"F:\data_BJ_2017-01_2018-05-20_sample_weather_last_position_with_header_include_hour_weekday_month_winddirection_encoding_with_circle_with_utc_time.csv",index = False,encoding = 'utf-8')#header=None, 