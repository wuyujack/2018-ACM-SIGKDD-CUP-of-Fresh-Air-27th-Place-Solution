clear;
tic
[a,b,c]=xlsread('meo_170106_16');%导入气象站的经纬度坐标、风速风向等数据
y=readtable('beijing_17_01_18_05-20_aq.csv');%导入北京历史空气质量数据，包含NO2，CO，SO2
aqi_time_index=table2cell(unique(y(:,2)));
x=readtable('beijing_17_01_18_05-20_meo_with_weather.csv');%导入北京历史气象数据，包含天气
x=table2cell(x);
meo_time_index=unique(x(:,4));%获取唯一的utc_time时间戳
toc

k=1;
g=1;
j=1;
tic
aqi_utc_time=x(2,4);%初始化第一个匹配的utc_time
L=cell(18,11,100);%生成8782个18行，11列的元胞数据，注意行列要调换——（行，列，元胞个数）
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

%%%%%%%%计算非空行数目



%%记得打开knn_interplote_weather的m文件，因为要调用这个函数
tic
[d,~,~]=xlsread('station_AQI');%导入空气质量站的经纬度坐标
O=cell(35,6,size(L,3)-7);
for i=1:size(L,3)
      
            i  
       
       if i~=8226&&i~=8955&&i~=10724&&i~=10741&&i~=10780 ... 
               &&i~=10903&&i~=10987%%当天该小时的气象数据不完整
           %temp_meo=[cell2mat(L(:,2,i)) cell2mat(L(:,3,i)) cell2mat(L(:,10,i)) cell2mat(L(:,5,i)) cell2mat(L(:,6,i)) cell2mat(L(:,7,i)) cell2mat(L(:,8,i)) cell2mat(L(:,9,i))];
           temp_meo=[L(:,2,i) L(:,3,i) L(:,10,i) L(:,5,i) L(:,6,i) L(:,7,i) L(:,8,i) L(:,9,i)];
           W=knn_interplote_weather_without_encoding(temp_meo,d);
           O(1:35,2:10,i)=W(1:35,1:9,1); %%%将该小时的天气状况赋值到每一个空气质量观测站
       end
end
toc

%%将utc_time时间戳按照顺序从L表复制到P表的第一行第一列
 P=O;
for i=1:size(L,3)
P(1,1,i)=L(1,4,i);
end

%%将空气观测站的名称加入到P表的第11列
[d,e,f]=xlsread('station_AQI');%导入空气质量站的经纬度坐标
for i=1:size(L,3)
    if i~=8226&&i~=8955&&i~=10724&&i~=10741&&i~=10780 ... 
               &&i~=10903&&i~=10987%%当天该小时的气象数据不完整
     P(:,11,i)=e(2:size(P(:,:,i),1)+1,1);
    end
end

%%对北京aqi 历史数据的总表按照时间戳进行分组
k=1;
g=1;
j=1;

aqi_utc_time=y(1,2);%初始化第一个匹配的utc_time
aqi=cell(35,size(y,2),200);%生成6511个35行，12列的元胞数据，注意行列要调换——（行，列，元胞个数）
tic
 for i=1:size(y,1) %对17-18年的气象观测站数据表里面每一行与设定的utc_time进行匹配
  
    if mod(i,1000)==0 %观测算法的运算速度
       i  
    end
    if isequal(table2cell(y(i,2)),table2cell(aqi_utc_time)) %如果该行第4列的utc_time与预先设定好的utc_time匹配上，则执行如下操作
        aqi(j,1:size(y,2),k)=table2cell(y(i,1:size(y,2))); %将时间戳匹配上的记录复制到第k个元胞数组里，行是记录，列是不同的数据如utc_time,station等
        j=j+1;%记录循环次数，并且由于每个元胞都是从第1行开始然后到第35行，所以j用于控制复制的记录在元胞数组中的位置
    else %如果匹配不上
        %L(i-1,1:10,k)=x(i,1:10);
        aqi_utc_time=y(i,2);%如果匹配不上，由于提前已经对utc_time进行了排序，因此说明出现了新的时间戳，此时就要更改之前utc的默认值
        k=k+1;%由于出现了新的时间戳，因此要用一个新的二维元胞数组重新进行记录
        aqi(1,1:size(y,2),k)=table2cell(y(i,1:size(y,2)));%将这条记录放置到新的二维元胞数组里面，并且这一条是第一条记录，因此是“1”
        j=2;%后面的每一条新的匹配记录都是从2开始录入
    end
    
end
toc

