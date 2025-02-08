class RX_Slave_Config extends uvm_object;



`uvm_object_utils(RX_Slave_Config)



virtual PIPE_if PIPE_vif_h;

uvm_active_passive_enum active = UVM_ACTIVE;

bit Has_Coverage_Collector = 1;

event Received_TS2_in_Polling_Configuration;
event Received_2_TS1_in_Config_Link_Width_Start;
event Received_2_TS1_in_Config_Link_Width_Accept;
event Received_2_TS1_in_Config_Lanenum_Wait;
event Received_2_TS1_in_Config_Lanenum_Accept;
event Received_2_TS2_in_Config_Lanenum_Wait;
event Received_2_TS2_in_Config_Lanenum_Accept;
event Received_TS2_in_Config_Complete;
event Received_Idle_in_Config_Idle;
event Config_Complete_Substate_Completed;
event Polling_Active_Substate_Completed;
event Polling_Configuration_Substate_Completed;
event Config_Link_Width_Start_Substate_Completed;

function new (string name = "RX_Slave_Config");
  
   super.new(name);
  
endfunction



endclass