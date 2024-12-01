class PCIe_Env extends uvm_env;
`uvm_component_utils(PCIe_Env)
PCIe_ScoreboardD ScoreboardD;
PCIe_ScoreboardU ScoreboardU;
PCIe_AgentD_LTSSM1 LTSSM1_AD; // AD --> Agent Downstream
PCIe_AgentD_LTSSM2 LTSSM2_AD;
PCIe_AgentU_LTSSM1 LTSSM1_AU;
PCIe_AgentU_LTSSM2 LTSSM2_AU;
PCIe_AgentD_Master Master_AD;
PCIe_AgentU_Master Master_AU;
PCIe_AgentD_Slave1 Slave1_AD;
PCIe_AgentD_Slave2 Slave2_AD;
PCIe_AgentD_Slave3 Slave3_AD;
PCIe_AgentU_Slave1 Slave1_AU;
PCIe_AgentU_Slave2 Slave2_AU;
PCIe_AgentU_Slave3 Slave3_AU;
PCIe_CoverageCollector_D Cov_Col_D;
PCIe_CoverageCollector_U Cov_Col_U;

function new(string name = "PCIe_Env",uvm_component parent);
    super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ScoreboardD=PCIe_ScoreboardD::type_id::create("ScoreboardD",this);
    ScoreboardU=PCIe_ScoreboardU::type_id::create("ScoreboardU",this);
    LTSSM1_AD=PCIe_AgentD_LTSSM1::type_id::create("LTSSM1_AD",this);
    LTSSM2_AD=PCIe_AgentD_LTSSM2::type_id::create("LTSSM2_AD",this);
    LTSSM1_AU=PCIe_AgentU_LTSSM1::type_id::create("LTSSM1_AU",this);
    LTSSM2_AU=PCIe_AgentU_LTSSM2::type_id::create("LTSSM2_AU",this);
    Master_AD=PCIe_AgentD_Master::type_id::create("Master_AD",this);
    Master_AU=PCIe_AgentU_Master::type_id::create("Master_AU",this);
    Slave1_AD=PCIe_AgentD_Slave1::type_id::create("Slave1_AD",this);
    Slave2_AD=PCIe_AgentD_Slave2::type_id::create("Slave2_AD",this);
    Slave3_AD=PCIe_AgentD_Slave3::type_id::create("Slave3_AD",this);
    Slave1_AU=PCIe_AgentU_Slave1::type_id::create("Slave1_AU",this);
    Slave2_AU=PCIe_AgentU_Slave2::type_id::create("Slave2_AU",this);
    Slave3_AU=PCIe_AgentU_Slave3::type_id::create("Slave3_AU",this);
    Cov_Col_D=PCIe_CoverageCollector_D::type_id::create("Cov_Col_D",this);
    Cov_Col_U=PCIe_CoverageCollector_U::type_id::create("Cov_Col_U",this);
endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    /*
    Adapter --> Downstream
    Adapter --> fifo 
    Adapter name and put port name inside the Adapter must be modified to
    the actual names
    */
    Adapter_Name.down_put_port.connect(Slave2_AD.Driver_ADS2.Adapter_To_Down_RX_Tlm_Fifo.analysis_export);
    /*
    Adapter --> Upstream
    Adapter --> fifo 
    Adapter name and put port name inside the Adapter must be modified to
    the actual names
    */
    Adapter_Name.up_put_port.connect(Slave2_AU.Driver_AUS2.Adapter_To_Up_RX_Tlm_Fifo.analysis_export);
endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask


endclass