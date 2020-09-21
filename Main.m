clear
clc
% I = imread('测试图像\Airplane.tiff');
I = imread('测试图像\Lena.tiff');
% I = imread('测试图像\Man.tiff');
% I = imread('测试图像\Jetplane.tiff');
% I = imread('测试图像\Baboon.tiff');
% I = imread('测试图像\Tiffany.tiff');
origin_I = double(I); 
%% 产生二进制秘密数据
num = 10000000;
rand('seed',0); %设置种子
D = round(rand(1,num)*1); %产生稳定随机数
%% 设置图像加密密钥及数据加密密钥
Image_key = 1; 
Data_key = 2;
%% 设置参数(方便实验修改)
ref_x = 1; %用来作为参考像素的行数
ref_y = 1; %用来作为参考像素的列数
%% 图像加密及数据嵌入
[encrypt_I,stego_I,emD] = Encrypt_Embed(origin_I,D,Image_key,Data_key,ref_x,ref_y);
%% 数据提取及图像恢复
num_emD = length(emD);
if num_emD > 0  %表示有空间嵌入数据
    %--------在加密标记图像中提取信息--------%
    [Side_Information,Refer_Value,Encrypt_exD,Map_I,sign] = Extract_Data(stego_I,num,ref_x,ref_y);
    if sign == 1 %表示能完全提取辅助信息
        %---------------数据解密----------------%
        [exD] = Encrypt_Data(Encrypt_exD,Data_key);
        %---------------图像恢复----------------%
        [recover_I] = Recover_Image(stego_I,Image_key,Side_Information,Refer_Value,Map_I,num,ref_x,ref_y);
        %---------------图像对比----------------%
        figure;
        subplot(221);imshow(origin_I,[]);title('原始图像');
        subplot(222);imshow(encrypt_I,[]);title('加密图像');
        subplot(223);imshow(stego_I,[]);title('载密图像');
        subplot(224);imshow(recover_I,[]);title('恢复图像');
        %---------------结果记录----------------%
        [m,n] = size(origin_I);
        bpp = num_emD/(m*n);
        %---------------结果判断----------------%
        check1 = isequal(emD,exD);
        check2 = isequal(origin_I,recover_I);
        if check1 == 1
            disp('提取数据与嵌入数据完全相同！')
        else
            disp('Warning！数据提取错误！')
        end
        if check2 == 1
            disp('重构图像与原始图像完全相同！')
        else
            disp('Warning！图像重构错误！')
        end
        %---------------结果输出----------------%
        if check1 == 1 && check2 == 1
            disp(['Embedding capacity equal to : ' num2str(num_emD)])
            disp(['Embedding rate equal to : ' num2str(bpp)])
            fprintf(['该测试图像------------ OK','\n\n']);
        else
            fprintf(['该测试图像------------ ERROR','\n\n']);
        end     
    else
        disp('无法提取全部辅助信息！')
        fprintf(['该测试图像------------ ERROR','\n\n']);
    end
else
    disp('辅助信息大于总嵌入量，导致无法存储数据！') 
    fprintf(['该测试图像------------ ERROR','\n\n']);
end 
