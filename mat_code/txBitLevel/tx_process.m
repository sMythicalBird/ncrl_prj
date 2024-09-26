function [tx_data, payload_bits, t_data] = tx_process(pxsch ,type)
    % blks:传输块的数量
    % nof_sc:资源负载
    % len_blk:块长
    % nof_symbs:总符号数
    % tx_data:经过比特级处理后的数据。  维度：fft_size * nof_symbs
    % payload_bits: 发送端的原始数据。  维度：len_blk * blks
        nof_symbs = pxsch.nof_symbs;
    
    fft_size = pxsch.fft_size;
    tx_data = zeros(fft_size, nof_symbs);
    data_carrier_set = pxsch.data_carrier_set;


    % 生成dmrs
    dmrs_sym_id = pxsch.dmrs_sym_id;
    dmrs_sym = dmrs_base_sequence(pxsch);
    nz_dmrs_sc_set = pxsch.nz_dmrs_sc_set;
    beta = pxsch.beta;
    tx_data(data_carrier_set(nz_dmrs_sc_set),dmrs_sym_id) = dmrs_sym * beta;

    % 生成传输数据,在发送端进行处理
    

    len_blk = pxsch.len_blk;
    len_coded = pxsch.len_coded;      % 编码长度
    sym_begin_id = pxsch.data_sym_begin_id;
    sym_end_id = pxsch.data_sym_end_id;
    blks = sym_end_id - sym_begin_id + 1;     % 需要生成的传输块数量
    payload_bits = randi(2, len_blk, blks) - 1;                   % 生成blks个传输块
    if type == 'ul'
        payload_bits(:, blks) = 1;
    end
    n_id_set = pxsch.n_id_set;
    rnti = pxsch.rnti_set;
    c_init = rnti * 32768 + n_id_set;
    rv = pxsch.rv_set;
    nlayers = pxsch.nlayers;
    modulation = pxsch.modulation_type;
    crc_n = pxsch.crc_n;
    cbsInfo = ncrlCbsInfo(len_blk, len_blk/len_coded, crc_n);
    data_idx = sym_begin_id;
    t_data = zeros(160,3);
    for i = 1:blks
        data = payload_bits(:,i);
        % CRC
        ncrl_data_crc = ncrlCRCEncode(data,cbsInfo.CRC);
        % code blocks
        ncrlcbsIn = ncrlCodeBlockSegmentLDPC(ncrl_data_crc,cbsInfo.BGN);
        % LDPC encoding
        ncrl_ldpc = ncrlLDPCEncode(ncrlcbsIn,cbsInfo.BGN);
        % rate matching of LDPC
        ncrl_rm = ncrlRateMatchLDPC(ncrl_ldpc, len_coded, rv, modulation, nlayers,cbsInfo.BGN);
        % 加扰
        payload_scramble = scrambling(ncrl_rm, length(ncrl_rm), c_init);
        data_sym = ncrlModulate(payload_scramble,modulation);
        t_data(:,i) = data_sym;
        tx_data(data_carrier_set,data_idx) = data_sym;
        data_idx = data_idx + 1;
    end
end



