////////////////////////////////////////////////////////////////////////////////
// Author: Marwan mohamed
// Description: agent for up stream LTSSM 2
// 
////////////////////////////////////////////////////////////////////////////////
package PCIe_AgentU_LTSSM2_pkg;
    import uvm_pkg::*;
        `include "uvm_macros.svh"
    import PCIe_Seq_Item_pkg::*;
    import PCIe_Cfg_LTSSM2_pkg::*;
    import PCIe_Driver_AUL2_pkg::*;
    import PCIe_Monitor_AUL2_pkg::*;
    import PCIe_sequencer_AUL2_pkg::*;

    class PCIe_AgentU_LTSSM2 extends uvm_agent;
        `uvm_component_utils(PCIe_AgentU_LTSSM2)

        PCIe_Monitor_AUL2 Monitor_AUL2;
        PCIe_Driver_AUL2    Driver_AUL2;
        PCIe_sequencer_AUL2 sequencer_AUL2;
        PCIe_Cfg_LTSSM2     CFG_L2;

        uvm_analysis_port #(PCIe_Seq_Item) LTSSM2_agentU_port;

        extern function new(string name="PCIe_AgentU_LTSSM2",uvm_component parent);

        extern function void build_phase(uvm_phase phase);


        extern function void connect_phase(uvm_phase phase);

    endclass


        function PCIe_AgentU_LTSSM2::new(string name="PCIe_AgentU_LTSSM2",uvm_component parent);
            super.new(name,parent);
        endfunction

        function void PCIe_AgentU_LTSSM2::build_phase(uvm_phase phase);
            super.build_phase(phase);
            Driver_AUL2=PCIe_Driver_AUL2::type_id::create("Driver_AUL2",this);
            sequencer_AUL2=PCIe_sequencer_AUL2::type_id::create("sequencer_AUL2",this);
            LTSSM2_agentU_port=new("LTSSM2 UPSTEREAM analysis port");
            Monitor_AUL2=PCIe_Monitor_AUL2::type_id::create("Monitor_AUL2",this);

            if(! uvm_config_db #(PCIe_Cfg_LTSSM2)::get(this,"*","LPIF_intfD",CFG_L2))
                `uvm_fatal("build_phase","cant get configuration object for PCIe_AgentD_LTSSM2");
        endfunction

        function void PCIe_AgentU_LTSSM2::connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            Driver_AUL2.seq_item_port.connect(sequencer_AUL2.seq_item_export);
            Monitor_AUL2.monitor_AUL2_port.connect(LTSSM2_agentU_port);
            Driver_AUL2.LPIF_vif=CFG_L2.vif;
            Monitor_AUL2.LPIF_intfD=CFG_L2.vif;
        endfunction

endpackage