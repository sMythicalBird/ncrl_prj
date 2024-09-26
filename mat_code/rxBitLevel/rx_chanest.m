function rx_data = rx_chanest(rx_sig, pxsch)

    cp_len = pxsch.cp_len;
    nof_symbs = pxsch.nof_symbs;
    fft_size = pxsch.fft_size;
    data_carrier_set = pxsch.data_carrier_set;
    rx_data = zeros(length(data_carrier_set), nof_symbs);
    dmrs_freq_spacing = pxsch.dmrs_freq_spacing;
    dmrs_sym_id = pxsch.dmrs_sym_id;
    nz_dmrs_sc_set = pxsch.nz_dmrs_sc_set;
    dmrs_sym = dmrs_base_sequence(pxsch);
    start_idx = 0;
    beta = pxsch.beta;

    dst_data_idx = start_idx + cp_len + (dmrs_sym_id - 1) * fft_size + (1:fft_size);
    % remove CP
    sig_t = rx_sig(dst_data_idx, :);
    sig_f = fft(sig_t, fft_size)/sqrt(fft_size);
    sig_f = fftshift(sig_f);
    rx_dmrs = sig_f(data_carrier_set);

    h_ls = (rx_dmrs(nz_dmrs_sc_set)/beta) ./ dmrs_sym;          % ls估计
    TAe = angle(sum(h_ls(1:end-1) .* conj(h_ls(2:end))));              % TA补偿(这里计算相邻两个dmrs_rs的相移值)
    STO = TAe * fft_size / 2 / pi / dmrs_freq_spacing;
%     start_idx = start_idx + round(STO);





    start_idx = round(STO);          % 假设定时无偏差
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








%     h_ls = h_ls .* exp(1j * TAe / dmrs_freq_spacing * (nz_dmrs_sc_set - 1)');
%     h_ls = kron(h_ls,ones(2,1));                                            % 简单插值，相邻两个sc共用一个估计值
%     h_ls = h_ls .* exp(-1j * TAe / dmrs_freq_spacing * (0:nof_sc-1)');       % 加入保留的TA
%     % 噪声方差估计，信噪比
%     [noise_var, snr_clt] = dmrs_sigma2_est(dmrs_sym, rx_dmrs, h_ls, pxsch);  
% 
%     for i = (dmrs_sym_id + 1):nof_symbs
%         % index of data in destination block
%         dst_data_idx = start_idx + cp_len + (1:fft_size);
%         % remove CP
%         sig_t = rx_sig(dst_data_idx, :);
%         sig_f = fft(sig_t, fft_size)/sqrt(fft_size);
%         sig_f = fftshift(sig_f);
%         rx_data(:, i) = sig_f(data_carrier_set);
%         start_idx = start_idx + cp_len + fft_size;
%     end


end

