class Adapter extends uvm_component;

  `uvm_component_utils(Adapter)


  uvm_analysis_port#(PIPE_seq_item)     Adapter_To_D_RX_ap;
  uvm_analysis_port#(PIPE_seq_item)     Adapter_To_U_RX_ap;

  
  uvm_tlm_analysis_fifo#(PIPE_seq_item) Adapter_From_D_TX_af;
  uvm_tlm_analysis_fifo#(PIPE_seq_item) Adapter_From_U_TX_af;
  
  
  PIPE_seq_item PIPE_seq_item_From_Up;
  PIPE_seq_item PIPE_seq_item_From_Down;



  function new(string name, uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), "Inside Adapter class constructor", UVM_LOW);


    Adapter_To_D_RX_ap = new("Adapter_To_D_RX_ap", this);
    Adapter_To_U_RX_ap = new("Adapter_To_U_RX_ap", this);


    Adapter_From_D_TX_af = new("Adapter_From_D_TX_af", this);
    Adapter_From_U_TX_af = new("Adapter_From_U_TX_af", this);
    
  endfunction




  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Inside Adapter class build phase", UVM_LOW);
    
  endfunction




  task run_phase(uvm_phase phase);
    
    super.run_phase(phase);
    `uvm_info(get_type_name(), "Inside Adapter class run phase", UVM_LOW);
   
       fork 
  
             ByPassData2Up();
             ByPassData2Down();
  
      join
        
        
  endtask





 task ByPassData2Up();
   
   
     forever begin
       
      Adapter_From_D_TX_af.get(PIPE_seq_item_From_Down);
   
      Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);  
      
    end
   
   
 endtask
 




 task ByPassData2Down();
   
   
   forever begin
   
       Adapter_From_U_TX_af.get(PIPE_seq_item_From_Up);
   
       Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
   
    end
   
   
 endtask

 



endclass
