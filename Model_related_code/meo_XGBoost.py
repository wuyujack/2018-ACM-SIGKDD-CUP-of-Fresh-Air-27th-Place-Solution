import pandas as pd
import xgboost as xgb
from sklearn import preprocessing
import random
import numpy as np
import matplotlib.pyplot as plt
import os
%matplotlib inline

per = 0.1

Type = 'humidity'
        #'temperautre'
        #'windspeed'
        #pressure
location = 'BJ'
        #'LD'
f = open('/home/dedekinds/'+location+'_'+Type+'_2_step.csv')
df = pd.read_csv(f)
data = df.values

raw = int(data.shape[0]*(1-per))
train_x = data[:raw,:-1]
train_y = data[:raw,-1]


data_train = xgb.DMatrix(train_x, label=train_y)  
watch_list = [(data_train, 'train')]  
param = {'max_depth': 6, 'eta': 0.8, 'silent': 0, 'objective': 'reg:linear'}  
bst = xgb.train(param, data_train, num_boost_round=1000, evals=watch_list)  

model_dir = "xgboost_model"
model_name = Type+'_xgboost_'+location+'.txt'
if not os.path.exists(model_dir):
    os.mkdir(model_dir)
bst.save_model(os.path.join(model_dir, model_name))





##读取模型进行测试
#import pandas as pd
#import xgboost as xgb
#from sklearn import preprocessing
#import random
#import numpy as np
#import matplotlib.pyplot as plt
#import os
#%matplotlib inline
#
#per = 0.1
#
#Type = 'humidity'   #<---------------只需要修改这里
#location = 'BJ'     #<---------------只需要修改这里

#f = open('/home/dedekinds/'+location+'_'+Type+'_new_month_2_step.csv')
#df = pd.read_csv(f)
#data = df.values
#
#model_dir = "xgboost_model"
#model_name = Type+'_xgboost_'+location+'.txt'
#
#bst = xgb.Booster(model_file=os.path.join(model_dir, model_name))  
#
#test_x = data[:,:-1]
#test_y = data[:,-1]
#data_test = xgb.DMatrix(test_x, label=test_y)  
#y_hat = bst.predict(data_test)    #<---------------湿度  风速必须为正y_hat = np.abs(bst.predict(data_test))
#
#
#acc=np.average(np.abs(y_hat-test_y[:len(y_hat)]))  #偏差
#print(acc)
##以折线图表示结果
#plt.figure()
#plt.plot(list(range(len(y_hat))), y_hat, color='b')
#plt.plot(list(range(len(test_y))), test_y,  color='r')
#plt.show()