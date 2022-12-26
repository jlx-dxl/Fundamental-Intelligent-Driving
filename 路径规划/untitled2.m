% 基于栅格地图的机器人路径规划算法
% 第1节：利用Matlab快速绘制栅格地图
clc
clear
close all

%% 构建颜色MAP图
cmap = [1 1 1; ...       % 1-白色-空地
    0 0 0; ...           % 2-黑色-静态障碍
    1 0 0; ...           % 3-红色-动态障碍
    1 1 0;...            % 4-黄色-起始点 
    1 0 1;...            % 5-品红-目标点
    0 1 0; ...           % 6-绿色-到目标点的规划路径   
    0 1 1];              % 7-青色-动态规划的路径

% 构建颜色MAP图
colormap(cmap);

%% 构建栅格地图场景
% 栅格界面大小:行数和列数
rows = 10;  
cols = 20; 

% 定义栅格地图全域，并初始化空白区域
field = ones(rows, cols);

% 障碍物区域
obsRate = 0.1;
obsNum = floor(rows*cols*obsRate);          %定义障碍物的数量
obsIndex = randi([1,rows*cols],obsNum,1);   %定义障碍物的线性索引值
field(obsIndex) = 2;                        %将地图区域中障碍物的值设置为2

% 起始点和目标点
startPos = 2;
goalPos = rows*cols-2;
field(startPos) = 4;
field(goalPos) = 5;

%% 画栅格图
image(1.5,1.5,field);
grid on;
set(gca,'gridline','-','gridcolor','k','linewidth',1,'GridAlpha',1);  %设置栅格线条的样式（颜色、透明度等）
set(gca,'xtick',1:cols+1,'ytick',1:rows+1);      %设置横纵方向上步长为1
axis image; 