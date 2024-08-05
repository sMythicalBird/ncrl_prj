function out = ncrlModulate(in,modulation)
    narginchk(2,2);
    % List of modulation schemes
    modlist = {'pi/2-BPSK','BPSK','QPSK','16QAM','64QAM','256QAM'};
    % 调制模式
    modscheme = modulation;
    % PV pair check
    coder.extrinsic('nr5g.internal.parseOptions')
    outDataType = 'double';
    bpsList = [1 1 2 4 6 8];
    % 字符串匹配找到调制模式
    ind = strcmpi(modlist,modscheme);
    tmp = bpsList(ind);
    bps = tmp(1);
    modOrder = 2^bps;
%     % 检查输入数据是否符合格式，调制阶数整除输入长度
%     coder.internal.errorIf(mod(numel(in),bps) ~= 0, ...
%         'nr5g:nrSymbolModDemod:InvalidInputLength',numel(in),bps);

    % 检查输入是否为空，为空直接返回
    if isempty(in)
        out = zeros(size(in),char(outDataType));
        return;
    end

    intmp = cast(in,char(outDataType));

    % 获取调制向量
    symbolOrdVector = ncrlgetSymOrderVec(bps);

    % 调制
    symb = comm.internal.qam.modulate(intmp,modOrder,'custom',symbolOrdVector, ...
        1,1,[]);

    if bps == 1 % BPSK and pi/2-BPSK
        rotsymb  = symb.*exp(-1j*3*pi/4);
        if ind(1) % pi/2-BPSK
            out = rotsymb;
            out(2:2:end) = 1j*rotsymb(2:2:end);     % 增加相移
        else % BPSK
            out = rotsymb;
        end
    else % QPSK, 16QAM, 64QAM, 256QAM
        out = symb;
    end

end

