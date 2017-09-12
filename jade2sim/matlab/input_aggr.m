function y = input_aggr(x,period)
x_period = reshape(x(2:end),period,[]);
y = sum(x_period,1)';