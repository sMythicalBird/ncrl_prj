function [blk,err] = ncrlCRCDecode(blkcrc,poly,varargin)
    narginchk(2,3);
    % Initialize inputs
    if nargin == 3 && ~isempty(varargin{1})
        mask = varargin{1};
    else
        mask = 0;
    end
    % 获取CRC位数
    polyList = {'6','11','16','24A','24B','24C'};
    polyIndex = strcmpi(poly,polyList);
    polyLengths = [6 11 16 24 24 24];
    gLen = 0; 
    gLen(:) = polyLengths(polyIndex);
    
    % 再做一遍crc校验
    reEncodedBlk = ncrlCRCEncode(blkcrc(1:end-gLen,:),poly,mask);
    [codeLen,numCodeBlocks] = size(blkcrc);
    if isempty(blkcrc)
        blk = zeros(0,numCodeBlocks,class(blkcrc));
        err = zeros(0,numCodeBlocks,'uint32');
    else
        blk = reEncodedBlk(1:end-gLen,:);
        if codeLen <= gLen      % 输入比特长度小于crc校验位长度
            % For input length less than parity bit length
            blkcrcL = [false(gLen-codeLen,numCodeBlocks); blkcrc>0];

            errBits = blkcrcL;
        else
            errBits = xor(reEncodedBlk(end-gLen+1:end,:)>0, ...
                blkcrc(end-gLen+1:end,:));
        end
        err = uint32(sum(double(errBits).*repmat((2.^(gLen-1:-1:0)'), ...
            [1 numCodeBlocks])));
    end

end
