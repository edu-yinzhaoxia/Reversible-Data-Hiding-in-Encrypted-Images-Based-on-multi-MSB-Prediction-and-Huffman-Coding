function [encrypt_I,stego_I,emD] = Encrypt_Embed(origin_I,D,Image_key,Data_key,ref_x,ref_y)
% 函数说明：将原始图像origin_I加密并嵌入数据
% 输入：origin_I（原始图像）,D（要嵌入的数据）,Image_key,Data_key（密钥）,ref_x,ref_y（参考像素的行列数）
% 输出：encrypt_I（加密图像）,stego_I（加密标记图像）,emD（嵌入的数据）

%% 计算origin_I的预测值
[origin_PV_I] = Predictor_Value(origin_I,ref_x,ref_y); 
%% 对每个像素值进行标记（即原始图像的位置图）
[Map_origin_I] = Category_Mark(origin_PV_I,origin_I,ref_x,ref_y);
%% 将像素值的标记类别进行Huffman编码标记
hist_Map_origin_I = tabulate(Map_origin_I(:)); %统计每个标记类别的像素值个数
num_Map_origin_I = zeros(9,2);
for i=1:9  % 9种类别的标记
    num_Map_origin_I(i,1) = i-1; 
end
[m,~] = size(hist_Map_origin_I);
for i=1:9
    for j=2:m %hist_Map_origin_I第一行统计的是参考像素的个数
        if num_Map_origin_I(i,1) == hist_Map_origin_I(j,1)
            num_Map_origin_I(i,2) = hist_Map_origin_I(j,2);
        end
    end
end
[Code,Code_Bin] = Huffman_Code(num_Map_origin_I); %计算标记的映射关系及其二进制序列表示
%% 将位置图Map_origin_I转换成二进制数组
[Map_Bin] = Map_Binary(Map_origin_I,Code);
%% 计算存储Map_Binary长度需要的信息长度
[row,col]=size(origin_I); 
max = ceil(log2(row)) + ceil(log2(col)) + 2; %用这么长的二进制表示Map_Binary的长度
length_Map = length(Map_Bin);
len_Bin = dec2bin(length_Map)-'0'; %将length_Map转换成二进制数组
if length(len_Bin) < max
    len = length(len_Bin);
    B = len_Bin;
    len_Bin = zeros(1,max);
    for i=1:len
        len_Bin(max-len+i) = B(i); %存储Map_Bin的长度信息
    end 
end
%% 统计恢复时需要的辅助信息（Code_Bin，len_Bin，Map_Bin）
Side_Information = [Code_Bin,len_Bin,Map_Bin];
%% 对原始图像origin_I进行加密
[encrypt_I] = Encrypt_Image(origin_I,Image_key);
%% 在Encrypt_I中嵌入信息
[stego_I,emD] = Embed_Data(encrypt_I,Map_origin_I,Side_Information,D,Data_key,ref_x,ref_y);
end