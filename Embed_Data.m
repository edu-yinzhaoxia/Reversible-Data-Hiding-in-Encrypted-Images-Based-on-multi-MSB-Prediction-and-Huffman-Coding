function [stego_I,emD] = Embed_Data(encrypt_I,Map_origin_I,Side_Information,D,Data_key,ref_x,ref_y)
% 函数说明：根据位置图将辅助信息和秘密信息嵌入到加密图像中
% 输入：encrypt_I（加密图像）,Map_origin_I（位置图）,Side_Information（辅助信息）,D（秘密信息）,Data_key（数据加密密钥）,ref_x,ref_y（参考像素的行列数）
% 输出：stego_I（加密标记图像）,emD（嵌入的数据）
stego_I = encrypt_I;
[row,col] = size(encrypt_I); %统计encrypt_I的行列数
%% 对原始秘密信息D进行加密
[Encrypt_D] = Encrypt_Data(D,Data_key);
%% 将前ref_y列、前ref_x行的参考像素记录下来，放在秘密信息之前嵌入图像中
Refer_Value = zeros();
t = 0; %计数
for i=1:row
    for j=1:ref_y  %前ref_y列
        value = encrypt_I(i,j);
        [bin2_8] = Decimalism_Binary(value); %将十进制整数转换成8位二进制数组
        Refer_Value(t+1:t+8) = bin2_8;
        t = t + 8; 
    end
end
for i=1:ref_x  %前ref_x行
    for j=ref_y+1:col
        value = encrypt_I(i,j);
        [bin2_8] = Decimalism_Binary(value); %将十进制整数转换成8位二进制数组
        Refer_Value(t+1:t+8) = bin2_8;
        t = t + 8; 
    end
end 
%% 辅助量
num_D = length(D); %求秘密信息D的长度
num_emD = 0; %计数，统计嵌入秘密信息的个数
num_S = length(Side_Information); %求辅助信息Side_Information的长度
num_side = 0;%计数，统计嵌入辅助信息的个数
num_RV = length(Refer_Value); %参考像素二进制序列信息的长度
num_re = 0; %计数，统计嵌入参考像素二进制序列信息的长度
%% 先在前ref_y列、前ref_x行的参考像素中存储辅助信息
for i=1:row
    for j=1:ref_y  %前ref_y列
        bin2_8 = Side_Information(num_side+1:num_side+8);
        [value] = Binary_Decimalism(bin2_8); %将8位二进制数组转换成十进制整数
        stego_I(i,j) = value;
        num_side = num_side + 8;
    end
end
for i=1:ref_x  %前ref_x行
    for j=ref_y+1:col
        bin2_8 = Side_Information(num_side+1:num_side+8);
        [value] = Binary_Decimalism(bin2_8); %将8位二进制数组转换成十进制整数
        stego_I(i,j) = value;
        num_side = num_side + 8;
    end
