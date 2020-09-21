function [value] = Binary_Decimalism(bin2_8)
% 函数说明：将二进制数组转换成十进制整数
% 输出：bin2_8（二进制数组）
% 输入：value（十进制整数）
value = 0;
len = length(bin2_8);
for i=1:len
    value = value + bin2_8(i)*(2^(len-i));
end