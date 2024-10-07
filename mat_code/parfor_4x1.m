clear;
clc;

pdsch = pxsch_config();     % 配置pxsch信息
pusch = pxsch_config();     % 配置pxsch信息

% 传输使用的毫米波信道
bas_par = initinalize_basic_param_4x1(pdsch);   % 配置信道


txPower = 5:14;
n_group = [1,1,2,5,10,20,50,100,210,420];
% n_group = [1,1,1,2,3,3,3,3,3,3,3];
bits_err_percent = zeros(2, length(txPower));
blks_err_percent = zeros(2, length(txPower));
bits_err_percent(1,:) = txPower;
blks_err_percent(1,:) = txPower;

for idx = 1:length(txPower)
    bas_par.txpower_dBm = txPower(idx);     % 发送功率设置
    num_group = n_group(idx);
    numpar = 1000;
    num_bits_E = zeros(1,length(num_group));
    num_blks_E = zeros(1,length(num_group));
    for k = 1:num_group
        disp(['发送功率：' num2str(bas_par.txpower_dBm) '     第' num2str(k) '组'])
        tic
        bits_err = zeros(1,numpar);
        blks_err = zeros(1,numpar);
        Ht = mmW_channel(bas_par);  % 每组子帧生成一次毫米波信道
        parfor i = 1:numpar         % 多个子帧并行
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
            bits_err(i) = sum(bit_err);
            blks_err(i) = sum(blk_err);
        end
        num_bits_E(k) = sum(bits_err);
        num_blks_E(k) = sum(blks_err);
        toc
    end
    bits_err_percent(2,idx) = sum(num_bits_E) / (k * numpar * 136 * 3 * 8);
    blks_err_percent(2,idx) = sum(num_blks_E) / (k * numpar * 3 * 8);

end

semilogy(txPower,bits_err_percent(2,:),'-s',txPower,blks_err_percent(2,:),'-o');
% semilogy(txPower,blks_err_percent(2,:),'-o');
grid on;
legend('BER','BLER');
xlabel('TxPower(dBm)');
ylabel('ERR');