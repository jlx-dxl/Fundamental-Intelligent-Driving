load('Map.mat');    % import the existed map
% map = zeros(100); % uncomment this line to replace map with a 100*100 zero matrix
start_node = [1, 1];    % coordinate of the start node
dest_node  = [12, 18]; % coordinate of the destination node
path = Dstar(map, start_node, dest_node);
if(size(path,2) ~= 0)
    display('plan succeeded!');
else
    display('plan failed!');
end