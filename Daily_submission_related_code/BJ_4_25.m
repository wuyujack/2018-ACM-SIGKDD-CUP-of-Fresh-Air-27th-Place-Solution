%%% author: Jason Leung

clear
tic
BJ=readtable('bj_meo_2018-05-31.csv'); %%%按照站点顺序排列，时间在第二列，删除掉station_id, 天气状况这两列，其他不用删除
toc

tic
temp_station_id=table2cell(BJ(1,1)); %初始化第一个用于分类的staion_id
BJ_data=cell(5,7,10);%初始化三维元胞数组, 注意第一个位置的值要调整一下，即每个元胞的行数
BJ_num=1;%站点数目
j=1;%记录循环中每个二维元胞数组里面行号
for i = 1:size(BJ,1)
      if mod(i,1000)==0 %观测算法的运算速度
       i  
      end
      if isequal(temp_station_id, table2cell(BJ(i,1)))
           BJ_data(j,1:7,BJ_num)=table2cell(BJ(i,1:7));
           j=j+1;
      else
           temp_station_id=table2cell(BJ(i,1));
           BJ_num=BJ_num + 1;
           BJ_data(1,1:7,BJ_num)=table2cell(BJ(i,1:7));
           j=2;
      end
end
toc

%%将空气观测站的名称加入到BJ_data表的第8,9列
[d,e,f]=xlsread('station_meo');%导入空气质量站的经纬度坐标
for i=1:size(BJ_data,3)
   
     BJ_data(1:size(BJ_data(:,:,i),1),8:9,i)=repmat(f(i+1,2:3),size(BJ_data(:,:,i),1),1);
    
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
writetable(BJ_new,'BJ_5_31_data_with_location.csv','Delimiter',',','QuoteStrings',true)
toc

%%%%%%%%%%%%%%%先调整好utc时间顺序再上传

clear;
tic
[a,b,c]=xlsread('meo_170106_16.xlsx');%导入气象站的经纬度坐标、风速风向等数据
y=readtable('bj_aqi_2018-05-31.csv');%注意只保留数据完整的9小时，检查是否只保留了PM2.5、PM10、O3
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
aqi=cell(35,5,5);%生成6511个35行，12列的元胞数据，注意行列要调换——（行，列，元胞个数）
tic
 for i=1:size(y,1) %对17-18年的气象观测站数据表里面每一行与设定的utc_time进行匹配
  
    if mod(i,1000)==0 %观测算法的运算速度
       i  
    end
    if isequal(table2cell(y(i,2)),table2cell(aqi_utc_time)) %如果该行第4列的utc_time与预先设定好的utc_time匹配上，则执行如下操作
        aqi(j,1:5,k)=table2cell(y(i,1:5)); %将时间戳匹配上的记录复制到第k个元胞数组里，行是记录，列是不同的数据如utc_time,station等
        j=j+1;%记录循环次数，并且由于每个元胞都是从第1行开始然后到第35行，所以j用于控制复制的记录在元胞数组中的位置
    else %如果匹配不上
        %L(i-1,1:10,k)=x(i,1:10);
        aqi_utc_time=y(i,2);%如果匹配不上，由于提前已经对utc_time进行了排序，因此说明出现了新的时间戳，此时就要更改之前utc的默认值
        k=k+1;%由于出现了新的时间戳，因此要用一个新的二维元胞数组重新进行记录
        aqi(1,1:5,k)=table2cell(y(i,1:5));%将这条记录放置到新的二维元胞数组里面，并且这一条是第一条记录，因此是“1”
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
                    if isequal(aqi(q,1,i),P(r,10,j))
                        aqi(q,6:15,i)=P(r,1:10,j);
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
beijing_aqi_full(:,{'beijing_aqi_full6','beijing_aqi_full15'}) = [];

BJ=beijing_aqi_full;
BJ=table2cell(BJ);

