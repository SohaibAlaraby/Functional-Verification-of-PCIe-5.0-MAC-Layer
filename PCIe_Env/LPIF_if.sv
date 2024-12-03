interface LPIF_if #(parameter  = ;)();



/////LTSSM Related Signals\\\\\
logic lpreset; 
logic[3:0] lp_state_req;
logic[3:0] pl_state_sts;
logic[2:0] pl_speedmode;
logic lp_force_detect;
logic pl_linkUp;




/////TX Related Signals\\\\\
logic  lp_irdy;    
logic[64-1:0] lp_dlpstart;
logic[64-1:0] lp_dlpend;
logic[64-1:0] lp_tlpstart;
logic[64-1:0] lp_tlpend;
logic[512-1:0] lp_data;
logic[64-1:0] lp_valid;




/////RX Related Signals\\\\\
logic pl_trdy;
logic[64-1:0] pl_dlpstart;
logic[64-1:0] pl_dlpend;
logic[64-1:0] pl_tlpstart;
logic[64-1:0] pl_tlpend;
logic[64-1:0] pl_tlpedb;
logic[512-1:0] pl_data;
logic[64-1:0] pl_valid;





endinterface
