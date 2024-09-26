function [F_RF,W_RF] = design_analog_beam(bas_par,chl_par)
% Description:
%  This function generates ananlog beamforming matrices.
%
% Inputs:
%  bas_par   - basic parameters [struct]
%  chl_par   - channel parameters [struct]
%
% Outputs:
%  F_RF      - analog beamforming at th Tx [blkdiag(f_RF_1,...,f_RF_Mt)]
%  W_RF      - analog beamforming at th Rx [blkdiag(w_RF_1,...,w_RF_Mr)]


% *** initialize ***
F_RF = zeros(bas_par.nRxSubarray*bas_par.nAntSubarray,bas_par.nTxSubarray);
W_RF = zeros(bas_par.nTxSubarray*bas_par.nAntSubarray,bas_par.nRxSubarray);

% *** analog beamforming using phase shifters ***
for i_tx = 1:bas_par.nTxSubarray
    for i_rx = 1:bas_par.nRxSubarray
        % beamsteering based on LOS
        f_RF = arr_vec_upa(bas_par.nHoriAntOfSubarray,bas_par.nVertAntOfSubarray, ...
            chl_par.aod_hori(1,i_rx,i_tx),chl_par.aod_vert(1,i_rx,i_tx));
        w_RF = arr_vec_upa(bas_par.nHoriAntOfSubarray,bas_par.nVertAntOfSubarray, ...
            chl_par.aoa_hori(1,i_rx,i_tx),chl_par.aoa_vert(1,i_rx,i_tx));
        idx_tx_SA = (i_rx-1)*bas_par.nAntSubarray+1:i_rx*bas_par.nAntSubarray;
        idx_rx_SA = (i_tx-1)*bas_par.nAntSubarray+1:i_tx*bas_par.nAntSubarray;
        F_RF(idx_tx_SA,i_tx)  = f_RF;
        W_RF(idx_rx_SA,i_rx)  = w_RF;
    end
end
end % end_function