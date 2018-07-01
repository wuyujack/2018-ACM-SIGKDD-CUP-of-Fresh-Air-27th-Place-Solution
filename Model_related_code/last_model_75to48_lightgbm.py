# -*- coding: utf-8 -*-
"""
Created on Sun Apr 22 10:21:32 2018

@author: dedekinds
"""




import os
import pandas as pd
import random
import numpy as np
import matplotlib.pyplot as plt
import lightgbm as lgb
from sklearn.externals import joblib
from sklearn.ensemble import BaggingRegressor

#LD_data_8_60_time_new.csv

location = 'BJ'
num_of_variable =[145,174][location == 'BJ']

f = open('/home/dedekinds/'+location+'_data_8_60_time_new.csv')

def num_out_val(location):
    if location == 'LD':return 2
    else:return 3
out_size = 60*num_out_val(location)
def splitdata(data):
    #按时间顺序来split数据集变为测试集和训练集
    #per:测试集占比    data数据集(array)
    test_data_raw = int(data.shape[0]*p)
    n = data.shape[0]
    m = test_data_raw
    #在n个数中不重复抽取m个样本且保证顺序哦~ 很适合时间序列的说
    delete_row = []
    #记下来data被抽取出来的行的index
    for i in range(n):
        if random.randint(0, n-i+1) < m:
            delete_row.append(i)
            m-=1

    data = np.delete(data, delete_row, axis=0) 
    return data #test_data train_data


df =pd.read_csv(f)
df = df.dropna(axis=0,how='any')
temp_data = df.values
per = 0.03
p = 0.5




for j in range(out_size):
    print(j)
    total_data = splitdata(temp_data)
    raw = int(np.shape(total_data)[0]*(1-per))
    
    train_x = total_data[:raw,:num_of_variable]
    test_x = total_data[raw:,:num_of_variable]#for early_stop
    train_y = total_data[:raw,num_of_variable+j]
    test_y = total_data[raw:,num_of_variable+j]
    num = 5
    merge_model = []
    
    for i in range(1,num+1):
        gbm = lgb.LGBMRegressor(objective='regression',
                                num_leaves=30+i*2,
                                learning_rate=0.3,
                                n_estimators=1000)
        gbm.fit(train_x, train_y,
                eval_set=[(test_x, test_y)],
                eval_metric='l2',
                early_stopping_rounds=10)
        merge_model.append(gbm)
        
    model_dir = "aqi48_75"
    model_name = '_lightgbm_'+location+str(j)+'.txt'#.pkl?
    if not os.path.exists(model_dir):
        os.mkdir(model_dir)
    joblib.dump(merge_model, os.path.join(model_dir, model_name))
    
#————————————————————————————————————————————
#测试测试集

#————————————————————————
#读取测试集的真实数据得到tru准备测试
import os
import pandas as pd
import random
import numpy as np
import matplotlib.pyplot as plt
import lightgbm as lgb
from sklearn.externals import joblib
from sklearn.ensemble import BaggingRegressor

delay = 0
pre_time = 48#<=60

location = 'LD'
f = open('/home/dedekinds/'+location+'_data_8_60_test_sample.csv')#BJ_data_8_60_test_sample_new.csv
df =pd.read_csv(f)
total_data = df.values
num_of_variable =[56,65][location == 'BJ']#beiing
test_x = total_data[:,:num_of_variable]

def num_out_val(location):
    if location == 'LD':return 2
    else:return 3
    
def smape(actual, predicted):
    a = np.abs(np.array(actual) - np.array(predicted))
    b = np.array(actual) + np.array(predicted)
    
    return 2 * np.mean(np.divide(a, b, out=np.zeros_like(a), where=b!=0, casting='unsafe'))

tru = np.zeros((1,num_out_val(location)))
for i in range(len(total_data)):
        temp = total_data[i, num_of_variable+delay : num_of_variable+delay+pre_time*num_out_val(location)]
        temp = temp.reshape(-1,num_out_val(location))
        tru = np.row_stack((tru,temp))
tru = np.delete(tru,[0],axis=0)
if location == 'LD':
    tru = np.column_stack((tru,np.zeros( (np.shape(tru)[0],1) )))





#读取模型获得ans准备和tru做对比__________________________________________________________________________________
#提交只需要看这部分
import os
import pandas as pd
import random
import numpy as np
import matplotlib.pyplot as plt
import lightgbm as lgb
from sklearn.externals import joblib
from sklearn.ensemble import BaggingRegressor

delay = 0
pre_time = 48#<=60

location = 'BJ'
f = open('/home/dedekinds/'+location+'_data_8_60_test_sample.csv')
df =pd.read_csv(f)
total_data = df.values
num_of_variable =[56,65][location == 'BJ']#beiing
test_x = total_data[:,:num_of_variable]

def num_out_val(location):
    if location == 'LD':return 2
    else:return 3
    
def recall_aqi(location,data,model_index):
    model_dir = "aqi48_75"
    model_name = '_lightgbm_'+location+str(model_index)+'.txt'
    model = joblib.load(os.path.join(model_dir, model_name))
    temp_ans = 0
    for mod in model:
        temp_ans+=mod.predict(data, num_iteration=mod.best_iteration_)
    return (temp_ans/len(model))[0]

ans = np.zeros((1,3))
for i in range(len(total_data)):
    data = test_x[i].reshape(-1,num_of_variable)
    temp_ans = []
    for j in range(delay,delay+pre_time*num_out_val(location)):
        temp_ans.append(recall_aqi(location,data,j))
    temp_ans = np.array(temp_ans).reshape(-1,num_out_val(location))
    if location == 'LD':
        temp_ans = np.column_stack((temp_ans,np.zeros( (np.shape(temp_ans)[0],1) )))
    ans = np.row_stack((ans,temp_ans))
ans = np.delete(ans,[0],axis=0)  
    
    
#smape(tru, ans)
pd_data = pd.DataFrame(ans)
print(pd_data)
pd_data.to_csv('result_'+location+'_aqi48_75_ans.csv')