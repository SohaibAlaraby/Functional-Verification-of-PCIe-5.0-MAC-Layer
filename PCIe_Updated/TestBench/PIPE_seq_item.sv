class PIPE_seq_item extends uvm_sequence_item;
  
`uvm_object_utils(PIPE_seq_item)


bit [`MAXPIPEWIDTH*`LANESNUMBER-1:0] TxData;
bit [`LANESNUMBER-1:0] TxDataValid;
bit [`LANESNUMBER-1:0] TxElecIdle;
bit [`LANESNUMBER-1:0] TxStartBlock;
bit [(`MAXPIPEWIDTH/8)*`LANESNUMBER-1:0] TxDataK;
bit [2*`LANESNUMBER -1:0] TxSyncHeader;
bit [`LANESNUMBER-1:0] TxDetectRx_Loopback;





bit [`MAXPIPEWIDTH*`LANESNUMBER-1:0] RxData;
bit [`LANESNUMBER-1:0] RxDataValid;
bit [(`MAXPIPEWIDTH/8)*`LANESNUMBER-1:0] RxDataK;
bit [`LANESNUMBER-1:0] RxStartBlock;
bit [2*`LANESNUMBER-1:0] RxSyncHeader;
bit [3*`LANESNUMBER-1:0] RxStatus;
bit [15:0] RxElectricalIdle;

/////LTSSM Related Signals\\\\\

bit phy_reset;
bit [1:0] width;
bit [4*`LANESNUMBER-1:0] PowerDown;
bit [3:0] Rate;
bit [`LANESNUMBER-1:0] PhyStatus;
bit [4:0] PCLKRate;
bit PclkChangeAck;
bit PclkChangeOk;
bit [18*`LANESNUMBER-1:0] LocalTxPresetCoefficients;
bit [18*`LANESNUMBER-1:0] TxDeemph;
bit [6*`LANESNUMBER-1:0] LocalFS;
bit [6*`LANESNUMBER-1:0] LocalLF;
bit [4*`LANESNUMBER-1:0] LocalPresetIndex;
bit [`LANESNUMBER-1:0] GetLocalPresetCoeffcients;
bit [`LANESNUMBER-1:0] LocalTxCoefficientsValid;
bit [6*`LANESNUMBER-1:0] LF;
bit [6*`LANESNUMBER-1:0] FS;
bit [`LANESNUMBER-1:0] RxEqEval;
bit [`LANESNUMBER-1:0] InvalidRequest;
bit [6*`LANESNUMBER-1:0] LinkEvaluationFeedbackDirectionChange;
bit [7:0] M2P_MessageBus;
bit [7:0] P2M_MessageBus;
bit [15:0] RxStandby;





bit[5:0] Current_Substate,Next_Substate;
bit[11:0] TS_Count;
bit[1:0] TS_Type;



function new(string name = "PIPE_seq_item");
    super.new(name);
endfunction



endclass