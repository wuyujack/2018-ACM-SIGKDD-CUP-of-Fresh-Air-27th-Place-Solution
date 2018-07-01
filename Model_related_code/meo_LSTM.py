# %load meo_LSTM.py
# %load temperature_LSTM.py
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Apr  7 21:42:58 2018

@author: dedekinds
"""
import os
import random
import pandas as pd
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt
%matplotlib inline

rnn_unit = 40
lr = 0.0005
per = 0.1
batch_size = 30
time_step = 1

Type = 'temperature'
        #'temperautre'
        #'windspeed'
        #'pressure'
        #‘humidity’
location = 'BJ'
        #'LD'
f = open('/home/dedekinds/'+location+'_'+Type+'_2_step.csv')
df = pd.read_csv(f)
data = df.values


input_size = np.shape(data)[1]-1
output_size = 1


def get_train_data(batch_size,time_step):
    batch_index = []
    data_train = data
    normalized_train_data = (data_train-np.mean(data_train,axis=0))/(0.0001+np.std(data_train,axis=0))#+0.00001   /0
    train_x = []
    train_y = []
    for i in range(len(data_train)-time_step):
        if i % batch_size==0:
            batch_index.append(i)
        x = normalized_train_data[i:i+time_step ,:input_size]
        y = normalized_train_data[i:i+time_step ,input_size,np.newaxis]
        train_x.append(x.tolist())
        train_y.append(y.tolist())
    batch_index.append(len(data_train)-time_step)
    return batch_index,train_x,train_y


weights={
         'in':tf.Variable(tf.random_normal([input_size,rnn_unit])),
         'out':tf.Variable(tf.random_normal([rnn_unit,output_size]))
        }
biases={
        'in':tf.Variable(tf.constant(0.1,shape=[rnn_unit,])),
        'out':tf.Variable(tf.constant(0.1,shape=[output_size,]))
       }



#——————————————————定义神经网络变量——————————————————
def lstm(X,keep_prob):     
    batch_size=tf.shape(X)[0]
    time_step=tf.shape(X)[1]
    w_in=weights['in']
    b_in=biases['in']  
    input=tf.reshape(X,[-1,input_size])  #需要将tensor转成2维进行计算，计算后的结果作为隐藏层的输入
    input_rnn=tf.matmul(input,w_in)+b_in
    input_rnn=tf.reshape(input_rnn,[-1,time_step,rnn_unit])  #将tensor转成3维，作为lstm cell的输入
    cell=tf.nn.rnn_cell.BasicLSTMCell(rnn_unit)
    init_state=cell.zero_state(batch_size,dtype=tf.float32)
    output_rnn,final_states=tf.nn.dynamic_rnn(cell, input_rnn,initial_state=init_state, dtype=tf.float32)  #output_rnn是记录lstm每个输出节点的结果，final_states是最后一个cell的结果
    output=tf.reshape(output_rnn,[-1,rnn_unit]) #作为输出层的输入

    w_out=weights['out']
    b_out=biases['out']
    pred=tf.matmul(output,w_out)+b_out
    return pred,final_states

#——————————————————训练模型——————————————————
def train_lstm(batch_size,time_step):
    keep_prob = tf.placeholder(tf.float32)
    X=tf.placeholder(tf.float32, shape=[None,time_step,input_size])
    Y=tf.placeholder(tf.float32, shape=[None,time_step,output_size])
    batch_index,train_x,train_y=get_train_data(batch_size,time_step)
    pred,_=lstm(X,keep_prob)
    #损失函数
    loss=tf.reduce_mean(tf.square(tf.reshape(pred,[-1])-tf.reshape(Y, [-1])))
    train_op=tf.train.AdamOptimizer(lr).minimize(loss)
#    saver=tf.train.Saver(tf.global_variables(),max_to_keep=15)
#    module_file = tf.train.latest_checkpoint()    
    with tf.Session() as sess:
        sess.run(tf.global_variables_initializer())
        
        saver = tf.train.Saver()
        tf.add_to_collection('X', X)
        tf.add_to_collection('keep_prob', keep_prob)
        tf.add_to_collection('pred', pred)
                
        #重复训练10000次
        for i in range(500):
            for step in range(len(batch_index)-1):
                _,loss_=sess.run([train_op,loss],feed_dict={X:train_x[batch_index[step]:batch_index[step+1]],Y:train_y[batch_index[step]:batch_index[step+1]],keep_prob:0.9})
            print(i,loss_)
#            if i % 200==0:
#                print("保存模型：",saver.save(sess,'stock2.model',global_step=i))
        model_dir = "lstm_model"
        model_name = Type+'_lstm_'+location
        if not os.path.exists(model_dir):
            os.mkdir(model_dir)
        # 保存模型
        saver.save(sess, os.path.join(model_dir, model_name))
        print("保存模型成功！")


train_lstm(batch_size,time_step)

'''读取测试数据并测试
#__________________________________________________________________-
import os
import random
import pandas as pd
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt
%matplotlib inline

rnn_unit = 40
lr = 0.0005
per = 0.1
batch_size = 30
time_step = 1

Type = 'temperature'
        #'temperautre'
        #'windspeed'
        #'pressure'
        #‘humidity’
location = 'BJ'
        #'LD'
f = open('/home/dedekinds/'+location+'_'+Type+'_new_month_2_step.csv')
df = pd.read_csv(f)
data = df.values
input_size = np.shape(data)[1]-1
def get_test_data(time_step):
    data_test = data
    mean = np.mean(data_test,axis = 0)
    std = np.std(data_test,axis = 0)
    normalized_test_data = (data_test-mean)/(std+0.0001)
    size = (len(normalized_test_data)+time_step-1)//time_step
    test_x = []
    test_y = []
    for i in range(size-1):
        x = normalized_test_data[i*time_step:(i+1)*time_step,:input_size]
        y = normalized_test_data[i*time_step:(i+1)*time_step,input_size]
        test_x.append(x.tolist())
        test_y.extend(y)
    test_x.append((normalized_test_data[(i+1)*time_step:,:input_size]).tolist())
    test_y.extend((normalized_test_data[(i+1)*time_step:,input_size]).tolist())
    
    return mean,std,test_x,test_y

def prediction(time_step):
    #Y=tf.placeholder(tf.float32, shape=[None,time_step,output_size])
    mean,std,test_x,test_y=get_test_data(time_step)   
#    saver=tf.train.Saver(tf.global_variables())
    # 创建会话
    sess = tf.Session()
    
    model_dir = "lstm_model"
    model_name = Type+'_lstm_'+location
    
    new_saver = tf.train.import_meta_graph(model_dir+'/'+model_name+'.meta')
    new_saver.restore(sess, model_dir+'/'+model_name)
    X = tf.get_collection('X')[0]
    keep_prob = tf.get_collection('keep_prob')[0]
    pred = tf.get_collection('pred')[0]
    print("恢复模型成功！")

    test_predict=[]
    for step in range(len(test_x)-1):
        prob=sess.run(pred,feed_dict={X:[test_x[step]],keep_prob:1})   
        predict=prob.reshape((-1))
        test_predict.extend(predict)
    test_y=np.array(test_y)*std[-1]+mean[-1]
    test_predict=np.array(test_predict)*std[-1]+mean[-1]
    acc=np.average(np.abs(test_predict-test_y[:len(test_predict)]))  #偏差
    print(acc)
    #以折线图表示结果
    plt.figure()
    plt.plot(list(range(len(test_predict))), test_predict, color='b')
    plt.plot(list(range(len(test_y))), test_y,  color='r')
    plt.show()
        
prediction(time_step) 
'''