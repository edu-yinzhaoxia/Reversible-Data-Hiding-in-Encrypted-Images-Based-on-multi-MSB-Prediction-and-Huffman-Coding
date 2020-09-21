function [value,this_end] = Huffman_DeCode(Binary,last_end)
% 求二进制比特流Binary中下一个Huffman编码转换成的整数值
% 输入：Binary（二进制映射序列）,last_end（上一个映射结束的位置）
% 输出：value（十进制整数值）→{0,1,4,5,12,13,14,30,31},end（本次结束的位置）
len = length(Binary);
i = last_end+1;
t = 0; %计数
if i <= len
    if i+1<=len && Binary(i)==0 %→0
        t = t + 1;
        if Binary(i+1) == 0 %→00表示0
            t = t + 1;
            value = 0;
        elseif Binary(i+1) == 1 %→01表示1
            t = t + 1;
            value = 1;
        end
    else  % Binary(i)==1
        if i+2<=len && Binary(i+1)==0 %→10
            t = t + 2;
            if Binary(i+2) == 0  %→100表示4
                t = t + 1;
                value = 4;
            elseif Binary(i+2) == 1 %→101表示5
                t = t + 1;
                value = 5;
            end
        else % Binary(i+1)==1
            if i+3<=len && Binary(i+2)==0  %→110
                t = t + 3;
                if Binary(i+3) == 0  %→1100表示12
                    t = t + 1;
                    value = 12;
                elseif Binary(i+3) == 1  %→1101表示13
                    t = t + 1;
                    value = 13;
                end
            else % Binary(i+2)==1
                if i+3 <= len
                    t = t + 3;
                    if Binary(i+3) == 0  %→1110表示14
                        t = t + 1;
                        value = 14;
                    elseif i+4<=len && Binary(i+3)==1  %→1111
                        t = t + 1;
                        if Binary(i+4) == 0  %→11110表示30
                            t = t + 1;
                            value = 30;
                        elseif Binary(i+4) == 1  %→11111表示31
                            t = t + 1;
                            value = 31;
                        end
                    else
                        t = 0;   
                        value = -1; %表示辅助信息长度不够，无法恢复下一个Huffman编码
                    end
                else
                    t = 0;
                    value = -1; %表示辅助信息长度不够，无法恢复下一个Huffman编码
                end
            end
        end
    end
else
    t = 0;               
    value = -1; %表示辅助信息长度不够，无法恢复下一个Huffman编码
end
this_end = last_end + t;
end

