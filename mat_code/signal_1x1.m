clear
clc

pdsch = pxsch_config();     % 配置pxsch信息
pusch = pxsch_config();     % 配置pxsch信息
% 传输使用的毫米波信道

bas_par = initinalize_basic_param(pdsch);   % 配置信道
Ht = mmW_channel(bas_par);


txPower = 10;
bas_par.txpower_dBm = txPower;     % 发送功率设置


[tx_data, payload_bits] = tx_process(pdsch, 'dl');
tx_sig  = tx_ofdm(tx_data, pdsch);

rx_sig = channel(tx_sig, Ht, bas_par);

rx_data = rx_ofdm(rx_sig, pdsch);
r_data = rx_data(:,2:4);


result = rx_process(rx_data, payload_bits, pdsch); 
disp(result)
