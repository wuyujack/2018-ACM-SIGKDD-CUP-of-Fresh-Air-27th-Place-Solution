import os
import sys  
import pandas as pd
import random
import numpy as np




#location = 'BJ'
#model_dir = "result"
#model_name = 'result_'+location+'_Iteration_ans.csv'
#f = open(os.path.join(model_dir, model_name))
#df =pd.read_csv(f)
#model1 = df.values[:,1:]
#
#model_name = 'result_'+location+'_aqi48_75_ans_include_April.csv'
#f = open(os.path.join(model_dir, model_name))
#df =pd.read_csv(f)
#model2 = df.values[:,1:]
#
#for i in [1,3,5,7,9]:
#    pd_data = pd.DataFrame(model1 * 0.1*i+model2 *0.1*(10-i))
#    print(pd_data)
#    model_name = 'result_'+location+'_merge_ans(aqi48_75+iter)_include_April'+str(i)+'.csv'
#    pd_data.to_csv(os.path.join(model_dir, model_name))

#________________________________
location = 'BJ'
model_dir = "result"
model_name = 'result_'+location+'_aqi48_include_April_enhance2hour.csv'#result_BJ_aqi48_include_April_enhance2hour.csv
f = open(os.path.join(model_dir, model_name))
df =pd.read_csv(f)
model1 = df.values[:,1:]

model_name = 'result_'+location+'_aqi48_75_ans_include_April.csv'
f = open(os.path.join(model_dir, model_name))
df =pd.read_csv(f)
model2 = df.values[:,1:]

for i in [3]:#[1,3,5,7,9]:
    pd_data = pd.DataFrame(model1 * 0.1*i+model2 *0.1*(10-i))
    print(pd_data)
    model_name = 'result_'+location+'_merge_ans.csv'#(aqi48_75+aqi48)_include_April'+str(i)+'.csv'
    pd_data.to_csv(os.path.join(model_dir, model_name))

#___________


#location = 'LD'
#model_dir = "result"
#model_name = 'result_'+location+'_Iteration_ans.csv'
#f = open(os.path.join(model_dir, model_name))
#df =pd.read_csv(f)
#model1 = df.values[:,1:]
#
#model_name = 'result_'+location+'_aqi48_75_ans.csv'
#f = open(os.path.join(model_dir, model_name))
#df =pd.read_csv(f)
#model2 = df.values[:,1:]
#
#for i in [1,3,5,7,9]:
#    pd_data = pd.DataFrame(model1 * 0.1*i+model2 *0.1*(10-i))
#    print(pd_data)
#    model_name = 'result_'+location+'_merge_ans(aqi48_75+iter)_'+str(i)+'.csv'
#    pd_data.to_csv(os.path.join(model_dir, model_name))

#________________________________
#location = 'LD'
#model_dir = "result"
#model_name = 'result_'+location+'_aqi48_ans.csv'
#f = open(os.path.join(model_dir, model_name))
#df =pd.read_csv(f)
#model1 = df.values[:,1:]

#model_name = 'result_'+location+'_aqi48_75_ans.csv'
#f = open(os.path.join(model_dir, model_name))
#df =pd.read_csv(f)
#model2 = df.values[:,1:]

#for i in [1,3,5,7,9]:
#    pd_data = pd.DataFrame(model1 * 0.1*i+model2 *0.1*(10-i))
#    print(pd_data)
#    model_name = 'result_'+location+'_merge_ans(aqi48_75+aqi48)_'+str(i)+'.csv'
#    pd_data.to_csv(os.path.join(model_dir, model_name))