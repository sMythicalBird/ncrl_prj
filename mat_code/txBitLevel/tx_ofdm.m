function [tx_sig]  = tx_ofdm(tx_data, pxsch)
    cp_len = pxsch.cp_len;
    nof_symbs = pxsch.nof_symbs;
    fft_size = pxsch.fft_size;
    tx_sig = zeros((fft_size + cp_len) * nof_symbs, 1);
    start_idx = 0;
    for i = 1:nof_symbs
        sig_f = ifftshift(tx_data(:,i));
        sig_t = ifft(sig_f, fft_size) * sqrt(fft_size);
        % index of CP in source block
        src_cp_idx = (fft_size - cp_len + 1):fft_size;
        % index of CP in destination block
        dst_cp_idx = start_idx+(1:cp_len);
        % index of data in destination block
        dst_data_idx = start_idx + cp_len + (1:fft_size);
        % add CP
        tx_sig(dst_cp_idx, :) = sig_t(src_cp_idx, :);
        % data block
        tx_sig(dst_data_idx, :) = sig_t;
        start_idx = start_idx + cp_len + fft_size;
    end
end

