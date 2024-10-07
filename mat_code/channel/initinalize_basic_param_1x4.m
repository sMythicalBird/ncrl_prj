function bas_par = initinalize_basic_param_1x4(pxsch)
    bas_par.nVertAntOfSubarray  = 8; % num. of vertical antennas
    bas_par.nHoriAntOfSubarray  = 8; % num. of horizontal antennas
    bas_par.nAntSubarray        = bas_par.nVertAntOfSubarray*bas_par.nHoriAntOfSubarray; % num. of antennas deployed at each subarray
    
    bas_par.nTxVertSubarray     = 1; % num. of vertical subarrays
    bas_par.nTxHoriSubarray     = 1; % num. of horizontal subarrays
    bas_par.nTxSubarray         = bas_par.nTxVertSubarray*bas_par.nTxHoriSubarray; % num. of subarrays at the tx
    
    bas_par.nRxVertSubarray     = 1;
    bas_par.nRxHoriSubarray     = 4;
    bas_par.nRxSubarray         = bas_par.nRxVertSubarray*bas_par.nRxHoriSubarray; % num. of subarrays at the rx

    % *** system parameter ***
    bas_par.D                   = 50; % distance between tx and rx (deployed face to face) [m]
    bas_par.H                   = 2; % height from the ground [m]
    bas_par.fc                  = pxsch.center_frequency; % carrier frequency [Hz]
    bas_par.spdOfLight          = 3e8;
    bas_par.lambda_c            = bas_par.spdOfLight/bas_par.fc; % wavelength [m]
    bas_par.d_sub               = 200*bas_par.lambda_c; % distance between neighboring subarrays
    bas_par.d_ant               = 0.5*bas_par.lambda_c; % antenna spacing inside any subarray
    bas_par.nBitOfPS            = 8; % num. of quantized bits of phase shifters

    % *** ofdm parameter ***
    bas_par.Bw                  = 122.88e6; % system bandwidth [Hz]
    bas_par.df                  = 480e3; % subcarrier bandwith [Hz]
    bas_par.Nc                  = 256;  % num. of total subcarriers
    bas_par.Ncu                 = 160;  % num. of subcarriers with data
    bas_par.fs                  = bas_par.df*bas_par.Nc;          % sampling frequency, 
    bas_par.Ts                  = 1/bas_par.fs ; 
    bas_par.Bwc                 = bas_par.df*bas_par.Ncu;       % 有效带宽

    % *** scenario setup ***
    bas_par.txpower_dBm         = -24;    % transmitting power
    bas_par.antGain_dBi         = 16; % antenna gain
    bas_par.maxTxPow_dBm        = 30; % total transmitting power budget
    bas_par.noisePowDensity     = -174; % dBm/Hz
    bas_par.noiseFigure_dB      = 9; 
    bas_par.varNoise_dBm        = bas_par.noisePowDensity+10*log10(bas_par.Bwc)+bas_par.noiseFigure_dB;
    
    % *** ground reflection ***
    bas_par.coeff_dielectric    = 3.6478; % relative dielectric constant of concrete
    bas_par.loss_tangent        = 0.2053; % loss tangent of concrete
    bas_par.nPath               = 2; % number of paths including both LOS and NLOS

end

