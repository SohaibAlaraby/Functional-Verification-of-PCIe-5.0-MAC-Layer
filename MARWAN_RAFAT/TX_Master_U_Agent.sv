class TX_Master_U_Agent extends uvm_agent;
  
`uvm_component_utils(TX_Master_U_Agent)

TX_Master_Config          TX_Master_Config_h;
TX_Master_U_Driver        TX_Master_U_Driver_h;
TX_Master_U_Sequencer     TX_Master_U_Sequencer_h;

uvm_analysis_port #(TX_Master_seq_item) send_ap;



extern function new(string name="TX_Master_U_Agent",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);




endclass





function TX_Master_U_Agent::new(string name="TX_Master_U_Agent",uvm_component parent);
            super.new(name,parent);
endfunction




function void TX_Master_U_Agent::build_phase(uvm_phase phase);
            super.build_phase(phase);
            TX_Master_U_Driver_h    = TX_Master_U_Driver::type_id::create("TX_Master_U_Driver_h",this);
            TX_Master_U_Sequencer_h = TX_Master_U_Sequencer::type_id::create("TX_Master_U_Sequencer_h",this);
            send_ap              = new("send_ap",this);
            `uvm_info(get_type_name() ," in build_phase of TX_Master_U_Agent ",UVM_LOW);
            if(! uvm_config_db #(TX_Master_Config)::get(this,"*","TX_Master_U_Config_h",TX_Master_Config_h))
                `uvm_fatal("build_phase","Can't get TX Master U configuration object");

endfunction





function void TX_Master_U_Agent::connect_phase(uvm_phase phase);
            `uvm_info(get_type_name() ," in connect_phase of TX_Master_U_Agent ",UVM_LOW);
            super.connect_phase(phase);
            
            TX_Master_U_Driver_h.seq_item_port.connect(TX_Master_U_Sequencer_h.seq_item_export);
            TX_Master_U_Driver_h.LPIF_vif_h = TX_Master_Config_h.LPIF_vif_h;
            
            TX_Master_U_Driver_h.send_ap.connect(send_ap);
            
endfunction
