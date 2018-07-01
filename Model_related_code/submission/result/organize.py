# -*- coding: utf-8 -*-
"""
Created on Sat Apr 28 23:15:58 2018

@author: dedekinds
"""

import numpy as np
import pandas as pd
import os

#aqi48____________________________________________________________________________________
f = open('模板submission.csv')#模板
df =pd.read_csv(f)
total = df.values[:,0]

f = open('result_BJ_aqi48_ans.csv')
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
model_name = 'result_aqi48.csv'
pd_data.to_csv(os.path.join(model_dir, model_name),index=False)

#aqi48-75____________________________________________________________________________________
#f = open('模板submission.csv')#模板
#df =pd.read_csv(f)
#total = df.values[:,0]
#
#f = open('result_BJ_aqi48_75_ans.csv')
#df =pd.read_csv(f)
#model1 = df.values[:,1:]
#f = open('result_LD_aqi48_75_ans.csv')
#df =pd.read_csv(f)
#model2 = df.values[:,1:]
#
#model1 = np.row_stack((model1,model2))
#total = np.column_stack((total,model1))
#pd_data = pd.DataFrame(total)
#
#pd_data.columns = ['test_id','PM2.5','PM10','O3']
#model_dir = "last_submission"
#model_name = 'result_aqi48_75.csv'
#pd_data.to_csv(os.path.join(model_dir, model_name),index=False)

#iteration____________________________________________________________________________________
#f = open('模板submission.csv')#模板
#df =pd.read_csv(f)
#total = df.values[:,0]
#
#f = open('result_BJ_Iteration_ans.csv')
#df =pd.read_csv(f)
#model1 = df.values[:,1:]
#f = open('result_LD_Iteration_ans.csv')
#df =pd.read_csv(f)
#model2 = df.values[:,1:]
#
#model1 = np.row_stack((model1,model2))
#total = np.column_stack((total,model1))
#pd_data = pd.DataFrame(total)
#
#pd_data.columns = ['test_id','PM2.5','PM10','O3']
#model_dir = "last_submission"
#model_name = 'result_iter.csv'
#pd_data.to_csv(os.path.join(model_dir, model_name),index=False)

#aqi48-75+iter____________________________________________________________________________________
#result_BJ_merge_ans(aqi48_75+iter)_1.csv
#for temp in [1,3,5,7,9]:
#    f = open('模板submission.csv')#模板
#    df =pd.read_csv(f)
#    total = df.values[:,0]
#    
#    f = open('result_BJ_merge_ans(aqi48_75+iter)_'+str(temp)+'.csv')
#    df =pd.read_csv(f)
#    model1 = df.values[:,1:]
#    f = open('result_LD_merge_ans(aqi48_75+iter)_'+str(temp)+'.csv')
#    df =pd.read_csv(f)
#    model2 = df.values[:,1:]
#    
#    model1 = np.row_stack((model1,model2))
#    total = np.column_stack((total,model1))
#    pd_data = pd.DataFrame(total)
#    
#    pd_data.columns = ['test_id','PM2.5','PM10','O3']
#    model_dir = "last_submission"
#    model_name = 'result_merge2_'+str(temp)+'.csv'
#    pd_data.to_csv(os.path.join(model_dir, model_name),index=False)





#aqi48+aqi48____________________________________________________________________________________
#for temp in [1,3,5,7,9]:
#    f = open('模板submission.csv')#模板
#    df =pd.read_csv(f)
#    total = df.values[:,0]
#    
#    f = open('result_BJ_merge_ans(aqi48_75+aqi48)_'+str(temp)+'.csv')
#    df =pd.read_csv(f)
#    model1 = df.values[:,1:]
#    f = open('result_LD_merge_ans(aqi48_75+aqi48)_'+str(temp)+'.csv')
#    df =pd.read_csv(f)
#    model2 = df.values[:,1:]
#    
#    model1 = np.row_stack((model1,model2))
#    total = np.column_stack((total,model1))
#    pd_data = pd.DataFrame(total)
#    
#    pd_data.columns = ['test_id','PM2.5','PM10','O3']
#    model_dir = "last_submission"
#    model_name = 'result_merge3_'+str(temp)+'.csv'
#    pd_data.to_csv(os.path.join(model_dir, model_name),index=False)
    
    
print('ok!')