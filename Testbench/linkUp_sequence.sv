package linkUp_sequence_pkg;
    
    import PCIe_Seq_Item_pkg::*;
    import uvm_pkg::*;
        `include "uvm_macros.svh"
    class linkUp1_sequence extends uvm_sequence #(PCIe_Seq_Item) ;
        `uvm_object_utils(linkUp1_sequence)

        PCIe_Seq_Item item;
        function new(string name ="linkUp1_sequence");
            super.new(name);
        endfunction

        task body();
            item=PCIe_Seq_Item::type_id::create("item");
            start_item(item);
                item.operation=2'b00;
            finish_item(item);
        endtask
    endclass

    class reset_sequence extends uvm_sequence #(PCIe_Seq_Item) ;
        `uvm_component_utils(reset_sequence)

        PCIe_Seq_Item item;
        function new(string name ="reset_sequence");
            super.new(name);
        endfunction

        task body();
            item=PCIe_Seq_Item::type_id::create("item");
            start_item(item);
                item.lpreset=0;
                #2;
                item.lpreset=1;
            finish_item(item);
        endtask 
    endclass


    class virtual_sequence extends uvm_sequence #(PCIe_Seq_Item) ;
        `uvm_component_utils(reset_sequence)

        uvm_sequencer sqr_u1;
        uvm_sequencer sqr_u2;

        reset_sequence rst_n;
        linkUp1_sequence LinkUp;
        PCIe_Seq_Item item;
        function new(string name ="reset_sequence");
            super.new(name);
        endfunction

        task body();
            rst_n=reset_sequence::type_id::create("rst");
            LinkUp=linkUp1_sequence::type_id::create("linkUp1_sequence");

            rst_n.start(sqr_u1);
            rst_n.start(sqr_u2);
            #1;
            LinkUp.start(sqr_u1);
            LinkUp.start(sqr_u2);
        endtask
    endclass








endpackage