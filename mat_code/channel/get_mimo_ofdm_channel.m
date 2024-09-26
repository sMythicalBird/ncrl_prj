function Ht = get_mimo_ofdm_channel(bas_par,chl_par,F_RF,W_RF)
% Description:
%  This function generates the mimo channels in the time domain.
%
% Inputs:
%  bas_par   - basic parameters [struct]
%  chl_par   - channel parameters [struct]
%  F_RF      - analog beamforming at th Tx [blkdiag(f_RF_1,...,f_RF_Mt)]
%  W_RF      - analog beamforming at th Rx [blkdiag(w_RF_1,...,w_RF_Mr)]


% *** initialize ***
Ht        = zeros(bas_par.nRxSubarray,bas_par.nTxSubarray,bas_par.Nc); 
Hf_SA_eq  = zeros(bas_par.nRxSubarray,bas_par.nTxSubarray,bas_par.Nc);

% *** reconstruct frequency-domain channels ***
for i_tx = 1:bas_par.nTxSubarray 
    for i_rx = 1:bas_par.nRxSubarray
        % analog beamforming
        idx_tx_SA  = (i_rx-1)*bas_par.nAntSubarray+1:i_rx*bas_par.nAntSubarray;
        idx_rx_SA  = (i_tx-1)*bas_par.nAntSubarray+1:i_tx*bas_par.nAntSubarray;
        f_RF       = F_RF(idx_tx_SA,i_tx);
        w_RF       = W_RF(idx_rx_SA,i_rx);
        
        % LOS
        txAntGain_LOS = db2pow(bas_par.antGain_dBi);
        rxAntGain_LOS = db2pow(bas_par.antGain_dBi);
        
        at_LOS  = arr_vec_upa(bas_par.nHoriAntOfSubarray,bas_par.nVertAntOfSubarray, ...
            chl_par.aod_hori(1,i_rx,i_tx),chl_par.aod_vert(1,i_rx,i_tx));
        ar_LOS  = arr_vec_upa(bas_par.nHoriAntOfSubarray,bas_par.nVertAntOfSubarray, ...
            chl_par.aoa_hori(1,i_rx,i_tx),chl_par.aoa_vert(1,i_rx,i_tx));
        tau_LOS = chl_par.tau(1,i_rx,i_tx);
        % NLOS
        txAntGain_NLOS = db2pow(bas_par.antGain_dBi);
        rxAntGain_NLOS = db2pow(bas_par.antGain_dBi);
        at_NLOS  = arr_vec_upa(bas_par.nHoriAntOfSubarray,bas_par.nVertAntOfSubarray, ...
            chl_par.aod_hori(2,i_rx,i_tx),chl_par.aod_vert(2,i_rx,i_tx));
        ar_NLOS  = arr_vec_upa(bas_par.nHoriAntOfSubarray,bas_par.nVertAntOfSubarray, ...
            chl_par.aoa_hori(2,i_rx,i_tx),chl_par.aoa_vert(2,i_rx,i_tx));
        tau_NLOS = chl_par.tau(2,i_rx,i_tx);
        Hf_LOS_Sa = sqrt(txAntGain_LOS*rxAntGain_LOS)*chl_par.alpha(1,i_rx,i_tx) * (ar_LOS*at_LOS');
        Hf_NLOS_Sa = sqrt(txAntGain_NLOS*rxAntGain_NLOS)*chl_par.alpha(2,i_rx,i_tx) * (ar_NLOS*at_NLOS');

        % subcarriers
        for q = 1:bas_par.Nc
            f_sub = (q-1)*bas_par.df;   % subcarrier frequency           
            Hf_LOS_SA = Hf_LOS_Sa * exp(-1i*2*pi*f_sub*tau_LOS);
            Hf_NLOS_SA = Hf_NLOS_Sa * exp(-1i*2*pi*f_sub*tau_NLOS);
            % LOS+NLOS
            Hf_SA = Hf_LOS_SA+Hf_NLOS_SA;
            Hf_SA_eq(i_rx,i_tx,q) = w_RF'*Hf_SA*f_RF;
        end % end_for_q


        % *** get time-domain channels (freq. to time) ***
        Ht(i_rx,i_tx,:)  = ifft(Hf_SA_eq(i_rx,i_tx,:),bas_par.Nc);

    end % end_for_i_rx
    
end % end_for_i_tx

end % end_function