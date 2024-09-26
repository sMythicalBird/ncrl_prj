function [noi_var, snr_clt] = dmrs_sigma2_est(dmrs_sym, rx_dmrs, h_ls, pxsch)
   
    beta_ru = pxsch.beta;     
    Xi = dmrs_sym.*beta_ru;         % 发送端发送值
    Y_dmrs = rx_dmrs;               % 实际接收值

    dmrs_sc_set = pxsch.nz_dmrs_sc_set;
    Hi = h_ls(dmrs_sc_set);
    sig_pow_tmp = Hi.*Xi;           % 信号通过信道的无噪声理想值

    % 信号平均功率
    sig_pow_clat = mean(abs(sig_pow_tmp).*abs(sig_pow_tmp),"all");      % 平均功率
    
    % Y_dmrs(=Y-HX): dmrs_sc*dmrs_symb
    Y_dmrs(dmrs_sc_set) = Y_dmrs(dmrs_sc_set) - sig_pow_tmp;            % 实际接收值与估计值之间的差——噪声值
            
    % 噪声方差
    noi_var = mean(abs(Y_dmrs).*abs(Y_dmrs),"all");    % 计算误差方差

    % 接收信噪比
    snr_clt = 10*log10(sig_pow_clat/noi_var);              
end

