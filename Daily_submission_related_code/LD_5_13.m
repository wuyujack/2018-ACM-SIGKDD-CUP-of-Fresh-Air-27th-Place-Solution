% %%%%每日用于训练的伦敦aqi-meo数据表格生成
% 
% %%%将网格对应的经纬度坐标添加到4月份新的伦敦气象数据表格上面
% clear
% LD=readtable('ld_meo_2018-05-13.csv');%a按站点顺序，不用删除天气状况和风向，删去station_id
% LD = sortrows(LD,'station_id','ascend');
% LD_grid=readtable('London_meo_grid.csv');
% 
% %%%将4月份的新数据按照grid分组
% tic
% temp_grid=table2cell(LD(1,1)); %初始化第一个用于分类的grid名称
% LD_data=cell(5,8,10);%初始化三维元胞数组
% LD_num=1;%站点数目
% j=1;%记录循环中每个二维元胞数组里面行号
% for i = 1:size(LD,1)
%       if mod(i,1000)==0 %观测算法的运算速度
%        i  
%       end
%       if isequal(temp_grid, table2cell(LD(i,1)))
%            LD_data(j,1:8,LD_num)=table2cell(LD(i,1:8));
%            j=j+1;
%       else
%            temp_grid=table2cell(LD(i,1));
%            LD_num=LD_num + 1;
%            LD_data(1,1:8,LD_num)=table2cell(LD(i,1:8));
%            j=2;
%       end
% end
% toc
% 
% %%%将对应的经纬度坐标添加到LD_data的9,10列
% 
% for i=1:size(LD_data,3)
%    
%      LD_data(1:size(LD_data(:,:,i),1),9:11,i)=repmat(table2cell(LD_grid(i,1:3)),size(LD_data(:,:,i),1),1);
%     
% end
% 
% %%合并
% tic
% LD_temperature=LD_data(:,:,1);
% for j=2:LD_num
%        j     
%     LD_temperature=cat(1,LD_temperature,LD_data(:,:,j));
% end
% 
% toc
% 
% LD_temperature=cell2table(LD_temperature);
% 
% %%%导出csv以后记得去删除空白行
% tic
% writetable(LD_temperature,'LD_5_13_with_location.csv','Delimiter',',','QuoteStrings',true)
% toc
% 
% %%%%%%%对伦敦4月份气象网格数据（18.3.31-18.4.12），根据伦敦空气质量站的位置，确定每个空气质量站附近的4个网格点，提取出来后去重(unique()函数进行去重)
% %%%%%%%可以获得一个简化后的测试集作为预测下一小时气象数据的测试集；也可以用来求解气象总表，利用反距离加权
% 
% clear
% tic
% LD=readtable('LD_5_13_with_location_new.csv');%%%导入伦敦历史气象网格数据，上传前要按时间排序，不用删除任何行，一共11行
% LD_AQ_Stations=readtable('London_AirQuality_Stations.csv');
% LD_AQ_Stations = sortrows(LD_AQ_Stations,'Longitude','ascend');
% toc
% 
% LD(:,'LD_temperature3') = [];
% LD(:,'LD_temperature9') = [];
% LD = LD(:,[1 8 2:7 end]);
% LD = LD(:,[1:2 9 3:8]);
% 
% %%%将4月份的新数据按照utc_time分组
% tic
% temp_utc=table2cell(LD(1,4)); %初始化第一个用于分类的utc_time名称
% LD_data=cell(861,size(LD,2),5);%初始化三维元胞数组
% LD_num=1;%站点数目
% j=1;%记录循环中每个二维元胞数组里面行号
% for i = 1:size(LD,1)
%       if mod(i,1000)==0 %观测算法的运算速度
%        i  
%       end
%       if isequal(temp_utc, table2cell(LD(i,4)))
%            LD_data(j,1:size(LD,2),LD_num)=table2cell(LD(i,1:size(LD,2)));
%            j=j+1;
%       else
%            temp_utc=table2cell(LD(i,4));
%            LD_num=LD_num + 1;
%            LD_data(1,1:size(LD,2),LD_num)=table2cell(LD(i,1:size(LD,2)));
%            j=2;
%       end
% end
% toc
% 
% 
% %%求出每个空气质量站的邻近4个格点
% tic
% grid_data=cell(96,9,5);
% LD_grid_step=1;
% for i=1:size(LD_data,3)
%     if mod(i,861*18)==1 %观测算法的运算速度
%        i  
%      end
%    for j=1:size(LD_AQ_Stations,1)
%        temp_lon_index=(floor((table2array(LD_AQ_Stations(j,6))-(-2))/0.1))*21+1;
%        temp_lat_index=floor((table2array(LD_AQ_Stations(j,5))-(50.5000))/0.1);
%        temp_index_1=temp_lon_index+temp_lat_index;
%        grid_data(LD_grid_step,1:9,i)=LD_data(temp_index_1,1:9,i);
%        temp_index_2=temp_index_1+21;
%        LD_grid_step=LD_grid_step+1;
%        grid_data(LD_grid_step,1:9,i)=LD_data(temp_index_2,1:9,i);
%        temp_index_3=temp_index_1+1;
%        LD_grid_step=LD_grid_step+1;
%        grid_data(LD_grid_step,1:9,i)=LD_data(temp_index_3,1:9,i);
%        temp_index_4=temp_index_2+1;
%        LD_grid_step=LD_grid_step+1;
%        grid_data(LD_grid_step,1:9,i)=LD_data(temp_index_4,1:9,i);
%        LD_grid_step=LD_grid_step+1;
%    end
%    LD_grid_step=1;
% end
% toc
% 
% %%为grid_data(:,:,1)添加一列距离，每4行对应于一个aqi观测站，分别求这四行对应的格点坐标到该aqi观测站的距离
% %%一共24个观测站（注意需要预测的只有13个）
% 
% temp_grid_data=grid_data(:,:,1); %%看看计算有没有错误并用于后续的计算
% temp_grid_data_2=grid_data(:,:,2);
% LD_AQ_Stations_temp=table2cell(LD_AQ_Stations);
% j=1;
% for i=1:4:size(temp_grid_data,1) 
%         temp_grid_data(i,10)=num2cell(sqrt((cell2mat(LD_AQ_Stations_temp(j,5))-cell2mat(temp_grid_data(i,3)))^2+(cell2mat(LD_AQ_Stations_temp(j,6))-cell2mat(temp_grid_data(i,2)))^2));
%         temp_grid_data(i+1,10)=num2cell(sqrt((cell2mat(LD_AQ_Stations_temp(j,5))-cell2mat(temp_grid_data(i+1,3)))^2+(cell2mat(LD_AQ_Stations_temp(j,6))-cell2mat(temp_grid_data(i+1,2)))^2));
%         temp_grid_data(i+2,10)=num2cell(sqrt((cell2mat(LD_AQ_Stations_temp(j,5))-cell2mat(temp_grid_data(i+2,3)))^2+(cell2mat(LD_AQ_Stations_temp(j,6))-cell2mat(temp_grid_data(i+2,2)))^2));
%         temp_grid_data(i+3,10)=num2cell(sqrt((cell2mat(LD_AQ_Stations_temp(j,5))-cell2mat(temp_grid_data(i+3,3)))^2+(cell2mat(LD_AQ_Stations_temp(j,6))-cell2mat(temp_grid_data(i+3,2)))^2));
%         j=j+1;
% end
% 
% 
% %%将temp_grid_data(:,:,10)复制到剩余的所有元胞数组里面（因为每一个二维元胞里面包含的邻近格点都是相同的，因此计算相同）
% %%这样10806个二维元胞数组都增加了一列距离
% 
% grid_data(:,10,1)=temp_grid_data(:,10,1);
% temp_grid_data_distance=grid_data(:,10);
% for i=2:size(grid_data,3)
%         grid_data(:,10,i)=grid_data(:,10,1);
% end
% 
% %%%反距离平均求解温度、湿度、压强
% tic
% for j=1:size(grid_data,3)
%     for i=1:4:size(grid_data(:,:,j),1)
%         grid_data(i,11,j)=num2cell(cell2mat(grid_data(i,5,j))/(cell2mat(grid_data(i,10,j)))^2);%%%温度除以距离的平方
%         grid_data(i+1,11,j)=num2cell(cell2mat(grid_data(i+1,5,j))/cell2mat(grid_data(i+1,10,j))^2);
%         grid_data(i+2,11,j)=num2cell(cell2mat(grid_data(i+2,5,j))/cell2mat(grid_data(i+2,10,j))^2);
%         grid_data(i+3,11,j)=num2cell(cell2mat(grid_data(i+3,5,j))/cell2mat(grid_data(i+3,10,j))^2);
%         
%         grid_data(i,12,j)=num2cell(cell2mat(grid_data(i,6,j))/cell2mat(grid_data(i,10,j))^2);%%压强除以距离的平方
%         grid_data(i+1,12,j)=num2cell(cell2mat(grid_data(i+1,6,j))/cell2mat(grid_data(i+1,10,j))^2);
%         grid_data(i+2,12,j)=num2cell(cell2mat(grid_data(i+2,6,j))/cell2mat(grid_data(i+2,10,j))^2);
%         grid_data(i+3,12,j)=num2cell(cell2mat(grid_data(i+3,6,j))/cell2mat(grid_data(i+3,10,j))^2);
%         
%         grid_data(i,13,j)=num2cell(cell2mat(grid_data(i,7,j))/cell2mat(grid_data(i,10))^2);%%湿度除以距离的平方
%         grid_data(i+1,13,j)=num2cell(cell2mat(grid_data(i+1,7,j))/cell2mat(grid_data(i+1,10,j))^2);
%         grid_data(i+2,13,j)=num2cell(cell2mat(grid_data(i+2,7,j))/cell2mat(grid_data(i+2,10,j))^2);
%         grid_data(i+3,13,j)=num2cell(cell2mat(grid_data(i+3,7,j))/cell2mat(grid_data(i+3,10,j))^2);
%     end
% end
% toc
% 
% %%新建一个3维元胞数据存储伦敦空气质量站数据+对应气象站数据
% tic
% LD_aqi_stations_data=cell(24,13,size(grid_data,3));
% for i=1:size(grid_data,3)
%         LD_aqi_stations_data(:,1:8,i)=table2cell(LD_AQ_Stations(:,1:8));
% end
% toc
% 
% tic
% k=1;
% for j=1:size(grid_data,3)
%      if mod(j,1000)==0 %观测算法的运算速度
%        j  
%      end
%     for i=1:4:size(grid_data(:,:,j),1)
%         
%          LD_aqi_stations_data(k,9,j)=grid_data(1,4,j);
%          temp_fenzi=cell2mat(grid_data(i,11,j))+cell2mat(grid_data(i+1,11,j))+cell2mat(grid_data(i+2,11,j))+cell2mat(grid_data(i+3,11,j));
%          temp_fenmu=1/(cell2mat(grid_data(i,10,j))^2)+1/(cell2mat(grid_data(i+1,10,j))^2)+1/(cell2mat(grid_data(i+2,10,j))^2)+1/(cell2mat(grid_data(i+3,10,j))^2);
%          
%          avg_temp=temp_fenzi/temp_fenmu;
%          LD_aqi_stations_data(k,10,j)=num2cell(avg_temp);%将4个格点求出来的温度平均值放在第10列
%          
%          pressure_fenzi=cell2mat(grid_data(i,12,j))+cell2mat(grid_data(i+1,12,j))+cell2mat(grid_data(i+2,12,j))+cell2mat(grid_data(i+3,12,j));
%          pressure_fenmu=1/(cell2mat(grid_data(i,10,j))^2)+1/(cell2mat(grid_data(i+1,10,j))^2)+1/(cell2mat(grid_data(i+2,10,j))^2)+1/(cell2mat(grid_data(i+3,10,j))^2);
%          
%          avg_pressure=pressure_fenzi/pressure_fenmu;
%          LD_aqi_stations_data(k,11,j)=num2cell(avg_pressure);%将4个格点求出来的压强平均值放在第11列
%          
%          humidity_fenzi=cell2mat(grid_data(i,13,j))+cell2mat(grid_data(i+1,13,j))+cell2mat(grid_data(i+2,13,j))+cell2mat(grid_data(i+3,13,j));
%          humidity_fenmu=1/(cell2mat(grid_data(i,10,j))^2)+1/(cell2mat(grid_data(i+1,10,j))^2)+1/(cell2mat(grid_data(i+2,10,j))^2)+1/(cell2mat(grid_data(i+3,10,j))^2);
%          
%          avg_humidity=humidity_fenzi/humidity_fenmu;
%          LD_aqi_stations_data(k,12,j)=num2cell(avg_humidity);%将4个格点求出来的湿度平均值放在第12列
%          
%          k=k+1;
%     end
%     k=1;
% end
% toc
% 
% %%%%风速u-v分解，分解后保存到grid_data的14,15列
% tic
% for j=1:size(grid_data,3)
%         for i=1:4:size(grid_data(:,:,j),1)
%         %(cell2mat(grid_data(i,9,j)) * sind(cell2mat(grid_data(i,8,j))));%u方向分量
%         %(cell2mat(grid_data(i,9,j)) * cosd(cell2mat(grid_data(i,8,j))));%u方向分量
%         
%         grid_data(i,14,j)=num2cell((cell2mat(grid_data(i,9,j)) * sind(cell2mat(grid_data(i,8,j))))/(cell2mat(grid_data(i,10,j)))^2);%%%u方向风速除以距离的平方
%         grid_data(i+1,14,j)=num2cell((cell2mat(grid_data(i+1,9,j)) * sind(cell2mat(grid_data(i,8,j))))/cell2mat(grid_data(i+1,10,j))^2);
%         grid_data(i+2,14,j)=num2cell((cell2mat(grid_data(i+2,9,j)) * sind(cell2mat(grid_data(i,8,j))))/cell2mat(grid_data(i+2,10,j))^2);
%         grid_data(i+3,14,j)=num2cell((cell2mat(grid_data(i+3,9,j)) * sind(cell2mat(grid_data(i,8,j))))/cell2mat(grid_data(i+3,10,j))^2);
%         
%         grid_data(i,15,j)=num2cell((cell2mat(grid_data(i,9,j)) * cosd(cell2mat(grid_data(i,8,j))))/(cell2mat(grid_data(i,10,j)))^2);%%%v方向风速除以距离的平方
%         grid_data(i+1,15,j)=num2cell((cell2mat(grid_data(i+1,9,j)) * cosd(cell2mat(grid_data(i,8,j))))/cell2mat(grid_data(i+1,10,j))^2);
%         grid_data(i+2,15,j)=num2cell((cell2mat(grid_data(i+2,9,j)) * cosd(cell2mat(grid_data(i,8,j))))/cell2mat(grid_data(i+2,10,j))^2);
%         grid_data(i+3,15,j)=num2cell((cell2mat(grid_data(i+3,9,j)) * cosd(cell2mat(grid_data(i,8,j))))/cell2mat(grid_data(i+3,10,j))^2);
%         end
% end
% toc
% 
% %%将u-v风速添加到LD_aqi_stations_data的13,14列，第15列计算合并风速
% tic
% k=1;
% for j=1:size(grid_data,3)
%      if mod(j,1000)==0 %观测算法的运算速度
%        j  
%      end
%     for i=1:4:size(grid_data(:,:,j),1)
%          %%反向加权平均求解u方向风速
%          u_fenzi=cell2mat(grid_data(i,14,j))+cell2mat(grid_data(i+1,14,j))+cell2mat(grid_data(i+2,14,j))+cell2mat(grid_data(i+3,14,j));
%          u_fenmu=1/(cell2mat(grid_data(i,10,j))^2)+1/(cell2mat(grid_data(i+1,10,j))^2)+1/(cell2mat(grid_data(i+2,10,j))^2)+1/(cell2mat(grid_data(i+3,10,j))^2);
%          
%          avg_u=u_fenzi/u_fenmu;
%          LD_aqi_stations_data(k,13,j)=num2cell(avg_u);
%          
%          %%反向加权平均求解v方向风速
%          v_fenzi=cell2mat(grid_data(i,15,j))+cell2mat(grid_data(i+1,15,j))+cell2mat(grid_data(i+2,15,j))+cell2mat(grid_data(i+3,15,j));
%          v_fenmu=1/(cell2mat(grid_data(i,10,j))^2)+1/(cell2mat(grid_data(i+1,10,j))^2)+1/(cell2mat(grid_data(i+2,10,j))^2)+1/(cell2mat(grid_data(i+3,10,j))^2);
%          avg_v=v_fenzi/v_fenmu;
%          LD_aqi_stations_data(k,14,j)=num2cell(avg_v);
%          
%          %%合成风速
%          LD_aqi_stations_data(k,15,j)=num2cell(sqrt((avg_u)^2+(avg_v)^2));
%          
%          k=k+1;
%     end
%     k=1;
% end
% toc
% 
% %%将风向添加到LD_aqi_stations_data的16列
% tic
% for j=1:size(grid_data,3)
%     for i=1:24
%             if cell2mat(LD_aqi_stations_data(i,13,j))>0 && cell2mat(LD_aqi_stations_data(i,14,j))>0
%             LD_aqi_stations_data(i,16,j)=num2cell((atan(cell2mat(LD_aqi_stations_data(i,13,j))/cell2mat(LD_aqi_stations_data(i,14,j)))/pi)*180);
%             elseif cell2mat(LD_aqi_stations_data(i,13,j))>0 && cell2mat(LD_aqi_stations_data(i,14,j))<0
%             LD_aqi_stations_data(i,16,j)= num2cell((atan(cell2mat(LD_aqi_stations_data(i,13,j))/cell2mat(LD_aqi_stations_data(i,14,j)))/pi)*180+180);
%             elseif cell2mat(LD_aqi_stations_data(i,13,j))<0 && cell2mat(LD_aqi_stations_data(i,14,j))<0
%             LD_aqi_stations_data(i,16,j)=num2cell((atan(cell2mat(LD_aqi_stations_data(i,13,j))/cell2mat(LD_aqi_stations_data(i,14,j)))/pi)*180+180);
%             elseif cell2mat(LD_aqi_stations_data(i,13,j))<0 && cell2mat(LD_aqi_stations_data(i,14,j))>0 
%             LD_aqi_stations_data(i,16,j)=num2cell((atan(cell2mat(LD_aqi_stations_data(i,13,j))/cell2mat(LD_aqi_stations_data(i,14,j)))/pi)*180+360);
%             elseif cell2mat(LD_aqi_stations_data(i,13,j))==0 && cell2mat(LD_aqi_stations_data(i,14,j))>0
%             LD_aqi_stations_data(i,16,j)=num2cell(0);
%             elseif cell2mat(LD_aqi_stations_data(i,13,j))==0 && cell2mat(LD_aqi_stations_data(i,14,j))<0
%             LD_aqi_stations_data(i,16,j)=num2cell(180);  
%             elseif cell2mat(LD_aqi_stations_data(i,13,j))>0 && cell2mat(LD_aqi_stations_data(i,14,j))==0
%             LD_aqi_stations_data(i,16,j)=num2cell(90);
%             elseif cell2mat(LD_aqi_stations_data(i,13,j))<0 && cell2mat(LD_aqi_stations_data(i,14,j))==0
%             LD_aqi_stations_data(i,16,j)=num2cell(270);
%             else
%             LD_aqi_stations_data(i,16,j)=Null;
%             end
%     end
% end
% toc
% 
% %%%合并伦敦aqi-meo总表
% 
% London_station_data_aqi=unique(cell2table(LD_aqi_stations_data(:,:,1)));
% tic
% for j=2:size(grid_data,3)
%        if mod(j,1000)==0 %观测算法的运算速度
%             j
%        end   
%     London_station_data_aqi=cat(1,London_station_data_aqi,cell2table(LD_aqi_stations_data(:,:,j)));
% end
% toc
% 
% tic
% writetable(London_station_data_aqi,'London_5_13_get_test_data.csv','Delimiter',',','QuoteStrings',true)
% toc
% 
% %%%%%%%%%%%%求aqi-meo总表
% 
% clear
% tic
% LD_aqi_forecast=readtable('ld_aqi_2018-05-13.csv');%%%导入伦敦历史气象网格数据，通过api获取以后，保留站点、经纬度、PM2.5、PM10、NO2
% LD_aqi_forecast = sortrows(LD_aqi_forecast,'station_id','ascend');
% toc
% a=LD_aqi_forecast;
% 
% 
% %%将London_aqi总表的utc_time分割
% temp=table2array(a(:,2));
% vec=datevec(temp);
% vec1=num2cell(vec);
% a(:,6:9)=vec1(:,1:4);
% a = a(:,[1 6 2:5 7:end]);
% a = a(:,[1:2 7 3:6 8:end]);
% a = a(:,[1:3 8 4:7 end]);
% a = a(:,[1:4 9 5:8]);
% a(:,'time') = [];
% 
% %%将London_meo总表的utc_time分割
% London_station_data_aqi=readtable('London_5_13_get_test_data_new.csv');%%注意要只保留aqi列为true的表格，也就是第一列为true
% London_station_data_aqi = sortrows(London_station_data_aqi,'Var1','ascend');
% temp=table2array(London_station_data_aqi(:,9));
% vec=datevec(temp);
% vec1=num2cell(vec);
% London_station_data_aqi(:,17:22)=vec1(:,1:6);
% London_station_data_aqi = London_station_data_aqi(:,[1 17 2:16 18:end]);
% London_station_data_aqi = London_station_data_aqi(:,[1:2 18 3:17 19:end]);
% London_station_data_aqi = London_station_data_aqi(:,[1:3 19 4:18 20:end]);
% London_station_data_aqi = London_station_data_aqi(:,[1:4 20 5:19 21:end]);
% London_station_data_aqi(:,'Var21') = [];
% London_station_data_aqi(:,'Var22') = [];
% 
% %%%将aqi总表按照站点分组
% tic
% temp_station_name=table2cell(a(1,1)); %初始化第一个用于分类的网格名称
% LD_data=cell(5,8,5);%初始化三维元胞数组
% LD_num=1;%站点数目
% j=1;%记录循环中每个二维元胞数组里面行号
% for i = 1:size(a,1)
%       if mod(i,1000)==0 %观测算法的运算速度
%        i  
%       end
%       if isequal(temp_station_name, table2cell(a(i,1)))
%            LD_data(j,:,LD_num)=table2cell(a(i,:));
%            j=j+1;
%       else
%            temp_station_name=table2cell(a(i,1));
%            LD_num=LD_num + 1;
%            LD_data(1,:,LD_num)=table2cell(a(i,:));
%            j=2;
%       end
% end
% toc
% 
% %%将meo总表按站点分组
% tic
% temp_station_name=table2cell(London_station_data_aqi(1,1)); %初始化第一个用于分类的网格名称
% LD_meo_data=cell(5,20,5);%初始化三维元胞数组
% LD_num=1;%站点数目
% j=1;%记录循环中每个二维元胞数组里面行号
% for i = 1:size(London_station_data_aqi,1)
%       if mod(i,1000)==0 %观测算法的运算速度
%        i  
%       end
%       if isequal(temp_station_name, table2cell(London_station_data_aqi(i,1)))
%            LD_meo_data(j,:,LD_num)=table2cell(London_station_data_aqi(i,:));
%            j=j+1;
%       else
%            temp_station_name=table2cell(London_station_data_aqi(i,1));
%            LD_num=LD_num + 1;
%            LD_meo_data(1,:,LD_num)=table2cell(London_station_data_aqi(i,:));
%            j=2;
%       end
% end
% toc
% 
% %%%% 合并aqi-meo两个表格
% tic
% k=1;
% for i=1:19
%     i
%     for j=1:size(LD_data(:,:,i),1)
%         for  k =1:size(LD_meo_data(:,:,i),1)
%             if isequal(LD_meo_data(k,1,i),LD_data(j,1,i)) && isequal(LD_meo_data(k,2,i),LD_data(j,2,i)) ...
%         && isequal(LD_meo_data(k,3,i),LD_data(j,3,i)) && isequal(LD_meo_data(k,4,i),LD_data(j,4,i)) ...
%         && isequal(LD_meo_data(k,5,i),LD_data(j,5,i))  
%                
%         LD_data(j,9:23,i)=LD_meo_data(k,6:20,i);
%             end
%         end
%     end
% end
% toc
% 
%  %%合并
% tic
% LD_temperature=LD_data(:,:,1);
% for j=2:LD_num
%        j     
%     LD_temperature=cat(1,LD_temperature,LD_data(:,:,j));
% end
% 
% toc
% 
% LD_temperature=cell2table(LD_temperature);
% 
% %%%导出csv以后记得去删除空白行
% tic
% writetable(LD_temperature,'LD_5_13_test_full_result.csv','Delimiter',',','QuoteStrings',true)
% %writetable(LD,'LD_temperature.txt','Delimiter',',')
% toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
tic
LD=readtable('LD_5_31_test_full_result_sort_time.csv');%%%导入之前先将PM2.5，PM10，O3的负值变成NaN
toc

