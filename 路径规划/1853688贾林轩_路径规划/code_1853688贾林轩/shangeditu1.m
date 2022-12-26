clc
clear

%% 1.建立原始栅格地图
%% 构建颜色MAP图
% identifier setting
Obstacle = 2;
Origin = 3;
Destination = 4;
Finished = 5;
Unfinished = 6;
Path = 7;

% color setting
white = [1,1,1];
black = [0,0,0];
green = [0,1,0];
yellow = [1,1,0];
red = [1,0,0];
blue = [0,0,1];
cyan = [0,1,1];
color_list = [white; black; green; yellow; red; blue; cyan];
colormap(color_list);

%% 构建栅格地图场景
% 栅格界面大小:行数和列数
rows = 15;  
cols = 100; 

% 定义栅格地图全域，并初始化空白区域
field = ones(rows, cols);

% 障碍物区域
% obstacle1
for i=1:4
    for j=1:10
        field(3+i,20+j)=2;
    end
end
% obstacle2
for i=1:4
    for j=1:10
        field(8+i,45+j)=2;
    end
end
% obstacle3
for i=1:4
    for j=1:10
        field(3+i,70+j)=2;
    end
end

% 起始点和目标点
% start
for i=1:5
    for j=1:10
        field(2+i,5+j)=3;
    end
end
% goal
for i=1:5
    for j=1:10
        field(2+i,85+j)=4;
    end
end

%% 画栅格图
figure(1);
image(0.5,0.5,field);
grid on;
axis equal;
axis([0,cols,0,rows])
set(gca,'gridline','-','gridcolor','k','linewidth',0.1,'GridAlpha',1);  %设置栅格线条的样式（颜色、透明度等）
set(gca,'xtick',0:1:cols,'ytick',0:1:rows)

save('field.mat',"field")

%% 2.建立抽象栅格地图
%% 对障碍物进行膨胀处理
dilaterow=5;
dilatecol=3;
field1 = ones(rows, cols);
% 障碍物区域膨胀
% obstacle1
for i=1:4+2*dilatecol
    for j=1:10+2*dilaterow
        field1(3-dilatecol+i,20-dilaterow+j)=2;
    end
end
% obstacle2
for i=1:4+2*dilatecol
    for j=1:10+2*dilaterow
        field1(8-dilatecol+i,45-dilaterow+j)=2;
    end
end
% obstacle3
for i=1:4+2*dilatecol
    for j=1:10+2*dilaterow
        field1(3-dilatecol+i,70-dilaterow+j)=2;
    end
end
% start
field1(5,10)=3;
% goal
field1(5,90)=4;

%% 画栅格图
figure(2);
colormap(color_list);
image(0.5,0.5,field1);
grid on;
axis equal;
axis([0,cols,0,rows])
set(gca,'gridline','-','gridcolor','k','linewidth',0.1,'GridAlpha',1); 
set(gca,'xtick',0:1:cols,'ytick',0:1:rows)

save('field1.mat',"field1")



