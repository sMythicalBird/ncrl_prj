function blk = nrclCodeBlockDesegmentLDPC(cbs,bgn,blklen,chsinfo)


    narginchk(4,4);

    % Validate inputs
    fcnName = 'nrCodeBlockDesegmentLDPC';
    validateattributes(cbs,{'double','int8'},{'2d','real','nonnan'},fcnName,'CBS');
    validateattributes(bgn,{'numeric'},{'scalar','integer','>=',1,'<=',2},fcnName,'BGN');
    validateattributes(blklen,{'numeric'},{'scalar','integer','nonnegative'},fcnName,'BLKLEN');

    % Check for empty cbs or zero value blklen
    if isempty(cbs) || ~blklen
        blk = zeros(0,1,class(cbs));
        return;
    end

%     % Get information of code block segments
%     chsinfo = nr5g.internal.getCBSInfo(blklen,bgn);

    % Validate dimensions of cbs if there is input for block length
    [K,C] = size(cbs);
    coder.internal.errorIf((C ~= chsinfo.C) || (K ~= chsinfo.K),'nr5g:nrCodeBlockDesegment:InvalidCBSize',K,C,chsinfo.K,chsinfo.C);

    % Remove filler bits
    cbi = cbs(1:end-chsinfo.F,:);

    % Perform code block desegmentation and CRC decoding
    if C == 1
        blk = cbi(:);
    else
        cb = nrCRCDecode(cbi,'24B');
        blk = cb(:);
    end
    blk = blk(1:blklen);

end
