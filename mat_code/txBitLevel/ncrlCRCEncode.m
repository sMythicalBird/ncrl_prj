function blkcrc = ncrlCRCEncode(blk, poly, varargin)

    % Persistent variable to store CRC system objects for all polynomials
    persistent encoders;
    narginchk(2,3);
    gLen = 0;
    polyList = {'16','24A','24B'};
    polyIndex = strcmpi(poly,polyList);
    polyLengths = [16 24];
    gLen(:) = polyLengths(polyIndex);

    % 获取blk的码长和块数
    [codeLen,numCodeBlocks] = size(blk);
    blkL = logical(blk);
    % 初始化crc数据结果
    blkcrcL = false(codeLen+gLen,numCodeBlocks);
    % Initialize CRC encoder system objects for each NR polynomial
    if isempty(encoders)
        encoders = cell(1,3);
        polyCell = {
            [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1]', ....                % '16'
            [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1]', ... % '24A'
            [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 1 1]', ... % '24B'
            }; 
        for i = 1:3
            encoders{i} = comm.CRCGenerator('Polynomial',polyCell{i});
        end
    end
    encoder = encoders{polyIndex};
    for i = 1:numCodeBlocks
        blkcrcL(:,i) = encoder(blkL(:,i));
    end

    blkcrc = [blk; cast(blkcrcL(end-gLen+1:end,:),class(blk))];
end









