function [v] = arr_vec_upa(nAntRow,nAntCol,azi_ang,elv_ang,ratio_de_lambda)
% Description: 
%  This function generates the array response vector for an uniform 
%  planar array (UPA).
%
% Inputs:
%  nAntRow         - num. of antennas in each row (along axis y)
%  nAntCol         - num. of antennas in each column (along axis z)
%  azi_ang         - azimuth angle with axis x+ in [-pi/2,pi/2)
%  elv_ang         - elevation angle with axis z+ in [0,pi)
%  ratio_de_lambda - ratio between antenna spacing (de) and wavelength (lambda)
%
% Outputs:
%  v               - array response vector [nAntRow*nAntCol,1]
%
% Notes:
%  # The upa is on the y-z plane and its element at the left corner is 
%    marked as the first one (at the orgin). 
%  # v(azi_ang,elv_ang) = kron(v_y(azi_ang,elv_ang),v_z(azi_ang))
%    v_y(azi_ang,elv_ang) = [1, ..., exp(j*2*pi/lambda*(nAntRow-1)*sin(elv_ang)*sin(azi_ang))].'
%    v_z(azi_ang) = [1, ..., exp(j*2*pi/lambda*(nAntCol-1)*cos(elv_ang))].' 


% *** default value (half-wavelength) ***
if (nargin<=4)
    ratio_de_lambda = 0.5;
end

% *** generate array response vector for upa ***
v = zeros(nAntRow*nAntCol,1);
for m = 0:nAntCol-1
    for n = 0:nAntRow-1
        v(m * nAntRow + n + 1) = exp(1i*2*pi*ratio_de_lambda*m*(sin(azi_ang)* ...
            sin(elv_ang)+n*cos(elv_ang)));
    end
end

end % end_function