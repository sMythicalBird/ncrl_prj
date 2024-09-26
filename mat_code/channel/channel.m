function rx_sig = channel(tx_sig, Ht, bas_par)
    a = 84;  % 放大系数
    txpower_dBm = bas_par.txpower_dBm + a;
    varNoise_dBm = bas_par.varNoise_dBm + a;
    noise_var = 10^(varNoise_dBm/10);
    % 根据功率求发送天线实际发送能量
    total_power = sum(abs(tx_sig).^2);
    tx_coefficient = 10^(txpower_dBm/10) * 1200 / bas_par.fs / total_power;
    tx_sig = tx_coefficient * tx_sig;

    Ht_tmp = squeeze(Ht);
    rx_tmp = conv(tx_sig, Ht_tmp);

    len = size(rx_tmp,1);
    noise = sqrt(noise_var/2) .* (randn(len,1) + 1j*randn(len,1));
    rx_sig = rx_tmp + noise;

%     rx_sig = tx_sig;
% rx_sig = rx_sig*15;

end

