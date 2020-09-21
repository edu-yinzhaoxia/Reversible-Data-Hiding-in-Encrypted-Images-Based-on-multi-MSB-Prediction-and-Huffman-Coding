function [recover_I] = Recover_Image(stego_I,Image_key,Side_Information,Refer_Value,Map_I,num,ref_x,ref_y)
% 函数说明：根据提取的辅助信息恢复图像
% 输入：stego_I（载密图像）,Image_key（图像加密密钥）,Side_Information（辅助信息）,Refer_Value（参考像素信息）,Map_I（位置图）,num（秘密信息的长度）,ref_x,ref_y（参考像素的行列数）
% 输出：recover_I（恢复图像）
[row,col] = size(stego_I); %统计stego_I的行列数
%% 根据Refer_Value恢复前ref_y列、前ref_x行的参考像素
refer_I = stego_I;
t = 0; %计数
for i=1:row
    for j=1:ref_y
        bin2_8 = Refer_Value(t+1:t+8);
        [value] = Binary_Decimalism(bin2_8); %将8位二进制数组转换成十进制整数
        refer_I(i,j) = value;
        t = t + 8;
    end
end
for i=1:ref_x
    for j=ref_y+1:col
        bin2_8 = Refer_Value(t+1:t+8);
        [value] = Binary_Decimalism(bin2_8); %将8位二进制数组转换成十进制整数
        refer_I(i,j) = value;
        t = t + 8;
    end
end
%% 将图像refer_I根据图像加密密钥解密
[decrypt_I] = Encrypt_Image(refer_I,Image_key);
%% 根据Side_Information、Map_I和num恢复其他位置的像素
recover_I = decrypt_I;
num_S = length(Side_Information);
num_D = num_S + num; %嵌入信息的总数
re = 0; %计数
for i=ref_x+1:row
    for j=ref_y+1:col
        if re >= num_D %嵌入信息的比特位全部恢复完毕
            break;
        end
        %---------求当前像素点的预测值---------%
        a = recover_I(i-1,j);
        b = recover_I(i-1,j-1);
        c = recover_I(i,j-1);
        if b <= min(a,c)
            pv = max(a,c);
        elseif b >= max(a,c)
            pv = min(a,c);
        else
            pv = a + c - b;
        end
        %--将原始值和预测值转换成8位二进制数组--%
        x = recover_I(i,j);
        [bin2_x] = Decimalism_Binary(x);
        [bin2_pv] = Decimalism_Binary(pv);
        %--------表示这个像素点需要恢复 1 bit MSB--------%
        if Map_I(i,j) == 0  %Map=0表示原始像素值的第1MSB与其预测值相反
            if bin2_pv(1) == 0 
                bin2_x(1) = 1; 
            else  
                bin2_x(1) = 0;
            end
            [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
            recover_I(i,j) = value;
            re = re + 1; %恢复1bit  
        %--------表示这个像素点需要恢复 2 bit MSB--------%
        elseif Map_I(i,j) == 1  %Map=1表示原始像素值的第2MSB与其预测值相反
            if re+2 <= num_D
                if bin2_pv(2) == 0
                    bin2_x(2) = 1;
                else
                    bin2_x(2) = 0;
                end
                bin2_x(1) = bin2_pv(1);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + 2; %恢复2bit
            else 
                t = num_D - re; %剩余恢复的bit数
                bin2_x(1:t) = bin2_pv(1:t);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + t; %恢复tbit 
            end
        %--------表示这个像素点需要恢复 3 bit MSB--------%
        elseif Map_I(i,j) == 2  %Map=2表示原始像素值的第3MSB与其预测值相反
            if re+2 <= num_D
                if bin2_pv(3) == 0 
                    bin2_x(3) = 1; 
                else                    
                    bin2_x(3) = 0;
                end
                bin2_x(1:2) = bin2_pv(1:2);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + 3; %恢复3bit
            else 
                t = num_D - re; %剩余恢复的bit数
                bin2_x(1:t) = bin2_pv(1:t);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + t; %恢复tbit
            end    
        %--------表示这个像素点需要恢复 4 bit MSB--------%
        elseif Map_I(i,j) == 3  %Map=3表示原始像素值的第4MSB与其预测值相反
            if re+3 <= num_D
                if bin2_pv(4) == 0 
                    bin2_x(4) = 1; 
                else                    
                    bin2_x(4) = 0;
                end
                bin2_x(1:3) = bin2_pv(1:3);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + 4; %恢复4bit
            else 
                t = num_D - re; %剩余恢复的bit数
                bin2_x(1:t) = bin2_pv(1:t);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + t; %恢复tbit
            end  
        %--------表示这个像素点需要恢复 5 bit MSB--------%
        elseif Map_I(i,j) == 4  %Map=4表示原始像素值的第5MSB与其预测值相反
            if re+4 <= num_D
                if bin2_pv(5) == 0 
                    bin2_x(5) = 1; 
                else                    
                    bin2_x(5) = 0;
                end
                bin2_x(1:4) = bin2_pv(1:4);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + 5; %恢复5bit
            else 
                t = num_D - re; %剩余恢复的bit数
                bin2_x(1:t) = bin2_pv(1:t);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + t; %恢复tbit
            end    
        %--------表示这个像素点需要恢复 6 bit MSB--------%
        elseif Map_I(i,j) == 5  %Map=5表示原始像素值的第6MSB与其预测值相反
            if re+5 <= num_D
                if bin2_pv(6) == 0 
                    bin2_x(6) = 1; 
                else                    
                    bin2_x(6) = 0;
                end
                bin2_x(1:5) = bin2_pv(1:5);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + 6; %恢复6bit
            else 
                t = num_D - re; %剩余恢复的bit数
                bin2_x(1:t) = bin2_pv(1:t);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + t; %恢复tbit
            end 
        %--------表示这个像素点需要恢复 7 bit MSB--------%
        elseif Map_I(i,j) == 6  %Map=6表示原始像素值的第7MSB与其预测值相反
            if re+6 <= num_D
                if bin2_pv(7) == 0 
                    bin2_x(7) = 1; 
                else                    
                    bin2_x(7) = 0;
                end
                bin2_x(1:6) = bin2_pv(1:6);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + 7; %恢复7bit
            else 
                t = num_D - re; %剩余恢复的bit数
                bin2_x(1:t) = bin2_pv(1:t);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + t; %恢复tbit
            end 
        %--------表示这个像素点需要恢复 8 bit MSB--------%
        elseif Map_I(i,j) == 7  %Map=7表示原始像素值的第8MSB与其预测值相反
            if re+7 <= num_D
                if bin2_pv(8) == 0 
                    bin2_x(8) = 1; 
                else                    
                    bin2_x(8) = 0;
                end
                bin2_x(1:7) = bin2_pv(1:7);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + 8; %恢复8bit
            else 
                t = num_D - re; %剩余恢复的bit数
                bin2_x(1:t) = bin2_pv(1:t);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + t; %恢复tbit
            end  
        %--------表示这个像素点需要恢复 8 bit MSB--------%
        elseif Map_I(i,j) == 8  %Map=8表示原始像素值等于其预测值
            if re+8 <= num_D
                bin2_x(1:8) = bin2_pv(1:8);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + 8; %恢复8bit
            else 
                t = num_D - re; %剩余恢复的bit数
                bin2_x(1:t) = bin2_pv(1:t);
                [value] = Binary_Decimalism(bin2_x); %将8位二进制数组转换成十进制整数
                recover_I(i,j) = value;
                re = re + t; %恢复tbit
            end
        end
    end
end
end