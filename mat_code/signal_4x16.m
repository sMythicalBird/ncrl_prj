clear
clc

% 4ap16ue    多组时分独立传输

pdsch = pxsch_config();     % 配置pxsch信息
pusch = pxsch_config();     % 配置pxsch信息
% 传输使用的毫米波信道

bas_par = initinalize_basic_param_1x4(pdsch);   % 配置信道
Ht = mmW_channel(bas_par);


txPower = 10;
bas_par.txpower_dBm = txPower;     % 发送功率设置
blk_err = zeros(1,8);
bit_err = zeros(1,8);

% 下行
for slot_idx = 1:4
    sidx = mod(slot_idx - 1, 4) + 1;
    % 发送端处理
    [tx_data, payload_bits] = tx_process(pdsch, 'dl');
    tx_sig  = tx_ofdm(tx_data, pdsch);
    % 过信道
    rx_sig = channel(tx_sig, Ht, bas_par);
    % 接收端处理
    rx_data = rx_ofdm(rx_sig, pdsch);
    result = rx_process(rx_data, payload_bits, pdsch);
    blk_err(slot_idx) = result.blk_err;
    bit_err(slot_idx) = result.bit_err;
end

% 上行
for slot_idx = 5:8
    sidx = mod(slot_idx - 1, 4) + 1;
    % 发送端处理
    [tx_data, payload_bits] = tx_process(pusch, 'ul');
    tx_sig  = tx_ofdm(tx_data, pusch);
    % 过信道
    rx_sig = channel(tx_sig, Ht, bas_par);
    % 接收端处理
    rx_data = rx_ofdm(rx_sig, pusch);
    result = rx_process(rx_data, payload_bits, pusch);
    blk_err(slot_idx) = result.blk_err;
    bit_err(slot_idx) = result.bit_err;
end


