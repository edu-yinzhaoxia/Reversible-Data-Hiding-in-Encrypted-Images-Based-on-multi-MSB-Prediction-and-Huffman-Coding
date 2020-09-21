function [Map_Bin] = Map_Binary(Map_origin_I,Code)
% 函数说明：将位置图Map_origin_I转换成二进制数组Map
% 输入：Map_origin_I（原始图像的位置图）,Code（映射关系）
% 输出：Map_Bin（原始图像位置图的二进制数组）
[row,col] = size(Map_origin_I); %计算Map_origin_II的行列值
Map_Bin = zeros();
t = 0; %计数，二进制数组的长度
for i=1:row 
    for j=1:col
        if Map_origin_I(i,j) == -1 %标为-1的点是作为参考像素，不统计
            continue;
        end
        for k=1:9
            if Map_origin_I(i,j) == Code(k,1)
                value = Code(k,2);
                break;
            end
        end
        if value == 0
            Map_Bin(t+1) = 0;
            Map_Bin(t+2) = 0;
            t = t+2;
        elseif value == 1
            Map_Bin(t+1) = 0;
            Map_Bin(t+2) = 1;
            t = t+2;
        else
            add = ceil(log2(value+1)); %表示标记编码的长度
            Map_Bin(t+1:t+add) = dec2bin(value)-'0'; %将value转换成二进制数组
            t = t + add;
        end 
    end
end