LD(:,{'LD_temperature9','LD_temperature10','LD_temperature11','LD_temperature14','LD_temperature15','LD_temperature20','LD_temperature21'}) = [];
LD(:,{'LD_temperature2','LD_temperature3','LD_temperature4','LD_temperature5'}) = [];
LD = LD(:,[1 5 2:4 6:end]);
LD = LD(:,[1 6 2:5 7:end]);
LD = LD(:,[1 7 2:6 8:end]);
LD = LD(:,[1:4 6:11 5 end]);
LD = LD(:,[1:4 6:11 5 end]);
LD = LD(:,[1:4 6:11 5 end]);

%%对伦敦按照utc_time来分组，形成三维元胞数组
tic
temp_utc_time=table2cell(LD(1,2)); %初始化第一个用于分类的aqi_station
LD_data=cell(5,size(LD,2),10);%初始化三维元胞数组
LD_num=1;%站点数目
j=1;%记录循环中每个二维元胞数组里面行号
for i = 1:size(LD,1)
      if mod(i,1000)==0 %观测算法的运算速度
       i  
      end
      if isequal(temp_utc_time, table2cell(LD(i,2)))
           LD_data(j,1:size(LD,2),LD_num)=table2cell(LD(i,1:size(LD,2)));
           j=j+1;
      else
           temp_utc_time=table2cell(LD(i,2));
           LD_num=LD_num + 1;
           LD_data(1,1:size(LD,2),LD_num)=table2cell(LD(i,1:size(LD,2)));
           j=2;
      end
