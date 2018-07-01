clear
tic
BJ=readtable('bj_meo_2018-05-31-22-23.csv'); %%%按照站点顺序排列，时间在第二列，删除掉station_id
toc
BJ=table2cell(BJ);

for i=1:size(BJ,1)
    if isequal(BJ{i,3},'Cloudy') 
            BJ(i,3)=num2cell(1);
    elseif isequal(BJ{i,3},'Dust') 
            BJ(i,3)=num2cell(2);
    elseif isequal(BJ{i,3},'Fog') 
            BJ(i,3)=num2cell(3);
    elseif isequal(BJ{i,3},'Hail') || isequal(BJ{i,3},'Haze')
            BJ(i,3)=num2cell(4);
    elseif isequal(BJ{i,3},'Light Rain') 
            BJ(i,3)=num2cell(5);
    elseif isequal(BJ{i,3},'Overcast') 
            BJ(i,3)=num2cell(6);
    elseif isequal(BJ{i,3},'Rain') 
            BJ(i,3)=num2cell(7);
    elseif isequal(BJ{i,3},'Rain with Hail') 
            BJ(i,3)=num2cell(8);
    elseif isequal(BJ{i,3},'Rain/Snow with Hail') 
            BJ(i,3)=num2cell(9);
    elseif isequal(BJ{i,3},'Sand') 
            BJ(i,3)=num2cell(10);
    elseif isequal(BJ{i,3},'Sleet') 
            BJ(i,3)=num2cell(11);
    elseif isequal(BJ{i,3},'Snow') 
            BJ(i,3)=num2cell(12);
    elseif isequal(BJ{i,3},'Sunny/clear') 
            BJ(i,3)=num2cell(13);
    else
            BJ(i,3)=num2cell(14);
    end
end

BJ=cell2table(BJ);

tic
temp_station_id=table2cell(BJ(1,1)); %初始化第一个用于分类的staion_id
BJ_data=cell(1,8,1);%初始化三维元胞数组, 注意第一个位置的值要调整一下，即每个元胞的行数
BJ_num=1;%站点数目
j=1;%记录循环中每个二维元胞数组里面行号
for i = 1:size(BJ,1)
      if mod(i,1000)==0 %观测算法的运算速度
       i  
      end
      if isequal(temp_station_id, table2cell(BJ(i,1)))
           BJ_data(j,1:8,BJ_num)=table2cell(BJ(i,1:8));
           j=j+1;
      else
           temp_station_id=table2cell(BJ(i,1));
           BJ_num=BJ_num + 1;
           BJ_data(1,1:8,BJ_num)=table2cell(BJ(i,1:8));
           j=2;
      end
end
toc

%%将空气观测站的名称加入到BJ_data表的第8,9列
[d,e,f]=xlsread('station_meo');%导入空气质量站的经纬度坐标
for i=1:size(BJ_data,3)
   
     BJ_data(1:size(BJ_data(:,:,i),1),9:10,i)=repmat(f(i+1,2:3),size(BJ_data(:,:,i),1),1);
    
end

tic
BJ_new=BJ_data(:,:,1);
for j=2:BJ_num
       j     
    BJ_new=cat(1,BJ_new,BJ_data(:,:,j));
end

toc

%%%导出带有经纬度的北京4月份数据表
BJ_new=cell2table(BJ_new);

tic
writetable(BJ_new,'BJ_5_31_22_23_with_location_new_encoding.csv','Delimiter',',','QuoteStrings',true)
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
tic
[a,b,c]=xlsread('meo_170106_16');%导入气象站的经纬度坐标、风速风向等数据
x=readtable('BJ_5_31_22_23_with_location_new_encoding_new.csv');%导入北京历史气象数据,按时间排序
x = x(:,[1 9 2:8 end]);
x = x(:,[1:2 10 3:9]);
x = x(:,[1:4 6:10 5]);
x=table2cell(x);
toc

