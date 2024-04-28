x = -3;
y = -5;
x_int = int8(x*2^3);
y_int = int8(y*2^3);
 theta = 0;
 flag = 0;
a = 0;
theta_LUT = [0.7854;...
             0.463647;...
             0.244978;...
             0.12435;...
             0.06242;...
             0.031239;...
             0.0156237;...
             0.00781
             ];
if (x_int<0)
    x_int = -x_int;
    flag = 1;
end
if (y_int<0)
    d=-1;
else
    d = 1;
end
for i = 1:8
    
   if(y_int>0)
       a=1;
   else
       a=-1;
   end
   temp_x = x_int;
   x_int = x_int + a*y_int*2^(-i+1);
   y_int = y_int - a*temp_x*2^(-i+1);
   theta = theta + a*theta_LUT(i);
end
% x = x*.60716;
% x_int = x_int*5;
  x_int = double(x_int)*2^(-3)*.60716;
 if(flag == 1)
     theta = d*(pi-d*theta);
 end
%  theta = theta * 180 / pi;     
% plot((mag-xvector)/mag*100);
% figure
% plot(y-y_int);