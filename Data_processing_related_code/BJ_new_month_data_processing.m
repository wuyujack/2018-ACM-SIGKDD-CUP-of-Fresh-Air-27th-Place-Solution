clear
tic
%BJ=readtable('bj_meteorology_2018-03-04-12_clean.csv');
%BJ=readtable('beijing_201802_201804_me.csv');%%%增加了天气变量
%BJ=readtable('bj_meo_2018-04-30-05-11.csv');%%%增加了天气变量
BJ=readtable('bj_meo_2018-05-11-20.csv');%%%增加了天气变量
toc

tic
temp_station_id=table2cell(BJ(1,1)); %初始化第一个用于分类的staion_id
BJ_data=cell(10,8,17);%初始化三维元胞数组, 注意第一个位置的值要调整一下，即每个元胞的行数
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

%%将空气质量站的经纬度按照站点复制到BJ_data的每一个子表里面

% tic
% BJ_new=BJ_data(:,:,1);
% for j=2:BJ_num
%        j     
%     BJ_new=cat(1,BJ_new,BJ_data(:,:,j));
% end
% 
% toc

%%将空气观测站的名称加入到BJ_data表的第8,9列
[d,e,f]=xlsread('station_meo');%导入气象观测站的经纬度坐标
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
BJ_new = BJ_new(:,[1 9 2:8 end]);
BJ_new = BJ_new(:,[1:2 10 3:9]);
BJ_new = BJ_new(:,[1:4 6:10 5]);

tic
%writetable(BJ_new,'BJ_new_month_data_with_location.csv','Delimiter',',','QuoteStrings',true)
writetable(BJ_new,'bj_meo_2018-05-11-20_with_location_weather.csv','Delimiter',',','QuoteStrings',true)
toc

%%% 按照相关关系整理出5张表格

%%% 湿度：温度

BJ_humidity=BJ_new;
BJ_humidity=cell2table(BJ_humidity);


BJ_humidity(:,{'BJ_humidity6','BJ_humidity7'}) = [];
BJ_humidity(:,'BJ_humidity4') = [];
BJ_humidity = BJ_humidity(:,[1 5 2:4 end]);
BJ_humidity = BJ_humidity(:,[1:2 6 3:5]);
toc

%%% 压强：温度，风速

BJ_pressure=BJ_new;
BJ_pressure=cell2table(BJ_pressure);

BJ_pressure = BJ_pressure(:,[1 8 2:7 end]);
BJ_pressure = BJ_pressure(:,[1:2 9 3:8]);
BJ_pressure(:,'BJ_pressure7') = [];
BJ_pressure(:,'BJ_pressure5') = [];
BJ_pressure = BJ_pressure(:,[1:5 7 6]);

tic
writetable(BJ_pressure,'BJ_pressure_new_month.csv','Delimiter',',','QuoteStrings',true)
toc

%%% 温度：压强，湿度

BJ_new=BJ_new;
BJ_new=cell2table(BJ_new);
BJ_new = BJ_new(:,[1 8 2:7 end]);
BJ_new = BJ_new(:,[1:2 9 3:8]);
BJ_new(:,{'BJ_temperature6','BJ_temperature7'}) = [];
BJ_new = BJ_new(:,[1:4 6:7 5]);

tic
writetable(BJ_new,'BJ_temperature_new_month.csv','Delimiter',',','QuoteStrings',true)
toc

%%% 风向：压强

BJ_winddirection=BJ_new;
BJ_winddirection=cell2table(BJ_winddirection);
BJ_winddirection = BJ_winddirection(:,[1 8 2:7 end]);
BJ_winddirection = BJ_winddirection(:,[1:2 9 3:8]);
BJ_winddirection(:,'BJ_winddirection6') = [];
BJ_winddirection(:,'BJ_winddirection5') = [];
BJ_winddirection(:,'BJ_winddirection3') = [];

tic
writetable(BJ_winddirection,'BJ_winddirection_new_month.csv','Delimiter',',','QuoteStrings',true)
toc

%%% 风速：温度，压强

BJ_windspeed=BJ_new;
BJ_windspeed=cell2table(BJ_windspeed);
BJ_windspeed = BJ_windspeed(:,[1 8 2:7 end]);
BJ_windspeed = BJ_windspeed(:,[1:2 9 3:8]);
BJ_windspeed(:,'BJ_windspeed5') = [];
BJ_windspeed(:,'BJ_windspeed7') = [];

tic
writetable(BJ_windspeed,'BJ_windspeed_new_month.csv','Delimiter',',','QuoteStrings',true)
toc