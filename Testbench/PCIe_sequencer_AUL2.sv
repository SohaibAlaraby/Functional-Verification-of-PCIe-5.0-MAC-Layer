////////////////////////////////////////////////////////////////////////////////
// Author: Marwan mohamed
// Description: sequencer for up stream LTSSM 2
// 
////////////////////////////////////////////////////////////////////////////////


package PCIe_sequencer_AUL2_pkg;
    import uvm_pkg::*;
        `include "uvm_macros.svh"
    import PCIe_Seq_Item_pkg::*;

    class PCIe_sequencer_AUL2 extends uvm_sequencer #(PCIe_Seq_Item);
        `uvm_component_utils(PCIe_sequencer_AUL2)

        extern function new(string name="PCIe_sequencer_AUL2",uvm_component phase);

    endclass

    function PCIe_sequencer_AUL2::new(string name="PCIe_sequencer_AUL2",uvm_component phase);
            super.new(name,phase);
    endfunction
endpackage