% %%%找出重复了的aqi_without_winter 记录
% tic
% multiple_aqi=[];
% multiple_aqi_location=[];
% for j=1:size(aqi,3)%对于aqi里面的每一个二维元胞数组
%      for w=36:70%对于里面的36-70列每一列都进行查询
%      if ~isempty(cell2mat(aqi(w,1,j)))%如果该行的第一个元胞不是空，则说明该小时里面的35个站点的记录重复
%          multiple_aqi=cat(1,multiple_aqi,w); %输出这列的列号
%          multiple_aqi_location=cat(1,multiple_aqi_location,j); %输出元胞所在位置
%      end
%      end
% end
% toc
% 
%  %%%删除重复记录
%  for j=1:size(aqi,3)
%      if mod(i,1000)==0 %观测算法的运算速度
%        j     
%     end
%       for w1=1:size(aqi(:,:,j),1)
%           for w2=1:size(aqi(:,:,j),1)  
%               if w2 ~=w1
%                 if strcmp(cell2mat(aqi(w1,1,j)),cell2mat(aqi(w2,1,j)))
%                    for w3=1:size(aqi,2)
%                     aqi{w2,w3,j}=[];%%对元胞数组删除数据的时候只能有一个非冒号索引，因此只能手动循环
%                    end
%                 end
%               end
%            end
%       end
%  end
% 

%%将P表和历史aqi表先按照小时然后按照站点进行匹配
tic
t1=1;
s1=1;
for i=1:size(aqi,3)
    if mod(i,1000)==0 %观测算法的运算速度
       i     
    end
    for j=t1:size(P,3)
        if isequal(aqi(1,2,i),P(1,1,j))
            for q=1:size(aqi(:,:,i),1)
                for r=1:size(P(:,:,j),1)
                    if isequal(aqi(q,1,i),P(r,size(P,2),j))
                        aqi(q,size(y,2)+1:size(y,2)+size(P,2),i)=P(r,1:size(P,2),j);
                    end
                end
            end
        end
    end
end
toc

tic
beijing_aqi_full=aqi(:,:,1);
for j=2:size(aqi,3)
    if mod(j,1000)==0 %观测算法的运算速度
       j     
    end
    beijing_aqi_full=cat(1,beijing_aqi_full,aqi(:,:,j));
end
toc

    beijing_aqi_full=cell2table(beijing_aqi_full);
    
%     %%%%只保留beijing_aqi_full里面的非空行
%     beijing_aqi_full_new(1,:)=beijing_aqi_full(1,:);
%     k=1;
%     for i=1:size(beijing_aqi_full,1)
%         if mod(i,1000)==0 %观测算法的运算速度
%         i;    
%          end
%          if ~isequal(cell2mat(table2array(beijing_aqi_full(i,1))),[])
%                 beijing_aqi_full_new(k,:)=beijing_aqi_full(i,:);
%                 k=k+1;
%          end
%     end
% beijing_aqi_full(:,{'beijing_aqi_full6','beijing_aqi_full12','beijing_aqi_full13','beijing_aqi_full15'}) = [];
% beijing_aqi_full = beijing_aqi_full(:,[1:2 6 3:5 7:end]);
% beijing_aqi_full = beijing_aqi_full(:,[1:3 7 4:6 8:end]);
% beijing_aqi_full = beijing_aqi_full(:,[1:4 8 5:7 9:end]);
% beijing_aqi_full = beijing_aqi_full(:,[1:5 9 6:8 10:end]);
% beijing_aqi_full = beijing_aqi_full(:,[1:6 10 7:9 end]);
% beijing_aqi_full = beijing_aqi_full(:,[1:7 11 8:10]);

tic
writetable(beijing_aqi_full,'beijing_17_01_18_05-20_all_aqi_meo_weather_75_model_without_encoding.csv','Delimiter',',','QuoteStrings',true)
toc



%%%%%%%将北京的历史数据aqi-meo总表在第18列增加风向。然后将它转换成table以后，将PM2.5、PM10、O3
%%%%%%%移动到风向的前面，天气移到风向后面。然后根据时间进行分组，利用BJ_knn_aqi函数进行空间插值
%%%%%%%最后再根据站点分组，进行时间线性插值

clear
tic
BJ=readtable('beijing_17_01_18_05-20_all_aqi_meo_weather_75_model_without_encoding_new.csv'); %%导入北京aqi-meo总表，导入前要清理空白
toc

BJ=table2cell(BJ);

%%将风向添加到BJ的18列
tic
for i=1:size(BJ,1)
            if mod(i,1000)==0 %观测算法的运算速度
            i    
            end
            if cell2mat(BJ(i,14))>0 && cell2mat(BJ(i,15))>0
            BJ(i,18)=num2cell((atan(cell2mat(BJ(i,14))/cell2mat(BJ(i,15)))/pi)*180);
            elseif cell2mat(BJ(i,14))>0 && cell2mat(BJ(i,15))<0
            BJ(i,18)= num2cell((atan(cell2mat(BJ(i,14))/cell2mat(BJ(i,15)))/pi)*180+180);
            elseif cell2mat(BJ(i,14))<0 && cell2mat(BJ(i,15))<0
            BJ(i,18)=num2cell((atan(cell2mat(BJ(i,14))/cell2mat(BJ(i,15)))/pi)*180+180);
            elseif cell2mat(BJ(i,14))<0 && cell2mat(BJ(i,15))>0 
            BJ(i,18)=num2cell((atan(cell2mat(BJ(i,14))/cell2mat(BJ(i,15)))/pi)*180+360);
            elseif cell2mat(BJ(i,14))==0 && cell2mat(BJ(i,15))>0
            BJ(i,18)=num2cell(0);
            elseif cell2mat(BJ(i,14))==0 && cell2mat(BJ(i,15))<0
            BJ(i,18)=num2cell(180);  
            elseif cell2mat(BJ(i,14))>0 && cell2mat(BJ(i,15))==0
            BJ(i,18)=num2cell(90);
            elseif cell2mat(BJ(i,14))<0 && cell2mat(BJ(i,15))==0
            BJ(i,18)=num2cell(270);
            else
            BJ(i,18)=num2cell(NaN);
            end
