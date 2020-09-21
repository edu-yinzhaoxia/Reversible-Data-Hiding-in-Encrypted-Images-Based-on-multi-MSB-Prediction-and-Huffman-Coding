function [Side_Information,Refer_Value,Encrypt_exD,Map_I,sign] = Extract_Data(stego_I,num,ref_x,ref_y)
% 函数说明：在加密标记图像中提取信息
% 输入：stego_I（加密标记图像）,num（秘密信息的长度）,ref_x,ref_y（参考像素的行列数）
% 输出：Side_Information（辅助信息）,Refer_Value（参考像素信息）,Encrypt_exD（加密的秘密信息）,Map_I（位置图）,sign（判断标记）
[row,col]=size(stego_I); %统计stego_I的行列数
%% 构建存储位置图的矩阵
Map_I = zeros(row,col); %构建存储位置图的矩阵
for i=1:row
    for j=1:ref_y
        Map_I(i,j) = -1; %前面ref_y列为参考像素，不进行标记
    end
end
for i=1:ref_x
    for j=ref_y+1:col       
        Map_I(i,j) = -1; %前面ref_x行为参考像素，不进行标记   
    end
end
%% 先提取前ref_y列、前ref_x行中的辅助信息
Side_Information = zeros();
num_side = 0;%计数，统计提取辅助信息的个数
for i=1:row
    for j=1:ref_y
        value = stego_I(i,j);
        [bin2_8] = Decimalism_Binary(value); %将十进制整数转换成8位二进制数组
        Side_Information(num_side+1:num_side+8) = bin2_8;
        num_side = num_side + 8;  
    end
end
for i=1:ref_x
    for j=ref_y+1:col
        value = stego_I(i,j);
        [bin2_8] = Decimalism_Binary(value); %将十进制整数转换成8位二进制数组
        Side_Information(num_side+1:num_side+8) = bin2_8;
        num_side = num_side + 8; 
    end
end
%% 提取代表映射规则的辅助信息
Code_Bin = Side_Information(1:32); %前32位是映射规则信息
Code = [0,-1;1,-1;2,-1;3,-1;4,-1;5,-1;6,-1;7,-1;8,-1];
this_end = 0;
for i=1:9 %将二进制序列映射转换成整数映射
    last_end = this_end;
    [code_value,this_end] = Huffman_DeCode(Code_Bin,last_end);
    Code(i,2) = code_value;
end
%% 提取位置图二进制序列的长度信息
max = ceil(log2(row)) + ceil(log2(col)) + 2; %用这么长的二进制表示Map_I转化成二进制数列的长度
len_Bin = Side_Information(33:32+max); %前33到32+max位是位置图二进制序列的长度信息
num_Map = 0; %将二进制序列len_Bin转换成十进制数
for i=1:max
    num_Map = num_Map + len_Bin(i)*(2^(max-i));
