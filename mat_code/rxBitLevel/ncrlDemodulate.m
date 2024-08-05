function out = ncrlDemodulate(in,modulation,varargin) 
    narginchk(2,3)
    % List of modulation schemes
    modlist = {'pi/2-BPSK', 'BPSK', 'QPSK', '16QAM', '64QAM', '256QAM'};
    % Modulation scheme check
    fcnName = 'nrSymbolDemodulate';
    modscheme = validatestring(modulation,modlist,fcnName,'MODULATION');

    % 检查是否在里面
    isInList = any(strcmp(modulation, modlist));
    if isInList == 0
        disp("解调类型有误")
        return 
    end

    coder.extrinsic('nr5g.internal.parseOptions')

    nInArgs = nargin;
    % 软解调
    if nInArgs == 2
        % nrSymbolDemodulate(cw,mod)
        decType = 'soft';
        nVar = 1e-10;
    else
        % nrSymbolDemodulate(cw,mod,nVar)
        decType = 'soft';
        nVar = varargin{1};
    end
    
    % Clip nVar to allowable value to avoid +/-Inf outputs
    if nVar < 1e-10
        nVar = 1e-10;
    end
    
    bpsList = [1 1 2 4 6 8];

    ind = strcmpi(modlist,modscheme);
    bps = bpsList(ind);
    modOrder = 2^bps;

    outDType= class(in);
    % 输入为空
    if isempty(in)
        out = zeros(size(in),outDType);
        return;
    end
    % 输出格式 软解调输出最大似然信息
    outType = 'approxLLR';

    % Generate symbol order vector
    % symbolOrdVector = [0,1];
    switch (bps)
        case 2 % QPSK
            symbolOrdVector = [2 3 0 1];
        case 4 % 16QAM
            symbolOrdVector = [11 10 14 15 9 8 12 13 1 0 4 5 3 2 6 7];
        case 6 % 64QAM
            symbolOrdVector = [47 46 42 43 59 58 62 63 45 44 40 41 57 56 60 ...
                61 37 36 32 33 49 48 52 53 39 38 34 35 51 50 ...
                54 55 7 6 2 3 19 18 22 23 5 4 0 1 17 16 20 ...
                21 13 12 8 9 25 24 28 29 15 14 10 11 27 26 30 31];
        case 8 %256QAM
            symbolOrdVector = [191 190 186 187 171 170 174 175 239 238 234 ...
                235 251 250 254 255 189 188 184 185 169 168 ...
                172 173 237 236 232 233 249 248 252 253 181 ...
                180 176 177 161 160 164 165 229 228 224 225 ...
                241 240 244 245 183 182 178 179 163 162 166 ...
                167 231 230 226 227 243 242 246 247 151 150 ...
                146 147 131 130 134 135 199 198 194 195 211 ...
                210 214 215 149 148 144 145 129 128 132 133 ...
                197 196 192 193 209 208 212 213 157 156 152 ...
                153 137 136 140 141 205 204 200 201 217 216 ...
                220 221 159 158 154 155 139 138 142 143 207 ...
                206 202 203 219 218 222 223 31 30 26 27 11 ...
                10 14 15 79 78 74 75 91 90 94 95 29 28 24 25 ...
                9 8 12 13 77 76 72 73 89 88 92 93 21 20 16 17 ...
                1 0 4 5 69 68 64 65 81 80 84 85 23 22 18 19 3 ...
                2 6 7 71 70 66 67 83 82 86 87 55 54 50 51 35 ...
                34 38 39 103 102 98 99 115 114 118 119 53 52 ...
                48 49 33 32 36 37 101 100 96 97 113 112 116 ...
                117 61 60 56 57 41 40 44 45 109 108 104 105 ...
                121 120 124 125 63 62 58 59 43 42 46 47 111 ...
                110 106 107 123 122 126 127];
        otherwise % BPSK or pi/2-BPSK
            symbolOrdVector = [0 1];
    end


    if bps >= 2 % QPSK,16QAM,64QAM or 256QAM
        outTmp = comm.internal.qam.demodulate(in,modOrder,'custom', ...
            symbolOrdVector,1,outType,nVar);
    else % BPSK or pi/2-BPSK
        if ind(1) % pi/2-BPSK
            inoddrot = complex(in);
            inoddrot(2:2:end) = -1j*in(2:2:end);
            derotsymb = inoddrot*exp(1j*3*pi/4);
        else % BPSK
            derotsymb = in*exp(1j*3*pi/4);
        end
        outTmp = comm.internal.qam.demodulate(derotsymb,modOrder,'binary',...
            [0 1],1,outType,nVar);
    end

    if strcmpi(decType,'soft')
        out = outTmp;
    else % Hard decision
        out = cast(outTmp,outDType);
    end

end
