# -*- coding: utf-8 -*-
"""
Created on Sat Apr 28 23:15:58 2018

@author: dedekinds
"""

import numpy as np
import pandas as pd
import os



#aqi48-75____________________________________________________________________________________
f = open('模板submission.csv')#模板
df =pd.read_csv(f)
total = df.values[:,0]

f = open('result_BJ_aqi48_75_ans_include_April(smape_weather).csv')
df =pd.read_csv(f)
model1 = df.values[:,1:]
f = open('result_LD_aqi48_ans.csv')
df =pd.read_csv(f)
model2 = df.values[:,1:]

model1 = np.row_stack((model1,model2))
total = np.column_stack((total,model1))
pd_data = pd.DataFrame(total)

pd_data.columns = ['test_id','PM2.5','PM10','O3']
model_dir = "last_submission"
model_name = 'result_aqi48_75_include_April_smape_weather.csv'
pd_data.to_csv(os.path.join(model_dir, model_name),index=False)

#_________________________________________________________________________
f = open('模板submission.csv')#模板
df =pd.read_csv(f)
total = df.values[:,0]

f = open('result_BJ_merge_ans.csv')
df =pd.read_csv(f)
model1 = df.values[:,1:]
f = open('result_LD_aqi48_ans.csv')
df =pd.read_csv(f)
model2 = df.values[:,1:]

model1 = np.row_stack((model1,model2))
total = np.column_stack((total,model1))
pd_data = pd.DataFrame(total)

pd_data.columns = ['test_id','PM2.5','PM10','O3']

model_dir = "last_submission"
model_name = 'result_merge_75smape_weather.csv'
pd_data.to_csv(os.path.join(model_dir, model_name),index=False)
    

    
    
f = open('模板submission.csv')#模板
df =pd.read_csv(f)
total = df.values[:,0]

f = open('result_BJ_weather_new.csv')
df =pd.read_csv(f)
model1 = df.values[:,1:]
f = open('result_LD_aqi48_75_ans.csv')
df =pd.read_csv(f)
model2 = df.values[:,1:]

model1 = np.row_stack((model1,model2))
total = np.column_stack((total,model1))
pd_data = pd.DataFrame(total)

pd_data.columns = ['test_id','PM2.5','PM10','O3']
model_dir = "last_submission"
model_name = 'result_weather.csv'
pd_data.to_csv(os.path.join(model_dir, model_name),index=False)

print('ok!')