end
toc

BJ=cell2table(BJ);

% tic
% writetable(BJ,'beijing_historical_month_aqi_meo_full_75_model_with_wind_direction.csv','Delimiter',',','QuoteStrings',true)
% toc

%%%%%%%%%%%%调整顺序，删除u、v方向的风速，将PM2.5、PM10、O3、NO2，CO，SO2移到风向的前面，风向
%%%%%%%%%%%%将天气情况移到风向后面，变成最后一列

BJ(:,{'BJ14','BJ15'}) = [];%%删除u、v方向的风速
BJ = BJ(:,[1:14 16 15]);%将天气情况移到风向后面，变成最后一列
BJ = BJ(:,[1:2 4:14 3 15:end]);%%将PM2.5移到风向的前面
BJ = BJ(:,[1:2 4:14 3 15:end]);%%将PM10移到风向的前面
BJ = BJ(:,[1:2 4:14 3 15:end]);%%将O3移到风向的前面
BJ = BJ(:,[1:2 4:14 3 15:end]);%%将NO2移到风向的前面
BJ = BJ(:,[1:2 4:14 3 15:end]);%%将CO移到风向的前面
BJ = BJ(:,[1:2 4:14 3 15:end]);%%将SO2移到风向的前面


%%%%%%%%%%%%将BJ表格按照时间分组，然后对每一组进行空间插值填补NaN

%%对北京按照utc_time来分组，形成三维元胞数组
tic
temp_utc_time=table2cell(BJ(1,2)); %初始化第一个用于分类的utc_time
BJ_data=cell(5,size(BJ,2),10);%初始化三维元胞数组
BJ_num=1;%站点数目
j=1;%记录循环中每个二维元胞数组里面行号
for i = 1:size(BJ,1)
      if mod(i,1000)==0 %观测算法的运算速度
       i  
      end
      if isequal(temp_utc_time, table2cell(BJ(i,2)))
           BJ_data(j,1:size(BJ,2),BJ_num)=table2cell(BJ(i,1:size(BJ,2)));
           j=j+1;
      else
           temp_utc_time=table2cell(BJ(i,2));
           BJ_num=BJ_num + 1;
           BJ_data(1,1:size(BJ,2),BJ_num)=table2cell(BJ(i,1:size(BJ,2)));
           j=2;
      end
end
toc

temp_BJ_data_1=BJ_data(:,:,1);

%%对北京的PM2.5、PM10、O3按照空间最近邻进行反距离加权插值
temp_BJ_data_new=cell(size(BJ_data));
tic
for i=1:size(BJ_data,3)
        if mod(i,1000)==0 %观测算法的运算速度
         i  
        end
        temp_BJ_data_new(:,1:14,i)=BJ_knn_aqi_full(BJ_data(:,1:14,i));
        temp_BJ_data_new(:,15:16,i)=BJ_data(:,15:16,i);
end
toc

temp_BJ_data_test=temp_BJ_data_new(:,:,1);



%%将temp_BJ_data_new按照时间合并

%%合并
tic
BJ_temperature=temp_BJ_data_new(:,:,1);
for j=2:BJ_num
    if mod(j,1000)==0 %观测算法的运算速度
       j     
    end
    BJ_temperature=cat(1,BJ_temperature,temp_BJ_data_new(:,:,j));
end

toc


BJ_temperature=cell2table(BJ_temperature);

tic
writetable(BJ_temperature,'beijing_17_01_18_05-20_all_aqi_meo_weather_75_model_without_encoding_space_interplote.csv','Delimiter',',','QuoteStrings',true)
toc

%BJ_temperature = sortrows(BJ_temperature,'BJ_temperature1','ascend');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
tic
BJ=readtable('beijing_17_01_18_05-20_all_aqi_meo_weather_75_model_without_encoding_space_interplote_new.csv');%%导入按照站点排序的表格
toc


%%对北京按照aqi站点来分组，形成三维元胞数组
tic
temp_aqi_station=table2cell(BJ(1,1)); %初始化第一个用于分类的aqi_station
BJ_data=cell(200,size(BJ,2),10);%初始化三维元胞数组
BJ_num=1;%站点数目
j=1;%记录循环中每个二维元胞数组里面行号
for i = 1:size(BJ,1)
      if mod(i,1000)==0 %观测算法的运算速度
       i  
      end
      if isequal(temp_aqi_station, table2cell(BJ(i,1)))
           BJ_data(j,1:size(BJ,2),BJ_num)=table2cell(BJ(i,1:size(BJ,2)));
           j=j+1;
      else
           temp_aqi_station=table2cell(BJ(i,1));
           BJ_num=BJ_num + 1;
           BJ_data(1,1:size(BJ,2),BJ_num)=table2cell(BJ(i,1:size(BJ,2)));
           j=2;
      end
