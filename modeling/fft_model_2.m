memory_real = zeros(16,1);
memory_imag = zeros(16,1);
temp_real = zeros(16,1);
temp_imag = zeros(16,1);
X = [-3;-2;-1;0;1;2;3;4;4;3;2;1;0;0;1;2];
W_real = [1            ;...
          0.9238795325 ; ...
          0.7071067812 ; ...
          0.3826834324 ; ...
          0            ; ...
          -0.3826834324; ...
          -0.7071067812; ...
          -0.9238795325 ];
W_imag = [ 0           ;...
          -0.3826834324;...
          -0.7071067812;...
          -0.9238795325;...
          -1           ;...
          -0.9238795325;...
          -0.7071067812;...
          -0.3826834324];
w_real = int16(W_real*2^8);
w_imag = int16(W_imag*2^8);
x = int16(X*2^8);
for i = 1:4
   
    if i == 1
       
        memory_real(1)  = x(1) + x(9) ;
        memory_real(2)  = x(1) - x(9) ;
        memory_real(3)  = x(5) + x(13);
        memory_real(4)  = x(5) - x(13);
        memory_real(5)  = x(3) + x(11);
        memory_real(6)  = x(3) - x(11);
        memory_real(7)  = x(7) + x(15);
        memory_real(8)  = x(7) - x(15);
        memory_real(9)  = x(2) + x(10);
        memory_real(10) = x(2) - x(10);
        memory_real(11) = x(6) + x(14);
        memory_real(12) = x(6) - x(14);
        memory_real(13) = x(4) + x(12);
        memory_real(14) = x(4) - x(12);
        memory_real(15) = x(8) + x(16);
        memory_real(16) = x(8) - x(16);

    elseif i == 2
            
        temp_real(1)  = memory_real(1)  + ( memory_real(3) *w_real(1) - memory_imag(3) *w_imag(1) );
        temp_real(3)  = memory_real(1)  - ( memory_real(3) *w_real(1) - memory_imag(3) *w_imag(1) );
        temp_real(2)  = memory_real(2)  + ( memory_real(4) *w_real(5) - memory_imag(4) *w_imag(5) );
        temp_real(4)  = memory_real(2)  - ( memory_real(4) *w_real(5) - memory_imag(4) *w_imag(5) );
        temp_real(5)  = memory_real(5)  + ( memory_real(7) *w_real(1) - memory_imag(7) *w_imag(1) );
        temp_real(7)  = memory_real(5)  - ( memory_real(7) *w_real(1) - memory_imag(7) *w_imag(1) );
        temp_real(6)  = memory_real(6)  + ( memory_real(8) *w_real(5) - memory_imag(8) *w_imag(5) );
        temp_real(8)  = memory_real(6)  - ( memory_real(8) *w_real(5) - memory_imag(8) *w_imag(5) );
        temp_real(9)  = memory_real(9)  + ( memory_real(11)*w_real(1) - memory_imag(11)*w_imag(1) );
        temp_real(11) = memory_real(9)  - ( memory_real(11)*w_real(1) - memory_imag(11)*w_imag(1) );
        temp_real(10) = memory_real(10) + ( memory_real(12)*w_real(5) - memory_imag(12)*w_imag(5) );
        temp_real(12) = memory_real(10) - ( memory_real(12)*w_real(5) - memory_imag(12)*w_imag(5) );
        temp_real(13) = memory_real(13) + ( memory_real(15)*w_real(1) - memory_imag(15)*w_imag(1) );
        temp_real(15) = memory_real(13) - ( memory_real(15)*w_real(1) - memory_imag(15)*w_imag(1) );
        temp_real(14) = memory_real(14) + ( memory_real(16)*w_real(5) - memory_imag(16)*w_imag(5) );
        temp_real(16) = memory_real(14) - ( memory_real(16)*w_real(5) - memory_imag(16)*w_imag(5) );
        
        temp_imag(1)  = memory_imag(1)  + ( memory_imag(3)*w_real(1)  + memory_real(3) *w_imag(1) );
        temp_imag(3)  = memory_imag(1)  - ( memory_imag(3)*w_real(1)  + memory_real(3) *w_imag(1) );
        temp_imag(2)  = memory_imag(2)  + ( memory_imag(4)*w_real(5)  + memory_real(4) *w_imag(5) );
        temp_imag(4)  = memory_imag(2)  - ( memory_imag(4)*w_real(5)  + memory_real(4) *w_imag(5) );
        temp_imag(5)  = memory_imag(5)  + ( memory_imag(7)*w_real(1)  + memory_real(7) *w_imag(1) );
        temp_imag(7)  = memory_imag(5)  - ( memory_imag(7)*w_real(1)  + memory_real(7) *w_imag(1) );
        temp_imag(6)  = memory_imag(6)  + ( memory_imag(8)*w_real(5)  + memory_real(8) *w_imag(5) );
        temp_imag(8)  = memory_imag(6)  - ( memory_imag(8)*w_real(5)  + memory_real(8) *w_imag(5) );
        temp_imag(9)  = memory_imag(9)  + ( memory_imag(11)*w_real(1) + memory_real(11)*w_imag(1) );
        temp_imag(11) = memory_imag(9)  - ( memory_imag(11)*w_real(1) + memory_real(11)*w_imag(1) );
        temp_imag(10) = memory_imag(10) + ( memory_imag(12)*w_real(5) + memory_real(12)*w_imag(5) );
        temp_imag(12) = memory_imag(10) - ( memory_imag(12)*w_real(5) + memory_real(12)*w_imag(5) );
        temp_imag(13) = memory_imag(13) + ( memory_imag(15)*w_real(1) + memory_real(15)*w_imag(1) );
        temp_imag(15) = memory_imag(13) - ( memory_imag(15)*w_real(1) + memory_real(15)*w_imag(1) );
        temp_imag(14) = memory_imag(14) + ( memory_imag(16)*w_real(5) + memory_real(16)*w_imag(5) );
        temp_imag(16) = memory_imag(14) - ( memory_imag(16)*w_real(5) + memory_real(16)*w_imag(5) );

        memory_real = temp_real;
        memory_imag = temp_imag;
     elseif i == 3
   
        temp_real(1)  = memory_real(1)  + ( memory_real(5) *w_real(1) - memory_imag(5) *w_imag(1) );
        temp_real(5)  = memory_real(1)  - ( memory_real(5) *w_real(1) - memory_imag(5) *w_imag(1) );
        temp_real(2)  = memory_real(2)  + ( memory_real(6) *w_real(3) - memory_imag(6) *w_imag(3) );
        temp_real(6)  = memory_real(2)  - ( memory_real(6) *w_real(3) - memory_imag(6) *w_imag(3) );
        temp_real(3)  = memory_real(3)  + ( memory_real(7) *w_real(5) - memory_imag(7) *w_imag(5) );
        temp_real(7)  = memory_real(3)  - ( memory_real(7) *w_real(5) - memory_imag(7) *w_imag(5) );
        temp_real(4)  = memory_real(4)  + ( memory_real(8) *w_real(7) - memory_imag(8) *w_imag(7) );
        temp_real(8)  = memory_real(4)  - ( memory_real(8) *w_real(7) - memory_imag(8) *w_imag(7) );
        temp_real(9)  = memory_real(9)  + ( memory_real(13)*w_real(1) - memory_imag(13)*w_imag(1) );
        temp_real(13) = memory_real(9)  - ( memory_real(13)*w_real(1) - memory_imag(13)*w_imag(1) );
        temp_real(10) = memory_real(10) + ( memory_real(14)*w_real(3) - memory_imag(14)*w_imag(3) );
        temp_real(14) = memory_real(10) - ( memory_real(14)*w_real(3) - memory_imag(14)*w_imag(3) );
        temp_real(11) = memory_real(11) + ( memory_real(15)*w_real(5) - memory_imag(15)*w_imag(5) );
        temp_real(15) = memory_real(11) - ( memory_real(15)*w_real(5) - memory_imag(15)*w_imag(5) );
        temp_real(12) = memory_real(12) + ( memory_real(16)*w_real(7) - memory_imag(16)*w_imag(7) );
        temp_real(16) = memory_real(12) - ( memory_real(16)*w_real(7) - memory_imag(16)*w_imag(7) );
        
        temp_imag(1)  = memory_imag(1)  + ( memory_imag(5) *w_real(1) + memory_real(5) *w_imag(1) );
        temp_imag(5)  = memory_imag(1)  - ( memory_imag(5) *w_real(1) + memory_real(5) *w_imag(1) );
        temp_imag(2)  = memory_imag(2)  + ( memory_imag(6) *w_real(3) + memory_real(6) *w_imag(3) );
        temp_imag(6)  = memory_imag(2)  - ( memory_imag(6) *w_real(3) + memory_real(6) *w_imag(3) );
        temp_imag(3)  = memory_imag(3)  + ( memory_imag(7) *w_real(5) + memory_real(7) *w_imag(5) );
        temp_imag(7)  = memory_imag(3)  - ( memory_imag(7) *w_real(5) + memory_real(7) *w_imag(5) );
        temp_imag(4)  = memory_imag(4)  + ( memory_imag(8) *w_real(7) + memory_real(8) *w_imag(7) );
        temp_imag(8)  = memory_imag(4)  - ( memory_imag(8) *w_real(7) + memory_real(8) *w_imag(7) );
        temp_imag(9)  = memory_imag(9)  + ( memory_imag(13)*w_real(1) + memory_real(13)*w_imag(1) );
        temp_imag(13) = memory_imag(9)  - ( memory_imag(13)*w_real(1) + memory_real(13)*w_imag(1) );
        temp_imag(10) = memory_imag(10) + ( memory_imag(14)*w_real(3) + memory_real(14)*w_imag(3) );
        temp_imag(14) = memory_imag(10) - ( memory_imag(14)*w_real(3) + memory_real(14)*w_imag(3) );
        temp_imag(11) = memory_imag(11) + ( memory_imag(15)*w_real(5) + memory_real(15)*w_imag(5) );
        temp_imag(15) = memory_imag(11) - ( memory_imag(15)*w_real(5) + memory_real(15)*w_imag(5) );
        temp_imag(12) = memory_imag(12) + ( memory_imag(16)*w_real(7) + memory_real(16)*w_imag(7) );
        temp_imag(16) = memory_imag(12) - ( memory_imag(16)*w_real(7) + memory_real(16)*w_imag(7) );

        memory_real = temp_real;
        memory_imag = temp_imag;
      elseif i == 4
        
        temp_real(1)  = memory_real(1) + ( memory_real(9) *w_real(1) - memory_imag(9) *w_imag(1) );
        temp_real(9)  = memory_real(1) - ( memory_real(9) *w_real(1) - memory_imag(9) *w_imag(1) );
        temp_real(2)  = memory_real(2) + ( memory_real(10)*w_real(2) - memory_imag(10)*w_imag(2) );
        temp_real(10) = memory_real(2) - ( memory_real(10)*w_real(2) - memory_imag(10)*w_imag(2) );
        temp_real(3)  = memory_real(3) + ( memory_real(11)*w_real(3) - memory_imag(11)*w_imag(3) );
        temp_real(11) = memory_real(3) - ( memory_real(11)*w_real(3) - memory_imag(11)*w_imag(3) );
        temp_real(4)  = memory_real(4) + ( memory_real(12)*w_real(4) - memory_imag(12)*w_imag(4) );
        temp_real(12) = memory_real(4) - ( memory_real(12)*w_real(4) - memory_imag(12)*w_imag(4) );
        temp_real(5)  = memory_real(5) + ( memory_real(13)*w_real(5) - memory_imag(13)*w_imag(5) );
        temp_real(13) = memory_real(5) - ( memory_real(13)*w_real(5) - memory_imag(13)*w_imag(5) );
        temp_real(6)  = memory_real(6) + ( memory_real(14)*w_real(6) - memory_imag(14)*w_imag(6) );
        temp_real(14) = memory_real(6) - ( memory_real(14)*w_real(6) - memory_imag(14)*w_imag(6) );
        temp_real(7)  = memory_real(7) + ( memory_real(15)*w_real(7) - memory_imag(15)*w_imag(7) );
        temp_real(15) = memory_real(7) - ( memory_real(15)*w_real(7) - memory_imag(15)*w_imag(7) );
        temp_real(8)  = memory_real(8) + ( memory_real(16)*w_real(8) - memory_imag(16)*w_imag(8) );
        temp_real(16) = memory_real(8) - ( memory_real(16)*w_real(8) - memory_imag(16)*w_imag(8) );
        
        temp_imag(1)   = memory_imag(1) + ( memory_imag(9) *w_real(1) + memory_real(9) *w_imag(1) );
        temp_imag(9)   = memory_imag(1) - ( memory_imag(9) *w_real(1) + memory_real(9) *w_imag(1) );
        temp_imag(2)   = memory_imag(2) + ( memory_imag(10)*w_real(2) + memory_real(10)*w_imag(2) );
        temp_imag(10)  = memory_imag(2) - ( memory_imag(10)*w_real(2) + memory_real(10)*w_imag(2) );
        temp_imag(3)   = memory_imag(3) + ( memory_imag(11)*w_real(3) + memory_real(11)*w_imag(3) );
        temp_imag(11)  = memory_imag(3) - ( memory_imag(11)*w_real(3) + memory_real(11)*w_imag(3) );
        temp_imag(4)   = memory_imag(4) + ( memory_imag(12)*w_real(4) + memory_real(12)*w_imag(4) );
        temp_imag(12)  = memory_imag(4) - ( memory_imag(12)*w_real(4) + memory_real(12)*w_imag(4) );
        temp_imag(5)   = memory_imag(5) + ( memory_imag(13)*w_real(5) + memory_real(13)*w_imag(5) );
        temp_imag(13)  = memory_imag(5) - ( memory_imag(13)*w_real(5) + memory_real(13)*w_imag(5) );
        temp_imag(6)   = memory_imag(6) + ( memory_imag(14)*w_real(6) + memory_real(14)*w_imag(6) );
        temp_imag(14)  = memory_imag(6) - ( memory_imag(14)*w_real(6) + memory_real(14)*w_imag(6) );
        temp_imag(7)   = memory_imag(7) + ( memory_imag(15)*w_real(7) + memory_real(15)*w_imag(7) );
        temp_imag(15)  = memory_imag(7) - ( memory_imag(15)*w_real(7) + memory_real(15)*w_imag(7) );
        temp_imag(8)   = memory_imag(8) + ( memory_imag(16)*w_real(8) + memory_real(16)*w_imag(8) );
        temp_imag(16)  = memory_imag(8) - ( memory_imag(16)*w_real(8) + memory_real(16)*w_imag(8) );

        memory_real = temp_real;
        memory_imag = temp_imag;
    end  
end
