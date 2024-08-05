function info = ncrlCbsInfo(tbs , tcr, varargin)
%nrDLSCHInfo 6G DL-SCH segmentation information   
    % tbs:编码前的码块长度
    % tcr:编码使用的码率
    % varargin:自定义CRC长度
    narginchk(2,3);
    % Get base graph number and CRC information
    if nargin == 3 && ~isempty(varargin{1})
        bgInfo = ncrlgetBGNInfo(tbs,tcr, varargin{1});
    else
        bgInfo = ncrlgetBGNInfo(tbs,tcr);
    end

    % Get code block segment information    
    cbInfo = nr5g.internal.getCBSInfo(bgInfo.B,bgInfo.BGN);
    % Get number of bits (including filler bits) to be encoded by LDPC
    % encoder
    if bgInfo.BGN == 1
        N = 66*cbInfo.Zc;
    else
        N = 50*cbInfo.Zc;
    end

    % Combine information into the output structure
    info.CRC      = bgInfo.CRC;             % CRC polynomial
    info.L        = bgInfo.L;               % Number of CRC bits
    info.BGN      = bgInfo.BGN;             % Base graph number
    info.C        = cbInfo.C;               % Number of code block segments
    info.Lcb      = cbInfo.Lcb;             % Number of parity bits per code block
    info.F        = cbInfo.F;               % Number of <NULL> filler bits per code block
    info.Zc       = cbInfo.Zc;              % Selected lifting size
    info.K        = cbInfo.K;               % Number of bits per code block after CBS
    info.N        = N;                      % Number of bits per code block after LDPC coding

    % Modify the output fields if tbs is empty or zero
    if ~tbs
        info.L    = 0;
        info.F    = 0;
        info.Zc   = 2;
        info.K    = 0;
        info.N    = 0;
    end
end

