function bas_pars = init_param_4x16(pdsch)
% 生成四组信道参数
bas_pars(1) = initinalize_basic_param_1x4(pdsch); 
bas_pars(2) = initinalize_basic_param_1x4(pdsch); 
bas_pars(3) = initinalize_basic_param_1x4(pdsch); 
bas_pars(4) = initinalize_basic_param_1x4(pdsch); 

bas_pars(1).D = 35;
bas_pars(2).D = 40;
bas_pars(3).D = 45;
bas_pars(4).D = 50;

end

