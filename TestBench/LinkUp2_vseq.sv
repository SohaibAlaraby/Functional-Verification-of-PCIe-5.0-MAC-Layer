
class LinkUp2_vseq extends uvm_sequence #(LTSSM2_seq_item);

        `uvm_object_utils(LinkUp2_vseq)

        LTSSM2_D_Sequencer sqr_u1;
        LTSSM2_U_Sequencer sqr_u2;

        Reset_LTSSM2_seq    rst_n;
        LinkUp2_seq         LinkUp;
        LTSSM2_seq_item     item;

        function new(string name ="LinkUp2_vseq");
            super.new(name);
        endfunction

        task body();
            rst_n=Reset_LTSSM2_seq::type_id::create("rst");
            LinkUp=LinkUp2_seq::type_id::create("LinkUp2_seq");

            rst_n.start(sqr_u1);
            rst_n.start(sqr_u2);
            #50;
            LinkUp.start(sqr_u1);
            LinkUp.start(sqr_u2);
            
        endtask
endclass