end
%% 再在其余位置嵌入辅助信息、参考像素和秘密数据
for i=ref_x+1:row  
    for j=ref_y+1:col 
        if num_emD >= num_D %秘密数据已嵌完
            break;
        end
        %------表示这个像素点可以嵌入 1 bit信息------%
        if Map_origin_I(i,j) == 0  %Map=0表示原始像素值的第1MSB与其预测值相反
            if num_side < num_S %辅助信息没有嵌完
                num_side = num_side + 1;
                stego_I(i,j) = mod(stego_I(i,j),2^7) + Side_Information(num_side)*(2^7); %替换1位MSB
            else
                if num_re < num_RV %参考像素二进制序列信息没有嵌完
                    num_re = num_re + 1;
                    stego_I(i,j) = mod(stego_I(i,j),2^7) + Refer_Value(num_re)*(2^7); %替换1位MSB
                else %最后嵌入秘密信息
                    num_emD = num_emD + 1;
                    stego_I(i,j) = mod(stego_I(i,j),2^7) + Encrypt_D(num_emD)*(2^7); %替换1位MSB
                end       
            end
        %------表示这个像素点可以嵌入 2 bit信息------%
        elseif Map_origin_I(i,j) == 1  %Map=1表示原始像素值的第2MSB与其预测值相反  
            if num_side < num_S %辅助信息没有嵌完
                if num_side+2 <= num_S %2位MSB都用来嵌入辅助信息
                    num_side = num_side + 2;
                    stego_I(i,j) = mod(stego_I(i,j),2^6) + Side_Information(num_side-1)*(2^7) + Side_Information(num_side)*(2^6); %替换2位MSB
                else
                    num_side = num_side + 1; %1bit辅助信息
                    num_re = num_re + 1; %1bit参考像素二进制序列信息
                    stego_I(i,j) = mod(stego_I(i,j),2^6) + Side_Information(num_side)*(2^7) + Refer_Value(num_re)*(2^6); %替换2位MSB
                end
            else
                if num_re < num_RV %参考像素二进制序列信息没有嵌完
                    if num_re+2 <= num_RV %2位MSB都用来嵌入参考像素二进制序列信息   
                        num_re = num_re + 2;
                        stego_I(i,j) = mod(stego_I(i,j),2^6) + Refer_Value(num_re-1)*(2^7) + Refer_Value(num_re)*(2^6); %替换2位MSB
                    else
                        num_re = num_re + 1; %1bit参考像素二进制序列信息
                        num_emD = num_emD + 1; %1bit秘密信息
                        stego_I(i,j) = mod(stego_I(i,j),2^6) + Refer_Value(num_re)*(2^7) + Encrypt_D(num_emD)*(2^6); %替换2位MSB
                    end
                else
                    if num_emD+2 <= num_D
                        num_emD = num_emD + 2; %2bit秘密信息
                        stego_I(i,j) = mod(stego_I(i,j),2^6) + Encrypt_D(num_emD-1)*(2^7) + Encrypt_D(num_emD)*(2^6); %替换2位MSB
                    else
                        num_emD = num_emD + 1; %1bit秘密信息
                        stego_I(i,j) = mod(stego_I(i,j),2^7) + Encrypt_D(num_emD)*(2^7); %替换1位MSB
                    end   
                end
            end
        %------表示这个像素点可以嵌入 3 bit信息------%
        elseif Map_origin_I(i,j) == 2  %Map=2表示原始像素值的第3MSB与其预测值相反
            bin2_8 = zeros(1,8); %用来记录要嵌入的信息，少于8位的低位(LSB)默认为0
            if num_side < num_S %辅助信息没有嵌完
                if num_side+3 <= num_S %3位MSB都用来嵌入辅助信息
                    bin2_8(1:3) = Side_Information(num_side+1:num_side+3); 
                    num_side = num_side + 3;
                    [value] = Binary_Decimalism(bin2_8);
                    stego_I(i,j) = mod(stego_I(i,j),2^5) + value; %替换3位MSB
                else
                    t = num_S - num_side; %剩余辅助信息个数
                    bin2_8(1:t) = Side_Information(num_side+1:num_S); %tbit辅助信息
                    num_side = num_side + t;
                    bin2_8(t+1:3) = Refer_Value(num_re+1:num_re+3-t); %(3-t)bit参考像素二进制序列信息
                    num_re = num_re + 3-t;
                    [value] = Binary_Decimalism(bin2_8);
                    stego_I(i,j) = mod(stego_I(i,j),2^5) + value; %替换3位MSB
                end
            else
                if num_re < num_RV  %参考像素二进制序列信息没有嵌完
                    if num_re+3 <= num_RV %3位MSB都用来嵌入参考像素二进制序列信息
                        bin2_8(1:3) = Refer_Value(num_re+1:num_re+3); 
                        num_re = num_re + 3;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^5) + value; %替换3位MSB
                    else
                        t = num_RV - num_re; %剩余参考像素二进制序列信息个数
                        bin2_8(1:t) = Refer_Value(num_re+1:num_RV); %tbit参考像素二进制序列信息
                        num_re = num_re + t;
                        bin2_8(t+1:3) = Encrypt_D(num_emD+1:num_emD+3-t); %(3-t)bit秘密信息
                        num_emD = num_emD + 3-t;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^5) + value; %替换3位MSB
                    end 
                else
                    if num_emD+3 <= num_D
                        bin2_8(1:3) = Encrypt_D(num_emD+1:num_emD+3); %3bit秘密信息 
                        num_emD = num_emD + 3;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^5) + value; %替换3位MSB
                    else
                        t = num_D - num_emD; %剩余秘密信息个数
                        bin2_8(1:t) = Encrypt_D(num_emD+1:num_emD+t); %tbit秘密信息
                        num_emD = num_emD + t;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^(8-t)) + value; %替换t位MSB
                    end 
                end
            end   
        %------表示这个像素点可以嵌入 4 bit信息------%    
        elseif Map_origin_I(i,j) == 3  %Map=3表示原始像素值的第4MSB与其预测值相反
            bin2_8 = zeros(1,8); %用来记录要嵌入的信息，少于8位的低位(LSB)默认为0
            if num_side < num_S %辅助信息没有嵌完
                if num_side+4 <= num_S %4位MSB都用来嵌入辅助信息
                    bin2_8(1:4) = Side_Information(num_side+1:num_side+4); 
                    num_side = num_side + 4;
                    [value] = Binary_Decimalism(bin2_8);
                    stego_I(i,j) = mod(stego_I(i,j),2^4) + value; %替换4位MSB
                else
                    t = num_S - num_side; %剩余辅助信息个数
                    bin2_8(1:t) = Side_Information(num_side+1:num_S); %tbit辅助信息
                    num_side = num_side + t;
                    bin2_8(t+1:4) = Refer_Value(num_re+1:num_re+4-t); %(4-t)bit参考像素二进制序列信息
                    num_re = num_re + 4-t;
                    [value] = Binary_Decimalism(bin2_8);
                    stego_I(i,j) = mod(stego_I(i,j),2^4) + value; %替换4位MSB
                end
            else
                if num_re < num_RV  %参考像素二进制序列信息没有嵌完
                    if num_re+4 <= num_RV %4位MSB都用来嵌入参考像素二进制序列信息
                        bin2_8(1:4) = Refer_Value(num_re+1:num_re+4); 
                        num_re = num_re + 4;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^4) + value; %替换4位MSB
                    else
                        t = num_RV - num_re; %剩余参考像素二进制序列信息个数
                        bin2_8(1:t) = Refer_Value(num_re+1:num_RV); %tbit参考像素二进制序列信息
                        num_re = num_re + t;
                        bin2_8(t+1:4) = Encrypt_D(num_emD+1:num_emD+4-t); %(4-t)bit秘密信息
                        num_emD = num_emD + 4-t;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^4) + value; %替换4位MSB
                    end 
                else
                    if num_emD+4 <= num_D
                        bin2_8(1:4) = Encrypt_D(num_emD+1:num_emD+4); %4bit秘密信息 
                        num_emD = num_emD + 4;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^4) + value; %替换4位MSB
                    else
                        t = num_D - num_emD; %剩余秘密信息个数
                        bin2_8(1:t) = Encrypt_D(num_emD+1:num_emD+t); %tbit秘密信息
                        num_emD = num_emD + t;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^(8-t)) + value; %替换t位MSB
                    end 
                end
            end    
        %------表示这个像素点可以嵌入 5 bit信息------%    
        elseif Map_origin_I(i,j) == 4 %Map=4表示原始像素值的第5MSB与其预测值相反
            bin2_8 = zeros(1,8); %用来记录要嵌入的信息，少于8位的低位(LSB)默认为0
            if num_side < num_S %辅助信息没有嵌完
                if num_side+5 <= num_S %5位MSB都用来嵌入辅助信息
                    bin2_8(1:5) = Side_Information(num_side+1:num_side+5); 
                    num_side = num_side + 5;
                    [value] = Binary_Decimalism(bin2_8);
                    stego_I(i,j) = mod(stego_I(i,j),2^3) + value; %替换5位MSB
                else
                    t = num_S - num_side; %剩余辅助信息个数
                    bin2_8(1:t) = Side_Information(num_side+1:num_S); %tbit辅助信息
                    num_side = num_side + t;
                    bin2_8(t+1:5) = Refer_Value(num_re+1:num_re+5-t); %(5-t)bit参考像素二进制序列信息
                    num_re = num_re + 5-t;
                    [value] = Binary_Decimalism(bin2_8);
                    stego_I(i,j) = mod(stego_I(i,j),2^3) + value; %替换5位MSB
                end
            else
                if num_re < num_RV  %参考像素二进制序列信息没有嵌完
                    if num_re+5 <= num_RV %5位MSB都用来嵌入参考像素二进制序列信息
                        bin2_8(1:5) = Refer_Value(num_re+1:num_re+5); 
                        num_re = num_re + 5;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^3) + value; %替换5位MSB
                    else
                        t = num_RV - num_re; %剩余参考像素二进制序列信息个数
                        bin2_8(1:t) = Refer_Value(num_re+1:num_RV); %tbit参考像素二进制序列信息
                        num_re = num_re + t;
                        bin2_8(t+1:5) = Encrypt_D(num_emD+1:num_emD+5-t); %(5-t)bit秘密信息
                        num_emD = num_emD + 5-t;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^3) + value; %替换5位MSB
                    end 
                else
                    if num_emD+5 <= num_D
                        bin2_8(1:5) = Encrypt_D(num_emD+1:num_emD+5); %5bit秘密信息 
                        num_emD = num_emD + 5;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^3) + value; %替换5位MSB
                    else
                        t = num_D - num_emD; %剩余秘密信息个数
                        bin2_8(1:t) = Encrypt_D(num_emD+1:num_emD+t); %tbit秘密信息
                        num_emD = num_emD + t;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^(8-t)) + value; %替换t位MSB
                    end 
                end
            end           
        %------表示这个像素点可以嵌入 6 bit信息------%    
        elseif Map_origin_I(i,j) == 5  %Map=5表示原始像素值的第6MSB与其预测值相反
            bin2_8 = zeros(1,8); %用来记录要嵌入的信息，少于8位的低位(LSB)默认为0
            if num_side < num_S %辅助信息没有嵌完
                if num_side+6 <= num_S %6位MSB都用来嵌入辅助信息
                    bin2_8(1:6) = Side_Information(num_side+1:num_side+6); 
                    num_side = num_side + 6;
                    [value] = Binary_Decimalism(bin2_8);
                    stego_I(i,j) = mod(stego_I(i,j),2^2) + value; %替换6位MSB
                else
                    t = num_S - num_side; %剩余辅助信息个数
                    bin2_8(1:t) = Side_Information(num_side+1:num_S); %tbit辅助信息
                    num_side = num_side + t;
                    bin2_8(t+1:6) = Refer_Value(num_re+1:num_re+6-t); %(6-t)bit参考像素二进制序列信息
                    num_re = num_re + 6-t;
                    [value] = Binary_Decimalism(bin2_8);
                    stego_I(i,j) = mod(stego_I(i,j),2^2) + value; %替换6位MSB
                end
            else
                if num_re < num_RV  %参考像素二进制序列信息没有嵌完
                    if num_re+6 <= num_RV %3位MSB都用来嵌入参考像素二进制序列信息
                        bin2_8(1:6) = Refer_Value(num_re+1:num_re+6); 
                        num_re = num_re + 6;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^2) + value; %替换6位MSB
                    else
                        t = num_RV - num_re; %剩余参考像素二进制序列信息个数
                        bin2_8(1:t) = Refer_Value(num_re+1:num_RV); %tbit参考像素二进制序列信息
                        num_re = num_re + t;
                        bin2_8(t+1:6) = Encrypt_D(num_emD+1:num_emD+6-t); %(6-t)bit秘密信息
                        num_emD = num_emD + 6-t;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^2) + value; %替换6位MSB
                    end 
                else
                    if num_emD+6 <= num_D
                        bin2_8(1:6) = Encrypt_D(num_emD+1:num_emD+6); %6bit秘密信息 
                        num_emD = num_emD + 6;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^2) + value; %替换6位MSB
                    else
                        t = num_D - num_emD; %剩余秘密信息个数
                        bin2_8(1:t) = Encrypt_D(num_emD+1:num_emD+t); %tbit秘密信息
                        num_emD = num_emD + t;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^(8-t)) + value; %替换t位MSB
                    end 
                end
            end      
        %------表示这个像素点可以嵌入 7 bit信息------%    
        elseif Map_origin_I(i,j) == 6  %Map=6表示原始像素值的第7MSB与其预测值相反
            bin2_8 = zeros(1,8); %用来记录要嵌入的信息，少于8位的低位(LSB)默认为0
            if num_side < num_S %辅助信息没有嵌完
                if num_side+7 <= num_S %7位MSB都用来嵌入辅助信息
                    bin2_8(1:7) = Side_Information(num_side+1:num_side+7); 
                    num_side = num_side + 7;
                    [value] = Binary_Decimalism(bin2_8);
                    stego_I(i,j) = mod(stego_I(i,j),2^1) + value; %替换7位MSB
                else
                    t = num_S - num_side; %剩余辅助信息个数
                    bin2_8(1:t) = Side_Information(num_side+1:num_S); %tbit辅助信息
                    num_side = num_side + t;
                    bin2_8(t+1:7) = Refer_Value(num_re+1:num_re+7-t); %(7-t)bit参考像素二进制序列信息
                    num_re = num_re + 7-t;
                    [value] = Binary_Decimalism(bin2_8);
                    stego_I(i,j) = mod(stego_I(i,j),2^1) + value; %替换7位MSB
                end
            else
                if num_re < num_RV  %参考像素二进制序列信息没有嵌完
                    if num_re+7 <= num_RV %7位MSB都用来嵌入参考像素二进制序列信息
                        bin2_8(1:7) = Refer_Value(num_re+1:num_re+7); 
                        num_re = num_re + 7;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^1) + value; %替换7位MSB
                    else
                        t = num_RV - num_re; %剩余参考像素二进制序列信息个数
                        bin2_8(1:t) = Refer_Value(num_re+1:num_RV); %tbit参考像素二进制序列信息
                        num_re = num_re + t;
                        bin2_8(t+1:7) = Encrypt_D(num_emD+1:num_emD+7-t); %(7-t)bit秘密信息
                        num_emD = num_emD + 7-t;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^1) + value; %替换7位MSB
                    end 
                else
                    if num_emD+7 <= num_D
                        bin2_8(1:7) = Encrypt_D(num_emD+1:num_emD+7); %7bit秘密信息 
                        num_emD = num_emD + 7;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^1) + value; %替换7位MSB
                    else
                        t = num_D - num_emD; %剩余秘密信息个数
                        bin2_8(1:t) = Encrypt_D(num_emD+1:num_emD+t); %tbit秘密信息
                        num_emD = num_emD + t;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^(8-t)) + value; %替换t位MSB
                    end 
                end
            end           
        %------表示这个像素点可以嵌入 8 bit信息------%    
        elseif Map_origin_I(i,j) == 7 || Map_origin_I(i,j) == 8  %Map=7表示原始像素值的第8MSB(LSB)与其预测值相反
            bin2_8 = zeros(1,8); %用来记录要嵌入的信息，少于8位的低位(LSB)默认为0
            if num_side < num_S %辅助信息没有嵌完
                if num_side+8 <= num_S %8位MSB都用来嵌入辅助信息
                    bin2_8(1:8) = Side_Information(num_side+1:num_side+8); 
                    num_side = num_side + 8;
                    [value] = Binary_Decimalism(bin2_8);
                    stego_I(i,j) = value; %替换8位MSB
                else
                    t = num_S - num_side; %剩余辅助信息个数
                    bin2_8(1:t) = Side_Information(num_side+1:num_S); %tbit辅助信息
                    num_side = num_side + t;
                    bin2_8(t+1:8) = Refer_Value(num_re+1:num_re+8-t); %(8-t)bit参考像素二进制序列信息
                    num_re = num_re + 8-t;
                    [value] = Binary_Decimalism(bin2_8);
                    stego_I(i,j) = value; %替换8位MSB
                end
            else
                if num_re < num_RV  %参考像素二进制序列信息没有嵌完
                    if num_re+8 <= num_RV %8位MSB都用来嵌入参考像素二进制序列信息
                        bin2_8(1:8) = Refer_Value(num_re+1:num_re+8); 
                        num_re = num_re + 8;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = value; %替换8位MSB
                    else
                        t = num_RV - num_re; %剩余参考像素二进制序列信息个数
                        bin2_8(1:t) = Refer_Value(num_re+1:num_RV); %tbit参考像素二进制序列信息
                        num_re = num_re + t;
                        bin2_8(t+1:8) = Encrypt_D(num_emD+1:num_emD+8-t); %(8-t)bit秘密信息
                        num_emD = num_emD + 8-t;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = value; %替换8位MSB
                    end 
                else
                    if num_emD+8 <= num_D
                        bin2_8(1:8) = Encrypt_D(num_emD+1:num_emD+8); %8bit秘密信息 
                        num_emD = num_emD + 8;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = value; %替换8位MSB
                    else
                        t = num_D - num_emD; %剩余秘密信息个数
                        bin2_8(1:t) = Encrypt_D(num_emD+1:num_emD+t); %tbit秘密信息
                        num_emD = num_emD + t;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(i,j) = mod(stego_I(i,j),2^(8-t)) + value; %替换t位MSB
                    end 
                end
            end         
        end
    end
end
%% 统计嵌入的秘密数据
emD = D(1:num_emD);
end