end
toc

temp_BJ_data_1=BJ_data(:,:,1);
temp_BJ_data_6=BJ_data(:,:,6);
BJ_data_beta=BJ_data;
BJ_data=BJ_data_beta; %%出了问题，运行这行恢复

%%求出非“空”行数：不能用size去求非“空”行的元胞数组行数因为包含空集的元胞数组非空，因此无法求出真实的非“空”行
BJ_empty=double(BJ_num);
k=0;
 for i=1:BJ_num
     for j=1:size(BJ_data(:,:,i),1)
         if isempty(BJ_data{j,1,i})~=1
         k=k+1;
         end
     end
     BJ_empty(i,1)=k;
     k=0;
 end
 
%%%%%对每个aqi站点，根据时间发展顺序，连续不超过7个PM2.5、PM10、O3是NaN的时候
%%%%%利用线性差值的方式进行插值，填补NaN
h=1;
tic
for i=1:size(BJ_data,3)
    i
        for j=1:size(BJ_data(:,:,i),1)
            if isnan(cell2mat(BJ_data(j,9,i)))%%判断PM2.5是否为NaN
               if j+1<size(BJ_data(:,:,i),1) && j~=1 %%边界判断，由于后面出现了j-1,为了保证索引不为0，因此j不能等于1
                   if ~isnan(cell2mat(BJ_data(j+1,9,i))) || ~isnan(cell2mat(BJ_data(j+2,9,i))) ...
                         || ~isnan(cell2mat(BJ_data(j+3,9,i))) || ~isnan(cell2mat(BJ_data(j+4,9,i))) ...
                         || ~isnan(cell2mat(BJ_data(j+5,9,i))) || ~isnan(cell2mat(BJ_data(j+6,9,i))) || ~isnan(cell2mat(BJ_data(j+7,9,i)))
                     %如果第八个不是NaN，也就是连续NaN数最多是7,注意这个“或”条件是按照从左到右的顺序执行的，一定要从小到大去写
                        for k=1:6
                            if isnan(cell2mat(BJ_data(j+k,9,i)))
                                h=h+1;
                            else
                                break
                            end
                        end
                        for k=1:h
                            BJ_data(j+k-1,9,i)=num2cell(((cell2mat(BJ_data(j+h,9,i))-cell2mat(BJ_data(j-1,9,i)))/(h+1))*k+cell2mat(BJ_data(j-1,9,i)));
                        end
                   end
               end
            end
            h=1;
        end
        
        h=1;
        
        for j=1:size(BJ_data(:,:,i),1)
            if isnan(cell2mat(BJ_data(j,10,i)))%%判断PM10是否为NaN
               if j+1<size(BJ_data(:,:,i),1) && j~=1 %%边界判断，由于后面出现了j-1,为了保证索引不为0，因此j不能等于1
                 if ~isnan(cell2mat(BJ_data(j+1,10,i))) || ~isnan(cell2mat(BJ_data(j+2,10,i))) ...
                         || ~isnan(cell2mat(BJ_data(j+3,10,i))) || ~isnan(cell2mat(BJ_data(j+4,10,i))) ...
                         || ~isnan(cell2mat(BJ_data(j+5,10,i))) || ~isnan(cell2mat(BJ_data(j+6,10,i))) || ~isnan(cell2mat(BJ_data(j+7,10,i)))
                     %%r如果第八个不是NaN，也就是连续NaN数最多是7
                        for k=1:6
                            if isnan(cell2mat(BJ_data(j+k,10,i)))
                                h=h+1;
                            else
                                break
                            end
                        end
                        for k=1:h
                            BJ_data(j+k-1,10,i)=num2cell(((cell2mat(BJ_data(j+h,10,i))-cell2mat(BJ_data(j-1,10,i)))/(h+1))*k+cell2mat(BJ_data(j-1,10,i)));
                        end
                 end
               end
            end
            h=1;
        end
            h=1;
            
        for j=1:size(BJ_data(:,:,i),1)
            if isnan(cell2mat(BJ_data(j,11,i)))%%判断O3是否为NaN
               if j+1<size(BJ_data(:,:,i),1) && j~=1 %%边界判断，由于后面出现了j-1,为了保证索引不为0，因此j不能等于1
                if ~isnan(cell2mat(BJ_data(j+1,11,i))) || ~isnan(cell2mat(BJ_data(j+2,11,i))) ...
                         || ~isnan(cell2mat(BJ_data(j+3,11,i))) || ~isnan(cell2mat(BJ_data(j+4,11,i))) ...
                         || ~isnan(cell2mat(BJ_data(j+5,11,i))) || ~isnan(cell2mat(BJ_data(j+6,11,i))) || ~isnan(cell2mat(BJ_data(j+7,11,i)))
                     %%r如果第八个不是NaN，也就是连续NaN数最多是7
                        for k=1:6
                            if isnan(cell2mat(BJ_data(j+k,11,i)))
                                h=h+1;
                            else
                                break
                            end
                        end
                        for k=1:h
                            BJ_data(j+k-1,11,i)=num2cell(((cell2mat(BJ_data(j+h,11,i))-cell2mat(BJ_data(j-1,11,i)))/(h+1))*k+cell2mat(BJ_data(j-1,11,i)));
                        end
                end
               end
            end
                   h=1;
        end
        h=1;
        
         for j=1:size(BJ_data(:,:,i),1)
            if isnan(cell2mat(BJ_data(j,12,i)))%%判断NO2是否为NaN
               if j+1<size(BJ_data(:,:,i),1) && j~=1 %%边界判断，由于后面出现了j-1,为了保证索引不为0，因此j不能等于1
                if ~isnan(cell2mat(BJ_data(j+1,12,i))) || ~isnan(cell2mat(BJ_data(j+2,12,i))) ...
                         || ~isnan(cell2mat(BJ_data(j+3,12,i))) || ~isnan(cell2mat(BJ_data(j+4,12,i))) ...
                         || ~isnan(cell2mat(BJ_data(j+5,12,i))) || ~isnan(cell2mat(BJ_data(j+6,12,i))) || ~isnan(cell2mat(BJ_data(j+7,12,i)))
                     %%r如果第八个不是NaN，也就是连续NaN数最多是7
                        for k=1:6
                            if isnan(cell2mat(BJ_data(j+k,12,i)))
                                h=h+1;
                            else
                                break
                            end
                        end
                        for k=1:h
                            BJ_data(j+k-1,12,i)=num2cell(((cell2mat(BJ_data(j+h,12,i))-cell2mat(BJ_data(j-1,12,i)))/(h+1))*k+cell2mat(BJ_data(j-1,12,i)));
                        end
                end
               end
            end
                   h=1;
        end
        h=1;
        
        for j=1:size(BJ_data(:,:,i),1)
            if isnan(cell2mat(BJ_data(j,13,i)))%%判断CO是否为NaN
               if j+1<size(BJ_data(:,:,i),1) && j~=1 %%边界判断，由于后面出现了j-1,为了保证索引不为0，因此j不能等于1
                if ~isnan(cell2mat(BJ_data(j+1,13,i))) || ~isnan(cell2mat(BJ_data(j+2,13,i))) ...
                         || ~isnan(cell2mat(BJ_data(j+3,13,i))) || ~isnan(cell2mat(BJ_data(j+4,13,i))) ...
                         || ~isnan(cell2mat(BJ_data(j+5,13,i))) || ~isnan(cell2mat(BJ_data(j+6,13,i))) || ~isnan(cell2mat(BJ_data(j+7,13,i)))
                     %%r如果第八个不是NaN，也就是连续NaN数最多是7
                        for k=1:6
                            if isnan(cell2mat(BJ_data(j+k,13,i)))
                                h=h+1;
                            else
                                break
                            end
                        end
                        for k=1:h
                            BJ_data(j+k-1,13,i)=num2cell(((cell2mat(BJ_data(j+h,13,i))-cell2mat(BJ_data(j-1,13,i)))/(h+1))*k+cell2mat(BJ_data(j-1,13,i)));
                        end
                end
               end
            end
                   h=1;
        end
        h=1;
        
        for j=1:size(BJ_data(:,:,i),1)
            if isnan(cell2mat(BJ_data(j,14,i)))%%判断SO2是否为NaN
               if j+1<size(BJ_data(:,:,i),1) && j~=1 %%边界判断，由于后面出现了j-1,为了保证索引不为0，因此j不能等于1
                if ~isnan(cell2mat(BJ_data(j+1,14,i))) || ~isnan(cell2mat(BJ_data(j+2,14,i))) ...
                         || ~isnan(cell2mat(BJ_data(j+3,14,i))) || ~isnan(cell2mat(BJ_data(j+4,14,i))) ...
                         || ~isnan(cell2mat(BJ_data(j+5,14,i))) || ~isnan(cell2mat(BJ_data(j+6,14,i))) || ~isnan(cell2mat(BJ_data(j+7,14,i)))
                     %%r如果第八个不是NaN，也就是连续NaN数最多是7
                        for k=1:6
                            if isnan(cell2mat(BJ_data(j+k,14,i)))
                                h=h+1;
                            else
                                break
                            end
                        end
                        for k=1:h
                            BJ_data(j+k-1,14,i)=num2cell(((cell2mat(BJ_data(j+h,14,i))-cell2mat(BJ_data(j-1,14,i)))/(h+1))*k+cell2mat(BJ_data(j-1,14,i)));
                        end
                end
               end
            end
                   h=1;
        end
        h=1;
        
