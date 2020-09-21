function [origin_PV_I] = Predictor_Value(origin_I,ref_x,ref_y)  
% 函数说明：计算origin_I的预测值
% 输入：origin_I（原始图像）,ref_x,ref_y（参考像素的行列数）
% 输出：origin_PV_I（原始图像的预测值）
[row,col] = size(origin_I); %计算origin_I的行列值
origin_PV_I = origin_I;  %构建存储origin_I预测值的容器
for i=ref_x+1:row  %前ref_x行作为参考像素，不用预测
    for j=ref_y+1:col  %前ref_y列作为参考像素，不用预测
        a = origin_I(i-1,j);
        b = origin_I(i-1,j-1);
        c = origin_I(i,j-1);
        if b <= min(a,c)
            origin_PV_I(i,j) = max(a,c);
        elseif b >= max(a,c)
            origin_PV_I(i,j) = min(a,c);
        else
            origin_PV_I(i,j) = a + c - b;
        end
    end
end