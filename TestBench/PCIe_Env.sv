class PCIe_Env extends uvm_env;
  
`uvm_component_utils(PCIe_Env)

//PCIe_ScoreboardD ScoreboardD;
//PCIe_ScoreboardU ScoreboardU;

TX_Slave_D_Agent TX_Slave_D_Agent_h; 
TX_Slave_U_Agent TX_Slave_U_Agent_h;
RX_Slave_D_Agent RX_Slave_D_Agent_h; 
RX_Slave_U_Agent RX_Slave_U_Agent_h;

LTSSM1_D_Agent   LTSSM1_D_Agent_h;
LTSSM1_U_Agent   LTSSM1_U_Agent_h;
LTSSM2_D_Agent   LTSSM2_D_Agent_h;
LTSSM2_U_Agent   LTSSM2_U_Agent_h;

TX_Master_D_Agent TX_Master_D_Agent_h;
TX_Master_U_Agent TX_Master_U_Agent_h;

RX_Passive_D_Agent RX_Passive_D_Agent_h;
RX_Passive_U_Agent RX_Passive_U_Agent_h;
  
Adapter          Adapter_h;

//PCIe_CoverageCollector_D Cov_Col_D;
//PCIe_CoverageCollector_U Cov_Col_U;

function new(string name = "PCIe_Env",uvm_component parent);
  
    super.new(name,parent);
    
endfunction


function void build_phase(uvm_phase phase);
  
    super.build_phase(phase);
    
    TX_Slave_D_Agent_h = TX_Slave_D_Agent::type_id::create("TX_Slave_D_Agent_h",this);
    TX_Slave_U_Agent_h = TX_Slave_U_Agent::type_id::create("TX_Slave_U_Agent_h",this);
  
    TX_Master_D_Agent_h = TX_Master_D_Agent::type_id::create("TX_Master_D_Agent_h",this);
    TX_Master_U_Agent_h = TX_Master_U_Agent::type_id::create("TX_Master_U_Agent",this);
  
    RX_Passive_D_Agent_h = RX_Passive_D_Agent::type_id::create("RX_Passive_D_Agent_h",this);
    RX_Passive_U_Agent_h = RX_Passive_U_Agent::type_id::create("RX_Passive_U_Agent_h",this);
  
    RX_Slave_D_Agent_h = RX_Slave_D_Agent::type_id::create("RX_Slave_D_Agent_h",this);
    RX_Slave_U_Agent_h = RX_Slave_U_Agent::type_id::create("RX_Slave_U_Agent_h",this);
    
    LTSSM1_D_Agent_h   = LTSSM1_D_Agent::type_id::create("LTSSM1_D_Agent_h",this);
    LTSSM1_U_Agent_h   = LTSSM1_U_Agent::type_id::create("LTSSM1_U_Agent_h",this);
    
    LTSSM2_D_Agent_h   = LTSSM2_D_Agent::type_id::create("LTSSM2_D_Agent_h",this);
    LTSSM2_U_Agent_h   = LTSSM2_U_Agent::type_id::create("LTSSM2_U_Agent_h",this);

    Adapter_h          = Adapter::type_id::create("Adapter_h",this);    
    
endfunction





function void connect_phase(uvm_phase phase);
  
    super.connect_phase(phase);
    
    Adapter_h.Adapter_To_D_RX_ap.connect(RX_Slave_D_Agent_h.receive_ap);
    Adapter_h.Adapter_To_U_RX_ap.connect(RX_Slave_U_Agent_h.receive_ap);
    
    TX_Slave_D_Agent_h.send_ap1.connect(Adapter_h.Adapter_From_D_TX_af.analysis_export);
    TX_Slave_U_Agent_h.send_ap1.connect(Adapter_h.Adapter_From_U_TX_af.analysis_export);
    
endfunction




task run_phase(uvm_phase phase);
  
    super.run_phase(phase);
    
endtask


endclass