end
toc

%%将temp_BJ_data_new按照时间合并

%%合并
tic
BJ_temperature=BJ_data(:,:,1);
for j=2:BJ_num
     if mod(j,1000)==0 %观测算法的运算速度
       j 
    end     
    BJ_temperature=cat(1,BJ_temperature,BJ_data(:,:,j));
end

toc

BJ_temperature=cell2table(BJ_temperature);

tic
writetable(BJ_temperature,'temp_BJ_17_01_18_05-20_data_weather_75_model_with_time_interplot_new_without_encoding.csv');
toc

%%%%%%%%%%%%将临近四个站点的PM2.5、PM10、O3、NO2、CO、SO2放到16列以后（保留站点名称，后面好分辨是否插对了）
clear
tic
BJ=readtable('temp_BJ_17_01_18_05-20_data_weather_75_model_with_time_interplot_new_without_encoding_sort_time.csv');%%导入按照时间排序的表格
toc

% BJ(152049,1)=BJ(152048,2);
% BJ(152048,:) = [];
%%对北京按照utc_time来分组，形成三维元胞数组
tic
temp_utc_time=table2cell(BJ(1,2)); %初始化第一个用于分类的utc_time
BJ_data=cell(5,size(BJ,2),10);%初始化三维元胞数组
BJ_num=1;%站点数目
j=1;%记录循环中每个二维元胞数组里面行号
for i = 1:size(BJ,1)
      if mod(i,1000)==0 %观测算法的运算速度
       i  
      end
      if isequal(temp_utc_time, table2cell(BJ(i,2)))
           BJ_data(j,1:size(BJ,2),BJ_num)=table2cell(BJ(i,1:size(BJ,2)));
           j=j+1;
      else
           temp_utc_time=table2cell(BJ(i,2));
           BJ_num=BJ_num + 1;
           BJ_data(1,1:size(BJ,2),BJ_num)=table2cell(BJ(i,1:size(BJ,2)));
           j=2;
      end
