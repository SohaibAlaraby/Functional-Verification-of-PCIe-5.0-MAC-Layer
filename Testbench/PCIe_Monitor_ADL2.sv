////////////////////////////////////////////////////////////////////////////////
// Author: Marwan mohamed
// Description: monitor for down stream LTSSM 2
// 
////////////////////////////////////////////////////////////////////////////////


package PCIe_Monitor_ADL2_pkg;
    import uvm_pkg::*;
        `include "uvm_macros.svh"
    import PCIe_Seq_Item_pkg::*;

    class PCIe_Monitor_ADL2 extends uvm_monitor;
        `uvm_component_utils(PCIe_Monitor_ADL2)
        virtual LPIF_if LPIF_intfD; //beside LPIF Interface
        
        uvm_analysis_port #(PCIe_Seq_Item) monitor_ADL2_port;
        PCIe_Seq_Item item;

        extern function new(string name="PCIe_Monitor_ADL2",uvm_component parent);


        extern function void build_phase(uvm_phase phase);

        extern task run_phase(uvm_phase phase);

        

    endclass


    function PCIe_Monitor_ADL2::new(string name="PCIe_Monitor_ADL2",uvm_component parent);
        super.new(name,parent);
    endfunction 

    function void PCIe_Monitor_ADL2::build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor_ADL2_port = new("Monitor_To_Scoreboard",this);
    endfunction
     
    task PCIe_Monitor_ADL2::run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            
        end
    endtask
        
endpackage