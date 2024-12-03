class LinkUp1_vseq  extends uvm_sequence #(LTSSM1_seq_item) ;
`uvm_component_utils(LinkUp1_vseq)

        uvm_sequencer sqr_u1;
        uvm_sequencer sqr_u2;

LTSSM1_seq_item seq_item;
LinkUp1_seq Linkup_seq;
Reset_LTSSM1_seq reset_seq;

function new (string name = "LinkUp1_vseq");
		super.new (name);
	endfunction

task body ();
reset_seq = Reset_LTSSM1_seq::type_id::create("reset_seq");
Linkup_seq = PCIE_LinkUP_SequenceU_LTSSM1::type_id::create("Linkup_seq");
            
reset_seq.start(sqr_u1);
reset_seq.start(sqr_u2);
#50;
Linkup_seq.start(sqr_u1);
Linkup_seq.start(sqr_u2);


endtask


endclass
