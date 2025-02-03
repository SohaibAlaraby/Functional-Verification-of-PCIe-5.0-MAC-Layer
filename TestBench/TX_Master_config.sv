class TX_Master_Config extends uvm_object;
`uvm_object_utils(TX_Master_Config)

virtual LPIF_if LPIF_vif_h;

bit Has_Coverage_Collector = 1;

function new (string name = "TX_Master_Config");
   super.new(name);
endfunction

endclass
