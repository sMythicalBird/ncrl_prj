function data_carrier_set = sys_carrier_set(pxsch)
    nof_sc = pxsch.nof_sc;                        % 最大资源块数
    fft_size = pxsch.fft_size;
    base_id = (fft_size - nof_sc)/2;
    data_carrier_set = (1:nof_sc)' + base_id;
end

