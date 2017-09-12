function y = input_int(x,period)
x_period = reshape(x(2:end),period,[]);
y = x_period(1,:)';