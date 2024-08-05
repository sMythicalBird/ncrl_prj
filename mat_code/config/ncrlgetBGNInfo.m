function info = ncrlgetBGNInfo(A, R, varargin)
    narginchk(2,3);
    A = double(A);
    % 选择LDPC视图
    if A <= 292 || (A <= 3824 && R <= 0.67) || R <= 0.25
      bgn = 2;
    else
      bgn = 1;
    end
    % 自定义CRC位数
    if nargin == 3 && ~isempty(varargin{1})
        L        = varargin{1};
        if L == 16
            info.CRC = '16';
        else
            info.CRC = '24A';
        end
    % 按照标准协议
    else
        % structure info
        if A > 3824
          L        = 24;
          info.CRC = '24A';
        else
          L        = 16;
          info.CRC = '16';
        end
    end
    % Get the length of transport block after CRC attachment
    B = A + L;
    % Get the remaining fields of output structure info
    info.L   = L;       % CRC长度
    info.BGN = bgn;     % BGN视图
    info.B   = B;       % CRC校验之后的长度
end