end
toc

temp_BJ_data_1=BJ_data(:,:,1);

temp_BJ_data=temp_BJ_data_1;
temp_BJ_data_new=cell(size(BJ_data,1),64,size(BJ_data,3));
tic
for i=1:size(BJ_data,3)
        if mod(i,1000)==0 %观测算法的运算速度
        i  
        end 
         if ~isnan(cell2mat(BJ_data(1,3,i)))
        temp_BJ_data_new(:,1:63,i)=BJ_knn_full_aqi_station(BJ_data(:,1:15,i));
        temp_BJ_data_new(:,64,i)=BJ_data(:,16,i);
        end
end
toc
temp_BJ_data_new_1=temp_BJ_data_new(:,:,1);

%%将temp_BJ_data_new按照时间合并

%%合并
tic
BJ_temperature=temp_BJ_data_new(:,:,1);
for j=2:BJ_num
       if mod(j,1000)==0 %观测算法的运算速度
       j  
      end   
    BJ_temperature=cat(1,BJ_temperature,temp_BJ_data_new(:,:,j));
end

toc

BJ_temperature=cell2table(BJ_temperature);

tic
writetable(BJ_temperature,'temp_BJ_17_01_18_05-20_data_weather_75_model_full_result_new_new_without_encoding.csv');
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
tic
BJ=readtable('temp_BJ_17_01_18_05-20_data_weather_75_model_full_result_new_new_without_encoding_new.csv'); %%%按照站点顺序排列，天气在最后一列
toc
BJ=table2cell(BJ);

for i=1:size(BJ,1)
    if isequal(BJ{i,64},'Cloudy') 
            BJ(i,64)=num2cell(1);
    elseif isequal(BJ{i,64},'Dust') 
            BJ(i,64)=num2cell(2);
    elseif isequal(BJ{i,64},'Fog') 
            BJ(i,64)=num2cell(3);
    elseif isequal(BJ{i,64},'Hail') || isequal(BJ{i,64},'Haze')
            BJ(i,64)=num2cell(4);
    elseif isequal(BJ{i,64},'Light Rain') 
            BJ(i,64)=num2cell(5);
    elseif isequal(BJ{i,64},'Overcast') 
            BJ(i,64)=num2cell(6);
    elseif isequal(BJ{i,64},'Rain') 
            BJ(i,64)=num2cell(7);
    elseif isequal(BJ{i,64},'Rain with Hail') 
            BJ(i,64)=num2cell(8);
    elseif isequal(BJ{i,64},'Rain/Snow with Hail') 
            BJ(i,64)=num2cell(9);
    elseif isequal(BJ{i,64},'Sand') 
            BJ(i,64)=num2cell(10);
    elseif isequal(BJ{i,64},'Sleet') 
            BJ(i,64)=num2cell(11);
    elseif isequal(BJ{i,64},'Snow') 
            BJ(i,64)=num2cell(12);
    elseif isequal(BJ{i,64},'Sunny/clear') 
            BJ(i,64)=num2cell(13);
    else
            BJ(i,64)=num2cell(14);
    end
end

BJ=cell2table(BJ);

