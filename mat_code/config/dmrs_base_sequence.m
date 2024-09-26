function dmrs_base_seq = dmrs_base_sequence(pxsch)
    
    % dmrs base seq parameters
    nof_sc = pxsch.nof_sc;
    modulation          = pxsch.modulation_type;
    slot_idx_in_frame   = pxsch.slot_idx_in_frame;
    nof_symb_per_slot   = pxsch.nof_symbs;
    N_id_n_scid         = pxsch.N_id_n_scid_set;
    n_scid              = pxsch.n_scid_set;
    dmrs_symb_idx       = pxsch.dmrs_sym_id;
    
    dmrs_max_len        = nof_sc;

    ofdm_symb_idx = nof_symb_per_slot * slot_idx_in_frame + dmrs_symb_idx;
    c_init    = 2^17*(ofdm_symb_idx+1)*(2*N_id_n_scid+1)+2*N_id_n_scid+n_scid;
    c_init    = mod(c_init, 2^31);
    
    % get the PRBS
    dmrs_prbs = scrambling(0, dmrs_max_len, c_init);
    
    % QPSK modulation
    dmrs_base_seq = nrSymbolModulate(dmrs_prbs,modulation);
        

