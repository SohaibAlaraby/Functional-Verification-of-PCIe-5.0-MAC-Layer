class LTSSM2_U_Driver extends uvm_driver#(LTSSM2_seq_item);
  
`uvm_component_utils(LTSSM2_U_Driver)

virtual LPIF_if LPIF_vif_h;
LTSSM2_seq_item item;
        
        
extern function new(string name = "LTSSM2_U_Driver",uvm_component parent);
extern task run_phase(uvm_phase phase);
extern task drive (LTSSM2_seq_item item);

endclass




function LTSSM2_U_Driver::new(string name = "LTSSM2_U_Driver",uvm_component parent);
        super.new(name , parent);
endfunction 


task LTSSM2_U_Driver::run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name() ," in run_phase of driver of LTSSM2 ",UVM_LOW)
        forever begin
            item = LTSSM2_seq_item::type_id::create("item");
            seq_item_port.get_next_item(item);
            drive(item);
            seq_item_port.item_done();
        end
endtask: run_phase



task LTSSM2_U_Driver::drive (LTSSM2_seq_item item);
        
        
        
        case(item.operation)
         
         2'b00: begin
           
             LPIF_vif_h.lpreset=0; 
             @(posedge LPIF_vif_h.LCLK)
             LPIF_vif_h.lpreset=1;  
           
         end
         
         2'b01: begin
           
           LPIF_vif_h.lp_state_req = 1;
            
         end
          
          
    
        endcase 
        
  
endtask


