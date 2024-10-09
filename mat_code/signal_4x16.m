clear
clc

% 4ap16ue    多组时分独立传输

pdsch = pxsch_config();     % 配置pxsch信息
pusch = pxsch_config();     % 配置pxsch信息

% 传输使用的毫米波信道
bas_pars = init_param_4x16(pdsch);

blk_err = zeros(4,8);
bit_err = zeros(4,8);


for i_ap = 1:4      % ap索引
    bas_par = bas_pars(i_ap);   % 配置信道
    txPower = 10;
    bas_par.txpower_dBm = txPower;     % 发送功率设置
    Ht = mmW_channel(bas_par);
    % 不同时隙时分处理不同用户
    % 下行
    for slot_idx = 1:4
        i_ue = mod(slot_idx - 1, 4) + 1;
        % 发送端处理
        [tx_data, payload_bits] = tx_process(pdsch, 'dl');
        tx_sig  = tx_ofdm(tx_data, pdsch);
        % 过信道
        rx_sig = channel(tx_sig, Ht(i_ue,:,:), bas_par);    % 根据时隙情况选择对应的ue
        % 接收端处理
        rx_data = rx_ofdm(rx_sig, pdsch);
        result = rx_process(rx_data, payload_bits, pdsch);
        blk_err(i_ap, slot_idx) = result.blk_err;
        bit_err(i_ap, slot_idx) = result.bit_err;
    end
    
    % 上行
    for slot_idx = 5:8
        i_ue = mod(slot_idx - 1, 4) + 1;
        % 发送端处理
        [tx_data, payload_bits] = tx_process(pusch, 'ul');
        tx_sig  = tx_ofdm(tx_data, pusch);
        % 过信道
        rx_sig = channel(tx_sig, Ht(i_ue,:,:), bas_par);
        % 接收端处理
        rx_data = rx_ofdm(rx_sig, pusch);
        result = rx_process(rx_data, payload_bits, pusch);
        blk_err(i_ap, slot_idx) = result.blk_err;
        bit_err(i_ap, slot_idx) = result.bit_err;
    end
end