tic
writetable(BJ,'temp_BJ_17_01_18_05-20_data_weather_75_model_full_result_new_new_with_encoding.csv','Delimiter',',','QuoteStrings',true)
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear
% tic
% BJ=readtable('temp_BJ_all_month_data_weather_75_model_full_result_new_new_new_without_encoding.csv');%%%按站点排序
% toc
% 
% %%%%将北京aqi-meo总表按照aqi站点进行分组
% tic
% temp_aqi_station=table2cell(BJ(1,1)); %初始化第一个用于分类的aqi_station
% BJ_data=cell(200,size(BJ,2),35);%初始化三维元胞数组
% BJ_num=1;%站点数目
% j=1;%记录循环中每个二维元胞数组里面行号
% for i = 1:size(BJ,1)
%       if mod(i,1000)==0 %观测算法的运算速度
%        i  
%       end
%       if isequal(temp_aqi_station, table2cell(BJ(i,1)))
%            BJ_data(j,1:size(BJ,2),BJ_num)=table2cell(BJ(i,1:size(BJ,2)));
%            j=j+1;
%       else
%            temp_aqi_station=table2cell(BJ(i,1));
%            BJ_num=BJ_num + 1;
%            BJ_data(1,1:size(BJ,2),BJ_num)=table2cell(BJ(i,1:size(BJ,2)));
%            j=2;
%       end
% end
% toc
% 
% %BJ_data_beta=BJ_data;%%备份以防出错
% %BJ_data=BJ_data_beta;%%还原
% 
% %%%%%%将5-32列
% %%即温度、压强、湿度、风速、风向、PM2.5、PM10、O3以及4个临近站点的PM2.5、PM10、O3、风速、风向
% %%移动8次
% 
% timestep=8;
% for i=1:size(BJ_data,3) 
%     for k=1:timestep
%         for j=1:size(BJ_data(:,:,i),1)-1
%             BJ_data(j,37+32*(k-1):68+32*(k-1),i)=BJ_data(j+1,5+32*(k-1):36+32*(k-1),i);
%         end
%     end
% end
% 
% %temp_BJ_data_1=BJ_data(:,:,1);
% 
% %BJ_data_alpha=BJ_data;%%%备份
% 
% %%合并
% tic
% BJ_temperature=BJ_data(:,:,1);
% for j=2:BJ_num
%        j     
%     BJ_temperature=cat(1,BJ_temperature,BJ_data(:,:,j));
% end
% 
% toc
% 
% BJ_temperature=cell2table(BJ_temperature);
% 
% 
% %%%%%%%%将风向、天气统一移动到最后
% tic
% BJ_temperature = BJ_temperature(:,[1:267 269:292 268]);
% BJ_temperature = BJ_temperature(:,[1:235 237:292 236]);
% BJ_temperature = BJ_temperature(:,[1:203 205:292 204]);
% BJ_temperature = BJ_temperature(:,[1:171 173:292 172]);
% BJ_temperature = BJ_temperature(:,[1:139 141:292 140]);
% BJ_temperature = BJ_temperature(:,[1:107 109:292 108]);
% BJ_temperature = BJ_temperature(:,[1:75 77:292 76]);
% BJ_temperature = BJ_temperature(:,[1:43 45:292 44]);
% BJ_temperature = BJ_temperature(:,[1:11 13:292 12]);
% toc
% %BJ_temperature_beta=BJ_temperature;%%%备份
% %BJ_temperature=BJ_temperature_beta;%%%还原
% 
% %%%%%%%将最后五小时的邻近站点的pm2.5，pm10，O3，风速，风向移动到最后
% tic
% BJ_temperature = BJ_temperature(:,[1:259 284:292 260:283]);
% BJ_temperature = BJ_temperature(:,[1:228 253:292 229:252]);
% BJ_temperature = BJ_temperature(:,[1:197 222:292 198:221]);
% BJ_temperature = BJ_temperature(:,[1:166 191:292 167:190]);
% BJ_temperature = BJ_temperature(:,[1:135 160:292 136:159]);
% toc
% %BJ_temperature_alpha=BJ_temperature;%%备份
% 
% %%%%%%%将前4小时的邻近站点的数据全部删去
% tic
% BJ_temperature(:,{'BJ_temperature109','BJ_temperature110','BJ_temperature111','BJ_temperature112','BJ_temperature113','BJ_temperature114','BJ_temperature115','BJ_temperature116','BJ_temperature117','BJ_temperature118','BJ_temperature119','BJ_temperature120','BJ_temperature121','BJ_temperature122','BJ_temperature123','BJ_temperature124','BJ_temperature125','BJ_temperature126','BJ_temperature127','BJ_temperature128','BJ_temperature129','BJ_temperature130','BJ_temperature131','BJ_temperature132'}) = [];
% BJ_temperature(:,{'BJ_temperature77','BJ_temperature78','BJ_temperature79','BJ_temperature80','BJ_temperature81','BJ_temperature82','BJ_temperature83','BJ_temperature84','BJ_temperature85','BJ_temperature86','BJ_temperature87','BJ_temperature88','BJ_temperature89','BJ_temperature90','BJ_temperature91','BJ_temperature92','BJ_temperature93','BJ_temperature94','BJ_temperature95','BJ_temperature96','BJ_temperature97','BJ_temperature98','BJ_temperature99','BJ_temperature100'}) = [];
% BJ_temperature(:,{'BJ_temperature45','BJ_temperature46','BJ_temperature47','BJ_temperature48','BJ_temperature49','BJ_temperature50','BJ_temperature51','BJ_temperature52','BJ_temperature53','BJ_temperature54','BJ_temperature55','BJ_temperature56','BJ_temperature57','BJ_temperature58','BJ_temperature59','BJ_temperature60','BJ_temperature61','BJ_temperature62','BJ_temperature63','BJ_temperature64','BJ_temperature65','BJ_temperature66','BJ_temperature67','BJ_temperature68'}) = [];
% BJ_temperature(:,{'BJ_temperature13','BJ_temperature14','BJ_temperature15','BJ_temperature16','BJ_temperature17','BJ_temperature18','BJ_temperature19','BJ_temperature20','BJ_temperature21','BJ_temperature22','BJ_temperature23','BJ_temperature24','BJ_temperature25','BJ_temperature26','BJ_temperature27','BJ_temperature28','BJ_temperature29','BJ_temperature30','BJ_temperature31','BJ_temperature32','BJ_temperature33','BJ_temperature34','BJ_temperature35','BJ_temperature36'}) = [];
% toc
% %BJ_temperature_delta=BJ_temperature;%%备份
% 
% %%%%%%%删除站点名称
% tic
% BJ_temperature(:,{'BJ_temperature269','BJ_temperature275','BJ_temperature281','BJ_temperature287','BJ_temperature237','BJ_temperature243','BJ_temperature249','BJ_temperature255','BJ_temperature205','BJ_temperature211','BJ_temperature217','BJ_temperature223','BJ_temperature173','BJ_temperature179','BJ_temperature185','BJ_temperature191','BJ_temperature141','BJ_temperature147','BJ_temperature153','BJ_temperature159'}) = [];
% toc
% 
% %BJ_temperature_alpha=BJ_temperature;%%备份
% 
% %%%%%%%将最后一小时的PM2.5、PM10、O3移动60次
% 
% %%%%将北京aqi-meo总表按照aqi站点进行分组
% BJ=BJ_temperature;
% tic
% temp_aqi_station=table2cell(BJ(1,1)); %初始化第一个用于分类的aqi_station
% BJ_data=cell(200,size(BJ,2),35);%初始化三维元胞数组
% BJ_num=1;%站点数目
% j=1;%记录循环中每个二维元胞数组里面行号
% for i = 1:size(BJ,1)
%       if mod(i,1000)==0 %观测算法的运算速度
%        i  
%       end
%       if isequal(temp_aqi_station, table2cell(BJ(i,1)))
%            BJ_data(j,1:size(BJ,2),BJ_num)=table2cell(BJ(i,1:size(BJ,2)));
%            j=j+1;
%       else
%            temp_aqi_station=table2cell(BJ(i,1));
%            BJ_num=BJ_num + 1;
%            BJ_data(1,1:size(BJ,2),BJ_num)=table2cell(BJ(i,1:size(BJ,2)));
%            j=2;
%       end
% end
% toc
% 
% tic
% for i=1:BJ_num
%     i
%     for j=1:size(BJ_data(:,:,i),1)-1
%         BJ_data(j,177,i)=BJ_data(j+1,65,i); %%将变量移向右向上移动
%         BJ_data(j,178,i)=BJ_data(j+1,66,i); %%将变量移向右向上移动
%         BJ_data(j,179,i)=BJ_data(j+1,67,i); %%将变量移向右向上移动
%     end
% end
% toc
% 
% tic
% hour=59;
%  for i=1:BJ_num
%     i
%     for k=1:hour
%         for j=1:size(BJ_data(:,:,i),1)-1
%     BJ_data(j,180+3*(k-1),i)=BJ_data(j+1,177+3*(k-1),i); %%将变量移向右向上移动
%     BJ_data(j,181+3*(k-1),i)=BJ_data(j+1,178+3*(k-1),i); %%将变量移向右向上移动
%     BJ_data(j,182+3*(k-1),i)=BJ_data(j+1,179+3*(k-1),i); %%将变量移向右向上移动
%         end
%     end
%  end
%  toc
% 
% %合并成移动过后的aqi-meo总表
% tic
% BJ_temperature_new=BJ_data(:,:,1);
% for j=2:BJ_num
%        j     
%     BJ_temperature_new=cat(1,BJ_temperature_new,BJ_data(:,:,j));
% end
% 
% toc
% 
% BJ_temperature_new=cell2table(BJ_temperature_new);
% 
% %%%记得修改保存文件名称，导出后要删除最后一列里面的空白行
% tic
% writetable(BJ_temperature_new,'BJ_all_month_aqi_meo_75_model_train_new.csv','Delimiter',',','QuoteStrings',true)
% toc