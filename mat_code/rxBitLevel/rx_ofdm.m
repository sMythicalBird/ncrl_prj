function rx_data = rx_ofdm(rx_sig, pxsch)
    cp_len = pxsch.cp_len;
    nof_symbs = pxsch.nof_symbs;
    fft_size = pxsch.fft_size;
    data_carrier_set = pxsch.data_carrier_set;
    rx_data = zeros(length(data_carrier_set), nof_symbs);


    start_idx = 0;          % 假设定时无偏差
    for i = 1:nof_symbs
        % index of data in destination block
        dst_data_idx = start_idx + cp_len + (1:fft_size);
        % remove CP
        sig_t = rx_sig(dst_data_idx, :);
        sig_f = fft(sig_t, fft_size)/sqrt(fft_size);
        sig_f = fftshift(sig_f);
        rx_data(:, i) = sig_f(data_carrier_set);
        start_idx = start_idx + cp_len + fft_size;
    end
end

