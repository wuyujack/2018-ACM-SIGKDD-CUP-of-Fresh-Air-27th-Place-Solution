function temp_BJ_data_new=BJ_knn_aqi_station(temp_BJ_data)

%%%计算temp_BJ_data的非空行数
BJ_empty=double(1);
k=0;

 for j=1:size(temp_BJ_data,1)
      if isempty(temp_BJ_data{j,1})~=1
         k=k+1;
      end
         BJ_empty(j,1)=k;
         k=0; 
 end
     
 %%%计算temp_BJ_data的距离矩阵
 BJ_temp_dist=cell(size(BJ_empty,1),size(BJ_empty,1));
 
 k=1;
 for i=1:size(BJ_empty,1)
    for j=1:size(BJ_empty,1)
        
        temp_BJ_data(i,k+12)=num2cell(sqrt((cell2mat(temp_BJ_data(i,3))-cell2mat(temp_BJ_data(j,3)))^2+(cell2mat(temp_BJ_data(i,4))-cell2mat(temp_BJ_data(j,4)))^2));
        k=k+1;
        
    end
    BJ_temp_dist(i,1:size(BJ_temp_dist,2))=num2cell(sort(cell2mat(temp_BJ_data(i,13:size(BJ_temp_dist,2)+12))));
    k=1;
 end
 
 %%%如果发现某一列出现NaN，那么就利用距离矩阵，找出该空气质量站的最近的4个站点
 %%%利用反距离加权求解PM2.5、PM10、O3
 
 k=4; %近邻数大于等于2
 h=2; %反距离的距离的幂数
 j=1;
 temp_BJ_data_new=temp_BJ_data(:,1:12);
 
    for i=1:size(temp_BJ_data,1)%对35个空气质量站分别
        
       for l=3:k+2 %k是规定的选择的最大近邻的气象观测站的个数,由于第1个距离是0，因此要从第二开始
                        [~,n]=find(cell2mat(temp_BJ_data(i,13:47))==cell2mat(BJ_temp_dist(i,l-1)));%保留最近邻风速并且从l开始循环寻找距离空气质量站更远的气象观测站
                        temp_BJ_data_new(i,13+(j-1)*6)=temp_BJ_data(n,1);%站点名称
                        temp_BJ_data_new(i,14+(j-1)*6)=temp_BJ_data(n,10);%PM10
                        temp_BJ_data_new(i,15+(j-1)*6)=temp_BJ_data(n,11);%O3
                        temp_BJ_data_new(i,16+(j-1)*6)=temp_BJ_data(n,12);%风向
                        temp_BJ_data_new(i,17+(j-1)*6)=temp_BJ_data(n,8);%风速
                        temp_BJ_data_new(i,18+(j-1)*6)=temp_BJ_data(n,9);%PM2.5
                        j=j+1;
       end
       j=1;
    end
    
    
end