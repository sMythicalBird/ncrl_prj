function pxsch = pxsch_config()
    pxsch.center_frequency  = 25755.24e6;                                   % 中心频率
    pxsch.nof_symbs         = 4;                                           % 该模式的符号数(后面根据上行和下行情况分开设置)
    pxsch.nof_rb            = 20;                                           % 资源块数
    pxsch.sc_per_rb         = 8;                                           % 每个资源块上的资源单元个数
    pxsch.nof_sc            = pxsch.nof_rb * pxsch.sc_per_rb;               % 每个符号上的资源单元总数
    pxsch.nof_payload_re    = pxsch.nof_sc*pxsch.nof_symbs;                 % 总资源单元负载数
    pxsch.long_cp           = 544;                                          % 长cp
    pxsch.short_cp          = 288;                                          % 短cp
    pxsch.cp_len            = 44;                                  
    pxsch.subfre_space      = 480e3;                                        % 子载波间隔                        
    pxsch.fft_size          = 256;                                         % FFT长度                                  
    pxsch.sample_rate       = pxsch.subfre_space * pxsch.fft_size;          % 采样频率
    pxsch.data_carrier_set  = sys_carrier_set(pxsch);                       % 子载波的位置索引
    pxsch.code_rate         = 0.425;                                       % 码率
    pxsch.modulation_type   = 'QPSK';                                       % 调制方式  
    pxsch.nlayers           = 1;                                            % 传输层数
    pxsch.bits_per_qam      = 2;                                            % 每个符号的比特数
    pxsch.rv_set            = 0;                                            % 冗余度模式  
    pxsch.crc_n             = 24;
    pxsch.slot_idx_in_frame = 1;                                            % 当前时隙在帧中的索引



    
    % 配置用户id(加扰码)
    pxsch.rnti_set          = 1;                                            % UE临时标识符(这里只有一个ue，直接设为1，多个ue时可以生成随机值进行分配)
    cell_id_set             = 1;                                            % 小区标识符
    pxsch.n_id_set          = cell_id_set;
    % 设置 DMRS id
    scid=randi(100)-1;
    pxsch.nof_ue_group      = 1;
    pxsch.N_id_n_scid_set   = ones(pxsch.nof_ue_group, 1)*scid;
    pxsch.n_scid_set        = zeros(1, pxsch.nof_ue_group);  
    % 符号使用情况(sym1:dmmrs sym2-12:data)
    pxsch.dmrs_sym_id       = 1;
    pxsch.data_sym_begin_id = 2;
    pxsch.data_sym_end_id   = 4;
    pxsch.nz_dmrs_sc_set    = 1:2:pxsch.nof_sc;                             % dmrs索引
    pxsch.beta              = sqrt(2);                                      % 导频功率
    pxsch.dmrs_freq_spacing = 2;                                            % 间隔一个插导频


    pxsch.len_coded         = pxsch.nof_sc * pxsch.bits_per_qam;

    pxsch.tb_size           = fix(pxsch.nof_sc * pxsch.code_rate * pxsch.bits_per_qam /8);
    pxsch.len_blk           = pxsch.tb_size * 8;                            % 块长
%     pxsch.cbsInfo           = nrDLSCHInfo(pxsch.len_blk, pxsch.len_blk/pxsch.len_coded);        % 获取编码信息

    
    % 天线数
    pxsch.nof_tx_ant        = 1;
    pxsch.nof_rx_ant        = 1;
    

    % Doppler frequency
    v                       = 3;                                            % UE velocity in km/h
    fc                      = 3.19488e9;                                    % carrier frequency in Hz
    c                       = physconst('lightspeed');                      % speed of light in m/s
    pxsch.fd                = (v*1000/3600)/c*fc;                           % UE max Doppler frequency in Hz
    pxsch.DelaySpread       = 30e-9;
end

