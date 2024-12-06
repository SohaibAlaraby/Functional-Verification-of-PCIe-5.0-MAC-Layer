class PIPE_seq_item extends uvm_sequence_item;
  
`uvm_object_utils(PIPE_seq_item)


bit [`MAXPIPEWIDTH*`LANESNUMBER-1:0] TxData;
bit [`LANESNUMBER-1:0] TxDataValid;
bit [`LANESNUMBER-1:0] TxElecIdle;
bit [`LANESNUMBER-1:0] TxStartBlock;
bit [(`MAXPIPEWIDTH/8)*`LANESNUMBER-1:0] TxDataK;
bit [2*`LANESNUMBER -1:0] TxSyncHeader;
bit [`LANESNUMBER-1:0] TxDetectRx_Loopback;



function new(string name = "PIPE_seq_item");
    super.new(name);
endfunction



endclass