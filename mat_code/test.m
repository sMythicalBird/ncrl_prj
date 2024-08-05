clear;
clc
% 参数
% A = 144;                % 块长
len_blk = 144;          % 传输块长度
len_code = 320;         % 资源单元负载数
crc = 24;               % 校验位
rv = 0;                 % 冗余版本
nlayers = 1;            % 层数
code_rate = len_blk/len_code; % 码率

% 获取cbs
cbsInfo = ncrlCbsInfo(len_blk,code_rate, 24);
payload_bits = randi(2, len_blk, 1) - 1;       % 320*1
modulation = 'QPSK';


% 发送端比特级处理
% CRCEncode
data = nrCRCEncode(payload_bits,cbsInfo.CRC);
% code blocks
cbsIn = nrCodeBlockSegmentLDPC(data,cbsInfo.BGN);
% LDPC encoding
data_ldpc = nrLDPCEncode(cbsIn,cbsInfo.BGN);
% rate matching of LDPC
rate_matched = nrRateMatchLDPC(data_ldpc, len_code, rv, modulation, nlayers);
data_sym = nrSymbolModulate(rate_matched,modulation);

% ncrlCRC
ncrldata = ncrlCRCEncode(payload_bits,cbsInfo.CRC);
% ncrlCBS
ncrlcbsIn = ncrlCodeBlockSegmentLDPC(ncrldata,cbsInfo.BGN);
% ncrlLDPC
ncrl_ldpc = ncrlLDPCEncode(ncrlcbsIn,cbsInfo.BGN);
% ncrl rate matching
ncrl_rm = ncrlRateMatchLDPC(ncrl_ldpc, len_code, rv, modulation, nlayers, cbsInfo.BGN);
ncrl_qam = ncrlModulate(ncrl_rm,modulation);
sum(abs(data-ncrldata))         % CRC校验
sum(abs(cbsIn-ncrlcbsIn))       % CBS
sum(abs(ncrl_ldpc-data_ldpc))   % LDPC
sum(abs(ncrl_rm-rate_matched))  % 速率匹配
sum(abs(ncrl_qam-data_sym))     % 调制



disp("接收端处理")
% 接收端比特级处理
% Demodulation
demod = nrSymbolDemodulate(ncrl_qam,modulation);
ncrl_demod = ncrlDemodulate(ncrl_qam,modulation);
sum(abs(demod-ncrl_demod))
% recover rate
raterec = nrRateRecoverLDPC(demod,len_blk,code_rate,rv,modulation,nlayers);
ncrl_raterec = ncrlRateRecoverLDPC(ncrl_demod,len_blk,code_rate,rv,modulation,nlayers,cbsInfo);
% ldpcDecode
decBits = nrLDPCDecode(raterec, cbsInfo.BGN, 25);
% ncrl_decBits = nrLDPCDecode(ncrl_raterec, cbsInfo.BGN, 25);
ncrl_decBits = ncrLDPCDecode(ncrl_raterec, cbsInfo.BGN, 25);


% CBDS
% blk = nrCodeBlockDesegmentLDPC(decBits,cbsInfo.BGN, len_blk + cbsInfo.L);

blk = nrclCodeBlockDesegmentLDPC(ncrl_decBits,cbsInfo.BGN, len_blk + cbsInfo.L, cbsInfo);
% CRCDecode
% [data_ldpc, ldpc_err] = nrCRCDecode(blk,cbsInfo.CRC);
[ncrl_ldpc, ncrl_ldpc_err] = ncrlCRCDecode(blk,cbsInfo.CRC);


disp("res")
length(find(ncrl_ldpc ~= payload_bits))
