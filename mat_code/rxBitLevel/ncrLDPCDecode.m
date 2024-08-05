function out = ncrLDPCDecode(in,bgn, maxNumIter,varargin)


    narginchk(3,15);

    [params,algChoice,alphaBeta] = validateInputs(in,bgn,maxNumIter,varargin{:});
    isHardDec = int8(strcmp(params.DecisionType,'hard'));
    
    % Obtain input/output size
    [N,C] = size(in);
    typeIn = class(in);

    % Output empty if the input data is empty
    if isempty(in)
        if isHardDec 
            out = zeros(0,C,'int8');
        else
            out = zeros(0,C,typeIn);
        end
        actNumIter = 0;
        finalParityChecks = zeros(0,C);
        return;
    end

    % LDPC decoding parameters
    if bgn==1
        ncwnodes = 66;
    else
        ncwnodes = 50;
    end
    % 解Zc
    Zc = N/ncwnodes;
    % 检查Zc是否合理
    coder.internal.errorIf(fix(Zc)~=Zc, ...
        'nr5g:nrLDPC:InvalidInputLength',N,ncwnodes,bgn);
    ZcVec = [2:16 18:2:32 36:4:64 72:8:128 144:16:256 288:32:384];
    coder.internal.errorIf( ~any(Zc==ZcVec),'nr5g:nrLDPC:InvalidZc',Zc,bgn);

    algStr = {'bp','layered-bp','norm-min-sum','offset-min-sum'};
    
    % Get LDPC parameters for the bgn, Zc value pair
    cfg = nr5g.internal.ldpc.getParams(bgn,Zc);
    cfg.Algorithm = algStr{algChoice+1};

    % Add punctured 2*Zc information bits to recover the full codeword
    in = [zeros(2*Zc,C,typeIn); in];

    % Decode
    if nargout < 3
        % Specify two outputs to tell ldpcDecode not to compute finalParityChecks
        [out,actNumIter] = ldpcDecode(in,cfg,maxNumIter,'OutputFormat',params.OutputFormat,'DecisionType',params.DecisionType,'Termination',params.Termination,'MinSumScalingFactor',alphaBeta,'MinSumOffset',alphaBeta);
    else
        [out,actNumIter,finalParityChecks] = ldpcDecode(in,cfg,maxNumIter,'OutputFormat',params.OutputFormat,'DecisionType',params.DecisionType,'Termination',params.Termination,'MinSumScalingFactor',alphaBeta,'MinSumOffset',alphaBeta);
    end
end

function [params,alg,alphaBeta] = validateInputs(in,bgn,maxNumIter,varargin)
% Check and parse input parameters

    coder.extrinsic('nr5g.internal.parseOptions');
    fcnName = 'nrLDPCDecode';

    % Validate the input soft data
    validateattributes(in,{'double','single'},{'2d'},fcnName,'IN');

    % Validate the input base graph number (1 or 2)
    validateattributes(bgn,{'numeric'},{'scalar','integer'},fcnName,'BGN');  
    coder.internal.errorIf(~(bgn==1||bgn==2),'nr5g:nrLDPC:InvalidBGN',bgn);

    % Validate the maximum number of iterations
    validateattributes(maxNumIter, {'numeric'}, ...
        {'real','scalar','integer','>',0},fcnName,'MAXNUMITER');  

    % Parse and validate the optional params
    params = coder.const(nr5g.internal.parseOptions(fcnName, ...
        {'OutputFormat','DecisionType','Algorithm','ScalingFactor', ...
         'Offset','Termination'},varargin{:}));        
    
    switch params.Algorithm
        case 'Belief propagation'
            alg = 0;
            alphaBeta = 1; % Unused
        case 'Layered belief propagation'
            alg = 1;
            alphaBeta = 1; % Unused
        case 'Normalized min-sum'
            alg = 2;
            if isfield(params,'ScalingFactor')
                alphaBeta = params.ScalingFactor;
            else
                alphaBeta = 0.75;  % default
            end
        otherwise % "Offset min-sum"
            alg = 3;
            if isfield(params,'Offset')
                alphaBeta = params.Offset;
            else
                alphaBeta = 0.5;  % default
            end
    end
end
