class LTSSM1_D_Monitor extends uvm_monitor;


    `uvm_component_utils(LTSSM1_D_Monitor)

    virtual PIPE_if PIPE_vif_h

    LTSSM1_seq_item LTSSM1_seq_item_h;

    uvm_analysis_port #(LTSSM1_seq_item) send_ap;




    extern function new(string name="LTSSM1_D_Monitor",uvm_component parent);

    extern function void build_phase(uvm_phase phase);

    extern task run_phase(uvm_phase phase);


endclass

     function LTSSM1_D_Monitor::new(string name="LTSSM1_D_Monitor",uvm_component parent);

        super.new(name,parent);

     endfunction
     
     
     function void LTSSM1_D_Monitor::build_phase(uvm_phase phase);

        super.new(phase);

        send_ap = new("send_ap",this);

     endfunction

     task LTSSM1_D_Monitor::run_phase(uvm_phase phase);

        super.new(phase);
        
        forever begin
            
        end

     endtask