function temp_LD_data_new=LD_knn_aqi(temp_LD_data)
%%%计算temp_LD_data的非空行数，因为在matlab的cell数据类型里面，如果cell
%%%A的最后一行是空，前17行是非空，此时size(A,1)是等于18而不是等于17。
%%%但又由于我需要得到的是17而不是18来写循环，所以要先算出cell里面非空行的数目

LD_empty=0;
 for j=1:size(temp_LD_data,1)
      if isempty(temp_LD_data{j,1})~=1
         LD_empty=LD_empty+1;
      end
 end
 
 LD_num=size(temp_LD_data,2);
 LD_num_1=LD_empty;
 
 %%%计算temp_LD_data的距离矩阵
 LD_temp_dist=cell(LD_empty,LD_empty);
 k=1;
 for i=1:LD_empty
    for j=1:LD_empty
        
        temp_LD_data(i,k+11)=num2cell(sqrt((cell2mat(temp_LD_data(i,3))-cell2mat(temp_LD_data(j,3)))^2+(cell2mat(temp_LD_data(i,4))-cell2mat(temp_LD_data(j,4)))^2));
        k=k+1;
        
    end
    LD_temp_dist(i,1:size(LD_temp_dist,2))=num2cell(sort(cell2mat(temp_LD_data(i,12:size(LD_temp_dist,2)+11))));
    k=1;
 end
 
 %%%如果发现某一列出现NaN，那么就利用距离矩阵，找出该空气质量站的最近的4个站点
 %%%利用反距离加权求解PM2.5、PM10、NO2
 
 k=5; %近邻数大于等于2
 h=2; %反距离的距离的幂数
 pm25_fenzi=0;%初始化反向加权求解温度的分子
 pm25_fenmu=0;%初始化反向加权求解温度的分母
 pm10_fenzi=0;%初始化反向加权求解压强的分子
 pm10_fenmu=0;%初始化反向加权求解压强的分母
 O3_fenzi=0;%初始化反向加权求解湿度的分子
 O3_fenmu=0;%初始化反向加权求解湿度的分母
 
 for i=1:LD_empty%对24个空气质量站分别
        if cell2mat(LD_temp_dist(i,2))~=0 %%判断是否出现同样的经纬度
            if isnan(cell2mat(temp_LD_data(i,9))) %%判断该空气质量站的PM2.5是否为NaN
                    for l=3:k+1 %k是规定的选择的最大近邻的气象观测站的个数,由于第1个距离是0，因此要从第2开始（下面是3-1等于2）
                        if cell2mat(LD_temp_dist(i,l))-cell2mat(LD_temp_dist(i,2))<0.1 %如果第l个气象观测站到第i个空气质量站的距离与此空气质量站的最近邻气象观测站小于0.1
                        [~,n]=find(cell2mat(temp_LD_data(i,LD_num+1:LD_num+LD_num_1))==cell2mat(LD_temp_dist(i,l-1)));%保留最近邻风速并且从l开始循环寻找距离空气质量站更远的气象观测站
                        if size(n,2)==2
                            n=n(1); %%%由于伦敦有2对，共4个站点是同经纬度的，因此寻找的时候会找到两个位置，导致报错
                        end
                            if ~isnan(cell2mat(temp_LD_data(n,9)))
                        pm25_fenzi=pm25_fenzi+cell2mat(temp_LD_data(n,9))/(cell2mat(temp_LD_data(i,n+11))^h);
                        pm25_fenmu=pm25_fenmu+1/(cell2mat(temp_LD_data(i,n+11))^h);
                            else
                        pm25_fenzi=pm25_fenzi+0;
                        pm25_fenmu=pm25_fenmu+0;
                            end
                    
                        elseif cell2mat(LD_temp_dist(i,3))-cell2mat(LD_temp_dist(i,2))>0.1 || cell2mat(LD_temp_dist(i,3))>0.2 %经过数据可视化观测，当第二近邻的气象观测站与最近邻观测站的差值大于0.1
                                                                                   %或者第二近邻观测站距离大于0.2的时候，此时我们认为只保留最近邻气象观测
                                                                                   %站的风速并直接复制给这个空气质量站。因为从可视化的图上面那些远离大部分
                                                                                   %空气质量观测站的那些空气质量观测站附近都只有1个或者2个气象观测站
                        [~,n]=find(cell2mat(temp_LD_data(i,LD_num+1:LD_num+LD_num_1))==cell2mat(LD_temp_dist(i,2)));%只保留保留最近邻风速，因此是“2”
                            if size(n,2)==2
                            n=n(1); %%%由于伦敦有2对，共4个站点是同经纬度的，因此寻找的时候会找到两个位置，导致报错
                            end
                            if ~isnan(cell2mat(temp_LD_data(n,9)))
                            pm25_fenzi=pm25_fenzi+cell2mat(temp_LD_data(n,9))/(cell2mat(temp_LD_data(i,n+11))^h);
                            pm25_fenmu=pm25_fenmu+1/(cell2mat(temp_LD_data(i,n+11))^h);
                            else 
                            pm25_fenzi=pm25_fenzi+0;
                            pm25_fenmu=pm25_fenmu+0;
                            end
                        end   
                    end
                temp_LD_data(i,9)=num2cell(pm25_fenzi/pm25_fenmu);
            end
        
            if isnan(cell2mat(temp_LD_data(i,10))) %%判断该空气质量站的PM10是否为NaN
                    for l=3:k+1 %k是规定的选择的最大近邻的气象观测站的个数,由于第1个距离是0，因此要从第二开始
                        if cell2mat(LD_temp_dist(i,l))-cell2mat(LD_temp_dist(i,2))<0.1 %如果第l个气象观测站到第i个空气质量站的距离与此空气质量站的最近邻气象观测站小于0.1
                        [~,n]=find(cell2mat(temp_LD_data(i,LD_num+1:LD_num+LD_num_1))==cell2mat(LD_temp_dist(i,l-1)));%保留最近邻风速并且从l开始循环寻找距离空气质量站更远的气象观测站
                        if size(n,2)==2
                            n=n(1); %%%由于伦敦有2对，共4个站点是同经纬度的，因此寻找的时候会找到两个位置，导致报错
                        end
                        if ~isnan(cell2mat(temp_LD_data(n,10)))
                        pm10_fenzi=pm10_fenzi+cell2mat(temp_LD_data(n,10))/(cell2mat(temp_LD_data(i,n+11))^h);
                        pm10_fenmu=pm10_fenmu+1/(cell2mat(temp_LD_data(i,n+11))^h);
                    
                        else
                        pm10_fenzi=pm10_fenzi+0;
                        pm10_fenmu=pm10_fenmu+0;
                        end
                    
                        elseif cell2mat(LD_temp_dist(i,3))-cell2mat(LD_temp_dist(i,2))>0.1 || cell2mat(LD_temp_dist(i,3))>0.2 %经过数据可视化观测，当第二近邻的气象观测站与最近邻观测站的差值大于0.1
                                                                                   %或者第二近邻观测站距离大于0.2的时候，此时我们认为只保留最近邻气象观测
                                                                                   %站的风速并直接复制给这个空气质量站。因为从可视化的图上面那些远离大部分
                                                                                   %空气质量观测站的那些空气质量观测站附近都只有1个或者2个气象观测站
                    [~,n]=find(cell2mat(temp_LD_data(i,LD_num+1:LD_num+LD_num_1))==cell2mat(LD_temp_dist(i,2)));%只保留保留最近邻风速，因此是“1”
                        if size(n,2)==2
                            n=n(1); %%%由于伦敦有2对，共4个站点是同经纬度的，因此寻找的时候会找到两个位置，导致报错
                        end
                        if ~isnan(cell2mat(temp_LD_data(n,10)))
                        pm10_fenzi=pm10_fenzi+cell2mat(temp_LD_data(n,10))/(cell2mat(temp_LD_data(i,n+11))^h);
                        pm10_fenmu=pm10_fenmu+1/(cell2mat(temp_LD_data(i,n+11))^h);
                        else 
                        pm10_fenzi=pm10_fenzi+0;
                        pm10_fenmu=pm10_fenmu+0;
                        end
                        end   
                    end
                temp_LD_data(i,10)=num2cell(pm10_fenzi/pm10_fenmu);
            end
        
            if isnan(cell2mat(temp_LD_data(i,11))) %%判断该空气质量站的PM10是否为NaN
                    for l=3:k+1 %k是规定的选择的最大近邻的气象观测站的个数,由于第1个距离是0，因此要从第二开始
                        if cell2mat(LD_temp_dist(i,l))-cell2mat(LD_temp_dist(i,2))<0.1 %如果第l个气象观测站到第i个空气质量站的距离与此空气质量站的最近邻气象观测站小于0.1
                    [~,n]=find(cell2mat(temp_LD_data(i,LD_num+1:LD_num+LD_num_1))==cell2mat(LD_temp_dist(i,l-1)));%保留最近邻风速并且从l开始循环寻找距离空气质量站更远的气象观测站
                        if size(n,2)==2
                            n=n(1); %%%由于伦敦有2对，共4个站点是同经纬度的，因此寻找的时候会找到两个位置，导致报错
                        end
                        if ~isnan(cell2mat(temp_LD_data(n,11)))
                        O3_fenzi=O3_fenzi+cell2mat(temp_LD_data(n,11))/(cell2mat(temp_LD_data(i,n+11))^h);
                        O3_fenmu=O3_fenmu+1/(cell2mat(temp_LD_data(i,n+11))^h);
                    
                        else
                        O3_fenzi=O3_fenzi+0;
                        O3_fenmu=O3_fenmu+0;
                        end
                    
                        elseif cell2mat(LD_temp_dist(i,3))-cell2mat(LD_temp_dist(i,2))>0.1 || cell2mat(LD_temp_dist(i,3))>0.2 %经过数据可视化观测，当第二近邻的气象观测站与最近邻观测站的差值大于0.1
                                                                                   %或者第二近邻观测站距离大于0.2的时候，此时我们认为只保留最近邻气象观测
                                                                                   %站的风速并直接复制给这个空气质量站。因为从可视化的图上面那些远离大部分
                                                                                   %空气质量观测站的那些空气质量观测站附近都只有1个或者2个气象观测站
                    [~,n]=find(cell2mat(temp_LD_data(i,LD_num+1:LD_num+LD_num_1))==cell2mat(LD_temp_dist(i,2)));%只保留保留最近邻风速，因此是“1”
                        if size(n,2)==2
                            n=n(1); %%%由于伦敦有2对，共4个站点是同经纬度的，因此寻找的时候会找到两个位置，导致报错
                        end
                        if ~isnan(cell2mat(temp_LD_data(n,11)))
                        O3_fenzi=O3_fenzi+cell2mat(temp_LD_data(n,11))/(cell2mat(temp_LD_data(i,n+11))^h);
                        O3_fenmu=O3_fenmu+1/(cell2mat(temp_LD_data(i,n+11))^h);
                        else 
                        O3_fenzi=O3_fenzi+0;
                        O3_fenmu=O3_fenmu+0;
                        end
                        end   
                    end
                temp_LD_data(i,11)=num2cell(O3_fenzi/O3_fenmu);
            end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%如果出现相同经纬度   
        else
            if isnan(cell2mat(temp_LD_data(i,9))) %%判断该空气质量站的PM2.5是否为NaN
                    for l=4:k+2 %k是规定的选择的最大近邻的气象观测站的个数,由于第1，2个距离是0，因此要从第3开始（下面是4-1=3）
                        if cell2mat(LD_temp_dist(i,l))-cell2mat(LD_temp_dist(i,3))<0.1 %如果第l个气象观测站到第i个空气质量站的距离与此空气质量站的最近邻气象观测站小于0.1
                        [~,n]=find(cell2mat(temp_LD_data(i,LD_num+1:LD_num+LD_num_1))==cell2mat(LD_temp_dist(i,l-1)));%保留最近邻风速并且从l开始循环寻找距离空气质量站更远的气象观测站
                        if size(n,2)==2
                            n=n(1); %%%由于伦敦有2对，共4个站点是同经纬度的，因此寻找的时候会找到两个位置，导致报错
                        end
                            if ~isnan(cell2mat(temp_LD_data(n,9)))
                        pm25_fenzi=pm25_fenzi+cell2mat(temp_LD_data(n,9))/(cell2mat(temp_LD_data(i,n+11))^h);
                        pm25_fenmu=pm25_fenmu+1/(cell2mat(temp_LD_data(i,n+11))^h);
                            else
                        pm25_fenzi=pm25_fenzi+0;
                        pm25_fenmu=pm25_fenmu+0;
                            end
                    
                        elseif cell2mat(LD_temp_dist(i,4))-cell2mat(LD_temp_dist(i,3))>0.1 || cell2mat(LD_temp_dist(i,4))>0.2 %经过数据可视化观测，当第二近邻的气象观测站与最近邻观测站的差值大于0.1
                                                                                   %或者第二近邻观测站距离大于0.2的时候，此时我们认为只保留最近邻气象观测
                                                                                   %站的风速并直接复制给这个空气质量站。因为从可视化的图上面那些远离大部分
                                                                                   %空气质量观测站的那些空气质量观测站附近都只有1个或者2个气象观测站
                        [~,n]=find(cell2mat(temp_LD_data(i,LD_num+1:LD_num+LD_num_1))==cell2mat(BJ_temp_dist(i,3)));%只保留保留最近邻风速，因此是“3”
                            if size(n,2)==2
                            n=n(1); %%%由于伦敦有2对，共4个站点是同经纬度的，因此寻找的时候会找到两个位置，导致报错
                            end
                            if ~isnan(cell2mat(temp_LD_data(n,9)))
                            pm25_fenzi=pm25_fenzi+cell2mat(temp_LD_data(n,9))/(cell2mat(temp_LD_data(i,n+11))^h);
                            pm25_fenmu=pm25_fenmu+1/(cell2mat(temp_LD_data(i,n+11))^h);
                            else 
                            pm25_fenzi=pm25_fenzi+0;
                            pm25_fenmu=pm25_fenmu+0;
                            end
                        end   
                    end
                temp_LD_data(i,9)=num2cell(pm25_fenzi/pm25_fenmu);
            end
        
            if isnan(cell2mat(temp_LD_data(i,10))) %%判断该空气质量站的PM10是否为NaN
                    for l=4:k+2 %k是规定的选择的最大近邻的气象观测站的个数,由于第1，2个距离是0，因此要从第3开始（下面是4-1=3）
                        if cell2mat(LD_temp_dist(i,l))-cell2mat(LD_temp_dist(i,3))<0.1 %如果第l个气象观测站到第i个空气质量站的距离与此空气质量站的最近邻气象观测站小于0.1
                        [~,n]=find(cell2mat(temp_LD_data(i,LD_num+1:LD_num+LD_num_1))==cell2mat(LD_temp_dist(i,l-1)));%保留最近邻风速并且从l开始循环寻找距离空气质量站更远的气象观测站
                        if size(n,2)==2
                            n=n(1); %%%由于伦敦有2对，共4个站点是同经纬度的，因此寻找的时候会找到两个位置，导致报错
                        end
                        if ~isnan(cell2mat(temp_LD_data(n,10)))
                        pm10_fenzi=pm10_fenzi+cell2mat(temp_LD_data(n,10))/(cell2mat(temp_LD_data(i,n+11))^h);
                        pm10_fenmu=pm10_fenmu+1/(cell2mat(temp_LD_data(i,n+11))^h);
                    
                        else
                        pm10_fenzi=pm10_fenzi+0;
                        pm10_fenmu=pm10_fenmu+0;
                        end
                    
                        elseif cell2mat(LD_temp_dist(i,4))-cell2mat(LD_temp_dist(i,3))>0.1 || cell2mat(LD_temp_dist(i,4))>0.2 %经过数据可视化观测，当第二近邻的气象观测站与最近邻观测站的差值大于0.1
                                                                                   %或者第二近邻观测站距离大于0.2的时候，此时我们认为只保留最近邻气象观测
                                                                                   %站的风速并直接复制给这个空气质量站。因为从可视化的图上面那些远离大部分
                                                                                   %空气质量观测站的那些空气质量观测站附近都只有1个或者2个气象观测站
                    [~,n]=find(cell2mat(temp_LD_data(i,LD_num+1:LD_num+LD_num_1))==cell2mat(LD_temp_dist(i,3)));%只保留保留最近邻风速，因此是“1”
                        if size(n,2)==2
                            n=n(1); %%%由于伦敦有2对，共4个站点是同经纬度的，因此寻找的时候会找到两个位置，导致报错
                        end
                        if ~isnan(cell2mat(temp_LD_data(n,10)))
                        pm10_fenzi=pm10_fenzi+cell2mat(temp_LD_data(n,10))/(cell2mat(temp_LD_data(i,n+11))^h);
                        pm10_fenmu=pm10_fenmu+1/(cell2mat(temp_LD_data(i,n+11))^h);
                        else 
                        pm10_fenzi=pm10_fenzi+0;
                        pm10_fenmu=pm10_fenmu+0;
                        end
                        end   
                    end
                temp_LD_data(i,10)=num2cell(pm10_fenzi/pm10_fenmu);
            end
        
            if isnan(cell2mat(temp_LD_data(i,11))) %%判断该空气质量站的O3是否为NaN
                    for l=4:k+2 %k是规定的选择的最大近邻的气象观测站的个数,由于第1，2个距离是0，因此要从第3开始（下面是4-1=3）
                        if cell2mat(LD_temp_dist(i,l))-cell2mat(LD_temp_dist(i,3))<0.1 %如果第l个气象观测站到第i个空气质量站的距离与此空气质量站的最近邻气象观测站小于0.1
                    [~,n]=find(cell2mat(temp_LD_data(i,LD_num+1:LD_num+LD_num_1))==cell2mat(LD_temp_dist(i,l-1)));%保留最近邻风速并且从l开始循环寻找距离空气质量站更远的气象观测站
                        if size(n,2)==2
                            n=n(1); %%%由于伦敦有2对，共4个站点是同经纬度的，因此寻找的时候会找到两个位置，导致报错
                        end
                        if ~isnan(cell2mat(temp_LD_data(n,11)))
                        O3_fenzi=O3_fenzi+cell2mat(temp_LD_data(n,11))/(cell2mat(temp_LD_data(i,n+11))^h);
                        O3_fenmu=O3_fenmu+1/(cell2mat(temp_LD_data(i,n+11))^h);
                    
                        else
                        O3_fenzi=O3_fenzi+0;
                        O3_fenmu=O3_fenmu+0;
                        end
                    
                        elseif cell2mat(LD_temp_dist(i,4))-cell2mat(LD_temp_dist(i,3))>0.1 || cell2mat(LD_temp_dist(i,4))>0.2 %经过数据可视化观测，当第二近邻的气象观测站与最近邻观测站的差值大于0.1
                                                                                   %或者第二近邻观测站距离大于0.2的时候，此时我们认为只保留最近邻气象观测
                                                                                   %站的风速并直接复制给这个空气质量站。因为从可视化的图上面那些远离大部分
                                                                                   %空气质量观测站的那些空气质量观测站附近都只有1个或者2个气象观测站
                    [~,n]=find(cell2mat(temp_LD_data(i,LD_num+1:LD_num+LD_num_1))==cell2mat(LD_temp_dist(i,3)));%只保留保留最近邻风速，因此是“3”
                        if size(n,2)==2
                            n=n(1); %%%由于伦敦有2对，共4个站点是同经纬度的，因此寻找的时候会找到两个位置，导致报错
                        end
                        if ~isnan(cell2mat(temp_LD_data(n,11)))
                        O3_fenzi=O3_fenzi+cell2mat(temp_LD_data(n,11))/(cell2mat(temp_LD_data(i,n+11))^h);
                        O3_fenmu=O3_fenmu+1/(cell2mat(temp_LD_data(i,n+11))^h);
                        else 
                        O3_fenzi=O3_fenzi+0;
                        O3_fenmu=O3_fenmu+0;
                        end
                        end   
                    end
                temp_LD_data(i,11)=num2cell(O3_fenzi/O3_fenmu);
            end
        end
end
    
    temp_LD_data_new=temp_LD_data(1:size(temp_LD_data),1:11);
 
end