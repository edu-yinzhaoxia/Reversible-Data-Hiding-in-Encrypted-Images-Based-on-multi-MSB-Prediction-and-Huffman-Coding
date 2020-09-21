clear
clc 
load('num_UCID.mat'); %读取数据
load('bpp_UCID.mat');
len = length(num_UCID);
error_Data = 0;
error_Data_Image = zeros(); %存储辅助信息大于总嵌入量的图像ID
error_Side = 0;
error_Side_Image = zeros(); %存储无法提取全部辅助信息的图像ID
error_NoRe = 0;
error_NoRe_Image = zeros(); %存储提取数据或恢复图像不正确的图像ID
num_True = 0; %统计正确提取恢复图像的数目
num_bpp = 0;
for i=1:len
    if num_UCID(i) == -1 %辅助信息大于总嵌入量，不能嵌入数据
        error_Data = error_Data + 1;
        error_Data_Image(error_Data) = i;
    elseif bpp_UCID(i) == -1 %表示能嵌入信息但无法提取
        error_Side = error_Side + 1;
        error_Side_Image(error_Side) = i;
    elseif bpp_UCID(i)==-2 || bpp_UCID(i)==-3 || bpp_UCID(i)==-4
        error_NoRe = error_NoRe + 1;
        error_NoRe_Image(error_NoRe) = i;    
    else
        num_True = num_True + 1;
        num_bpp = num_bpp +  bpp_UCID(i);
    end
end
ave_bpp = num_bpp/num_True; %正确图像的平均嵌入率
%% 求最大嵌入率和最小嵌入率
min_bpp = 10;
max_bpp = 0;
for i=1:len
    if bpp_UCID(i) > max_bpp
        max_bpp = bpp_UCID(i);
    end
    if bpp_UCID(i) < min_bpp
        min_bpp = bpp_UCID(i);
    end
end