
import os
import pandas as pd
import random
import numpy as np
import matplotlib.pyplot as plt
import lightgbm as lgb
from sklearn.externals import joblib
%matplotlib inline
p=0.4
num = 6

per = 0.1
Type = 'temperature'
        #'temperautre'
        #'windspeed'
        #pressure
location = 'BJ'
        #'LD'
f = open('/home/dedekinds/'+location+'_'+Type+'_5_step.csv')
df = pd.read_csv(f)
data = df.values
raw = int(data.shape[0]*(1-per))

for i in range(1,num+1):
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

    temp=splitdata(data)
    raw = int(temp.shape[0]*(1-per))
    train_x = temp[:raw,:-1]
    train_y = temp[:raw,-1]
    test_x = temp[raw:,:-1]
    test_y = temp[raw:,-1]

    gbm = lgb.LGBMRegressor(objective='regression',
                            num_leaves=31,
                            learning_rate=0.5,
                            n_estimators=2000)
    gbm.fit(train_x, train_y,
            eval_set=[(test_x, test_y)],
            eval_metric='l2',
            early_stopping_rounds=10)




    #保存模型
    model_dir = "lightgbm_merge_model"
    model_name = Type+'_lightgbm_merge_'+location+str(i)+'.txt'
    if not os.path.exists(model_dir):
        os.mkdir(model_dir)
    joblib.dump(gbm, os.path.join(model_dir, model_name))





#___________________________________________
p=0.4
num = 6
Type = 'temperature'
        #'temperautre'
        #'windspeed'
        #pressure
location = 'BJ'
        #'LD'
        
f = open('/home/dedekinds/'+location+'_'+Type+'_new_month_5_step.csv')
df = pd.read_csv(f)
data = df.values
test_x = data[:,:-1]
test_y = data[:,-1][:,np.newaxis]
y = np.zeros((1,np.shape(test_y)[0]))

for i in range(1,num+1):
    model_dir = "lightgbm_merge_model"
    model_name = Type+'_lightgbm_merge_'+location+str(i)+'.txt'
    gbm = joblib.load(os.path.join(model_dir, model_name))
    k=gbm.predict(test_x, num_iteration=gbm.best_iteration_)
    y = y+k
    
y=np.transpose(y/i)
acc=np.average(np.abs(y -test_y[:len(y )]))  #偏差
print(acc)
#以折线图表示结果
plt.figure()
plt.plot(list(range(len(y))), y , color='b')
plt.plot(list(range(len(test_y))), test_y,  color='r')
plt.show()