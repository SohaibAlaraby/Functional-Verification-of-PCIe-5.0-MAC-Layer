class LinkUp1_seq extends uvm_sequence #(LTSSM1_seq_item);
`uvm_object_utils(LinkUp1_seq)

LTSSM1_seq_item seq_item;

function new (string name = "LinkUp1_seq");

super.new(name);

endfunction

task body ();

seq_item = LTSSM1_seq_item::type_id::create("seq_item");

start_item(seq_item);
seq_item.operation = 2'b01;
finish_item(seq_item);

endtask

endclass
