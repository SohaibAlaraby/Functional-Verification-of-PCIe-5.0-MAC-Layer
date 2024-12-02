////////////////////////////////////////////////////////////////////////////////
// Author: Marwan mohamed
// Description: agent for down stream LTSSM 2
// 
////////////////////////////////////////////////////////////////////////////////

    class PCIe_AgentD_LTSSM2 extends uvm_agent;
        `uvm_component_utils(PCIe_AgentD_LTSSM2)
        PCIe_Cfg_LTSSM2     CFG_L2;
        PCIe_Monitor_ADL2   Monitor_ADL2;
        PCIe_Driver_ADL2    Driver_ADL2;
        PCIe_sequencer_ADL2 sequencer_ADL2;

        uvm_analysis_port #(PCIe_Seq_Item) LTSSM2_agentD_port;

        extern function new(string name="PCIe_AgentD_LTSSM2",uvm_component parent);


        extern function void build_phase(uvm_phase phase);

        extern function void connect_phase(uvm_phase phase);

        endclass

        function PCIe_AgentD_LTSSM2::new(string name="PCIe_AgentD_LTSSM2",uvm_component parent);
            super.new(name,parent);
        endfunction

        function void PCIe_AgentD_LTSSM2::build_phase(uvm_phase phase);
            super.build_phase(phase);
            Monitor_ADL2=PCIe_Monitor_ADL2::type_id::create("Monitor_ADL2",this);
            Driver_ADL2=PCIe_Driver_ADL2::type_id::create("Driver_ADL2",this);
            sequencer_ADL2=PCIe_sequencer_ADL2::type_id::create("sequencer_ADL2",this);
            LTSSM2_agentD_port=new("LTSSM2 DOWNSTEREAM analysis port");

            if(! uvm_config_db #(PCIe_Cfg_LTSSM2)::get(this,"*","LPIF_intfD",CFG_L2))
                `uvm_fatal("build_phase","cant get configuration object for PCIe_AgentD_LTSSM2");

        endfunction

        function void PCIe_AgentD_LTSSM2::connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            Driver_ADL2.seq_item_port.connect(sequencer_ADL2.seq_item_export);
            Driver_ADL2.LPIF_vif=CFG_L2.vif;
            Monitor_ADL2.LPIF_intfD=CFG_L2.vif;
            Monitor_ADL2.monitor_ADL2_port.connect(LTSSM2_agentD_port);
        endfunction