k=1;
g=1;
j=1;
tic
aqi_utc_time=x(2,4);%初始化第一个匹配的utc_time
L=cell(1,11,1);%生成8782个18行，11列的元胞数据，注意行列要调换——（行，列，元胞个数）
for i=2:size(x,1) %对17-18年的气象观测站数据表里面每一行与设定的utc_time进行匹配
    if mod(i,1000)==0 %观测算法的运算速度
       i  
    end
    if strcmp(cell2mat(x(i,4)),cell2mat(aqi_utc_time)) %如果该行第4列的utc_time与预先设定好的utc_time匹配上，则执行如下操作
        L(j,1:10,k)=x(i,1:10); %将时间戳匹配上的记录复制到第k个元胞数组里，行是记录，列是不同的数据如utc_time,station等
        j=j+1;%记录循环次数，并且由于每个元胞都是从第一行开始然后到第十八行，所以j用于控制复制的记录在元胞数组中的位置
    else %如果匹配不上
        %L(i-1,1:10,k)=x(i,1:10);
        aqi_utc_time=x(i,4);%如果匹配不上，由于提前已经对utc_time进行了排序，因此说明出现了新的时间戳，此时就要更改之前utc的默认值
        k=k+1;%由于出现了新的时间戳，因此要用一个新的二维元胞数组重新进行记录
        L(1,1:10,k)=x(i,1:10);%将这条记录放置到新的二维元胞数组里面，并且这一条是第一条记录，因此是“1”
        j=2;%后面的每一条新的匹配记录都是从2开始录入
    end
    
end
toc

temp_L_1=L(:,:,1);

%%记得打开knn_interplote_weather的m文件，因为要调用这个函数
tic
[d,~,~]=xlsread('station_AQI');%导入空气质量站的经纬度坐标
O=[35,6,2];
for i=1:size(L,3)
      
            i  
       
       if i~=8226&&i~=8955&&i~=10724&&i~=10741&&i~=10780&&i~=10903%%当天该小时的气象数据不完整
           temp_meo=[cell2mat(L(:,2,i)) cell2mat(L(:,3,i)) cell2mat(L(:,10,i)) cell2mat(L(:,5,i)) cell2mat(L(:,6,i)) cell2mat(L(:,7,i)) cell2mat(L(:,8,i)) cell2mat(L(:,9,i))];
           W=knn_interplote_weather(temp_meo,d);
           O(1:35,2:10,i)=W(1:35,1:9,1); %%%将该小时的天气状况赋值到每一个空气质量观测站
       end
end
toc

%%将utc_time时间戳按照顺序从L表复制到P表的第一行第一列
 P=num2cell(O);
for i=1:size(L,3)
P(1,1,i)=L(1,4,i);
end

%%将空气观测站的名称加入到P表的第11列
[d,e,f]=xlsread('station_AQI');%导入空气质量站的经纬度坐标
for i=1:size(L,3)
    if i~=8226&&i~=8955&&i~=10724&&i~=10741&&i~=10780&&i~=10903
     P(:,11,i)=e(2:size(P(:,:,i),1)+1,1);
    end
end

%%%%%%%%%按照submission的北京站点顺序进行排序
[~,~,BJ_predict_station]=xlsread('BJ_predict_station_id');%导入空气质量站的经纬度坐标
BJ_data_new=cell(size(P));

for i=1:size(BJ_predict_station,1)
   for k=1:size(P,1)
     for j=1:size(P,3)
        if isequal(P(k,11,j),BJ_predict_station(i,1))
            BJ_data_new(i,:,j)=P(k,:,j);
        end 
     end
   end
end

tic
BJ_new=BJ_data_new(:,:,1);
for j=2:size(BJ_data_new,3)
       j     
    BJ_new=cat(1,BJ_new,BJ_data_new(:,:,j));
end

toc

%%%导出带有经纬度的北京4月份数据表
BJ_new=cell2table(BJ_new);
BJ_new = BJ_new(:,[11 1:10]);

tic
writetable(BJ_new,'BJ_5_31_22_23_with_weather_new_encoding.csv','Delimiter',',','QuoteStrings',true)
toc
