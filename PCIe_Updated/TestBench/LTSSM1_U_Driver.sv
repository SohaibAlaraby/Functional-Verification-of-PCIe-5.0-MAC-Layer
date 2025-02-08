class LTSSM1_U_Driver  extends uvm_driver #(LTSSM1_seq_item);
  
`uvm_component_utils(LTSSM1_U_Driver)



LTSSM1_seq_item LTSSM1_seq_item_h;

virtual PIPE_if PIPE_vif_h;

event Receiver_Detected;


extern function new(string name = "LTSSM1_U_Driver",uvm_component parent);
extern function void build_phase (uvm_phase phase);
extern function void connect_phase (uvm_phase phase);
extern task run_phase (uvm_phase phase);
extern task drive (LTSSM1_seq_item LTSSM1_seq_item_h);


endclass








function LTSSM1_U_Driver::new(string name = "LTSSM1_U_Driver",uvm_component parent);
  
        super.new(name , parent);
        
endfunction 




function void LTSSM1_U_Driver::build_phase (uvm_phase phase);
  
super.build_phase(phase);

endfunction



function void LTSSM1_U_Driver::connect_phase (uvm_phase phase);
  
super.connect_phase(phase);

endfunction




task LTSSM1_U_Driver::run_phase (uvm_phase phase);
  
forever begin
  
   LTSSM1_seq_item_h =  LTSSM1_seq_item::type_id::create("LTSSM1_seq_item_h",this);
   
   seq_item_port.get_next_item(LTSSM1_seq_item_h);
   
   drive(LTSSM1_seq_item_h);
   
   seq_item_port.item_done(LTSSM1_seq_item_h);

end

endtask




task LTSSM1_U_Driver::drive (LTSSM1_seq_item  LTSSM1_seq_item_h);
  
`uvm_info(get_type_name() ," in LTSSM1_U_Driver ",UVM_HIGH)
        

   case (LTSSM1_seq_item_h.operation) 
     
       2'b00: begin
                    @(PIPE_vif_h.phy_reset);
                    PIPE_vif_h.PhyStatus = {`LANESNUMBER{1'b1}};
                    @(posedge PIPE_vif_h.PCLK);
                    PIPE_vif_h.PhyStatus = {`LANESNUMBER{1'b0}};;
    
               end

      2'b01: begin
                    `uvm_info(get_type_name() ," before detection ",UVM_HIGH)
                    wait(PIPE_vif_h.TxDetectRx_Loopback == {`LANESNUMBER{1'b1}});
                     -> Receiver_Detected;
                    `uvm_info(get_type_name() ," after detection ",UVM_HIGH)
                    PIPE_vif_h.PhyStatus = {`LANESNUMBER{1'b1}};
                    PIPE_vif_h.RxStatus={3*`LANESNUMBER{3'b011}};;
                    @(posedge PIPE_vif_h.PCLK);
                    PIPE_vif_h.PhyStatus = {`LANESNUMBER{1'b0}};
                    PIPE_vif_h.RxStatus={3*`LANESNUMBER{3'b000}};
             end

    endcase


endtask

