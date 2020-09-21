clear
clc
%% 产生二进制秘密数据
num = 10000000;
rand('seed',0); %设置种子
D = round(rand(1,num)*1); %产生稳定随机数
%% 图像数据集信息(ucid.v2),格式:TIFF,数量:1338；
I_file_path = 'D:\ImageDatabase\ucid.v2\'; %测试图像数据集文件夹路径
I_path_list = dir(strcat(I_file_path,'*.tif')); %获取该文件夹中所有pgm格式的图像
img_num = length(I_path_list); %获取图像总数量
%% 记录每张图像的嵌入量和嵌入率
num_UCID = zeros(1,img_num); %记录每张图像的嵌入量 
bpp_UCID = zeros(1,img_num); %记录每张图像的嵌入率
%% 设置图像加密密钥及数据加密密钥
Image_key = 1;
Data_key = 2;
%% 设置参数(方便实验修改)
ref_x = 1; %用来作为参考像素的行数
ref_y = 1; %用来作为参考像素的列数
%% 图像数据集测试
for i=1:img_num 
    %----------------读取图像----------------%
    I_name = I_path_list(i).name; %图像名
    I = imread(strcat(I_file_path,I_name));%读取图像
    origin_I = double(I);
    %-----------图像加密及数据嵌入-----------%
    [encrypt_I,stego_I,emD] = Encrypt_Embed(origin_I,D,Image_key,Data_key,ref_x,ref_y);
    num_emD = length(emD);
    if num_emD > 0
        %--------在加密标记图像中提取信息--------%
        [Side_Information,Refer_Value,Encrypt_exD,Map_I,sign] = Extract_Data(stego_I,num,ref_x,ref_y);
        if sign == 1
            %---------------数据解密----------------%
            [exD] = Encrypt_Data(Encrypt_exD,Data_key);
            %---------------图像恢复----------------%
            [recover_I] = Recover_Image(stego_I,Image_key,Side_Information,Refer_Value,Map_I,num,ref_x,ref_y);
            %---------------结果记录----------------%
            [m,n] = size(origin_I);
            num_UCID(i) = num_emD;   
            bpp_UCID(i) = num_emD/(m*n);
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
                bpp = bpp_UCID(i);
                disp(['Embedding capacity equal to : ' num2str(num_emD)])
                disp(['Embedding rate equal to : ' num2str(bpp)])
                fprintf(['第 ',num2str(i),' 幅图像-------- OK','\n\n']);
            else
                if check1 ~= 1 && check2 == 1
                    bpp_UCID(i) = -2; %表示提取数据不正确
                elseif check1 == 1 && check2 ~= 1
                    bpp_UCID(i) = -3; %表示图像恢复不正确
                else
                    bpp_UCID(i) = -4; %表示提取数据和恢复图像都不正确
                end 
                fprintf(['第 ',num2str(i),' 幅图像-------- ERROR','\n\n']);
            end  
        else
            num_UCID(i) = num_emD;
            bpp_UCID(i) = -1; %表示能嵌入信息但无法提取
            disp('无法提取全部辅助信息！')
            fprintf(['第 ',num2str(i),' 幅图像-------- ERROR','\n\n']);
        end
    else
        num_UCID(i) = -1; %表示不能嵌入信息  
        disp('辅助信息大于总嵌入量，导致无法存储数据！') 
        fprintf(['第 ',num2str(i),' 幅图像-------- ERROR','\n\n']);
    end  
end
%% 保存数据
save('num_UCID')
save('bpp_UCID')