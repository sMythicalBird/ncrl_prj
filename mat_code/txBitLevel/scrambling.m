function output_data = scrambling(input_data, len, c_init)
    
    nc = 1600;
    max_len = len + 31;

    x1 = zeros(nc+max_len, 1);
    x1(1)=1;
    
    x2 = zeros(nc+max_len, 1);
    x2_bin = bin_state(c_init, 31);
    x2(1:31) = x2_bin(end:-1:1);
    
    for n = 1:(nc+len)
        
        x1(n+31) = mod(x1(n+3) + x1(n),2);               
        
        x2(n+31) = mod(x2(n + 3) + x2(n + 2) + x2(n+1) + x2(n), 2);
        
    end
    
    %%  Generate pseudo-random sequence c(n)
    c = mod(x1(nc+(1:len)) + x2(nc+(1:len)), 2);
    
    % Scrambling
    output_data = xor(c, input_data);

end

