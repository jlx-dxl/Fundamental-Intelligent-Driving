clc
clear
load('field1.mat');    % import the existed map
% map = zeros(100); % uncomment this line to replace map with a 100*100 zero matrix
start_node = [5, 10];    % coordinate of the start node
dest_node  = [5, 90]; % coordinate of the destination node
path = Dstar(field1, start_node, dest_node);
if(size(path,2) ~= 0)
   disp(['plan succeeded! ','iteration times: ',num2str(iteration_times), ' path length: ', num2str(size(path,2))]);
else
    disp('plan failed!');
end