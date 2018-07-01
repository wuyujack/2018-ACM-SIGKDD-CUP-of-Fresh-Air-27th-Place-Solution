% clear
% tic
% BJ=readtable('bj_meo_2018-05-13.csv'); %%%按照站点顺序排列，时间在第二列，删除掉station_id, 天气状况这两列，其他不用删除
% toc
% 
% tic
% temp_station_id=table2cell(BJ(1,1)); %初始化第一个用于分类的staion_id
% BJ_data=cell(5,size(BJ,2),10);%初始化三维元胞数组, 注意第一个位置的值要调整一下，即每个元胞的行数
% BJ_num=1;%站点数目
% j=1;%记录循环中每个二维元胞数组里面行号
% for i = 1:size(BJ,1)
%       if mod(i,1000)==0 %观测算法的运算速度
%        i  
%       end
%       if isequal(temp_station_id, table2cell(BJ(i,1)))
%            BJ_data(j,1:size(BJ,2),BJ_num)=table2cell(BJ(i,1:size(BJ,2)));
%            j=j+1;
%       else
%            temp_station_id=table2cell(BJ(i,1));
%            BJ_num=BJ_num + 1;
%            BJ_data(1,1:size(BJ,2),BJ_num)=table2cell(BJ(i,1:size(BJ,2)));
%            j=2;
%       end
% end
% toc
% 
% %%将空气观测站的名称加入到BJ_data表的第8,9列
% [d,e,f]=xlsread('station_meo');%导入空气质量站的经纬度坐标
% for i=1:size(BJ_data,3)
%    
%      BJ_data(1:size(BJ_data(:,:,i),1),8:9,i)=repmat(f(i+1,2:3),size(BJ_data(:,:,i),1),1);
%     
% end
% 
% tic
% BJ_new=BJ_data(:,:,1);
% for j=2:BJ_num
%        j     
%     BJ_new=cat(1,BJ_new,BJ_data(:,:,j));
% end
% 
% toc
% 
% %%%导出带有经纬度的北京4月份数据表
% BJ_new=cell2table(BJ_new);
% 
% tic
% writetable(BJ_new,'BJ_5_13_data_with_location.csv','Delimiter',',','QuoteStrings',true)
% toc

%%%%%%%%%%%%%%%先调整好utc时间顺序再上传

clear;
tic
[a,b,c]=xlsread('meo_170106_16.xlsx');%导入气象站的经纬度坐标、风速风向等数据
y=readtable('bj_aqi_2018-05-31_new.csv');%注意只保留数据完整的9小时，包含NO2，CO，SO2
aqi_time_index=table2cell(unique(y(:,2)));
x=readtable('BJ_5_31_data_with_location_new.csv');%%%导入的表格是按照时间顺序排列的，只保留数据完整的和气象表对应的9小时
x = x(:,[1 8 2:7 end]);
x = x(:,[1:2 9 3:8]);
x = x(:,[1:7 9 8]);
x=table2cell(x);
meo_time_index=unique(x(:,4));%获取唯一的utc_time时间戳
toc

k=1;
g=1;
j=1;
tic
aqi_utc_time=x(2,4);%初始化第一个匹配的utc_time
L=cell(18,10,5);%生成8782个18行，10列的元胞数据，注意行列要调换——（行，列，元胞个数）
for i=2:size(x,1) %对17-18年的气象观测站数据表里面每一行与设定的utc_time进行匹配
    if mod(i,1000)==0 %观测算法的运算速度
       i  
    end
    if strcmp(cell2mat(x(i,4)),cell2mat(aqi_utc_time)) %如果该行第4列的utc_time与预先设定好的utc_time匹配上，则执行如下操作
        L(j,1:9,k)=x(i,1:9); %将时间戳匹配上的记录复制到第k个元胞数组里，行是记录，列是不同的数据如utc_time,station等
        j=j+1;%记录循环次数，并且由于每个元胞都是从第一行开始然后到第十八行，所以j用于控制复制的记录在元胞数组中的位置
    else %如果匹配不上
        %L(i-1,1:10,k)=x(i,1:10);
        aqi_utc_time=x(i,4);%如果匹配不上，由于提前已经对utc_time进行了排序，因此说明出现了新的时间戳，此时就要更改之前utc的默认值
        k=k+1;%由于出现了新的时间戳，因此要用一个新的二维元胞数组重新进行记录
        L(1,1:9,k)=x(i,1:9);%将这条记录放置到新的二维元胞数组里面，并且这一条是第一条记录，因此是“1”
        j=2;%后面的每一条新的匹配记录都是从2开始录入
    end
    
