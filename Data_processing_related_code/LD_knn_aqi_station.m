function temp_LD_data_new_1=LD_knn_aqi_station(temp_LD_data)
%%%计算temp_LD_data的非空行数

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
        
        temp_LD_data(i,k+12)=num2cell(sqrt((cell2mat(temp_LD_data(i,3))-cell2mat(temp_LD_data(j,3)))^2+(cell2mat(temp_LD_data(i,4))-cell2mat(temp_LD_data(j,4)))^2));
        k=k+1;
        
    end
    LD_temp_dist(i,1:size(LD_temp_dist,2))=num2cell(sort(cell2mat(temp_LD_data(i,13:size(LD_temp_dist,2)+12))));
    k=1;
 end
 k=4; %近邻数大于等于2
 h=2; %反距离的距离的幂数
 j=1;
 temp_LD_data_new_1=temp_LD_data(:,1:12);
 
    for i=1:LD_empty%对35个空气质量站分别
        
       for l=3:k+2 %k是规定的选择的最大近邻的气象观测站的个数,由于第1个距离是0，因此要从第二开始
                        [~,n]=find(cell2mat(temp_LD_data(i,13:12+LD_empty))==cell2mat(LD_temp_dist(i,l-1)));%保留最近邻风速并且从l开始循环寻找距离空气质量站更远的气象观测站
                        if size(n,2)==2
                            n=n(1); %%%由于伦敦有2对，共4个站点是同经纬度的，因此寻找的时候会找到两个位置，导致报错
                        end
                        temp_LD_data_new_1(i,13+(j-1)*6)=temp_LD_data(n,1);%站点名称
                        temp_LD_data_new_1(i,14+(j-1)*6)=temp_LD_data(n,9);%PM2.5
                        temp_LD_data_new_1(i,15+(j-1)*6)=temp_LD_data(n,10);%PM10
                        temp_LD_data_new_1(i,16+(j-1)*6)=temp_LD_data(n,11);%O3
                        temp_LD_data_new_1(i,17+(j-1)*6)=temp_LD_data(n,8);%风速
                        temp_LD_data_new_1(i,18+(j-1)*6)=temp_LD_data(n,12);%风向
                        j=j+1;
       end
       j=1;
    end
 
end