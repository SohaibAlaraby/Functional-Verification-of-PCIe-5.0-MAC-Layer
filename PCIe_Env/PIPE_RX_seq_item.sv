class PIPE_RX_seq_item extends uvm_sequence_item;
  
`uvm_object_utils(PIPE_RX_seq_item) 

bit [`MAXPIPEWIDTH*`LANESNUMBER-1:0] RxData;
bit [`LANESNUMBER-1:0] RxDataValid;
bit [(`MAXPIPEWIDTH/8)*`LANESNUMBER-1:0] RxDataK;
bit [`LANESNUMBER-1:0] RxStartBlock;
bit [2*`LANESNUMBER -1:0] RxSyncHeader;
bit [3*`LANESNUMBER -1:0] RxStatus;
bit [15:0] RxElectricalIdle;




function new(string name = "PIPE_RX_seq_item");
    super.new(name);
endfunction



endclass