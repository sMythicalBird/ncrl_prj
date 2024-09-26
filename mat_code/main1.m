% clear
% clc
% a = randi(2, 144, 1)-1;
pdsch = pxsch_config();     % 配置pxsch信息
pusch = pxsch_config();     % 配置pxsch信息
% 传输使用的毫米波信道
channel_from_file_flag = 1;
bas_par = initinalize_basic_param(pdsch);   % 配置信道
Ht = mmW_channel(bas_par, channel_from_file_flag);


txPower = -15.5;
bas_par.txpower_dBm = txPower;     % 发送功率设置


[tx_data, payload_bits, t_data] = tx_process(pdsch, 'dl',a,b);
tx_sig  = tx_ofdm(tx_data, pdsch);

rx_data = rx_ofdm(tx_sig, pdsch);
r_data = rx_data(:,2:4);
sum(sum(abs(r_data - t_data)))
result = rx_process(rx_data, payload_bits, pdsch); 
disp(result)