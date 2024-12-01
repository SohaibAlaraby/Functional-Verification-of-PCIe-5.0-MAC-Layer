interface PIPE #(parameter MAXPIPEWIDTH = 32,
                 parameter LANESNUMBER = 16 )
                 
                 (  
                   input bit CLK
                 );




/////TX Related Signals\\\\\
logic [MAXPIPEWIDTH*LANESNUMBER-1:0] TxData;
logic [LANESNUMBER-1:0] TxDataValid;
logic [LANESNUMBER-1:0] TxElecIdle;
logic [LANESNUMBER-1:0] TxStartBlock;
logic [(MAXPIPEWIDTH/8)*LANESNUMBER-1:0] TxDataK;
logic [2*LANESNUMBER -1:0] TxSyncHeader;
logic [LANESNUMBER-1:0] TxDetectRx_Loopback;



/////RX Related Signals\\\\\
logic [MAXPIPEWIDTH*LANESNUMBER-1:0] RxData;
logic [LANESNUMBER-1:0] RxDataValid;
logic [(MAXPIPEWIDTH/8)*LANESNUMBER-1:0] RxDataK;
logic [LANESNUMBER-1:0] RxStartBlock;
logic [2*LANESNUMBER -1:0] RxSyncHeader;
logic [3*LANESNUMBER -1:0] RxStatus;
logic [15:0] RxElectricalIdle;





/////LTSSM Related Signals\\\\\
logic phy_reset;
logic [1:0] width;
logic [4*LANESNUMBER-1:0] PowerDown;
logic [3:0] Rate;
logic [LANESNUMBER-1:0] PhyStatus;
logic [4:0] PCLKRate;
logic PclkChangeAck;
logic PclkChangeOk;
logic [18*LANESNUMBER -1:0] LocalTxPresetCoefficients;
logic [18*LANESNUMBER -1:0] TxDeemph;
logic [6*LANESNUMBER -1:0] LocalFS;
logic [6*LANESNUMBER -1:0] LocalLF;
logic [4*LANESNUMBER -1:0] LocalPresetIndex;
logic [LANESNUMBER -1:0] GetLocalPresetCoeffcients;
logic [LANESNUMBER -1:0] LocalTxCoefficientsValid;
logic [6*LANESNUMBER -1:0] LF;
logic [6*LANESNUMBER -1:0] FS;
logic [LANESNUMBER -1:0] RxEqEval;
logic [LANESNUMBER -1:0] InvalidRequest;
logic [6*LANESNUMBER -1:0] LinkEvaluationFeedbackDirectionChange;
logic [7:0] M2P_MessageBus;
logic [7:0] P2M_MessageBus;
logic [15:0] RxStandby;



endinterface