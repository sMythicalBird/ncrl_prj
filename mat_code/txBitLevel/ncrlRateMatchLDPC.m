function out = ncrlRateMatchLDPC(in,outlen,rv,modulation,nlayers,varargin)
    narginchk(5,6);

    % 检查输入是否为空，输出数据长度是否为0
    if isempty(in) || ~outlen
        out = zeros(0,1,class(in));
        return;
    end
 
    [N,C] = size(in);
    % 检查输入编码数据长度是否符合要求
    ZcVec = [2:16 18:2:32 36:4:64 72:8:128 144:16:256 288:32:384];
    coder.internal.errorIf(~(any(N==(ZcVec.*66)) || any(N==(ZcVec.*50))), ...
        'nr5g:nrLDPC:InvalidInputNumRows',N);

    
    % 确认视图
    if any(N==(ZcVec.*66))
        bgn = 1;
        ncwnodes = 66;
    else % must be one of ZcVec.*50
        bgn = 2;
        ncwnodes = 50;
    end
    % 确认Zc
    Zc = N/ncwnodes;

    % 获取调制阶数
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

    % 不对缓存区大小进行限制
    Ncb = N;

    % 获取循环缓冲区中的起始位置
    if bgn == 1
        if rv == 0
            k0 = 0;
        elseif rv == 1
            k0 = floor(17*Ncb/N)*Zc;
        elseif rv == 2
            k0 = floor(33*Ncb/N)*Zc;
        else % rv is equal to 3
            k0 = floor(56*Ncb/N)*Zc;
        end
    else
        if rv == 0
            k0 = 0;
        elseif rv == 1
            k0 = floor(13*Ncb/N)*Zc;
        elseif rv == 2
            k0 = floor(25*Ncb/N)*Zc;
        else % rv is equal to 3
            k0 = floor(43*Ncb/N)*Zc;
        end
    end

    % 获取所有已调度的码块的速率匹配输出
    out = [];
    for r = 0:C-1
        if r <= C-mod(outlen/(nlayers*Qm),C)-1
            E = nlayers*Qm*floor(outlen/(nlayers*Qm*C));    % 向下取整
        else
            E = nlayers*Qm*ceil(outlen/(nlayers*Qm*C));     % 向上取整
        end
        out = [out; cbsRateMatch(in(:,r+1),E,k0,Ncb,Qm)]; %#ok<AGROW>
    end
end

% d:输入ldpc编码后的传输块
% E:速率匹配输出比特长度
% k0:冗余版本开始位置
% Ncb:缓存区大小
% Qm:调制阶数

function e = cbsRateMatch(d,E,k0,Ncb,Qm)

    % 获取循环缓冲区内填充位的数量(填充位的数据为-1)
    NFillerBits = sum(d(1:Ncb) == -1); 

    % 如果为了获得总共E比特需要围绕循环缓冲区进行多次迭代，则复制数据
    d = repmat(d(1:Ncb),ceil(E/(length(d(1:Ncb))-NFillerBits)),1);

    % 将数据移位以从选定的冗余版本开始
    d = circshift(d,-k0);

    e = zeros(E,1,class(d));
    % 避免填充位
    % 如果输出比特为0，则提供一个空向量
%     e(:) = d(find(d ~= -1,E + (E==0)));
    e(:) = d(find(d ~= -1,E));
    
    % 比特交织
    e = reshape(e,E/Qm,Qm);
    e = e.';
    e = e(:); 

end


