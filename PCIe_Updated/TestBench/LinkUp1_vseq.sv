class LinkUp1_vseq  extends uvm_sequence #(LTSSM1_seq_item) ;
  
`uvm_object_utils(LinkUp1_vseq)

LTSSM1_D_Sequencer sqr_u1;
LTSSM1_U_Sequencer sqr_u2;


LinkUp1_seq Linkup_seq_D,Linkup_seq_U;
Reset_LTSSM1_seq reset_seq_D,reset_seq_U;


function new (string name = "LinkUp1_vseq");
		super.new (name);
	endfunction


task body ();
  
reset_seq_D = Reset_LTSSM1_seq::type_id::create("reset_seq_D");
reset_seq_U = Reset_LTSSM1_seq::type_id::create("reset_seq_U");

Linkup_seq_D = LinkUp1_seq::type_id::create("Linkup_seq_D");
Linkup_seq_U = LinkUp1_seq::type_id::create("Linkup_seq_U"); 
           
  reset_seq_D.start(sqr_u1);
  reset_seq_U.start(sqr_u2);

   
  #50;
  
 fork
  Linkup_seq_D.start(sqr_u1);
  Linkup_seq_U.start(sqr_u2);
 join

endtask


endclass
