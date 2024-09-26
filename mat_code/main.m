% clear;
% clc
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
% payload_bits = randi(2, len_blk, 1) - 1;      
payload_bits = a;
modulation = 'QPSK';


% 发送端比特级处理
% ncrlCRC
ncrldata = ncrlCRCEncode(payload_bits,cbsInfo.CRC);
% ncrlCBS
ncrlcbsIn = ncrlCodeBlockSegmentLDPC(ncrldata,cbsInfo.BGN);
% ncrlLDPC
ncrl_ldpc = ncrlLDPCEncode(ncrlcbsIn,cbsInfo.BGN);
% ncrl rate matching
ncrl_rm = ncrlRateMatchLDPC(ncrl_ldpc, len_code, rv, modulation, nlayers, cbsInfo.BGN);
ncrl_qam = ncrlModulate(ncrl_rm,modulation);

b.n1 = ncrldata;
b.n2 = ncrlcbsIn;
b.n3 = ncrl_ldpc;
b.n4 = ncrl_rm;
b.n5 = ncrl_qam;


disp("接收端处理")
% 接收端比特级处理
% Demodulation
ncrl_demod = ncrlDemodulate(ncrl_qam,modulation);
% recover rate
ncrl_raterec = ncrlRateRecoverLDPC(ncrl_demod,len_blk,code_rate,rv,modulation,nlayers,cbsInfo);
% ldpcDecode
ncrl_decBits = ncrLDPCDecode(ncrl_raterec, cbsInfo.BGN, 25);
blk = nrclCodeBlockDesegmentLDPC(ncrl_decBits,cbsInfo.BGN, len_blk + cbsInfo.L, cbsInfo);
% CRCDecode
[ncrl_ldpc, ncrl_ldpc_err] = ncrlCRCDecode(blk,cbsInfo.CRC);


disp("res")
length(find(ncrl_ldpc ~= payload_bits))
