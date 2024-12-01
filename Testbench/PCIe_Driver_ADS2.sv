class PCIe_Driver_ADS2  extends uvm_driver#(PCIe_Seq_Item);

    `uvm_component_utils(PCIe_Driver_ADS2)
    virtual PIPE PIPE_intfD;
    PCIe_Seq_Item item;
    // uvm_blocking_get_port #(PCIe_Seq_Item) Driver_ADS2_get_port;
    
    uvm_tlm_analysis_fifo #(PCIe_Seq_Item) Adapter_To_Down_RX_Tlm_Fifo;
    function new(string name = "PCIe_Driver_ADS2",uvm_component parent);
        super.new(name , parent);
        `uvm_info(get_type_name() ," in constructor of driver ",UVM_HIGH)
    endfunction 

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name() ," in build_phase of driver ",UVM_LOW)
        if(!(uvm_config_db #(virtual PIPE)::get(this,"*","PIPE_intfD",PIPE_intfD))) begin
        `uvm_error(get_type_name(),"Error, DUT interface is not found") 
        end    
        // Driver_ADS2_get_port = new ("Driver_ADS2_get_port", this);
        Adapter_To_Down_RX_Tlm_Fifo = new("Adapter_To_Down_RX_Tlm_Fifo",this);
    endfunction: build_phase

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name() ," in connect_phase of driver ",UVM_LOW)
    endfunction: connect_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name() ," in run_phase of driver ",UVM_LOW)
        forever begin
            //item = PCIe_Seq_Item::type_id::create("item");
            Adapter_To_Down_RX_Tlm_Fifo.get(item);
            //There is no sequencer
            //seq_item_port.get_next_item(item);
            drive(item);
            //seq_item_port.item_done();
        end
    endtask: run_phase
    task drive (PCIe_Seq_Item item);
        PIPE_intfD.RxData = item.RxData;
        PIPE_intfD.RxDataValid = item.RxDataValid;
        PIPE_intfD.RxDataK = item.RxDataK;
        PIPE_intfD.RxStartBlock = item.RxStartBlock;
        PIPE_intfD.RxSyncHeader = item.RxSyncHeader;
        PIPE_intfD.RxStatus = item.RxStatus;
        PIPE_intfD.RxElectricalIdle = item.RxElectricalIdle;
        

    endtask
/*logic [MAXPIPEWIDTH*LANESNUMBER-1:0] RxData;
logic [LANESNUMBER-1:0] RxDataValid;
logic [(MAXPIPEWIDTH/8)*LANESNUMBER-1:0] RxDataK;
logic [LANESNUMBER-1:0] RxStartBlock;
logic [2*LANESNUMBER -1:0] RxSyncHeader;
logic [3*LANESNUMBER -1:0] RxStatus;
logic [15:0] RxElectricalIdle;*/
endclass