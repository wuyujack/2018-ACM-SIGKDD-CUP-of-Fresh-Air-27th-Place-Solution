import os
import sys  
import pandas as pd
import random
import numpy as np
import matplotlib.pyplot as plt
import lightgbm as lgb
from sklearn.externals import joblib
from sklearn.ensemble import BaggingRegressor


for arg in sys.argv:  
    temp = arg
delay = int(temp)
print(delay)
pre_time = 48#<=60

location = 'BJ'
f = open('/home/dedekinds/aqi_data_submission_'+location+'.csv')
df =pd.read_csv(f)
total_data = df.values
num_of_variable =[56,65][location == 'BJ']#beiing
test_x = total_data[:,:num_of_variable]

def num_out_val(location):
    if location == 'LD':return 2
    else:return 3
    
def recall_aqi(location,data,model_index):
    model_dir = "/home/dedekinds/A_meo_code/aqi48"
    model_name = '_lightgbm_'+location+str(model_index)+'_include_April.txt'
    model = joblib.load(os.path.join(model_dir, model_name))
    temp_ans = 0
    for mod in model:
        temp_ans+=mod.predict(data, num_iteration=mod.best_iteration_)
    return (temp_ans/len(model))[0]

ans = np.zeros((1,3))
for i in range(len(total_data)):
    data = test_x[i].reshape(-1,num_of_variable)
    temp_ans = []
    for j in range(delay*num_out_val(location),(delay+pre_time)*num_out_val(location)):
        temp_ans.append(recall_aqi(location,data,j))
    temp_ans = np.array(temp_ans).reshape(-1,num_out_val(location))
    if location == 'LD':
        temp_ans = np.column_stack((temp_ans,np.zeros( (np.shape(temp_ans)[0],1) )))
    ans = np.row_stack((ans,temp_ans))
ans = np.delete(ans,[0],axis=0)  
    

#处理预测中可能出现的负数
def remove_nagative(ans):
    location  = np.where(ans<0)
    row = location[0]
    col = location[1]
    for i in range(len(row)):
        if row[i]-1>0 and row[i]+1<len(ans) and ans[row[i]-1][col[i]]>0 and ans[row[i]+1][col[i]]>0:
            ans[row[i]][col[i]] = (  ans[row[i]-1][col[i]]+ans[row[i]+1][col[i]]   )/2
    
    for j in range(len(ans[0])):#处理第一行
        if ans[0][j]<0:
            t = 0
            while True:
                if ans[0+t][j]>0:
                    ans[0][j] = ans[0+t][j]
                    break
                else:
                    t+=1
    
    location = np.where(ans<0)#处理连续的负数
    row = location[0]
    col = location[1]
    for i in range(len(row)):
        t = 0
        while True:
            if ans[row[i]-t][col[i]]>0:
                ans[row[i]][col[i]] = ans[row[i]-t][col[i]]
                break
            else:
                t+=1
    return ans 

ans = remove_nagative(ans) 
#smape(tru, ans)
#smape(tru, ans)
pd_data = pd.DataFrame(ans)
print(pd_data)
model_dir = "result"
model_name = 'result_'+location+'_aqi48_ans_include_April.csv'
pd_data.to_csv(os.path.join(model_dir, model_name))