class TX_Slave_D_Agent extends uvm_agent;
  
  
`uvm_component_utils(TX_Slave_D_Agent)


TX_Slave_Config           TX_Slave_D_Config_h;
TX_Slave_D_Monitor        TX_Slave_D_Monitor_h;

uvm_analysis_port #(PIPE_seq_item) send_ap1;
uvm_analysis_port #(PIPE_seq_item) send_ap2;




extern function new(string name="TX_Slave_D_Agent",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);




endclass








function TX_Slave_D_Agent::new(string name="TX_Slave_D_Agent",uvm_component parent);
  
    super.new(name,parent);

endfunction




function void TX_Slave_D_Agent::build_phase(uvm_phase phase);
  
    super.build_phase(phase);
    
    if(!uvm_config_db#(TX_Slave_Config)::get(this,"","TX_Slave_D_Config_h",TX_Slave_D_Config_h))
                   `uvm_fatal(get_type_name(),"Can't be able to get TX_Slave_D configuration object")
                   
    TX_Slave_D_Monitor_h = TX_Slave_D_Monitor::type_id::create("TX_Slave_D_Monitor_h",this);
    
    send_ap1 = new("send_ap1",this);
    send_ap2 = new("send_ap2",this);

endfunction




function void TX_Slave_D_Agent::connect_phase(uvm_phase phase);
  
    super.connect_phase(phase);
    
    TX_Slave_D_Monitor_h.send_ap1.connect(this.send_ap1);
    TX_Slave_D_Monitor_h.send_ap2.connect(this.send_ap2);
    TX_Slave_D_Monitor_h.PIPE_vif_h = TX_Slave_D_Config_h.PIPE_vif_h;
        
endfunction



task TX_Slave_D_Agent::run_phase(uvm_phase phase);
  
    super.run_phase(phase);

endtask
