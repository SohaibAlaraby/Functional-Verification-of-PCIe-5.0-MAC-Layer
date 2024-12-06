class Reset_LTSSM1_seq extends uvm_sequence #(LTSSM1_seq_item);
  
`uvm_object_utils(Reset_LTSSM1_seq)

LTSSM1_seq_item seq_item;

function new (string name = "Reset_LTSSM1_seq");

super.new(name);

endfunction

task body ();

seq_item = LTSSM1_seq_item::type_id::create("seq_item");

start_item(seq_item);
seq_item.OP = 2'b00;
finish_item(seq_item);

endtask

endclass