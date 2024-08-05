function out = ncrlLDPCEncode(in,bgn)
    % 检测bgn是否正确
    coder.internal.errorIf(~(bgn==1 || bgn==2), ...
        'nr5g:nrLDPC:InvalidBGN',bgn);
    typeIn = class(in);
    % 检查输入是否为空
    if isempty(in)
        out = zeros(0,size(in,2),typeIn);
        return;
    end

    % Obtain input/output size
    [K,C] = size(in);
    if bgn==1
        nsys = 22;
        ncwnodes = 66;
    else
        nsys = 10;
        ncwnodes = 50;
    end
    Zc = K/nsys;
    %   检查Zc
    coder.internal.errorIf(fix(Zc)~=Zc, ...
        'nr5g:nrLDPC:InvalidInputLength',K,nsys,bgn);
    
    ZcVec = [2:16 18:2:32 36:4:64 72:8:128 144:16:256 288:32:384];
    coder.internal.errorIf(~any(Zc==ZcVec),'nr5g:nrLDPC:InvalidZc',Zc,bgn);
    N = Zc*ncwnodes;

    % 将填充的-1置为0
    locs = find(in(:,1)==-1);
    in(locs,:) = 0;

    % LDPC编码
    outCBall = nr5g.internal.ldpc.encode(double(in),bgn,Zc);

    % 将填充部分再置为-1
    outCBall(locs,:) = -1;

    % 前面2*Zc比特打孔
    out = zeros(N,C,typeIn);
    out(:,:) = cast(outCBall(2*Zc+1:end,:),typeIn);
    
end

