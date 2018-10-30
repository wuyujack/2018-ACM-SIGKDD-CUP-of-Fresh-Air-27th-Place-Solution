%%%% author: Jason Leung
function temp_BJ_data_new=BJ_knn_aqi(temp_BJ_data)

%%% 计算temp_BJ_data的非空行数，因为在matlab的cell数据类型里面，如果cell
%%% A的最后一行是空，前17行是非空，此时size(A,1)是等于18而不是等于17（含有空集的元胞是非空的）。
%%% 但又由于我需要得到的是17而不是18来写循环，所以要先算出cell里面非空行的数目

%%% The following function is used for calculating the number of rows which is not null. Since in MATLAB if
%%% the the last row of the cell A is null while all the rows are not null, for example a (18,1) cell have 17 
%%% rows are not null and only the last row is null, then the return of size(A,1) will be 18 instead of 17
%%% (since a cell with 'null' is not empty). However, what I want is 17 instead of 18, so I write this function
%%% to return the exact number of non-empty rows.

BJ_empty=double(1); %% Initialize the matrix BJ_empty to store non-empty number %%初始化统计非空行的矩阵BJ_empty
k=0; %% Initialize the iteration number k %%初始化统计循环次数的k 

 for j=1:size(temp_BJ_data,1) %%% for each rows of the cell 'temp_BJ_data' %%%对于元胞数组temp_BJ_data里面的每一行 
      if isempty(temp_BJ_data{j,1})~=1 %%% If the element of this row is not null %%%如果元胞数组temp_BJ_data里面的这一行的第一列的元素不是空（这里用{}提取出cell里面的元素，因此空集也能被判断为空）
         k=k+1; %%% Then the number of non-empty rows will add 1 %%% 那么非空行的统计就增加1 
      end
         BJ_empty(j,1)=k;
         k=0; 
 end
     
 %%% Calculate the distance matrix 'temp_BJ_data' %%% 计算temp_BJ_data的距离矩阵
 BJ_temp_dist=cell(size(BJ_empty,1),size(BJ_empty,1)); %%% Initialize the size of temp_BJ_data %%% 初始化距离矩阵temp_BJ_data的大小，根据该小时非空行的数目进行构造
 
 k=1;
 for i=1:size(BJ_empty,1)
    for j=1:size(BJ_empty,1)
        %%% use Euclidean Distance to calcualte the distances between each station to the other stations
        %%% 利用欧式距离求解每个站点到所有站点的距离（包含到自身，因此有一个距离的值是0）
        temp_BJ_data(i,k+11)=num2cell(sqrt((cell2mat(temp_BJ_data(i,3))-cell2mat(temp_BJ_data(j,3)))^2+(cell2mat(temp_BJ_data(i,4))-cell2mat(temp_BJ_data(j,4)))^2));
        k=k+1;
        
    end
    BJ_temp_dist(i,1:size(BJ_temp_dist,2))=num2cell(sort(cell2mat(temp_BJ_data(i,12:size(BJ_temp_dist,2)+11)))); %%% BJ_temp_dist store the sorted distance for later indexing  %%%利用BJ_temp_dist来保存一个排序后（sort）的距离矩阵用于查询
    k=1;
 end
 
 %%% If the value of PM2.5, PM10, O3 is NaN, we will use Inverse Distance Weighted (IDW) interpolation
 %%% to interpolate the corresponding value. Here we choose the four closest station around the station
 %%% which have NaN value. About how the IDW works please refers to:
 %%% (http://webhelp.esri.com/arcgisdesktop/9.2/index.cfm?TopicName=How_Inverse_Distance_Weighted_(IDW)_interpolation_works)
 
 %%% 如果发现某一列出现NaN，那么就利用距离矩阵，找出该空气质量站的最近的4个站点
 %%% 利用反距离加权求解PM2.5、PM10、O3
 
 k=5; % Initialize the number of near neighbour  % 近邻数大于等于2
 h=2; % Intialize the power of the distance in IDW  % 反距离的距离的幂数
 pm25_fenzi=0; % Initialize the numerator of PM2.5 when calcualting IDW %初始化反向加权求解PM2.5的分子
 pm25_fenmu=0; % Initialize the denominator of PM2.5 when calcualting IDW % 初始化反向加权求解PM2.5的分母
 pm10_fenzi=0; % Initialize the numerator of PM 10 when calcualting IDW % 初始化反向加权求解PM10的分子
 pm10_fenmu=0; % Initialize the denominator of PM 10 when calcualting IDW  % 初始化反向加权求解PM10的分母
 O3_fenzi=0; % Initialize the numerator of O3 when calcualting IDW %初始化反向加权求解O3的分子
 O3_fenmu=0; % Initialize the denominator of O3 when calcualting IDW  %初始化反向加权求解O3的分母
 
    for i=1:size(temp_BJ_data,1) % Iteration for all the air quality stations % 对35个空气质量站分别
        
        if isnan(cell2mat(temp_BJ_data(i,9))) %% determine whether the value of PM2.5 is NaN %% 判断该空气质量站的PM2.5是否为NaN
                for l=3:k+1 % k is the number of near-neighbour, since the first distance in 'temp_BJ_data' is 0, therefore we should start from the second one
                            % k是规定的选择的最大近邻的空气质量观测站的个数,由于第1个距离是0，因此要从第二开始
                    if cell2mat(BJ_temp_dist(i,l))-cell2mat(BJ_temp_dist(i,2))<0.1  % If distance between the l_th air quality station and the i_th air quality stations is smaller than 0.1
                                                                                    % About why choose 0.1 as a threshold value, actually we have visualized the location of the air quality stations
                                                                                    % in digital map and by approximately calculation we found that when the threshold is 0.1, each air quality 
                                                                                    % stations will have enough near-neighbour for calculation.
                                                                                    
                                                                                    % 如果第 l 个空气观测站到第 i 个空气质量站的距离小于0.1
                                                                                    
                        [~,n]=find(cell2mat(temp_BJ_data(i,12:46))==cell2mat(BJ_temp_dist(i,l-1)));  % reserve the nearest air quality station and find the nearby air quality stations
                                                                                                     % start from l, which is the iteration number, iteratively.
                        
                                                                                                     % 保留最近邻空气观测站并且从 l 开始循环寻找距离空气质量站更远的空气质量站
                    
                        if ~isnan(cell2mat(temp_BJ_data(n,9))) %% If this near stations's PM2.5 value is not null %% 如果找到的这个临近站点不是NaN
                           pm25_fenzi=pm25_fenzi+cell2mat(temp_BJ_data(n,9))/(cell2mat(temp_BJ_data(i,n+11))^h); %% Calculate the numerator of the IDW corresponding to this station and add it to the PM2.5 IDW numerator matrix %% 分子累加
                           pm25_fenmu=pm25_fenmu+1/(cell2mat(temp_BJ_data(i,n+11))^h); %% Calculate the denominator of the IDW corresponding to this station and add it to the PM2.5 IDW denominator matrix %% 分母累加
                        else
                           pm25_fenzi=pm25_fenzi+0; %% Since this nearby air quality station also NaN, therefore we just add 0 to the numerator %% 如果这个临近站点是NaN的话，则不加入进行计算
                           pm25_fenmu=pm25_fenmu+0; %% Since this nearby air quality station also NaN, therefore we just add 0 to the denominator %% 如果这个临近站点是NaN的话，则不加入进行计算
                        end
                    
                    elseif cell2mat(BJ_temp_dist(i,3))-cell2mat(BJ_temp_dist(i,2))>0.1 || cell2mat(BJ_temp_dist(i,3))>0.2  % The reason of the threshold setting is: when the distance between second nearest neighbour
                                                                                                                           % the nearest neighbour air quality station is bigger than 0.1, or the distance between
                                                                                                                           % second nearest neighbour and the staion we want to interplote is bigger than 0.2, we only 
                                                                                                                           % reserve the nearest air quality station and copy its value of PM 2.5 to the station we want
                                                                                                                           % to interplote, sicne based on the data visualization we found that those air quality stations 
                                                                                                                           % that are far away from most of other air qualtiy stations only have one or two air quality stations
                                                                                                                           % near them which are also far away from others.
                    
                                                                                                                           % 经过数据可视化观测，当第二近邻的空气质量站与最近邻空气质量站的差值大于0.1
                                                                                                                           % 或者第二近邻空气质量观测站距离大于0.2的时候，此时我们认为只保留最近邻空气质量观测
                                                                                                                           % 站的PM2.5并直接复制给这个空气质量站。因为从可视化的图上我们发现那些远离大部分
                                                                                                                           % 空气质量观测站的较为孤立的空气质量观测站附近都只有1个或者2个同样孤立的空气质量站。
                        [~,n]=find(cell2mat(temp_BJ_data(i,12:46))==cell2mat(BJ_temp_dist(i,2))); % Only reserve the nearest station for interplotation % 只保留保留最近空气质量观测站用于插值，因此是“1”
                    
                        if ~isnan(cell2mat(temp_BJ_data(n,9))) %% If this nearest station with not null value of PM2.5, then we copy it to replace the NaN of the air quality staion which we want to interplote %% 如果找到的这个临近站点不是NaN
                            pm25_fenzi=pm25_fenzi+cell2mat(temp_BJ_data(n,9))/(cell2mat(temp_BJ_data(i,n+11))^h); %% 分子累加
                            pm25_fenmu=pm25_fenmu+1/(cell2mat(temp_BJ_data(i,n+11))^h); %% 分母累加
                        else %% If this nearest station have NaN value, then we do not include it.
                            pm25_fenzi=pm25_fenzi+0; %% 如果这个临近站点是NaN的话，则不加入进行计算
                            pm25_fenmu=pm25_fenmu+0; %% 如果这个临近站点是NaN的话，则不加入进行计算
                        end
                    end   
                end
                temp_BJ_data(i,9)=num2cell(pm25_fenzi/pm25_fenmu); %% Finally compute the IDW of the station which have NaN value of PM 2.5 %%最终求解出待插值站点的PM2.5
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PM10 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if isnan(cell2mat(temp_BJ_data(i,10))) %% determine whether the value of PM10 is NaN %%判断该空气质量站的PM10是否为NaN
                for l=3:k+1 % k is the number of near-neighbour, since the first distance in 'temp_BJ_data' is 0, therefore we should start from the second one
                            % k是规定的选择的最大近邻的空气质量观测站的个数,由于第1个距离是0，因此要从第二开始
                    if cell2mat(BJ_temp_dist(i,l))-cell2mat(BJ_temp_dist(i,2))<0.1  % If distance between the l_th air quality station and the i_th air quality stations is smaller than 0.1
                                                                                    % About why choose 0.1 as a threshold value, actually we have visualized the location of the air quality stations
                                                                                    % in digital map and by approximately calculation we found that when the threshold is 0.1, each air quality 
                                                                                    % stations will have enough near-neighbour for calculation.
                                                                                    
                                                                                    % 如果第 l 个空气观测站到第 i 个空气质量站的距离小于0.1
                       [~,n]=find(cell2mat(temp_BJ_data(i,12:46))==cell2mat(BJ_temp_dist(i,l-1)));   % reserve the nearest air quality station and find the nearby air quality stations
                                                                                                     % start from l, which is the iteration number, iteratively.
                        
                                                                                                     % 保留最近邻空气观测站并且从 l 开始循环寻找距离空气质量站更远的空气质量站
                    
                       if ~isnan(cell2mat(temp_BJ_data(n,10))) %% If this near stations's PM10 value is not null %% 如果找到的这个临近站点不是NaN
                          pm10_fenzi=pm10_fenzi+cell2mat(temp_BJ_data(n,10))/(cell2mat(temp_BJ_data(i,n+11))^h); %% Since this nearby air quality station also NaN, therefore we just add 0 to the denominator %% 如果这个临近站点是NaN的话，则不加入进行计算
                          pm10_fenmu=pm10_fenmu+1/(cell2mat(temp_BJ_data(i,n+11))^h); %% Calculate the denominator of the IDW corresponding to this station and add it to the PM2.5 IDW denominator matrix %% 分母累加
                    
                       else
                          pm10_fenzi=pm10_fenzi+0; %% Since this nearby air quality station also NaN, therefore we just add 0 to the numerator %% 如果这个临近站点是NaN的话，则不加入进行计算
                          pm10_fenmu=pm10_fenmu+0; %% Since this nearby air quality station also NaN, therefore we just add 0 to the denominator %% 如果这个临近站点是NaN的话，则不加入进行计算
                       end
                    
                    elseif cell2mat(BJ_temp_dist(i,3))-cell2mat(BJ_temp_dist(i,2))>0.1 || cell2mat(BJ_temp_dist(i,3))>0.2  % The reason of the threshold setting is: when the distance between second nearest neighbour
                                                                                                                           % the nearest neighbour air quality station is bigger than 0.1, or the distance between
                                                                                                                           % second nearest neighbour and the staion we want to interplote is bigger than 0.2, we only 
                                                                                                                           % reserve the nearest air quality station and copy its value of PM 2.5 to the station we want
                                                                                                                           % to interplote, sicne based on the data visualization we found that those air quality stations 
                                                                                                                           % that are far away from most of other air qualtiy stations only have one or two air quality stations
                                                                                                                           % near them which are also far away from others.
                    
                                                                                                                           % 经过数据可视化观测，当第二近邻的空气质量站与最近邻空气质量站的差值大于0.1
                                                                                                                           % 或者第二近邻空气质量观测站距离大于0.2的时候，此时我们认为只保留最近邻空气质量观测
                                                                                                                           % 站的PM2.5并直接复制给这个空气质量站。因为从可视化的图上我们发现那些远离大部分
                                                                                                                           % 空气质量观测站的较为孤立的空气质量观测站附近都只有1个或者2个同样孤立的空气质量站。
                        [~,n]=find(cell2mat(temp_BJ_data(i,12:46))==cell2mat(BJ_temp_dist(i,2))); % Only reserve the nearest station for interplotation % 只保留保留最近空气质量观测站用于插值，因此是“1”
                    
                        if ~isnan(cell2mat(temp_BJ_data(n,10))) %% If this nearest station with not null value of PM 10, then we copy it to replace the NaN of the air quality staion which we want to interplote %% 如果找到的这个临近站点不是NaN
                           pm10_fenzi=pm10_fenzi+cell2mat(temp_BJ_data(n,10))/(cell2mat(temp_BJ_data(i,n+11))^h);%%分子累加
                           pm10_fenmu=pm10_fenmu+1/(cell2mat(temp_BJ_data(i,n+11))^h);%%分母累加
                        else %% If this nearest station have NaN value, then we do not include it.
                           pm10_fenzi=pm10_fenzi+0; %% 如果这个临近站点是NaN的话，则不加入进行计算
                           pm10_fenmu=pm10_fenmu+0; %% 如果这个临近站点是NaN的话，则不加入进行计算
                        end
                    end   
                end
                temp_BJ_data(i,10)=num2cell(pm10_fenzi/pm10_fenmu); %% Finally compute the IDW of the station which have NaN value of PM10 %%最终求解出待插值站点的PM10
        end
        
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% O3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   
        if isnan(cell2mat(temp_BJ_data(i,11))) %% determine whether the value of O3 is NaN %%判断该空气质量站的O3是否为NaN
                for l=3:k+1 % k is the number of near-neighbour, since the first distance in 'temp_BJ_data' is 0, therefore we should start from the second one
                            % k是规定的选择的最大近邻的空气质量观测站的个数,由于第1个距离是0，因此要从第二开始
                    if cell2mat(BJ_temp_dist(i,l))-cell2mat(BJ_temp_dist(i,2))<0.1  % If distance between the l_th air quality station and the i_th air quality stations is smaller than 0.1
                                                                                    % About why choose 0.1 as a threshold value, actually we have visualized the location of the air quality stations
                                                                                    % in digital map and by approximately calculation we found that when the threshold is 0.1, each air quality 
                                                                                    % stations will have enough near-neighbour for calculation.
                                                                                    
                                                                                    % 如果第 l 个空气观测站到第 i 个空气质量站的距离小于0.1
                       [~,n]=find(cell2mat(temp_BJ_data(i,12:46))==cell2mat(BJ_temp_dist(i,l-1)));      % reserve the nearest air quality station and find the nearby air quality stations
                                                                                                        % start from l, which is the iteration number, iteratively.
                        
                                                                                                        % 保留最近邻空气观测站并且从 l 开始循环寻找距离空气质量站更远的空气质量                    
                       if ~isnan(cell2mat(temp_BJ_data(n,11))) %% If this near stations's O3 value is not null %% 如果找到的这个临近站点不是NaN
                           O3_fenzi=O3_fenzi+cell2mat(temp_BJ_data(n,11))/(cell2mat(temp_BJ_data(i,n+11))^h); %% Since this nearby air quality station also NaN, therefore we just add 0 to the denominator %% 如果这个临近站点是NaN的话，则不加入进行计算
                           O3_fenmu=O3_fenmu+1/(cell2mat(temp_BJ_data(i,n+11))^h); %% Calculate the denominator of the IDW corresponding to this station and add it to the O3 IDW denominator matrix %% 分母累加
                    
                       else
                           O3_fenzi=O3_fenzi+0; %% Since this nearby air quality station also NaN, therefore we just add 0 to the numerator %% 如果这个临近站点是NaN的话，则不加入进行计算
                           O3_fenmu=O3_fenmu+0; %% Since this nearby air quality station also NaN, therefore we just add 0 to the denominator %% 如果这个临近站点是NaN的话，则不加入进行计算
                       end
                    
                    elseif cell2mat(BJ_temp_dist(i,3))-cell2mat(BJ_temp_dist(i,2))>0.1 || cell2mat(BJ_temp_dist(i,3))>0.2  % The reason of the threshold setting is: when the distance between second nearest neighbour
                                                                                                                           % the nearest neighbour air quality station is bigger than 0.1, or the distance between
                                                                                                                           % second nearest neighbour and the staion we want to interplote is bigger than 0.2, we only 
                                                                                                                           % reserve the nearest air quality station and copy its value of PM 2.5 to the station we want
                                                                                                                           % to interplote, sicne based on the data visualization we found that those air quality stations 
                                                                                                                           % that are far away from most of other air qualtiy stations only have one or two air quality stations
                                                                                                                           % near them which are also far away from others.
                    
                                                                                                                           % 经过数据可视化观测，当第二近邻的空气质量站与最近邻空气质量站的差值大于0.1
                                                                                                                           % 或者第二近邻空气质量观测站距离大于0.2的时候，此时我们认为只保留最近邻空气质量观测
                                                                                                                           % 站的PM2.5并直接复制给这个空气质量站。因为从可视化的图上我们发现那些远离大部分
                                                                                                                           % 空气质量观测站的较为孤立的空气质量观测站附近都只有1个或者2个同样孤立的空气质量站。
                        [~,n]=find(cell2mat(temp_BJ_data(i,12:46))==cell2mat(BJ_temp_dist(i,2))); % Only reserve the nearest station for interplotation % 只保留保留最近空气质量观测站用于插值，因此是“1”
                    
                        if ~isnan(cell2mat(temp_BJ_data(n,11))) %% If this nearest station with not null value of O3, then we copy it to replace the NaN of the air quality staion which we want to interplote %% 如果找到的这个临近站点不是NaN
                           O3_fenzi=O3_fenzi+cell2mat(temp_BJ_data(n,11))/(cell2mat(temp_BJ_data(i,n+11))^h);%%分子累加
                           O3_fenmu=O3_fenmu+1/(cell2mat(temp_BJ_data(i,n+11))^h);%%分母累加
                        else %% If this nearest station have NaN value, then we do not include it.
                           O3_fenzi=O3_fenzi+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                           O3_fenmu=O3_fenmu+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                        end
                    end   
                end
                temp_BJ_data(i,11)=num2cell(O3_fenzi/O3_fenmu); %% Finally compute the IDW of the station which have NaN value of PM10 %%最终求解出待插值站点的PM10
        end
        
        
        
    end
    
    temp_BJ_data_new=temp_BJ_data(1:35,1:11); %% Return the result after interplotation %%将矩阵里面的前11列返回，也就是插值后的结果
    
end
