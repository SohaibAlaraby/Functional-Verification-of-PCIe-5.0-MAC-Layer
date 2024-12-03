class LTSSM1_U_Sequencer extends uvm_sequencer #(LTSSM1_seq_item);
`uvm_component_utils(LTSSM1_U_Sequencer)

function new(string name = "LTSSM1_U_Sequencer", uvm_component parent = null);

super.new(name,parent);

endfunction

endclass