end
toc

%%对伦敦的PM2.5、PM10、O3按照空间最近邻进行反距离加权插值（注意伦敦实际上是没有O3的，最后要去掉）
temp_LD_data_new=cell(size(LD_data));
tic
for i=1:size(LD_data,3)
        
         i  
  
        temp_LD_data_new(:,1:11,i)=LD_knn_aqi(LD_data(:,1:11,i));
        temp_LD_data_new(:,12,i)=LD_data(:,12,i);
end
toc

%%将临近4个站点的风速、风向、PM2.5、PM10放在12列的后面

temp_LD_data=temp_LD_data_new(:,:,1);%%%测试函数LD_knn_aqi_station用
temp_LD_data_new_beta=temp_LD_data_new;%%%备份

temp_LD_data_new_new=cell(size(LD_data,1),48,size(LD_data,3));
tic
for i=1:size(temp_LD_data_new,3)
         i 
         if ~isnan(cell2mat(temp_LD_data_new(1,3,i)))
        temp_LD_data_new_new(:,1:48,i)=LD_knn_full_aqi_station(temp_LD_data_new(:,:,i));
        end
end
toc
temp_LD_data_new_1=temp_LD_data_new_new(:,:,1);

%%合并
tic
LD_temperature_new=temp_LD_data_new_new(:,:,1);
for j=2:size(temp_LD_data_new_new,3)
       j     
    LD_temperature_new=cat(1,LD_temperature_new,temp_LD_data_new_new(:,:,j));
