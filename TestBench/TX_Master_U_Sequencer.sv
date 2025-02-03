
class TX_Master_U_Sequencer extends uvm_sequencer #(TX_Master_seq_item);
        `uvm_component_utils(TX_Master_U_Sequencer)

        extern function new(string name="TX_Master_U_Sequencer",uvm_component phase);

endclass



function TX_Master_U_Sequencer::new(string name="TX_Master_U_Sequencer",uvm_component phase);
            super.new(name,phase);
endfunction