end
toc

tic
[d,~,~]=xlsread('station_AQI');%导入空气质量站的经纬度坐标
O=[35,6,size(L,3)];
for i=1:size(L,3)
           i  
           temp_meo=[cell2mat(L(:,2,i)) cell2mat(L(:,3,i)) cell2mat(L(:,3,i)) cell2mat(L(:,5,i)) cell2mat(L(:,6,i)) cell2mat(L(:,7,i)) cell2mat(L(:,8,i)) cell2mat(L(:,9,i))];
           W=knn_interplote(temp_meo,d);
           O(1:35,2:9,i)=W(1:35,1:8,1);
end
toc

%%将utc_time时间戳按照顺序从L表复制到P表的第一行第一列
 P=num2cell(O);
for i=1:size(L,3)
P(1,1,i)=L(1,4,i);
end

%%将空气观测站的名称加入到P表的第10列
[d,e,f]=xlsread('station_AQI');%导入空气质量站的经纬度坐标
for i=1:size(L,3)
    if i~=8226
     P(:,10,i)=e(2:size(P(:,:,i),1)+1,1);
    end
end

%%对北京aqi 4月份新数据的总表按照时间戳进行分组
k=1;
g=1;
j=1;

aqi_utc_time=y(1,2);%初始化第一个匹配的utc_time
aqi=cell(35,size(y,2),5);%生成6511个35行，12列的元胞数据，注意行列要调换——（行，列，元胞个数）
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

%%将P表和4月份aqi表先按照小时然后按照站点进行匹配
tic
t1=1;
s1=1;
for i=1:size(aqi,3)
    
       i     
    
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
%beijing_aqi_full(:,{'beijing_aqi_full6','beijing_aqi_full15'}) = [];
beijing_aqi_full(:,{'beijing_aqi_full9','beijing_aqi_full18'}) = [];

BJ=beijing_aqi_full;
BJ=table2cell(BJ);

%%将风向添加到BJ的17列
tic
for i=1:size(BJ,1)
            if mod(i,1000)==0 %观测算法的运算速度
            i    
            end
            if cell2mat(BJ(i,14))>0 && cell2mat(BJ(i,15))>0
            BJ(i,17)=num2cell((atan(cell2mat(BJ(i,14))/cell2mat(BJ(i,15)))/pi)*180);
            elseif cell2mat(BJ(i,14))>0 && cell2mat(BJ(i,15))<0
            BJ(i,17)= num2cell((atan(cell2mat(BJ(i,14))/cell2mat(BJ(i,15)))/pi)*180+180);
            elseif cell2mat(BJ(i,14))<0 && cell2mat(BJ(i,15))<0
            BJ(i,17)=num2cell((atan(cell2mat(BJ(i,14))/cell2mat(BJ(i,15)))/pi)*180+180);
            elseif cell2mat(BJ(i,14))<0 && cell2mat(BJ(i,15))>0 
            BJ(i,17)=num2cell((atan(cell2mat(BJ(i,14))/cell2mat(BJ(i,15)))/pi)*180+360);
            elseif cell2mat(BJ(i,14))==0 && cell2mat(BJ(i,15))>0
            BJ(i,17)=num2cell(0);
            elseif cell2mat(BJ(i,14))==0 && cell2mat(BJ(i,15))<0
            BJ(i,17)=num2cell(180);  
            elseif cell2mat(BJ(i,14))>0 && cell2mat(BJ(i,15))==0
            BJ(i,17)=num2cell(90);
            elseif cell2mat(BJ(i,14))<0 && cell2mat(BJ(i,15))==0
            BJ(i,17)=num2cell(270);
            else
            BJ(i,17)=num2cell(NaN);
            end
end
toc

BJ=cell2table(BJ);

BJ(:,{'BJ14','BJ15'}) = [];
BJ = BJ(:,[1:2 4:14 3 end]);
BJ = BJ(:,[1:2 4:14 3 end]);
BJ = BJ(:,[1:2 4:14 3 end]);
BJ = BJ(:,[1:2 4:14 3 end]);
BJ = BJ(:,[1:2 4:14 3 end]);
BJ = BJ(:,[1:2 4:14 3 end]);

