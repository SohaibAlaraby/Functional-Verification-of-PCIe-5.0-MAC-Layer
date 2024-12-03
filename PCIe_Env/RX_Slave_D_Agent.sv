class RX_Slave_D_Agent extends uvm_agent;
 
  
`uvm_component_utils(RX_Slave_D_Agent)

RX_Slave_Config        RX_Slave_D_Config_h;
RX_Slave_D_Monitor     RX_Slave_D_Monitor_h;
RX_Slave_D_Driver      RX_Slave_D_Driver_h;

uvm_analysis_port #(PIPE_RX_seq_item) send_ap;
uvm_analysis_port #(PIPE_RX_seq_item) receive_ap;






function new(string name="RX_Slave_D_Agent",uvm_component parent);
function void build_phase(uvm_phase phase);
function void connect_phase(uvm_phase phase);
task run_phase(uvm_phase phase);
 



endclass







function RX_Slave_D_Agent::new(string name="RX_Slave_D_Agent",uvm_component parent);
  
     super.new(name,parent);

endfunction




function void RX_Slave_D_Agent::build_phase(uvm_phase phase);
  
    super.build_phase(phase);
      if(!uvm_config_db#(RX_Slave_Config)::get(this,"","RX_Slave_D_Config_h",RX_Slave_D_Config_h))
                   `uvm_fatal(get_type_name(),"Can't be able to get TX_Slave_D configuration object")
                   
    RX_Slave_D_Monitor_h = RX_Slave_D_Monitor::type_id::create("RX_Slave_D_Monitor_h",this);
    RX_Slave_D_Driver_h = RX_Slave_D_Driver::type_id::create("RX_Slave_D_Driver_h",this);   
    
    send_ap = new("send_ap",this);
    receive_ap = new("receive_ap",this);
    
endfunction






function void RX_Slave_D_Agent::connect_phase(uvm_phase phase);
  
    super.connect_phase(phase);
    RX_Slave_D_Driver_h.receive_TLM_FIFO.connect(this.receive_ap);
    RX_Slave_D_Monitor_h.send_ap.connect(this.send_ap);
    
    RX_Slave_D_Monitor_h.PIPE_vif_h = RX_Slave_D_Config_h.PIPE_vif_h;
    RX_Slave_D_Driver_h.PIPE_vif_h = RX_Slave_D_Config_h.PIPE_vif_h;
                    
endfunction





task RX_Slave_D_Agent::run_phase(uvm_phase phase);
  
    super.run_phase(phase);

endtask
