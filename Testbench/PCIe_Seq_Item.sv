class PCIe_Seq_Item extends uvm_sequence_item;
`uvm_object_utils(PCIe_Seq_Item) //parametrized seq item

//PIPE Interface Signals
/////TX Related Signals\\\\\
logic [`MAXPIPEWIDTH*`LANESNUMBER-1:0] TxData;
logic [`LANESNUMBER-1:0] TxDataValid;
logic [`LANESNUMBER-1:0] TxElecIdle;
logic [`LANESNUMBER-1:0] TxStartBlock;
logic [(`MAXPIPEWIDTH/8)*`LANESNUMBER-1:0] TxDataK;
logic [2*`LANESNUMBER -1:0] TxSyncHeader;
logic [`LANESNUMBER-1:0] TxDetectRx_Loopback;



/////RX Related Signals\\\\\
logic [`MAXPIPEWIDTH*`LANESNUMBER-1:0] RxData;
logic [`LANESNUMBER-1:0] RxDataValid;
logic [(`MAXPIPEWIDTH/8)*`LANESNUMBER-1:0] RxDataK;
logic [`LANESNUMBER-1:0] RxStartBlock;
logic [2*`LANESNUMBER -1:0] RxSyncHeader;
logic [3*`LANESNUMBER -1:0] RxStatus;
logic [15:0] RxElectricalIdle;





/////LTSSM Related Signals\\\\\
logic phy_reset;
logic [1:0] width;
logic [4*`LANESNUMBER-1:0] PowerDown;
logic [3:0] Rate;
logic [`LANESNUMBER-1:0] PhyStatus;
logic [4:0] PCLKRate;
logic PclkChangeAck;
logic PclkChangeOk;
logic [18*`LANESNUMBER -1:0] LocalTxPresetCoefficients;
logic [18*`LANESNUMBER -1:0] TxDeemph;
logic [6*`LANESNUMBER -1:0] LocalFS;
logic [6*`LANESNUMBER -1:0] LocalLF;
logic [4*`LANESNUMBER -1:0] LocalPresetIndex;
logic [`LANESNUMBER -1:0] GetLocalPresetCoeffcients;
logic [`LANESNUMBER -1:0] LocalTxCoefficientsValid;
logic [6*`LANESNUMBER -1:0] LF;
logic [6*`LANESNUMBER -1:0] FS;
logic [`LANESNUMBER -1:0] RxEqEval;
logic [`LANESNUMBER -1:0] InvalidRequest;
logic [6*`LANESNUMBER -1:0] LinkEvaluationFeedbackDirectionChange;
logic [7:0] M2P_MessageBus;
logic [7:0] P2M_MessageBus;
logic [15:0] RxStandby;

//LPIF related signals
/////LTSSM Related Signals\\\\\
logic CLK,
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


function new(string name = "PCIe_Seq_Item");
    super.new(name);
endfunction

endclass