%%%%%%%%%%%%将BJ表格按照时间分组，然后对每一组进行空间插值填补NaN

%%对北京按照utc_time来分组，形成三维元胞数组
tic
temp_utc_time=table2cell(BJ(1,2)); %初始化第一个用于分类的utc_time
BJ_data=cell(5,size(BJ,2),9);%初始化三维元胞数组
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
        temp_BJ_data_new(:,15,i)=BJ_data(:,15,i);
end
toc

temp_BJ_data_test=temp_BJ_data_new(:,:,1);



%%将temp_BJ_data_new按照时间合并

%%合并
tic
BJ_temperature=temp_BJ_data_new(:,:,1);
for j=2:BJ_num
       j     
    BJ_temperature=cat(1,BJ_temperature,temp_BJ_data_new(:,:,j));
end

toc


BJ_temperature=cell2table(BJ_temperature);
BJ_temperature = sortrows(BJ_temperature,'BJ_temperature1','ascend');
BJ=BJ_temperature;

tic
writetable(BJ,'beijing_5_31_aqi_meo_full_space_interplote_75_model_with_NO2_CO_SO2.csv');
toc

%%%%%%%%%%%%将临近四个站点的PM2.5、PM10、O3放到13列以后（保留站点名称，后面好分辨是否插对了）
clear
tic
BJ=readtable('beijing_5_31_aqi_meo_full_space_interplote_75_model_with_NO2_CO_SO2_sort_time.csv');%%导入按照时间排序的表格
toc

%%对北京按照utc_time来分组，形成三维元胞数组
tic
temp_utc_time=table2cell(BJ(1,2)); %初始化第一个用于分类的utc_time
BJ_data=cell(5,size(BJ,2),5);%初始化三维元胞数组
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
temp_BJ_data_new=cell(size(BJ_data,1),63,size(BJ_data,3));
tic
for i=1:size(BJ_data,3)
         i 
         if ~isnan(cell2mat(BJ_data(1,3,i)))
        temp_BJ_data_new(:,1:63,i)=BJ_knn_full_aqi_station(BJ_data(:,1:15,i));
        end
end
toc
temp_BJ_data_new_1=temp_BJ_data_new(:,:,1);

%%将temp_BJ_data_new按照时间合并

%%合并
tic
BJ_temperature=temp_BJ_data_new(:,:,1);
for j=2:BJ_num
       j     
    BJ_temperature=cat(1,BJ_temperature,temp_BJ_data_new(:,:,j));
end

toc

BJ_temperature=cell2table(BJ_temperature);

tic
writetable(BJ_temperature,'5_31_BJ_data_75_model_full_result_with_NO2_CO_SO2.csv');%%导出后要插入表头，并且按照站点排序，导入python处理
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%按照submission的北京站点顺序进行排序
clear
tic
BJ=readtable('5_31_BJ_data_75_model_full_result_with_NO2_CO_SO2_new_without_sort_winddirection_encoding.csv');%%%按照站点排序
toc

%%%%将北京aqi-meo总表按照aqi站点进行分组
tic
temp_aqi_station=table2cell(BJ(1,1)); %初始化第一个用于分类的aqi_station
BJ_data=cell(5,size(BJ,2),35);%初始化三维元胞数组
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

[~,~,BJ_predict_station]=xlsread('BJ_predict_station_id');%导入空气质量站的经纬度坐标
BJ_data_new=cell(size(BJ_data));

for i=1:size(BJ_predict_station,1)
     for j=1:size(BJ_data,3)
        if isequal(BJ_data(1,1,j),BJ_predict_station(i,1))
            BJ_data_new(:,:,i)=BJ_data(:,:,j);
        end 
     end
end

%%合并
tic
BJ_temperature=BJ_data_new(:,:,1);
for j=2:BJ_num
       j     
    BJ_temperature=cat(1,BJ_temperature,BJ_data_new(:,:,j));
end

toc

BJ_temperature=cell2table(BJ_temperature);

%%%记得修改保存文件名称
tic
writetable(BJ_temperature,'BJ_aqi_meo_5_31_75_model_test_new_with_NO2_CO_SO2_winddirection_encoding.csv','Delimiter',',','QuoteStrings',true)
toc
