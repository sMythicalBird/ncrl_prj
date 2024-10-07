function Ht = mmW_channel(bas_par)    
    %% generate channel
    % *** calculate locations of subarrays ***
    [loca_par] = calc_subarray_location(bas_par);
        
    % *** generate channel parameters ***
    [chl_par] = gen_channel_param(bas_par,loca_par);
        
    % *** design analog beamfoming ***
    [F_RF,W_RF] = design_analog_beam(bas_par,chl_par);
        
    % *** get equivalent channels in the time domain ***
    Ht = get_mimo_ofdm_channel(bas_par,chl_par,F_RF,W_RF);
end

