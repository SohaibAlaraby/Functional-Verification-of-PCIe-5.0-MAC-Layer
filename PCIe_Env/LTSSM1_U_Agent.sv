class LTSSM1_U_Agent extends uvm_agent;
`uvm_component_utils(LTSSM1_U_Agent)

uvm_analysis_port #(LTSSM1_seq_item) LTSSM1_U_Agent_ap;

LTSSM1_U_Driver DriverU_LTSSM1;
LTSSM1_U_Sequencer SequencerU_LTSSM1; 
PCIe_Monitor_AUL1 Monitor_AUL1;
LTSSM1_Config  Config_Obj_LTSSM1;

function new(string name="LTSSM1_U_Agent",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    DriverU_LTSSM1 = LTSSM1_U_Driver::type_id::create("DriverU_LTSSM1",this);
    SequencerU_LTSSM1 = LTSSM1_U_Sequencer::type_id::create("SequencerU_LTSSM1",this);
    Monitor_AUL1=PCIe_Monitor_AUL1::type_id::create("Monitor_AUL1",this);
    LTSSM1_U_Agent_ap = new("LTSSM1_U_Agent_ap",this);

    if(!uvm_config_db #(LTSSM1_Config)::get(this,"","cfg",Config_Obj_LTSSM1)) begin
        `uvm_fatal("build_phase","Config_Obj_LTSSM1 failed to get the configuration object from configuration database")
    end

endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
     DriverU_LTSSM1.seq_item_port.connect(SequencerU_LTSSM1.seq_item_export);
     DriverU_LTSSM1.driver_vif = Config_ObjU_LTSSM1.PIPE_vif; 
     Monitor_AUL1.mon_vif = Config_ObjU_LTSSM1.PIPE_vif;
     Monitor_AUL1.mon_ap.connect(LTSSM1_U_Agent_ap);

endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);

endtask

endclass
