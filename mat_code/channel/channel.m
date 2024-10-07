function rx_sig = channel(tx_sig, Ht, bas_par)
    a = 60;  % 放大系数
    txpower_dBm = bas_par.txpower_dBm + a;
    varNoise_dBm = bas_par.varNoise_dBm + a;
    noise_var = 10^(varNoise_dBm/10);
    % 根据功率求发送天线实际发送能量
    total_power = sum(abs(tx_sig).^2);
    tx_coefficient = 10^(txpower_dBm/10) * 1200 / bas_par.fs / total_power* bas_par.mul_ant_diversity;
    tx_sig = tx_coefficient * tx_sig;

    tx_idx = size(Ht,1);
    rx_idx = size(Ht,2);
    
    rx_sig = zeros(size(Ht,3)+size(tx_sig,1)-1,1);
    % 多天线收发子阵实现分集增益
    for i = 1:tx_idx
        for j = 1:rx_idx
            Ht_tmp = squeeze(Ht(i,j,:));
            rx_sig = rx_sig + conv(tx_sig, Ht_tmp);
        end
    end
    len = size(rx_sig,1);
    noise = sqrt(noise_var/2) .* (randn(len,1) + 1j*randn(len,1));
    rx_sig = rx_sig + noise;
end

