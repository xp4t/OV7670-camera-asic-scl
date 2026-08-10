create_library_set -name LS_TT -timing {../lib/nldm_tt_27_1p5.lib ../lib/scl1u_pads_typ.lib}
create_library_set -name LS_SS -timing {../lib/nldm_ss_125_2p45.lib ../lib/scl1u_pads_max.lib}
create_library_set -name LS_FF -timing {../lib/nldm_ff_m25_1p55.lib ../lib/scl1u_pads_min.lib}

create_rc_corner -name RC_TYP -T 27

create_delay_corner -name DC_TT -library_set LS_TT -rc_corner RC_TYP
create_delay_corner -name DC_SS -library_set LS_SS -rc_corner RC_TYP
create_delay_corner -name DC_FF -library_set LS_FF -rc_corner RC_TYP

create_constraint_mode -name CM_FUNC -sdc_files {../syn/sweep/E4/top_synth.sdc}

create_analysis_view -name AV_SETUP_SS -constraint_mode CM_FUNC -delay_corner DC_SS
create_analysis_view -name AV_HOLD_FF  -constraint_mode CM_FUNC -delay_corner DC_FF
create_analysis_view -name AV_FUNC_TT  -constraint_mode CM_FUNC -delay_corner DC_TT

set_analysis_view -setup {AV_SETUP_SS} -hold {AV_HOLD_FF}