%%将风向添加到BJ的14列
tic
for i=1:size(BJ,1)
            if mod(i,1000)==0 %观测算法的运算速度
            i    
            end
            if cell2mat(BJ(i,11))>0 && cell2mat(BJ(i,12))>0
            BJ(i,14)=num2cell((atan(cell2mat(BJ(i,11))/cell2mat(BJ(i,12)))/pi)*180);
            elseif cell2mat(BJ(i,11))>0 && cell2mat(BJ(i,12))<0
            BJ(i,14)= num2cell((atan(cell2mat(BJ(i,11))/cell2mat(BJ(i,12)))/pi)*180+180);
            elseif cell2mat(BJ(i,11))<0 && cell2mat(BJ(i,12))<0
            BJ(i,14)=num2cell((atan(cell2mat(BJ(i,11))/cell2mat(BJ(i,12)))/pi)*180+180);
            elseif cell2mat(BJ(i,11))<0 && cell2mat(BJ(i,12))>0 
            BJ(i,14)=num2cell((atan(cell2mat(BJ(i,11))/cell2mat(BJ(i,12)))/pi)*180+360);
            elseif cell2mat(BJ(i,11))==0 && cell2mat(BJ(i,12))>0
            BJ(i,14)=num2cell(0);
            elseif cell2mat(BJ(i,11))==0 && cell2mat(BJ(i,12))<0
            BJ(i,14)=num2cell(180);  
            elseif cell2mat(BJ(i,11))>0 && cell2mat(BJ(i,12))==0
            BJ(i,14)=num2cell(90);
            elseif cell2mat(BJ(i,11))<0 && cell2mat(BJ(i,12))==0
            BJ(i,14)=num2cell(270);
            else
            BJ(i,14)=num2cell(NaN);
            end
end
toc

BJ=cell2table(BJ);

BJ(:,{'BJ11','BJ12'}) = [];
BJ = BJ(:,[1:2 4:11 3 end]);
BJ = BJ(:,[1:2 4:11 3 end]);
BJ = BJ(:,[1:2 4:11 3 end]);
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
        temp_BJ_data_new(:,1:11,i)=BJ_knn_aqi(BJ_data(:,1:11,i));
        temp_BJ_data_new(:,12,i)=BJ_data(:,12,i);
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
writetable(BJ,'beijing_5_31_aqi_meo_full_space_interplote_75_model.csv');
toc

%%%%%%%%%%%%将临近四个站点的PM2.5、PM10、O3放到13列以后（保留站点名称，后面好分辨是否插对了）
clear
tic
BJ=readtable('beijing_5_31_aqi_meo_full_space_interplote_75_model_sort_time.csv');%%导入按照时间排序的表格
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
temp_BJ_data_new=cell(size(BJ_data,1),36,size(BJ_data,3));
tic
for i=1:size(BJ_data,3)
         i 
         if ~isnan(cell2mat(BJ_data(1,3,i)))
        temp_BJ_data_new(:,1:36,i)=BJ_knn_aqi_station(BJ_data(:,:,i));
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
writetable(BJ_temperature,'5_31_BJ_data_75_model_full_result.csv');%%导出后要插入表头，并且按照站点排序，导入python处理
toc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear
% tic
% BJ=readtable('5_08_BJ_data_75_model_full_result_new.csv');%%%按照站点排序
% toc
% 
% %%%%将北京aqi-meo总表按照aqi站点进行分组
% tic
% temp_aqi_station=table2cell(BJ(1,1)); %初始化第一个用于分类的aqi_station
% BJ_data=cell(5,size(BJ,2),35);%初始化三维元胞数组
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
% %%%%%%%%将风向统一移动到最后
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
% BJ=BJ_temperature;
% 
% tic
% temp_aqi_station=table2cell(BJ(1,1)); %初始化第一个用于分类的aqi_station
% BJ_data=cell(5,size(BJ,2),35);%初始化三维元胞数组
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

%%%%%%%%%按照submission的北京站点顺序进行排序
clear
tic
BJ=readtable('5_31_BJ_data_75_model_full_result_new_without_sort.csv');%%%按照站点排序
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
writetable(BJ_temperature,'BJ_aqi_meo_5_31_75_model_test_new.csv','Delimiter',',','QuoteStrings',true)
toc
