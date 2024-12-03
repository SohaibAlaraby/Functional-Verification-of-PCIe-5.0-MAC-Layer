
class LinkUp2_vseq extends uvm_sequence #(LTSSM2_seq_item) ;
        `uvm_object_utils(reset_sequence)

        uvm_sequencer sqr_u1;
        uvm_sequencer sqr_u2;

        reset_sequence rst_n;
        linkUp1_sequence LinkUp;
        LTSSM2_seq_item item;
        function new(string name ="reset_sequence");
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