end

toc

LD_temperature_new=cell2table(LD_temperature_new);
%%%%%导出csv文件删除空行
tic
writetable(LD_temperature_new,'5_31_LD_data_75_model_full_result_with_NO2.csv');
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
tic
LD=readtable('5_31_LD_data_75_model_full_result_with_NO2_new_without_sort_winddirection_encoding.csv');%%%按aqi站点排序
toc

%%对伦敦按照aqi站点来分组，形成三维元胞数组
tic
temp_aqi_station=table2cell(LD(1,1)); %初始化第一个用于分类的aqi_station
LD_data=cell(5,size(LD,2),10);%初始化三维元胞数组
LD_num=1;%站点数目
j=1;%记录循环中每个二维元胞数组里面行号
for i = 1:size(LD,1)
      if mod(i,1000)==0 %观测算法的运算速度
       i  
      end
      if isequal(temp_aqi_station, table2cell(LD(i,1)))
           LD_data(j,1:size(LD,2),LD_num)=table2cell(LD(i,1:size(LD,2)));
           j=j+1;
      else
           temp_aqi_station=table2cell(LD(i,1));
           LD_num=LD_num + 1;
           LD_data(1,1:size(LD,2),LD_num)=table2cell(LD(i,1:size(LD,2)));
           j=2;
      end
