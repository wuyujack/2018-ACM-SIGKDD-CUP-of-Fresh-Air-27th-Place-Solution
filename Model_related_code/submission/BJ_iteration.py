import os
import pandas as pd
import random
import numpy as np
import matplotlib.pyplot as plt
import lightgbm as lgb
from sklearn.externals import joblib
import sys

for arg in sys.argv:  
    temp = arg
delay = int(temp)
location = 'BJ'
f = open('/home/dedekinds/aqi_data_submission_'+location+'.csv')

df =pd.read_csv(f)
total_data = df.values[:,:[37,32][location == 'LD']]

def smape(actual, predicted):
    a = np.abs(np.array(actual) - np.array(predicted))
    b = np.array(actual) + np.array(predicted)
    
    return 2 * np.mean(np.divide(a, b, out=np.zeros_like(a), where=b!=0, casting='unsafe'))

def chooseType(arr,loacation):
    if location == 'BJ':
        if arr == 'temperature':
            return [0,1,3,4,2,10,11,9,17,18,16,24,25,23,31,32,30]
        if arr == 'humidity':
            return [0,1,2,4,9,11,16,18,23,25,30,32]
        if arr == 'pressure':
            return [0,1, 2,5,3, 9,12,10, 16,19,17, 23,26,24, 30,33,31]
        if arr == 'windspeed':
            return [0,1, 2,3,5 ,9,10,12, 16,17,19, 23,24,26, 30,31,33]
    else:
        if arr == 'temperature':
            return [0,1, 3,4,2, 9,10,8, 15,16,14, 21,22,20, 27,28,26]
        if arr == 'humidity':
            return [0,1, 2,4, 8,10, 14,16, 20,22, 26,28]
        if arr == 'pressure':
            return [0,1, 2,5,3, 8,11,9, 14,17,15, 20,23,21, 26,29,27]
        if arr == 'windspeed':
            return [0,1, 2,3,5 ,8,9,11, 14,15,17, 20,21,23, 26,27,29] 
    
def recall_meo(Type,location,data):
    num = 6
    res = 0
    temp = data[chooseType(Type,location)]
    
    test_x = temp.reshape(-1,len(temp))
    for i in range(1,num+1):
        model_dir = "/home/dedekinds/A_meo_code/lightgbm_merge_model"
        model_name = Type+'_lightgbm_merge_'+location+str(i)+'.txt'
        gbm = joblib.load(os.path.join(model_dir, model_name))
        res = res + gbm.predict(test_x, num_iteration=gbm.best_iteration_)
    res=res/i
    return res[0]

#recall_meo('windspeed','BJ',total_data[0])


def recall_aqi(Type,location,data):
    if location == 'LD' and Type == 'o3':
        return 0
    num = 6
    res = 0
    test_x = data.reshape(-1,len(data))
    for i in range(1,num+1):
        model_dir = "/home/dedekinds/A_meo_code/lightgbm_merge_model"
        model_name = Type+'_lightgbm_merge_'+location+str(i)+'.txt'#o3_lightgbm_merge_BJ1.txt
        gbm = joblib.load(os.path.join(model_dir, model_name))
        res = res + gbm.predict(test_x, num_iteration=gbm.best_iteration_)
    res=res/i
    return res[0]

#recall_aqi('o3','BJ',total_data[0][:-3])


ans = np.zeros((1,3))

for j in range(len(total_data)):
    data = total_data[j]
    temp_ans =[]
    for t in range(delay+48):
        temperature = recall_meo('temperature',location,data)
        humidity = recall_meo('humidity',location,data)
        pressure = recall_meo('pressure',location,data)
        windspeed = recall_meo('windspeed',location,data)
        
        pm25 = recall_aqi('pm25',location,data)
        pm10 = recall_aqi('pm10',location,data)
        o3 = recall_aqi('o3',location,data)
            
        #ans = np.row_stack((ans,np.array([pm25,pm10,o3])))
        temp_ans.append(pm25)
        temp_ans.append(pm10)
        temp_ans.append(o3)
        
        if location == 'BJ':
            temp = list(data)
            data = np.array(temp[0:2]+temp[9:]+[temperature,pressure,
                            humidity,windspeed,pm25,pm10,o3])
            
            #经度、纬度、温度、压强、湿度、风速、PM2.5、PM10、O3
        if location == 'LD':
            temp = list(data)
            data = np.array(temp[0:2]+temp[8:]+[temperature,pressure,
                            humidity,windspeed,pm25,pm10])
    temp2_ans = np.array(temp_ans[3*delay:]).reshape(-1,3)
    ans = np.row_stack((ans,temp2_ans))
               
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

#f = open('total_pre.csv')#打开19、20。21。22。23时候的总表:station_num*35
#df =pd.read_csv(f)
#data = df.values

#smape(ans, data)

pd_data = pd.DataFrame(ans)
print(pd_data)
model_dir = "result"
model_name = 'result_'+location+'_Iteration_ans.csv'
pd_data.to_csv(os.path.join(model_dir, model_name))