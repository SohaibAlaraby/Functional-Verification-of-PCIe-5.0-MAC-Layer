class PCIe_Monitor_AUS2 extends uvm_monitor;
    `uvm_component_utils(PCIe_Monitor_AUS2)
    virtual PIPE PIPE_intfU; //beside PIPE Interface
    // uvm_analysis_port #(PCIe_Seq_Item) Monitor_To_SubscriberU;
    // uvm_analysis_port #(PCIe_Seq_Item) Monitor_To_SubscriberD;
    uvm_analysis_port #(PCIe_Seq_Item) Monitor_AUS2_port;
    PCIe_Seq_Item item;

    function new(string name="PCIe_Monitor_AUS2",uvm_component parent);
        super.new(name,parent);
        // Monitor_To_SubscriberU = new("Monitor_To_SubscriberU",this);
        // Monitor_To_SubscriberD = new("Monitor_To_SubscriberD",this);
        Monitor_AUS2_port = new("Monitor_AUS2_port",this);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name() ," in monitor build_phase ",UVM_HIGH)
        if(!(uvm_config_db #(virtual PIPE)::get(this,"*","PIPE_intfU",PIPE_intfU))) begin
        `uvm_error(get_type_name(),"Error, DUT interface is not found") 
        end
        
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name() ," in monitor connect_phase ",UVM_HIGH)
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name() ," in monitor run_phase ",UVM_HIGH)
        forever begin
         
        end
    endtask
endclass