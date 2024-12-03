class LTSSM1_D_Agent  extends uvm_agent;
`uvm_component_utils(LTSSM1_D_Agent)

uvm_analysis_port #(LTSSM1_seq_item) LTSSM1_D_Agent_ap;

LTSSM1_D_Driver DriverD_LTSSM1;
LTSSM1_D_Sequencer SequencerD_LTSSM1; 
PCIe_Monitor_ADL1 Monitor_ADL1;
LTSSM1_Config  Config_Obj_LTSSM1;

function new(string name="LTSSM1_D_Agent",uvm_component parent = null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    DriverD_LTSSM1 = LTSSM1_D_Driver::type_id::create("DriverD_LTSSM1",this);
    SequencerD_LTSSM1 = LTSSM1_D_Sequencer::type_id::create("SequencerD_LTSSM1",this);
    Monitor_ADL1 = PCIe_Monitor_ADL1::type_id::create("Monitor_ADL1",this);
    LTSSM1_D_Agent_ap = new("LTSSM1_D_Agent_ap",this);

    if(!uvm_config_db #(LTSSM1_Config)::get(this,"","cfg",Config_Obj_LTSSM1)) begin
        `uvm_fatal("build_phase","Config_Obj_LTSSM1 failed to get the configuration object from configuration database")
    end
endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    DriverD_LTSSM1.seq_item_port.connect(SequencerD_LTSSM1.seq_item_export);
    DriverD_LTSSM1.driver_vif = Config_Obj_LTSSM1.PIPE_vif;
    Monitor_ADL1.mon_vif = Config_Obj_LTSSM1.PIPE_vif;
    Monitor_ADL1.mon_ap.connect(LTSSM1_D_Agent_ap);

endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);

endtask

endclass
