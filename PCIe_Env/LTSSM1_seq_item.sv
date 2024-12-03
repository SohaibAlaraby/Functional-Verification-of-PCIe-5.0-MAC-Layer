class LTSSM1_seq_item extends uvm_sequence_item;
`uvm_object_utils(LTSSM1_seq_item)

// Items // 
bit [1:0] OP;
logic [LANESNUMBER-1:0] TxDetectRx_Loopback;
logic [3*LANESNUMBER -1:0] RxStatus;
logic [LANESNUMBER-1:0] PhyStatus;
logic phy_reset;


// Constructor //
function new (string name = "LTSSM1_seq_item");

super.new(name);

endfunction


function string convert2string();

return $sformatf("%s , OP = 0b%b ",super.convert2string(),OP);

endfunction

function string convert2string_stimulus();

return $sformatf("OP = 0b%b ",OP);

endfunction


// Constraint Blocks //



endclass