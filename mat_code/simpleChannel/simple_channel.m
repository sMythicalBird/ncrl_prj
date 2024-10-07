function [H]=simple_channel(h,Nt,K,Bnoise,r1)
    n_ue = 1024;        % ue数
    n_ap = 256;         % ap数



    N=h*Nt;%总天线数
    H=zeros(K,N);
    BS=[0 0];
    user=position(K,r1);    %极坐标转化为直角坐标
    for ii = 1:h
        for k = 1:K
            d_ik = sqrt((BS(:,1)-user(k,1))^2+(BS(:,2)-user(k,2))^2);       % 求直线距离
    %                 pathloss=sqrt(10.^(-(35.3+37.6*log10(d_ik))/10));     % 大尺度衰落
                     pathloss=sqrt(10.^(-(128.1+37.6*log10(d_ik))/10));
            rayleigh=(randn(1,Nt)+ 1i*randn(1,Nt))*sqrt(0.5);               % 小尺度衰落
            H(k,1+(ii-1)*Nt:ii*Nt) = pathloss*rayleigh/sqrt(Bnoise);        % 信道增益  H(user,Nt)
        end
    end