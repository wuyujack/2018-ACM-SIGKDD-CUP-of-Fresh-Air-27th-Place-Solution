%%% author: Jason Leung

function W=knn_interplote_weather(temp_meo,d)
%W=1;
    
    %[d,~,~]=xlsread('station_AQI');%导入空气质量站的经纬度坐标
    temp=zeros(size(d,1),size(temp_meo,1));

    %%%%%求出18个气象观测站到35个空气质量站两两之间的欧式距离%%%%
    for i=1:size(d,1)
        for  j=1:size(temp_meo,1) 
            d(i,j+6)=sqrt((d(i,1)-temp_meo(j,1))^2+(d(i,2)-temp_meo(j,2))^2);%欧式距离=根号（（x1-x2）^2+(y1-y2)
        end
        temp(i,1:size(temp_meo,1))=sort(d(i,7:size(temp_meo,1)+6));%%对距离进行排序
    end

    %%%%求出18个气象观测站在u、v方向上面风速的分量
    u=zeros(size(temp_meo,1),1); %初始化u方向上的风速
    v=zeros(size(temp_meo,1),1); %初始化v方向上的风速
    for j = 1:size(temp_meo,1) %对于输入的某个时刻的气象站的风速
        if isnan(temp_meo(j,7)) %如果该行对应的气象站的风速为NaN
            u(j)=666666666; %对不存在风速记录的气象站的u分量赋值为666666666
            v(j)=666666666; %对不存在风速记录的气象站的u分量赋值为666666666
        elseif temp_meo(j,7)>=999016
            u(j)=0.5.*rand();  %对于风向大于999016的气象观测站而言，他们的风速小于0.5，因此随机生成一个小于0.5大于0的数
            v(j)=0.5.*rand();  %对于风向大于999016的气象观测站而言，他们的风速小于0.5，因此随机生成一个小于0.5大于0的数
        else
            u(j) = temp_meo(j,8) * sind((temp_meo(j,7)));%u方向分量
            v(j) = temp_meo(j,8) * cosd((temp_meo(j,7)));%v方向分量
        end
    end

    k=4; %近邻数大于等于2
    h=2; %反距离的距离的幂数
    W=[size(d,1),3,1];%以35个空气质量站数目构造一个三维数组
    ufenzi=0; %初始化反向加权求解u方向风速的分子
    ufenmu=0;%初始化反向加权求解u方向风速的分母
    vfenzi=0;%初始化反向加权求解v方向风速的分子
    vfenmu=0;%初始化反向加权求解v方向风速的分母
    temp_fenzi=0;%初始化反向加权求解温度的分子
    temp_fenmu=0;%初始化反向加权求解温度的分母
    pressure_fenzi=0;%初始化反向加权求解压强的分子
    pressure_fenmu=0;%初始化反向加权求解压强的分母
    humidity_fenzi=0;%初始化反向加权求解湿度的分子
    humidity_fenmu=0;%初始化反向加权求解湿度的分母

    for i=1:size(d,1)%对35个空气质量站分别求风向和风速
        [~,n]=find(d(i,:)==temp(i,1));%只保留保留最近邻风速，因此是“1”
        W(i,9,1)=temp_meo(n-6,3);
        for l=2:k %k是规定的选择的最大近邻的气象观测站的个数
            
            
            if temp(i,l)-temp(i,1)<0.1 %如果第l个气象观测站到第i个空气质量站的距离与此空气质量站的最近邻气象观测站小于0.1
            
            [~,n]=find(d(i,:)==temp(i,l-1));%保留最近邻风速并且从l开始循环寻找距离空气质量站更远的气象观测站
            ufenzi= ufenzi + u(n-6)/(d(i,n)^h); 
            ufenmu= ufenmu + 1/(d(i,n)^h);
            vfenzi= vfenzi + v(n-6)/(d(i,n)^h); 
            vfenmu= vfenmu + 1/(d(i,n)^h);
            temp_fenzi=temp_fenzi+temp_meo(n-6,4)/(d(i,n)^h);
            temp_fenmu=temp_fenmu+1/(d(i,n)^h);
            pressure_fenzi= pressure_fenzi+temp_meo(n-6,5)/(d(i,n)^h);
            pressure_fenmu=pressure_fenmu+1/(d(i,n)^h);
            humidity_fenzi=humidity_fenzi+temp_meo(n-6,6)/(d(i,n)^h);
            humidity_fenmu=humidity_fenmu+1/(d(i,n)^h);
            
            elseif temp(i,2)-temp(i,1)>0.1 || temp(i,2)>0.2 %经过数据可视化观测，当第二近邻的气象观测站与最近邻观测站的差值大于0.1
                                                                                   %或者第二近邻观测站距离大于0.2的时候，此时我们认为只保留最近邻气象观测
                                                                                   %站的风速并直接复制给这个空气质量站。因为从可视化的图上面那些远离大部分
                                                                                   %空气质量观测站的那些空气质量观测站附近都只有1个或者2个气象观测站
            [~,n]=find(d(i,:)==temp(i,1));%只保留保留最近邻风速，因此是“1”
            ufenzi= u(n-6)/(d(i,n)^h); 
            ufenmu= 1/(d(i,n)^h);
            vfenzi= v(n-6)/(d(i,n)^h); 
            vfenmu= 1/(d(i,n)^h);
            temp_fenzi=temp_fenzi+temp_meo(n-6,4)/(d(i,n)^h);
            temp_fenmu=temp_fenmu+1/(d(i,n)^h);
            pressure_fenzi= pressure_fenzi+temp_meo(n-6,5)/(d(i,n)^h);
            pressure_fenmu=pressure_fenmu+1/(d(i,n)^h);
            humidity_fenzi=humidity_fenzi+temp_meo(n-6,6)/(d(i,n)^h);
            humidity_fenmu=humidity_fenmu+1/(d(i,n)^h);
            
            end   
        end
            W(i,1,1)=d(i,1);
            W(i,2,1)=d(i,2);
            W(i,3,1)=temp_fenzi/temp_fenmu; %根据反向加权求出温度
            W(i,4,1)=pressure_fenzi/pressure_fenmu; %根据反向加权求出压强
            W(i,5,1)=humidity_fenzi/humidity_fenmu; %根据反向加权求出湿度
            W(i,6,1)=ufenzi/ufenmu; %根据反向加权求出u方向的风速
            W(i,7,1)=vfenzi/vfenmu; %根据反向加权求出v方向的风速
            W(i,8,1)=sqrt(W(i,6)^2+W(i,7)^2); %利用三角形法则(勾股定理)合成风速
    end
    
end
