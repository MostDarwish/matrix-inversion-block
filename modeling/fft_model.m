memory = zeros(16,1);
temp = zeros(16,1);
x = [-3;-2;-1;0;1;2;3;4;4;3;2;1;0;0;1;2];
W = [1;...
     0.9238795325  - 1i*0.3826834324;...
     0.7071067812  - 1i*0.7071067812;...
     0.3826834324  - 1i*0.9238795325;...
     0             - 1i             ;...
     -0.3826834324 - 1i*0.9238795325;...
     -0.7071067812 - 1i*0.7071067812;...
     -0.9238795325 - 1i*0.3826834324];
for i = 1:4
   
    if i == 1
       
        memory(1)  = x(1) + x(9) *W(1);
        memory(2)  = x(1) - x(9) *W(1);
        memory(3)  = x(5) + x(13)*W(1);
        memory(4)  = x(5) - x(13)*W(1);
        memory(5)  = x(3) + x(11)*W(1);
        memory(6)  = x(3) - x(11)*W(1);
        memory(7)  = x(7) + x(15)*W(1);
        memory(8)  = x(7) - x(15)*W(1);
        memory(9)  = x(2) + x(10)*W(1);
        memory(10) = x(2) - x(10)*W(1);
        memory(11) = x(6) + x(14)*W(1);
        memory(12) = x(6) - x(14)*W(1);
        memory(13) = x(4) + x(12)*W(1);
        memory(14) = x(4) - x(12)*W(1);
        memory(15) = x(8) + x(16)*W(1);
        memory(16) = x(8) - x(16)*W(1);
    elseif i == 2
            
        temp(1)  = memory(1)  + memory(3) *W(1);
        temp(3)  = memory(1)  - memory(3) *W(1);
        temp(2)  = memory(2)  + memory(4) *W(5);
        temp(4)  = memory(2)  - memory(4) *W(5);
        temp(5)  = memory(5)  + memory(7) *W(1);
        temp(7)  = memory(5)  - memory(7) *W(1);
        temp(6)  = memory(6)  + memory(8) *W(5);
        temp(8)  = memory(6)  - memory(8) *W(5);
        temp(9)  = memory(9)  + memory(11)*W(1);
        temp(11) = memory(9)  - memory(11)*W(1);
        temp(10) = memory(10) + memory(12)*W(5);
        temp(12) = memory(10) - memory(12)*W(5);
        temp(13) = memory(13) + memory(15)*W(1);
        temp(15) = memory(13) - memory(15)*W(1);
        temp(14) = memory(14) + memory(16)*W(5);
        temp(16) = memory(14) - memory(16)*W(5);
        memory = temp;
     elseif i == 3
            
        temp(1)  = memory(1)  + memory(5) *W(1);
        temp(5)  = memory(1)  - memory(5) *W(1);
        temp(2)  = memory(2)  + memory(6) *W(3);
        temp(6)  = memory(2)  - memory(6) *W(3);
        temp(3)  = memory(3)  + memory(7) *W(5);
        temp(7)  = memory(3)  - memory(7) *W(5);
        temp(4)  = memory(4)  + memory(8) *W(7);
        temp(8)  = memory(4)  - memory(8) *W(7);
        temp(9)  = memory(9)  + memory(13)*W(1);
        temp(13) = memory(9)  - memory(13)*W(1);
        temp(10) = memory(10) + memory(14)*W(3);
        temp(14) = memory(10) - memory(14)*W(3);
        temp(11) = memory(11) + memory(15)*W(5);
        temp(15) = memory(11) - memory(15)*W(5);
        temp(12) = memory(12) + memory(16)*W(7);
        temp(16) = memory(12) - memory(16)*W(7);
        memory = temp;
      elseif i == 4
            
        temp(1)  = memory(1)  + memory(9) *W(1);
        temp(9)  = memory(1)  - memory(9) *W(1);
        temp(2)  = memory(2)  + memory(10)*W(2);
        temp(10)  = memory(2)  - memory(10)*W(2);
        temp(3)  = memory(3)  + memory(11)*W(3);
        temp(11)  = memory(3)  - memory(11)*W(3);
        temp(4)  = memory(4)  + memory(12)*W(4);
        temp(12)  = memory(4)  - memory(12)*W(4);
        temp(5)  = memory(5)  + memory(13)*W(5);
        temp(13) = memory(5)  - memory(13)*W(5);
        temp(6) = memory(6)  + memory(14)*W(6);
        temp(14) = memory(6)  - memory(14)*W(6);
        temp(7) = memory(7)  + memory(15)*W(7);
        temp(15) = memory(7)  - memory(15)*W(7);
        temp(8) = memory(8)  + memory(16)*W(8);
        temp(16) = memory(8)  - memory(16)*W(8);
        memory = temp;
     end
    
end