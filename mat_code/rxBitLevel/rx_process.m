function result = rx_process(rx_data, payload_bits, pxsch)
   
    % 信道估计ls
    dmrs_sym_id = pxsch.dmrs_sym_id;  
    nz_dmrs_sc_set = pxsch.nz_dmrs_sc_set;
    dmrs_sym = dmrs_base_sequence(pxsch);
    beta = pxsch.beta;
%     dmrs_freq_spacing = pxsch.dmrs_freq_spacing;
    nof_sc = pxsch.nof_sc;
    rx_dmrs = rx_data(:,dmrs_sym_id);
    h_ls = (rx_dmrs(nz_dmrs_sc_set)/beta) ./ dmrs_sym;          % ls估计
%     TA = angle(sum(h_ls(1:end-1) .* conj(h_ls(2:end))));              % TA补偿(这里计算相邻两个dmrs_rs的相移值)
%     h_ls = h_ls .* exp(1j * TA / dmrs_freq_spacing * (nz_dmrs_sc_set - 1)');
    h_ls = kron(h_ls,ones(2,1));                                            % 简单插值，相邻两个sc共用一个估计值
%     h_ls = h_ls .* exp(-1j * TA / dmrs_freq_spacing * (0:nof_sc-1)');       % 加入保留的TA
   
    % 噪声方差估计，信噪比  噪声方差将用于后续计算
    [noise_var, snr_clt] = dmrs_sigma2_est(dmrs_sym, rx_dmrs, h_ls, pxsch);  
    

    % 估计数据信息
    sym_begin_id = pxsch.data_sym_begin_id;
    sym_end_id = pxsch.data_sym_end_id;
    nof_data_symb = sym_end_id - sym_begin_id + 1;
    data = rx_data(:, sym_begin_id:sym_end_id);     % 获取数据部分
    b = data;
    % MMSE估计数据
    for i = 1:nof_data_symb
        for sc = 1:nof_sc
            h_u = h_ls(sc);
            w = h_u' / (h_u * h_u' + noise_var);
            data(sc, i) = w * data(sc,i);
        end
%         data(:,i) = data(:,i) ./ h_ls;
    end
    


    % 软解调  
    modulation = pxsch.modulation_type;
    rnti = pxsch.rnti_set;
    n_id = pxsch.n_id_set;
    len_blk = pxsch.len_blk;
    rv = pxsch.rv_set;
    rate = pxsch.code_rate;
    nlayers = pxsch.nlayers;
    len_coded = pxsch.len_coded;
    crc_n = pxsch.crc_n;
    cbsInfo = ncrlCbsInfo(len_blk, len_blk/len_coded, crc_n);
%     ldpc_out = zeros(len_blk,nof_data_symb);
    blks_err = zeros(1,nof_data_symb);
    bits_err = zeros(1,nof_data_symb);
    noise_var = 1e-10;
%     noise_var = 1;
    for nd = 1:nof_data_symb
            % 解调制
            ncrl_demod = ncrlDemodulate(data(:,nd),modulation,noise_var);
            % 解扰
            ncrl_descram = nrPUSCHDescramble(ncrl_demod,n_id,rnti);
            % 速率恢复
            ncrl_raterec = ncrlRateRecoverLDPC(ncrl_demod,len_blk,rate,rv,modulation,nlayers,cbsInfo);
            % ldpc解码
            ncrl_decBits = ncrLDPCDecode(ncrl_raterec, cbsInfo.BGN, 25);
            blk = nrclCodeBlockDesegmentLDPC(ncrl_decBits,cbsInfo.BGN, len_blk + cbsInfo.L,cbsInfo);
            [ncrl_ldpc, ncrl_ldpc_err] = ncrlCRCDecode(blk,cbsInfo.CRC);
            bits_err(nd) = length(find(ncrl_ldpc ~= payload_bits(:,nd)));
            if bits_err(nd) ~= 0
                blks_err(nd) = 1;
            end
    end

    result.bit_err = sum(bits_err);
    result.blk_err = sum(blks_err);
end

