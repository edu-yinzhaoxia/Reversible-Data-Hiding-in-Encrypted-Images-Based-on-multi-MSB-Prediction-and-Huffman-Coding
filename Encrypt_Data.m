function [Encrypt_D] = Encrypt_Data(D,Data_key)
% 函数说明：对原始秘密信息D进行bit级异或加密
% 输入：D（原始秘密信息）,Data_key（数据加密密钥）
% 输出：Encrypt_D（加密的秘密信息）
num_D = length(D); %求嵌入数据D的长度
Encrypt_D = D;  %构建存储加密秘密信息的容器
%% 根据密钥生成与D长度相同的随机0/1序列
rand('seed',Data_key); %设置种子
E = round(rand(1,num_D)*1); %随机生成长度为num_D的0/1序列
%% 根据E对原始秘密信息D进行异或加密
for i=1:num_D  
    Encrypt_D(i) = bitxor(D(i),E(i));
end
end