function temp_BJ_data_new=BJ_knn_aqi(temp_BJ_data)

%%%计算temp_BJ_data的非空行数，因为在matlab的cell数据类型里面，如果cell
%%%A的最后一行是空，前17行是非空，此时size(A,1)是等于18而不是等于17（含有空集的元胞是非空的）。
%%%但又由于我需要得到的是17而不是18来写循环，所以要先算出cell里面非空行的数目

BJ_empty=double(1);%%初始化统计非空行的矩阵BJ_empty
k=0;%%初始化统计循环次数的k

 for j=1:size(temp_BJ_data,1) %%%对于元胞数组temp_BJ_data里面的每一行
      if isempty(temp_BJ_data{j,1})~=1%%如果元胞数组temp_BJ_data里面的这一行的第一列的元素不是空（这里用{}提取出cell里面的元素，因此空集也能被判断为空）
         k=k+1;%%那么非空行的统计就增加1
      end
         BJ_empty(j,1)=k;
         k=0; 
 end
     
 %%%计算temp_BJ_data的距离矩阵
 BJ_temp_dist=cell(size(BJ_empty,1),size(BJ_empty,1));%%%初始化距离矩阵temp_BJ_data的大小，根据该小时非空行的数目进行构造
 
 k=1;
 for i=1:size(BJ_empty,1)
    for j=1:size(BJ_empty,1)
        %%%%利用欧式距离求解每个站点到所有站点的距离（包含到自身，因此有一个距离的值是0）
        temp_BJ_data(i,k+11)=num2cell(sqrt((cell2mat(temp_BJ_data(i,3))-cell2mat(temp_BJ_data(j,3)))^2+(cell2mat(temp_BJ_data(i,4))-cell2mat(temp_BJ_data(j,4)))^2));
        k=k+1;
        
    end
    BJ_temp_dist(i,1:size(BJ_temp_dist,2))=num2cell(sort(cell2mat(temp_BJ_data(i,12:size(BJ_temp_dist,2)+11))));%%%%利用BJ_temp_dist来保存一个排序后（sort）的距离矩阵用于查询
    k=1;
 end
 
 %%%如果发现某一列出现NaN，那么就利用距离矩阵，找出该空气质量站的最近的4个站点
 %%%利用反距离加权求解PM2.5、PM10、O3
 
 k=5; %近邻数大于等于2
 h=2; %反距离的距离的幂数
 pm25_fenzi=0;%初始化反向加权求解温度的分子
 pm25_fenmu=0;%初始化反向加权求解温度的分母
 pm10_fenzi=0;%初始化反向加权求解压强的分子
 pm10_fenmu=0;%初始化反向加权求解压强的分母
 O3_fenzi=0;%初始化反向加权求解湿度的分子
 O3_fenmu=0;%初始化反向加权求解湿度的分母
 
    for i=1:size(temp_BJ_data,1)%对35个空气质量站分别
        
        if isnan(cell2mat(temp_BJ_data(i,9))) %%判断该空气质量站的PM2.5是否为NaN
                for l=3:k+1 %k是规定的选择的最大近邻的气象观测站的个数,由于第1个距离是0，因此要从第二开始
                    if cell2mat(BJ_temp_dist(i,l))-cell2mat(BJ_temp_dist(i,2))<0.1 %如果第l个气象观测站到第i个空气质量站的距离与此空气质量站的最近邻气象观测站小于0.1
                        [~,n]=find(cell2mat(temp_BJ_data(i,12:46))==cell2mat(BJ_temp_dist(i,l-1)));%保留最近邻风速并且从l开始循环寻找距离空气质量站更远的气象观测站
                    
                        if ~isnan(cell2mat(temp_BJ_data(n,9)))%%如果找到的这个临近站点不是NaN
                        pm25_fenzi=pm25_fenzi+cell2mat(temp_BJ_data(n,9))/(cell2mat(temp_BJ_data(i,n+11))^h);%%分子累加
                        pm25_fenmu=pm25_fenmu+1/(cell2mat(temp_BJ_data(i,n+11))^h);%%分母累加
                        else
                        pm25_fenzi=pm25_fenzi+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                        pm25_fenmu=pm25_fenmu+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                        end
                    
                    elseif cell2mat(BJ_temp_dist(i,3))-cell2mat(BJ_temp_dist(i,2))>0.1 || cell2mat(BJ_temp_dist(i,3))>0.2 %经过数据可视化观测，当第二近邻的气象观测站与最近邻观测站的差值大于0.1
                                                                                   %或者第二近邻观测站距离大于0.2的时候，此时我们认为只保留最近邻气象观测
                                                                                   %站的风速并直接复制给这个空气质量站。因为从可视化的图上面那些远离大部分
                                                                                   %空气质量观测站的那些空气质量观测站附近都只有1个或者2个气象观测站
                        [~,n]=find(cell2mat(temp_BJ_data(i,12:46))==cell2mat(BJ_temp_dist(i,2)));%只保留保留最近邻风速，因此是“1”
                    
                        if ~isnan(cell2mat(temp_BJ_data(n,9)))%%如果找到的这个临近站点不是NaN
                            pm25_fenzi=pm25_fenzi+cell2mat(temp_BJ_data(n,9))/(cell2mat(temp_BJ_data(i,n+11))^h);%%分子累加
                            pm25_fenmu=pm25_fenmu+1/(cell2mat(temp_BJ_data(i,n+11))^h);%%分母累加
                        else 
                            pm25_fenzi=pm25_fenzi+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                            pm25_fenmu=pm25_fenmu+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                        end
                    end   
                end
                temp_BJ_data(i,9)=num2cell(pm25_fenzi/pm25_fenmu);%%最终求解出待插值站点的PM2.5
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PM10 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if isnan(cell2mat(temp_BJ_data(i,10))) %%判断该空气质量站的PM10是否为NaN
                for l=3:k+1 %k是规定的选择的最大近邻的气象观测站的个数,由于第1个距离是0，因此要从第二开始
                    if cell2mat(BJ_temp_dist(i,l))-cell2mat(BJ_temp_dist(i,2))<0.1 %如果第l个气象观测站到第i个空气质量站的距离与此空气质量站的最近邻气象观测站小于0.1
                    [~,n]=find(cell2mat(temp_BJ_data(i,12:46))==cell2mat(BJ_temp_dist(i,l-1)));%保留最近邻风速并且从l开始循环寻找距离空气质量站更远的气象观测站
                    
                    if ~isnan(cell2mat(temp_BJ_data(n,10)))%%如果找到的这个临近站点不是NaN
                        pm10_fenzi=pm10_fenzi+cell2mat(temp_BJ_data(n,10))/(cell2mat(temp_BJ_data(i,n+11))^h);%%分子累加
                        pm10_fenmu=pm10_fenmu+1/(cell2mat(temp_BJ_data(i,n+11))^h);%%分母累加
                    
                    else
                        pm10_fenzi=pm10_fenzi+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                        pm10_fenmu=pm10_fenmu+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                    end
                    
                    elseif cell2mat(BJ_temp_dist(i,3))-cell2mat(BJ_temp_dist(i,2))>0.1 || cell2mat(BJ_temp_dist(i,3))>0.2 %经过数据可视化观测，当第二近邻的气象观测站与最近邻观测站的差值大于0.1
                                                                                   %或者第二近邻观测站距离大于0.2的时候，此时我们认为只保留最近邻气象观测
                                                                                   %站的风速并直接复制给这个空气质量站。因为从可视化的图上面那些远离大部分
                                                                                   %空气质量观测站的那些空气质量观测站附近都只有1个或者2个气象观测站
                    [~,n]=find(cell2mat(temp_BJ_data(i,12:46))==cell2mat(BJ_temp_dist(i,2)));%只保留保留最近邻风速，因此是“1”
                    
                    if ~isnan(cell2mat(temp_BJ_data(n,10)))%%如果找到的这个临近站点不是NaN
                        pm10_fenzi=pm10_fenzi+cell2mat(temp_BJ_data(n,10))/(cell2mat(temp_BJ_data(i,n+11))^h);%%分子累加
                        pm10_fenmu=pm10_fenmu+1/(cell2mat(temp_BJ_data(i,n+11))^h);%%分母累加
                    else 
                        pm10_fenzi=pm10_fenzi+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                        pm10_fenmu=pm10_fenmu+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                    end
                    end   
                end
                temp_BJ_data(i,10)=num2cell(pm10_fenzi/pm10_fenmu);%%最终求解出待插值站点的PM10
        end
        
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% O3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   
        if isnan(cell2mat(temp_BJ_data(i,11))) %%判断该空气质量站的O3是否为NaN
                for l=3:k+1 %k是规定的选择的最大近邻的气象观测站的个数,由于第1个距离是0，因此要从第二开始
                    if cell2mat(BJ_temp_dist(i,l))-cell2mat(BJ_temp_dist(i,2))<0.1 %如果第l个气象观测站到第i个空气质量站的距离与此空气质量站的最近邻气象观测站小于0.1
                    [~,n]=find(cell2mat(temp_BJ_data(i,12:46))==cell2mat(BJ_temp_dist(i,l-1)));%保留最近邻风速并且从l开始循环寻找距离空气质量站更远的气象观测站
                    
                    if ~isnan(cell2mat(temp_BJ_data(n,11)))%%如果找到的这个临近站点不是NaN
                        O3_fenzi=O3_fenzi+cell2mat(temp_BJ_data(n,11))/(cell2mat(temp_BJ_data(i,n+11))^h);%%分子累加
                        O3_fenmu=O3_fenmu+1/(cell2mat(temp_BJ_data(i,n+11))^h);%%分母累加
                    
                    else
                        O3_fenzi=O3_fenzi+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                        O3_fenmu=O3_fenmu+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                    end
                    
                    elseif cell2mat(BJ_temp_dist(i,3))-cell2mat(BJ_temp_dist(i,2))>0.1 || cell2mat(BJ_temp_dist(i,3))>0.2 %经过数据可视化观测，当第二近邻的气象观测站与最近邻观测站的差值大于0.1
                                                                                   %或者第二近邻观测站距离大于0.2的时候，此时我们认为只保留最近邻气象观测
                                                                                   %站的风速并直接复制给这个空气质量站。因为从可视化的图上面那些远离大部分
                                                                                   %空气质量观测站的那些空气质量观测站附近都只有1个或者2个气象观测站
                    [~,n]=find(cell2mat(temp_BJ_data(i,12:46))==cell2mat(BJ_temp_dist(i,2)));%只保留保留最近邻风速，因此是“1”
                    
                    if ~isnan(cell2mat(temp_BJ_data(n,11)))%%如果找到的这个临近站点不是NaN
                        O3_fenzi=O3_fenzi+cell2mat(temp_BJ_data(n,11))/(cell2mat(temp_BJ_data(i,n+11))^h);%%分子累加
                        O3_fenmu=O3_fenmu+1/(cell2mat(temp_BJ_data(i,n+11))^h);%%分母累加
                    else 
                        O3_fenzi=O3_fenzi+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                        O3_fenmu=O3_fenmu+0;%%如果这个临近站点是NaN的话，则不加入进行计算
                    end
                    end   
                end
                temp_BJ_data(i,11)=num2cell(O3_fenzi/O3_fenmu);%%最终求解出待插值站点的O3
        end
        
        
        
    end
    
    temp_BJ_data_new=temp_BJ_data(1:35,1:11);%%将矩阵里面的前11列返回，也就是插值后的结果
    
end