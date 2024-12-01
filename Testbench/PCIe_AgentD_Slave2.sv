class PCIe_AgentD_Slave2 extends uvm_agent;
`uvm_component_utils(PCIe_AgentD_Slave2)

PCIe_Monitor_ADS2 Monitor_ADS2;
PCIe_Driver_ADS2 Driver_ADS2;
uvm_analysis_port #(PCIe_Seq_Item) Monitor_ADS2_port;
function new(string name="PCIe_AgentD_Slave2",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    Monitor_ADS2_port=new("Monitor_ADS2_port",this);
    Monitor_ADS2=PCIe_Monitor_ADS2::type_id::create("Monitor_ADS2",this);
    Driver_ADS2=PCIe_Driver_ADS2::type_id::create("Driver_ADS2",this);
endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    Monitor_ADS2.Monitor_ADS2_port.connect(this.Monitor_ADS2_port);
endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);

endtask

endclass