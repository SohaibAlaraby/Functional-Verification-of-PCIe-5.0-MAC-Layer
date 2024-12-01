class PCIe_AgentU_Slave2 extends uvm_agent;
`uvm_component_utils(PCIe_AgentU_Slave2)

PCIe_Monitor_AUS2 Monitor_AUS2;
PCIe_Driver_AUS2 Driver_AUS2;
uvm_analysis_port #(PCIe_Seq_Item) Monitor_AUS2_port;
function new(string name="PCIe_AgentU_Slave2",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    Monitor_AUS2=PCIe_Monitor_AUS2::type_id::create("Monitor_AUS2",this);
    Driver_AUS2=PCIe_Driver_AUS2::type_id::create("Driver_AUS2",this);
    Monitor_AUS2_port=new("Monitor_AUS2_port",this);
endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    Monitor_AUS2.Monitor_AUS2_port.connect(this.Monitor_AUS2_port);
endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);

endtask

endclass