end
toc

% %%%%%%将5-36列
% %%即温度、压强、湿度、风速、风向、PM2.5、PM10、O3以及4个临近站点的PM2.5、PM10、O3、风速、风向
% %%移动8次
% 
% timestep=8;
% for i=1:size(LD_data,3) 
%     for k=1:timestep
%         for j=1:size(LD_data(:,:,i),1)-1
%             LD_data(j,37+32*(k-1):68+32*(k-1),i)=LD_data(j+1,5+32*(k-1):36+32*(k-1),i);
%         end
%     end
% end
% 
% %temp_LD_data_1=LD_data(:,:,1);
% 
% %LD_data_alpha=LD_data;%%%备份
% 
% %%合并
% tic
% LD_temperature=LD_data(:,:,1);
% for j=2:LD_num
%        j     
%     LD_temperature=cat(1,LD_temperature,LD_data(:,:,j));
% end
% 
% toc
% 
% LD_temperature=cell2table(LD_temperature);
% 
% 
% %%%%%%%%将风向统一移动到最后
% tic
% LD_temperature = LD_temperature(:,[1:267 269:292 268]);
% LD_temperature = LD_temperature(:,[1:235 237:292 236]);
% LD_temperature = LD_temperature(:,[1:203 205:292 204]);
% LD_temperature = LD_temperature(:,[1:171 173:292 172]);
% LD_temperature = LD_temperature(:,[1:139 141:292 140]);
% LD_temperature = LD_temperature(:,[1:107 109:292 108]);
% LD_temperature = LD_temperature(:,[1:75 77:292 76]);
% LD_temperature = LD_temperature(:,[1:43 45:292 44]);
% LD_temperature = LD_temperature(:,[1:11 13:292 12]);
% toc
% %LD_temperature_beta=LD_temperature;%%%备份
% %LD_temperature=LD_temperature_beta;%%%还原
% 
% %%%%%%%将最后五小时的邻近站点的pm2.5，pm10，O3，风速，风向移动到最后
% tic
% LD_temperature = LD_temperature(:,[1:259 284:292 260:283]);
% LD_temperature = LD_temperature(:,[1:228 253:292 229:252]);
% LD_temperature = LD_temperature(:,[1:197 222:292 198:221]);
% LD_temperature = LD_temperature(:,[1:166 191:292 167:190]);
% LD_temperature = LD_temperature(:,[1:135 160:292 136:159]);
% toc
% %LD_temperature_alpha=LD_temperature;%%备份
% 
% %%%%%%%将前4小时的邻近站点的数据全部删去
% tic
% LD_temperature(:,{'LD_temperature109','LD_temperature110','LD_temperature111','LD_temperature112','LD_temperature113','LD_temperature114','LD_temperature115','LD_temperature116','LD_temperature117','LD_temperature118','LD_temperature119','LD_temperature120','LD_temperature121','LD_temperature122','LD_temperature123','LD_temperature124','LD_temperature125','LD_temperature126','LD_temperature127','LD_temperature128','LD_temperature129','LD_temperature130','LD_temperature131','LD_temperature132'}) = [];
% LD_temperature(:,{'LD_temperature77','LD_temperature78','LD_temperature79','LD_temperature80','LD_temperature81','LD_temperature82','LD_temperature83','LD_temperature84','LD_temperature85','LD_temperature86','LD_temperature87','LD_temperature88','LD_temperature89','LD_temperature90','LD_temperature91','LD_temperature92','LD_temperature93','LD_temperature94','LD_temperature95','LD_temperature96','LD_temperature97','LD_temperature98','LD_temperature99','LD_temperature100'}) = [];
% LD_temperature(:,{'LD_temperature45','LD_temperature46','LD_temperature47','LD_temperature48','LD_temperature49','LD_temperature50','LD_temperature51','LD_temperature52','LD_temperature53','LD_temperature54','LD_temperature55','LD_temperature56','LD_temperature57','LD_temperature58','LD_temperature59','LD_temperature60','LD_temperature61','LD_temperature62','LD_temperature63','LD_temperature64','LD_temperature65','LD_temperature66','LD_temperature67','LD_temperature68'}) = [];
% LD_temperature(:,{'LD_temperature13','LD_temperature14','LD_temperature15','LD_temperature16','LD_temperature17','LD_temperature18','LD_temperature19','LD_temperature20','LD_temperature21','LD_temperature22','LD_temperature23','LD_temperature24','LD_temperature25','LD_temperature26','LD_temperature27','LD_temperature28','LD_temperature29','LD_temperature30','LD_temperature31','LD_temperature32','LD_temperature33','LD_temperature34','LD_temperature35','LD_temperature36'}) = [];
% toc
% %LD_temperature_delta=LD_temperature;%%备份
% 
% %%%%%%%删除站点名称
% tic
% LD_temperature(:,{'LD_temperature269','LD_temperature275','LD_temperature281','LD_temperature287','LD_temperature237','LD_temperature243','LD_temperature249','LD_temperature255','LD_temperature205','LD_temperature211','LD_temperature217','LD_temperature223','LD_temperature173','LD_temperature179','LD_temperature185','LD_temperature191','LD_temperature141','LD_temperature147','LD_temperature153','LD_temperature159'}) = [];
% toc
% 
% 
% 
% LD=LD_temperature;

