function [Map_origin_I] = Category_Mark(origin_PV_I,origin_I,ref_x,ref_y)
% 函数说明：对每个像素值进行标记，即生成原始图像的位置图
% 输入：origin_PV_I（预测值），origin_I（原始值）,ref_x,ref_y（参考像素的行列数）
% 输出：Map_origin_I（像素值的标记分类,即位置图）
[row,col] = size(origin_I); %计算origin_I的行列值
Map_origin_I = origin_I;  %构建存储origin_I标记的容器
for i=1:row
    for j=1:col
        if i<=ref_x || j<=ref_y %前ref_x行、前ref_y列作为参考像素，不标记
            Map_origin_I(i,j) = -1;   
        else
            x = origin_I(i,j); %原始值
            pv = origin_PV_I(i,j); %预测值
            for t=7:-1:0  
                if floor(x/(2^t)) ~= floor(pv/(2^t))
                    ca = 8-t-1; %用来记录像素值的标记类别
                    break;
                else
                    ca = 8; 
                end
            end
            Map_origin_I(i,j) = ca; %表示有ca位MSB相同，即可以嵌入ca位信息
        end        
    end
end