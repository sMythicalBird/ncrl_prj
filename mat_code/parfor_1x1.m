clear;
clc;

pxsch = pxsch_config();     % 配置pxsch信息


% 传输使用的毫米波信道
bas_par = initinalize_basic_param(pxsch);   % 配置信道


txPower = 5:15;
bits_err_percent = zeros(2, length(txPower));
blks_err_percent = zeros(2, length(txPower));
bits_err_percent(1,:) = txPower;
blks_err_percent(1,:) = txPower;

for idx = 1:length(txPower)
    bas_par.txpower_dBm = txPower(idx);     % 发送功率设置
    num_group = 1;
    numpar = 1000;
    num_bits_E = zeros(1,length(num_group));
    num_blks_E = zeros(1,length(num_group));
    for k = 1:num_group
        disp(['发送功率：' num2str(bas_par.txpower_dBm) '     第' num2str(k) '组'])
        tic
        bits_err = zeros(1,numpar);
        blks_err = zeros(1,numpar);
        Ht = mmW_channel(bas_par);
        parfor i = 1:numpar
            % 发送端处理
            [tx_data, payload_bits] = tx_process(pxsch,'dl');
            tx_sig  = tx_ofdm(tx_data, pxsch);
            
            rx_sig = channel(tx_sig, Ht, bas_par);
            
            % 接收端处理
            rx_data = rx_ofdm(rx_sig, pxsch);
            result = rx_process(rx_data, payload_bits, pxsch);
    
            bits_err(i) = result.bit_err;
            blks_err(i) = result.blk_err;
        end
        num_bits_E(k) = sum(bits_err);
        num_blks_E(k) = sum(blks_err);
        toc
    end
    bits_err_percent(2,idx) = sum(num_bits_E) / (k * numpar * 144 * 3);
    blks_err_percent(2,idx) = sum(num_blks_E) / (k * numpar * 3);

end

% semilogy(txPower,bits_err_percent(2,:),'-s',txPower,blks_err_percent(2,:),'-o');
semilogy(txPower,blks_err_percent(2,:),'-o');
grid on;
legend('BER','BLER');
xlabel('TxPower(dBm)');
ylabel('ERR');