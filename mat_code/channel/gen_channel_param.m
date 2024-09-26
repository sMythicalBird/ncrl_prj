function [chl_par] = gen_channel_param(bas_par,loca_par)
% Description:
%  This function generates the channel parameters among tx-rx subarrays.
%  (ground reflection two-ray model)
%
% Inputs:
%  bas_par    - basic parameters [struct]
%  loca_par   - location parameters [struct]
%
% Outputs:
%  chl_par    - channel parameters [struct]
% References:
%  [1] T. S. Rappaport, "Wireless Communications: Principles and Practice, ...
%      2nd Edition," Prentice Hall, 2001.


% *** initialize ***
chl_par.alpha     = zeros(bas_par.nPath,bas_par.nRxSubarray,bas_par.nTxSubarray); % fading coefficient
chl_par.tau       = zeros(bas_par.nPath,bas_par.nRxSubarray,bas_par.nTxSubarray); % delay
chl_par.aoa_vert  = zeros(bas_par.nPath,bas_par.nRxSubarray,bas_par.nTxSubarray); % vertical angle of arrival (aoa)
chl_par.aoa_hori  = zeros(bas_par.nPath,bas_par.nRxSubarray,bas_par.nTxSubarray); % horizontal aoa
chl_par.aod_vert  = zeros(bas_par.nPath,bas_par.nRxSubarray,bas_par.nTxSubarray); % vertical angle of departure (aod)
chl_par.aod_hori  = zeros(bas_par.nPath,bas_par.nRxSubarray,bas_par.nTxSubarray); % horizontal aod
chl_par.PhaseMat  = zeros(bas_par.nPath,bas_par.nRxSubarray,bas_par.nTxSubarray); % phase shift matrix

% *** ground reflection point ***
reflect_point = [rand*bas_par.D,0,-bas_par.H];

% *** define functions ***
dist2pt           = @(StartPoint,EndPoint) norm(EndPoint-StartPoint);
dist3pt           = @(StartPoint,MidPoint,EndPoint) dist2pt(StartPoint,MidPoint)+dist2pt(MidPoint,EndPoint);
calc_vert_angle   = @(direct_vec) acos(dot(direct_vec,[0,0,1])/norm(direct_vec));
calc_hori_angle   = @(direct_vec) asin(dot(direct_vec(1:2)/norm(direct_vec(1:2)),[0,1]));
integerize_delay  = @(real_time,sample_time) floor(real_time/sample_time)*sample_time;

% *** generate aoa, aod and delays ***
for i_tx = 1:bas_par.nTxSubarray
    
    for i_rx = 1:bas_par.nRxSubarray
        
        % *** LOS path ***
        dist_los = dist2pt(loca_par.tx_ref_point(i_tx,:),loca_par.rx_ref_point(i_rx,:));
        chl_par.tau(1,i_rx,i_tx)       = integerize_delay(dist_los/bas_par.spdOfLight,bas_par.Ts);
        chl_par.PhaseMat(1,i_rx,i_tx)  = exp(1i*2*pi/bas_par.lambda_c*dist_los);
        
        Gamma_los                      = 1;
        chl_par.alpha(1,i_rx,i_tx)     = Gamma_los*bas_par.lambda_c/(4*pi*dist_los);
        
        tx_direct_vec_los    = loca_par.rx_ref_point(i_rx,:)-loca_par.tx_ref_point(i_tx,:);
        rx_direct_vec_los    = -tx_direct_vec_los;
        chl_par.aod_vert(1,i_rx,i_tx)  = calc_vert_angle(tx_direct_vec_los);
        chl_par.aod_hori(1,i_rx,i_tx)  = calc_hori_angle(tx_direct_vec_los);
        chl_par.aoa_vert(1,i_rx,i_tx)  = calc_vert_angle(rx_direct_vec_los);
        chl_par.aoa_hori(1,i_rx,i_tx)  = calc_hori_angle(rx_direct_vec_los);
                
        % *** one NLOS path (due to ground reflection) ***
        dist_nlos = dist3pt(loca_par.tx_ref_point(i_tx,:),reflect_point,loca_par.rx_ref_point(i_rx,:));
        chl_par.tau(2,i_rx,i_tx)       = integerize_delay(dist_nlos/bas_par.spdOfLight,bas_par.Ts);
        chl_par.PhaseMat(2,i_rx,i_tx)  = exp(1i*2*pi/bas_par.lambda_c*dist_nlos);
        
        sin_theta      = bas_par.H/dist2pt(loca_par.tx_ref_point(i_tx,:),reflect_point); % angle of incidence (theta)
        cos_theta_squ  = 1-sin_theta^2;
        Z_vert         = sqrt(bas_par.coeff_dielectric-cos_theta_squ)/bas_par.coeff_dielectric ; % vertical polarization
        Gamma_nlos     = (sin_theta-Z_vert)/(sin_theta+Z_vert);
        chl_par.alpha(2,i_rx,i_tx) = Gamma_nlos*bas_par.lambda_c/(4*pi*dist_nlos);
        
        tx_direct_vec_nlos             = reflect_point-loca_par.tx_ref_point(i_tx,:);
        rx_direct_vec_nlos             = reflect_point-loca_par.rx_ref_point(i_rx,:);
        chl_par.aod_vert(2,i_rx,i_tx)  = calc_vert_angle(tx_direct_vec_nlos);
        chl_par.aod_hori(2,i_rx,i_tx)  = calc_hori_angle(tx_direct_vec_nlos);
        chl_par.aoa_vert(2,i_rx,i_tx)  = calc_vert_angle(rx_direct_vec_nlos);
        chl_par.aoa_hori(2,i_rx,i_tx)  = calc_hori_angle(rx_direct_vec_nlos);
             
    end % end_for_i_rx
    
end % end_for_i_tx

end % end_function