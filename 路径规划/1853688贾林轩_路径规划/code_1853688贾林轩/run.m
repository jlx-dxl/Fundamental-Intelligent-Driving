clc
clear
close
load('field1.mat');    % import the existed map
field1=field1-1;
start_node = [5, 10];    % coordinate of the start node
dest_node  = [5, 90]; % coordinate of the destination node

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
rows = 15;  
cols = 100; 

h = figure();				
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');	
jFrame = get(h,'JavaFrame');	
pause(0.1);					
set(jFrame,'Maximized',1);	
pause(0.1);					
warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');		

subplot(2,2,1);
[path, iteration_times,map1] = Astar(field1, start_node, dest_node);

if(size(path,2) ~= 0)
    disp(['A* plan succeeded! ','iteration times: ',num2str(iteration_times), ' path length: ', num2str(size(path,2))]);
else
    disp('A* plan failed!');
end

load("field.mat");
[m,n]=find(map1==7);
path1=[m,n];
for i=1:length(path1)
    field(path1(i,1),path1(i,2))=7;
end

pause(0.25);

subplot(2,2,3);
colormap(color_list);
image(0.5,0.5,field);
grid on;
axis equal;
axis([0,cols,0,rows])
title('A*');
set(gca,'gridline','-','gridcolor','k','linewidth',0.1,'GridAlpha',1);  %设置栅格线条的样式（颜色、透明度等）
set(gca,'xtick',0:1:cols,'xticklabel',[],'ytick',0:1:rows,'yticklabel',[])
save('fieldAstar.mat',"field")

pause(0.5);

subplot(2,2,2);
[path, iteration_times,map2] = Dijkstra(field1, start_node, dest_node);

if(size(path,2) ~= 0)
    disp(['Dijkstra plan succeeded! ','iteration times: ',num2str(iteration_times), ' path length: ', num2str(size(path,2))]);
else
    disp('Dijkstra plan failed!');
end

load("field.mat");
[m,n]=find(map2==7);
path2=[m,n];
for i=1:length(path2)
    field(path2(i,1),path2(i,2))=7;
end

pause(0.25);

subplot(2,2,4);
colormap(color_list);
image(0.5,0.5,field);
grid on;
axis equal;
axis([0,cols,0,rows])
title('Dijkstra');
set(gca,'gridline','-','gridcolor','k','linewidth',0.1,'GridAlpha',1);  %设置栅格线条的样式（颜色、透明度等）
set(gca,'xtick',0:1:cols,'xticklabel',[],'ytick',0:1:rows,'yticklabel',[])
save('fieldDijkstra.mat',"field")
    
