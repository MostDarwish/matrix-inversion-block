%% input requirments
bit_number = 16;
fraction_bits = 12;
err_per = 3;
step_size = .1;
%% generating the all possible combinations of the 2 inputs
[x,y] = meshgrid(-2^(bit_number-1)*2^(-fraction_bits):step_size:(2^(bit_number-1)-1)*2^(-fraction_bits), -2^(bit_number-1)*2^(-fraction_bits):step_size:(2^(bit_number-1)-1)*2^(-fraction_bits));
x_int = INT(x*2^(fraction_bits),bit_number);
y_int = INT(y*2^(fraction_bits),bit_number);
mag = sqrt(x.^2 + y.^2);
theta_exact = atan2(y,x);
theta_int = INT(zeros(length(x),length(y)),bit_number);
a = INT(zeros(length(x),length(y)),bit_number);
d = INT(zeros(length(x),length(y)),bit_number);
flag = INT(zeros(length(x),length(y)),bit_number);
%% theta lookup table 16 value
theta_LUT = [0.7854;... 
             0.463647;...
             0.244978;...
             0.12435;...
             0.06242;...
             0.031239;...
             0.0156237;...
             0.00781;...
             0.0039;...
             0.00195;...
             0.000976;...
             0.000488;...
             0.000244;...
             0.000122;...
             0.000061;...
             0.0000305
             0;0;0;0;0;0];
theta_LUT = INT(theta_LUT*2^(fraction_bits),bit_number);
%% check if the X is negative or not for handling         
for i = 1:length(x)
    for j = 1:length(x)
        if(x(i,j)<0)
            x_int(i,j) = -x_int(i,j);
            flag(i,j) = 1;
        end
    end
end
%% take the sign of the y0 in case x is negative we will need it
for j = 1:length(x)
        for k = 1:length(x)
            if(y(j,k)>0) 
               d(j,k) = 1;
            else
               d(j,k) = -1;
            end
        end
end
%% main CORDIC stages        
for i = 1:12
    for j = 1:length(x)
        for k = 1:length(x)
            if(y_int(j,k)>0) 
               a(j,k) = 1;
            else
             a(j,k) = -1;
            end
        end
    end
   temp_x = x_int;
   x_int = x_int + a.*y_int*2^(-i+1);
   y_int = y_int - a.*temp_x*2^(-i+1);
   theta_int = theta_int + a.*theta_LUT(i);
end
x_int = int16((int32(x_int) * 2488)*2^(-fraction_bits));
x_int = double(x_int)*2^(-fraction_bits);
error = (mag - x_int)./mag.*100;
for i=1:length(flag)
    for j=1:length(flag)
        if(flag(i,j)==1)
            theta_int(i,j)=d(i,j).*(pi*2^(fraction_bits)-d(i,j).*theta_int(i,j));
        end
    end
end
 theta_rad = double(theta_int)*2^(-fraction_bits); 
 theta = theta_rad * 180 / pi;  
%% plotting the exact magnitude function %%
surf(x,y,mag);
xlabel("X");
ylabel("Y");
zlabel("exact_mag");
figure;
surf(x,y,x_int);
xlabel("X");
ylabel("Y");
zlabel("approx_mag");
%% plotting error function and limited by the desierd error %%
figure;
surf(x,y,error);
xlabel("X");
ylabel("Y");
zlabel("error");
zlim([-err_per err_per]);
%% get the corresponding x and y values that meet the error requirment %%
indices = error >= -err_per & error <= err_per;
x_filtered = x(indices);
y_filtered = y(indices);
figure;
scatter(x_filtered, y_filtered, 50, 'filled');
xlabel('X-axis');
ylabel('Y-axis');
title('Filtered Data Points');
%% plotting error in theta %%
theta_error = (theta_exact - theta_rad) ./ theta_exact *100;
figure;
surf(x,y,theta_error);
xlabel("X");
ylabel("Y");
zlabel("theta_error");