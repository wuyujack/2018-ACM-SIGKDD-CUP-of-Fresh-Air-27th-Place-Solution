# %load BJ_humidity_lightgbm.py
# %load BJ_humidity_lightgbm.py
#!/usr/bin/env python3
"""
Created on Thu Apr 12 11:03:29 2018

@author: dedekinds
"""
import os
import pandas as pd
import random
import numpy as np
import matplotlib.pyplot as plt
import lightgbm as lgb
from sklearn.externals import joblib
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
test_x = data[raw:,:-1]
test_y = data[raw:,-1]

gbm = lgb.LGBMRegressor(objective='regression',
                        num_leaves=31,
                        learning_rate=0.5,
                        n_estimators=2000)
gbm.fit(train_x, train_y,
        eval_set=[(test_x, test_y)],
        eval_metric='l2',
        early_stopping_rounds=10)




#保存模型
model_dir = "lightgbm_model"
model_name = Type+'_lightgbm_'+location+'.txt'
if not os.path.exists(model_dir):
    os.mkdir(model_dir)
joblib.dump(gbm, os.path.join(model_dir, model_name))





##读取模型 并测试demo

#
#import os
#import pandas as pd
#import random
#import numpy as np
#import matplotlib.pyplot as plt
#import lightgbm as lgb
#from sklearn.externals import joblib
#%matplotlib inline
#
#Type = 'humidity'
#        #'temperautre'
#        #'windspeed'
#        #pressure
#location = 'BJ'
#        #'LD'
#        
#f = open('/home/dedekinds/'+location+'_'+Type+'_new_month_2_step.csv')
#df = pd.read_csv(f)
#data = df.values
#
#model_dir = "lightgbm_model"
#model_name = Type+'_lightgbm_'+location+'.txt'
#gbm = joblib.load(os.path.join(model_dir, model_name))
#
#test_x = data[:,:-1]
#test_y = data[:,-1]
#test_predict = gbm.predict(test_x, num_iteration=gbm.best_iteration_)
#
#acc=np.average(np.abs(test_predict -test_y[:len(test_predict )]))  #偏差
#print(acc)
##以折线图表示结果
#plt.figure()
#plt.plot(list(range(len(test_predict ))), test_predict , color='b')
#plt.plot(list(range(len(test_y))), test_y,  color='r')
#plt.show()