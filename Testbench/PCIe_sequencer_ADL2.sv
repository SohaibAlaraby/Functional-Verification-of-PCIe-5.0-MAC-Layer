////////////////////////////////////////////////////////////////////////////////
// Author: Marwan mohamed
// Description: sequencer for down stream LTSSM 2
// 
////////////////////////////////////////////////////////////////////////////////

    class PCIe_sequencer_ADL2 extends uvm_sequencer #(PCIe_Seq_Item);
        `uvm_component_utils(PCIe_sequencer_ADL2);

        extern function new(string name="PCIe_sequencer_ADL2",uvm_component phase);

    endclass

    function PCIe_sequencer_ADL2::new(string name="PCIe_sequencer_ADL2",uvm_component phase);
        super.new(name,phase);
    endfunction
