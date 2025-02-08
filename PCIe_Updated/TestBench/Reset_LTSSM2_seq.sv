
class Reset_LTSSM2_seq extends uvm_sequence #(LTSSM2_seq_item) ;
        `uvm_object_utils(Reset_LTSSM2_seq)

        LTSSM2_seq_item item;
        function new(string name ="Reset_LTSSM2_seq");
            super.new(name);
        endfunction

        task body();
            item=LTSSM2_seq_item::type_id::create("item");
            start_item(item);
                item.operation = 2'b00;
            finish_item(item);

            
            
        endtask 
endclass
