load('field1.mat');    % import the existed map
start_node = [5, 10];    % coordinate of the start node
dest_node  = [5, 90]; % coordinate of the destination node

[path, iteration_times] = Astar(field1, start_node, dest_node);

if(size(path,2) ~= 0)
    disp(['A* plan succeeded! ','iteration times: ',num2str(iteration_times), ' path length: ', num2str(size(path,2))]);
else
    disp('A* plan failed!');
end