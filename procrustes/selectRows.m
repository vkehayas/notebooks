function [X, Y, Z] = selectRows(data, ind)
  
  X = data.x0(ind);
  Y = data.y0(ind);
  Z = data.z(ind);
  
end
