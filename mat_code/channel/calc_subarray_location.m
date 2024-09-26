function [loca_par] = calc_subarray_location(bas_par)
% Description: 
%  This function calculates the locations of all tx-rx subarrays.
%
% Inputs:
%  bas_par    - a struct-type variable including all basic parameters
%
% Outputs:
%  loca_par - a struct-type variable including info. of subarray locations


% *** initialize ***
loca_par.tx_ref_point = zeros(bas_par.nTxSubarray,3);
loca_par.rx_ref_point = zeros(bas_par.nRxSubarray,3);

d_ref_row = bas_par.d_ant*(bas_par.nVertAntOfSubarray-1)+bas_par.d_sub;
d_ref_col = bas_par.d_ant*(bas_par.nHoriAntOfSubarray-1)+bas_par.d_sub;

% *** tx subarrays ***
for i_tx = 1:bas_par.nTxSubarray
    [tx_row,tx_col] = ind2sub([bas_par.nTxVertSubarray,bas_par.nTxHoriSubarray],i_tx);
	loca_par.tx_ref_point(i_tx,:) = [0,(tx_col-1)*d_ref_col,(tx_row-1)*d_ref_row];
end

% *** rx subarrays *** 
for i_rx = 1:bas_par.nRxSubarray
    [rx_row,rx_col] = ind2sub([bas_par.nRxVertSubarray,bas_par.nRxHoriSubarray],i_rx);
	loca_par.rx_ref_point(i_rx,:) = [bas_par.D,(rx_col-1)*d_ref_col,(rx_row-1)*d_ref_row];
end

end % end_function