%%%%%%%%%%%%%将最后的表格的站点顺序调整成submission里面的排列顺序
tic
temp_aqi_station=table2cell(LD(1,1)); %初始化第一个用于分类的aqi_station
LD_data=cell(5,size(LD,2),5);%初始化三维元胞数组
LD_num=1;%站点数目
j=1;%记录循环中每个二维元胞数组里面行号
for i = 1:size(LD,1)
      if mod(i,1000)==0 %观测算法的运算速度
       i  
      end
      if isequal(temp_aqi_station, table2cell(LD(i,1)))
           LD_data(j,1:size(LD,2),LD_num)=table2cell(LD(i,1:size(LD,2)));
           j=j+1;
      else
           temp_aqi_station=table2cell(LD(i,1));
           LD_num=LD_num + 1;
           LD_data(1,1:size(LD,2),LD_num)=table2cell(LD(i,1:size(LD,2)));
           j=2;
      end
end
toc

[~,~,LD_predict_station]=xlsread('LD_predict_id');%导入空气质量站的经纬度坐标
LD_data_new=cell(9,size(LD_data,2),13);

for i=1:size(LD_predict_station,1)
     for j=1:size(LD_data,3)
        if isequal(LD_data(1,1,j),LD_predict_station(i,1))
            LD_data_new(:,:,i)=LD_data(:,:,j);
        end 
     end
end

%%%%%%%%%%%%%

%%合并
tic
LD_temperature=LD_data_new(:,:,1);
for j=2:size(LD_data_new,3)
       j     
    LD_temperature=cat(1,LD_temperature,LD_data_new(:,:,j));
end

toc

LD_temperature=cell2table(LD_temperature);

%LD_temperature(:,{'LD_temperature11','LD_temperature18','LD_temperature25','LD_temperature32','LD_temperature39','LD_temperature46','LD_temperature53','LD_temperature60','LD_temperature67','LD_temperature79','LD_temperature84','LD_temperature89','LD_temperature94','LD_temperature99','LD_temperature104','LD_temperature109','LD_temperature114','LD_temperature119','LD_temperature124','LD_temperature129','LD_temperature134','LD_temperature139','LD_temperature144','LD_temperature149','LD_temperature154','LD_temperature159','LD_temperature164','LD_temperature169','LD_temperature174'}) = [];

%%%记得修改保存文件名称
tic
writetable(LD_temperature,'LD_aqi_meo_5_31_75_model_test_new_with_NO2_winddirection_encoding.csv','Delimiter',',','QuoteStrings',true)
toc