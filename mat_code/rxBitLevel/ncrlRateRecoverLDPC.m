function out = ncrlRateRecoverLDPC(in,trblklen,R,rv,modulation,nlayers,cbsinfo, varargin)


    narginchk(7,8);
    % Get scheduled code blocks and limited buffers for HARQ combining
    if nargin==7
        numCB = [];
        Nref = [];
    elseif nargin==8
        numCB = varargin{1};
        Nref = [];
    else
       numCB = varargin{1};
       Nref = varargin{2};
    end
    modulation = validateInputs(in,trblklen,R,rv,modulation,nlayers);
    typeIn = class(in);

    % Output empty if the input is empty or trblklen is 0
    if isempty(in) || ~trblklen
        out = zeros(0,1,typeIn);
        return;
    end

    % Get modulation order
    switch modulation
        case {'pi/2-BPSK', 'BPSK'}
            Qm = 1;
        case 'QPSK'
            Qm = 2;
        case '16QAM'
            Qm = 4;
        case '64QAM'
            Qm = 6;
        otherwise   % '256QAM'
            Qm = 8;
    end

    % Get base graph and code block segmentation parameters
%     cbsinfo = nrDLSCHInfo(trblklen,R);
    bgn = cbsinfo.BGN;
    Zc = cbsinfo.Zc;
    N = cbsinfo.N;

    % Get number of scheduled code block segments
    if ~isempty(numCB)
        fcnName = 'nrRateRecoverLDPC';
        validateattributes(numCB, {'numeric'}, ...
            {'scalar','integer','positive','<=',cbsinfo.C},fcnName,'NUMCB');  

        C = numCB;      % scheduled code blocks
    else
        C = cbsinfo.C;  % all code blocks
    end

    % Get code block soft buffer size
    if ~isempty(Nref)
        fcnName = 'nrRateRecoverLDPC';
        validateattributes(Nref, {'numeric'}, ...
            {'scalar','integer','positive'},fcnName,'Nref');

        Ncb = min(N,Nref);
    else    % No limit on buffer size
        Ncb = N;
    end

    % Get starting position in circular buffer
    if bgn == 1
        if rv == 0
            k0 = 0;
        elseif rv == 1
            k0 = floor(17*Ncb/N)*Zc;
        elseif rv == 2
            k0 = floor(33*Ncb/N)*Zc;
        else % rv == 3
            k0 = floor(56*Ncb/N)*Zc;
        end
    else
        if rv == 0
            k0 = 0;
        elseif rv == 1
            k0 = floor(13*Ncb/N)*Zc;
        elseif rv == 2
            k0 = floor(25*Ncb/N)*Zc;
        else % rv == 3
            k0 = floor(43*Ncb/N)*Zc;
        end
    end

    G = length(in);
    gIdx = 1;
    out = zeros(N,C,typeIn);
    for r = 0:C-1
        if r <= C-mod(G/(nlayers*Qm),C)-1
            E = nlayers*Qm*floor(G/(nlayers*Qm*C));
        else
            E = nlayers*Qm*ceil(G/(nlayers*Qm*C));
        end
        if G < E
            % Pad "unknown" bits to support insufficient input
            zeroPad = zeros(E-G,1,class(in));
            deconcatenated = [in; zeroPad];
        else
            deconcatenated = in(gIdx:gIdx+E-1,1);
        end
        gIdx = gIdx + E;
        out(:,r+1) = cbsRateRecover(deconcatenated,cbsinfo,k0,Ncb,Qm);
    end
    
end

function out = cbsRateRecover(in,cbsinfo,k0,Ncb,Qm)
% Rate recovery for a single code block segment

    % Perform bit de-interleaving according to TS 38.212 5.4.2.2
    E = length(in);
    in = reshape(in,Qm,E/Qm);
    in = in.';
    in = in(:);

    % Puncture systematic bits
    K = cbsinfo.K - 2*cbsinfo.Zc;
    Kd = K - cbsinfo.F;     % exclude fillers
    
    % Perform reverse of bit selection according to TS 38.212 5.4.2.1
    % Get number of filler bits inside the circular buffer
    NFillerBits = length(Kd+1:min(K,Ncb));

    % Duplicate data if more than one iteration around the circular
    % buffer is required to obtain a total of E bits
    NBuffer = Ncb-NFillerBits; % buffer size without filler bits
    idx = repmat(1:Ncb,1,ceil(E/NBuffer));

    % Shit data to start from selected redundancy version
    idx = circshift(idx,-k0);

    % Avoid filler bits indices
    indicesFillerBits = idx(find(idx > Kd & idx <= K,E));  
    indices = idx(~ismember(idx,indicesFillerBits));
    indices = indices(1:E); 

    % Recover circular buffer
    out = zeros(cbsinfo.N,1,class(in));
    
    % Filler bits are treated as 0 bits when encoding, 0 bits correspond to
    % Inf in received soft bits, this step improves error-correction
    % performance in the LDPC decoder
    out(Kd+1:K) = Inf;

    % Fill in the circular buffer
    if E > NBuffer
        for i=1:floor(E/NBuffer)
            out(indices(1:NBuffer)) = out(indices(1:NBuffer)) + ...
                in((i-1)*NBuffer+1:NBuffer*i);
        end
    
        remBits = mod(E,NBuffer);
        out(indices(1:remBits)) = out(indices(1:remBits)) + in(end-remBits+1:end);
    else
        out(indices) = in;
    end
    
end

function modulation = validateInputs(in,trblklen,R,rv,modulation,nlayers)
% Check inputs

    fcnName = 'nrRateRecoverLDPC';

    % Validate input soft data
    validateattributes(in,{'double','single'},{'real','column'},fcnName,'IN');

    % Validate transport block length
    validateattributes(trblklen,{'numeric'}, ...
        {'scalar','integer','nonnegative','finite'},fcnName,'TRBLKLEN');

    % Validate target code rate
    validateattributes(R,{'numeric'}, ...
        {'real','scalar','>',0,'<',1},fcnName,'RATE');

    % Validate redundancy version (0...3)
    validateattributes(rv,{'numeric'}, ...
        {'scalar','integer','nonnegative','<=',3},fcnName,'RV');

    % Validate modulation scheme
    modulation = validatestring(modulation,{'pi/2-BPSK','BPSK','QPSK', ...
        '16QAM','64QAM','256QAM'},fcnName,'MODULATION');

    % Validate the number of transmission layers (1...4)
    validateattributes(nlayers,{'numeric'}, ...
        {'scalar','integer','positive','<=',4},fcnName,'NLAYERS');
end