end
%% 辅助量
num_S = 32 + max + num_Map; %辅助信息长度
Refer_Value = zeros();
num_RV = (ref_x*row+ref_y*col-ref_x*ref_y)*8; %参考像素二进制序列信息的长度
num_re = 0; %计数，统计提取参考像素二进制序列信息的长度
Encrypt_exD = zeros();
num_D = num; %二进制秘密信息的长度
num_exD = 0; %计数，统计嵌入秘密信息的个数
%% 在前多行多列之外的位置提取信息
this_end = 32 + max; %前面的辅助信息不是位置图
sign = 1; %表示可以完全提取数据恢复图像
for i=ref_x+1:row
    if sign == 0 %表示不能完全提取数据恢复图像
        break;
    end
    for j=ref_y+1:col
        if num_exD >= num_D %秘密数据已提取完毕
            break;
        end
        %------将当前十进制像素值转换成8位二进制数组------%
        value = stego_I(i,j); 
        [bin2_8] = Decimalism_Binary(value); 
        %--通过辅助信息计算当前像素点能提取多少bit的信息--%
        last_end = this_end;
        [map_value,this_end] = Huffman_DeCode(Side_Information,last_end);
        if map_value == -1 %表示辅助信息长度不够，无法恢复下一个Huffman编码
            sign = 0;
            break; 
        end
        for k=1:9
            if map_value == Code(k,2)
                Map_I(i,j) = Code(k,1); %当前像素的位置图信息
                break;
            end
        end
        %--------表示这个像素点可以提取 1 bit信息--------%
        if Map_I(i,j) == 0  %Map=0表示原始像素值的第1MSB与其预测值相反
            if num_side < num_S %辅助信息没有提取完毕
                num_side = num_side + 1;
                Side_Information(num_side) = bin2_8(1);
            else
                if num_re < num_RV %参考像素二进制序列信息没有提取完毕
                    num_re = num_re + 1;
                    Refer_Value(num_re) = bin2_8(1);
                else %最后提取秘密信息
                    num_exD = num_exD + 1;
                    Encrypt_exD(num_exD) = bin2_8(1);
                end
            end
        %--------表示这个像素点可以提取 2 bit信息--------%
        elseif Map_I(i,j) == 1 %Map=1表示原始像素值的第2MSB与其预测值相反
            if num_side < num_S %辅助信息没有提取完毕
                if num_side+2 <= num_S %2位MSB都是辅助信息
                    Side_Information(num_side+1:num_side+2) = bin2_8(1:2);
                    num_side = num_side + 2;
                else
                    num_side = num_side + 1; %1bit辅助信息
                    Side_Information(num_side) = bin2_8(1);
                    num_re = num_re + 1; %1bit参考像素二进制序列信息
                    Refer_Value(num_re) = bin2_8(2);                   
                end
            else
                if num_re < num_RV %参考像素二进制序列信息没有提取完毕
                    if num_re+2 <= num_RV %2位MSB都是参考像素二进制序列信息
                        Refer_Value(num_re+1:num_re+2) = bin2_8(1:2);
                        num_re = num_re + 2;
                    else
                        num_re = num_re + 1; %1bit参考像素二进制序列信息
                        Refer_Value(num_re) = bin2_8(1);  
                        num_exD = num_exD + 1; %1bit秘密信息
                        Encrypt_exD(num_exD) = bin2_8(2);
                    end
                else
                    if num_exD+2 <= num_D
                        Encrypt_exD(num_exD+1:num_exD+2) = bin2_8(1:2); %2bit秘密信息
                        num_exD = num_exD + 2;
                    else
                        num_exD = num_exD + 1; %1bit秘密信息
                        Encrypt_exD(num_exD) = bin2_8(1);
                    end
                end
            end 
        %--------表示这个像素点可以提取 3 bit信息--------%
        elseif Map_I(i,j) == 2  %Map=2表示原始像素值的第3MSB与其预测值相反
            if num_side < num_S %辅助信息没有提取完毕
                if num_side+3 <= num_S %3位MSB都是辅助信息
                    Side_Information(num_side+1:num_side+3) = bin2_8(1:3);
                    num_side = num_side + 3;
                else
                    t = num_S - num_side; %剩余辅助信息个数
                    Side_Information(num_side+1:num_side+t) = bin2_8(1:t); %tbit辅助信息
                    num_side = num_side + t;
                    Refer_Value(num_re+1:num_re+3-t) = bin2_8(t+1:3); %(3-t)bit参考像素二进制序列信息
                    num_re = num_re + 3-t;                 
                end
            else
                if num_re < num_RV %参考像素二进制序列信息没有提取完毕
                    if num_re+3 <= num_RV %3位MSB都是参考像素二进制序列信息
                        Refer_Value(num_re+1:num_re+3) = bin2_8(1:3);
                        num_re = num_re + 3;
                    else
                        t = num_RV - num_re; %剩余参考像素二进制序列信息个数
                        Refer_Value(num_re+1:num_re+t) = bin2_8(1:t); %tbit参考像素二进制序列信息
                        num_re = num_re + t;
                        Encrypt_exD(num_exD+1:num_exD+3-t) = bin2_8(t+1:3); %(3-t)bit秘密信息
                        num_exD = num_exD + 3-t;
                    end
                else
                    if num_exD+3 <= num_D
                        Encrypt_exD(num_exD+1:num_exD+3) = bin2_8(1:3); %3bit秘密信息
                        num_exD = num_exD + 3;
                    else
                        t = num_D - num_exD;
                        Encrypt_exD(num_exD+1:num_exD+t) = bin2_8(1:t); %tbit秘密信息
                        num_exD = num_exD + t; 
                    end
                end
            end
        %--------表示这个像素点可以提取 4 bit信息--------%
        elseif Map_I(i,j) == 3  %Map=3表示原始像素值的第4MSB与其预测值相反
            if num_side < num_S %辅助信息没有提取完毕
                if num_side+4 <= num_S %4位MSB都是辅助信息
                    Side_Information(num_side+1:num_side+4) = bin2_8(1:4);
                    num_side = num_side + 4;
                else
                    t = num_S - num_side; %剩余辅助信息个数
                    Side_Information(num_side+1:num_side+t) = bin2_8(1:t); %tbit辅助信息
                    num_side = num_side + t;
                    Refer_Value(num_re+1:num_re+4-t) = bin2_8(t+1:4); %(4-t)bit参考像素二进制序列信息
                    num_re = num_re + 4-t;                 
                end
            else
                if num_re < num_RV %参考像素二进制序列信息没有提取完毕
                    if num_re+4 <= num_RV %4位MSB都是参考像素二进制序列信息
                        Refer_Value(num_re+1:num_re+4) = bin2_8(1:4);
                        num_re = num_re + 4;
                    else
                        t = num_RV - num_re; %剩余参考像素二进制序列信息个数
                        Refer_Value(num_re+1:num_re+t) = bin2_8(1:t); %tbit参考像素二进制序列信息
                        num_re = num_re + t;
                        Encrypt_exD(num_exD+1:num_exD+4-t) = bin2_8(t+1:4); %(4-t)bit秘密信息
                        num_exD = num_exD + 4-t;
                    end
                else
                    if num_exD+4 <= num_D
                        Encrypt_exD(num_exD+1:num_exD+4) = bin2_8(1:4); %4bit秘密信息
                        num_exD = num_exD + 4;
                    else
                        t = num_D - num_exD;
                        Encrypt_exD(num_exD+1:num_exD+t) = bin2_8(1:t); %tbit秘密信息
                        num_exD = num_exD + t; 
                    end
                end
            end
        %--------表示这个像素点可以提取 5 bit信息--------%
        elseif Map_I(i,j) == 4  %Map=4表示原始像素值的第5MSB与其预测值相反
            if num_side < num_S %辅助信息没有提取完毕
                if num_side+5 <= num_S %5位MSB都是辅助信息
                    Side_Information(num_side+1:num_side+5) = bin2_8(1:5);
                    num_side = num_side + 5;
                else
                    t = num_S - num_side; %剩余辅助信息个数
                    Side_Information(num_side+1:num_side+t) = bin2_8(1:t); %tbit辅助信息
                    num_side = num_side + t;
                    Refer_Value(num_re+1:num_re+5-t) = bin2_8(t+1:5); %(5-t)bit参考像素二进制序列信息
                    num_re = num_re + 5-t;                 
                end
            else
                if num_re < num_RV %参考像素二进制序列信息没有提取完毕
                    if num_re+5 <= num_RV %5位MSB都是参考像素二进制序列信息
                        Refer_Value(num_re+1:num_re+5) = bin2_8(1:5);
                        num_re = num_re + 5;
                    else
                        t = num_RV - num_re; %剩余参考像素二进制序列信息个数
                        Refer_Value(num_re+1:num_re+t) = bin2_8(1:t); %tbit参考像素二进制序列信息
                        num_re = num_re + t;
                        Encrypt_exD(num_exD+1:num_exD+5-t) = bin2_8(t+1:5); %(5-t)bit秘密信息
                        num_exD = num_exD + 5-t;
                    end
                else
                    if num_exD+5 <= num_D
                        Encrypt_exD(num_exD+1:num_exD+5) = bin2_8(1:5); %5bit秘密信息
                        num_exD = num_exD + 5;
                    else
                        t = num_D - num_exD;
                        Encrypt_exD(num_exD+1:num_exD+t) = bin2_8(1:t); %tbit秘密信息
                        num_exD = num_exD + t; 
                    end
                end
            end
            %--------表示这个像素点可以提取 6 bit信息--------%
        elseif Map_I(i,j) == 5  %Map=5表示原始像素值的第6MSB与其预测值相反
            if num_side < num_S %辅助信息没有提取完毕
                if num_side+6 <= num_S %6位MSB都是辅助信息
                    Side_Information(num_side+1:num_side+6) = bin2_8(1:6);
                    num_side = num_side + 6;
                else
                    t = num_S - num_side; %剩余辅助信息个数
                    Side_Information(num_side+1:num_side+t) = bin2_8(1:t); %tbit辅助信息
                    num_side = num_side + t;
                    Refer_Value(num_re+1:num_re+6-t) = bin2_8(t+1:6); %(6-t)bit参考像素二进制序列信息
                    num_re = num_re + 6-t;                 
                end
            else
                if num_re < num_RV %参考像素二进制序列信息没有提取完毕
                    if num_re+6 <= num_RV %6位MSB都是参考像素二进制序列信息
                        Refer_Value(num_re+1:num_re+6) = bin2_8(1:6);
                        num_re = num_re + 6;
                    else
                        t = num_RV - num_re; %剩余参考像素二进制序列信息个数
                        Refer_Value(num_re+1:num_re+t) = bin2_8(1:t); %tbit参考像素二进制序列信息
                        num_re = num_re + t;
                        Encrypt_exD(num_exD+1:num_exD+6-t) = bin2_8(t+1:6); %(6-t)bit秘密信息
                        num_exD = num_exD + 6-t;
                    end
                else
                    if num_exD+6 <= num_D
                        Encrypt_exD(num_exD+1:num_exD+6) = bin2_8(1:6); %6bit秘密信息
                        num_exD = num_exD + 6;
                    else
                        t = num_D - num_exD;
                        Encrypt_exD(num_exD+1:num_exD+t) = bin2_8(1:t); %tbit秘密信息
                        num_exD = num_exD + t; 
                    end
                end
            end
            %--------表示这个像素点可以提取 7 bit信息--------%
        elseif Map_I(i,j) == 6  %Map=6表示原始像素值的第7MSB与其预测值相反
            if num_side < num_S %辅助信息没有提取完毕
                if num_side+7 <= num_S %7位MSB都是辅助信息
                    Side_Information(num_side+1:num_side+7) = bin2_8(1:7);
                    num_side = num_side + 7;
                else
                    t = num_S - num_side; %剩余辅助信息个数
                    Side_Information(num_side+1:num_side+t) = bin2_8(1:t); %tbit辅助信息
                    num_side = num_side + t;
                    Refer_Value(num_re+1:num_re+7-t) = bin2_8(t+1:7); %(7-t)bit参考像素二进制序列信息
                    num_re = num_re + 7-t;                 
                end
            else
                if num_re < num_RV %参考像素二进制序列信息没有提取完毕
                    if num_re+7 <= num_RV %7位MSB都是参考像素二进制序列信息
                        Refer_Value(num_re+1:num_re+7) = bin2_8(1:7);
                        num_re = num_re + 7;
                    else
                        t = num_RV - num_re; %剩余参考像素二进制序列信息个数
                        Refer_Value(num_re+1:num_re+t) = bin2_8(1:t); %tbit参考像素二进制序列信息
                        num_re = num_re + t;
                        Encrypt_exD(num_exD+1:num_exD+7-t) = bin2_8(t+1:7); %(7-t)bit秘密信息
                        num_exD = num_exD + 7-t;
                    end
                else
                    if num_exD+7 <= num_D
                        Encrypt_exD(num_exD+1:num_exD+7) = bin2_8(1:7); %7bit秘密信息
                        num_exD = num_exD + 7;
                    else
                        t = num_D - num_exD;
                        Encrypt_exD(num_exD+1:num_exD+t) = bin2_8(1:t); %tbit秘密信息
                        num_exD = num_exD + t; 
                    end
                end
            end
            %--------表示这个像素点可以提取 8 bit信息--------%
        elseif Map_I(i,j) == 7 || Map_I(i,j) == 8  %Map=7表示原始像素值的第8MSB(LSB)与其预测值相反
            if num_side < num_S %辅助信息没有提取完毕
                if num_side+8 <= num_S %8位MSB都是辅助信息
                    Side_Information(num_side+1:num_side+8) = bin2_8(1:8);
                    num_side = num_side + 8;
                else
                    t = num_S - num_side; %剩余辅助信息个数
                    Side_Information(num_side+1:num_side+t) = bin2_8(1:t); %tbit辅助信息
                    num_side = num_side + t;
                    Refer_Value(num_re+1:num_re+8-t) = bin2_8(t+1:8); %(8-t)bit参考像素二进制序列信息
                    num_re = num_re + 8-t;                 
                end
            else
                if num_re < num_RV %参考像素二进制序列信息没有提取完毕
                    if num_re+8 <= num_RV %8位MSB都是参考像素二进制序列信息
                        Refer_Value(num_re+1:num_re+8) = bin2_8(1:8);
                        num_re = num_re + 8;
                    else
                        t = num_RV - num_re; %剩余参考像素二进制序列信息个数
                        Refer_Value(num_re+1:num_re+t) = bin2_8(1:t); %tbit参考像素二进制序列信息
                        num_re = num_re + t;
                        Encrypt_exD(num_exD+1:num_exD+8-t) = bin2_8(t+1:8); %(8-t)bit秘密信息
                        num_exD = num_exD + 8-t;
                    end
                else
                    if num_exD+8 <= num_D
                        Encrypt_exD(num_exD+1:num_exD+8) = bin2_8(1:8); %8bit秘密信息
                        num_exD = num_exD + 8;
                    else
                        t = num_D - num_exD;
                        Encrypt_exD(num_exD+1:num_exD+t) = bin2_8(1:t); %tbit秘密信息
                        num_exD = num_exD + t; 
                    end
                end
            end 
        end
    end
end
end