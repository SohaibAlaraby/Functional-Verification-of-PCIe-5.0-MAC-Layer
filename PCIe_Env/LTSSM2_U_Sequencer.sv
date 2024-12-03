
class LTSSM2_U_Sequencer extends uvm_sequencer #(LTSSM2_seq_item);
        `uvm_component_utils(LTSSM2_U_Sequencer)

        extern function new(string name="LTSSM2_U_Sequencer",uvm_component phase);

endclass



function LTSSM2_U_Sequencer::new(string name="LTSSM2_U_Sequencer",uvm_component phase);
            super.new(name,phase);
endfunction
