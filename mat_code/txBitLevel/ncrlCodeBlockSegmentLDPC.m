function cbs = ncrlCodeBlockSegmentLDPC(blk,bgn)
    narginchk(2,2);
    % Cast the input to double
    blkd = double(blk);
    blkLen = length(blkd);
    % Get information of code block segments
    chsinfo = nr5g.internal.getCBSInfo(blkLen,bgn);
    % Perform code block segmentation and CRC encoding
    if chsinfo.C == 1
        cbCRC = blkd;
    else
        cb = reshape([blkd; zeros(chsinfo.CBZ*chsinfo.C-blkLen,1)], ...
            chsinfo.CBZ,chsinfo.C);
        cbCRC = nrCRCEncode(cb,'24B');
    end
    % 末尾填充-1
    cbs = [cbCRC; -1*ones(chsinfo.F,chsinfo.C)];

end
