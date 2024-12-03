class RX_Slave_Config extends uvm_object;



`uvm_object_utils(RX_Slave_Config)



virtual PIPE_if PIPE_vif_h;

uvm_active_passive_enum active = UVM_ACTIVE;

bit Has_Coverage_Collector = 1;



function new (string name = "RX_Slave_Config");
  
   super.new(name);
  
endfunction



endclass