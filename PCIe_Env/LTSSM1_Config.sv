class LTSSM1_Config  extends uvm_object ;
`uvm_object_utils(LTSSM1_Config)

virtual PIPE PIPE_vif;

function new(string name = "LTSSM1_Config");

super.new(name);

endfunction

endclass

