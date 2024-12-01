class PCIe_Driver_AUS2 extends uvm_driver#(PCIe_Seq_Item);

    `uvm_component_utils(PCIe_Driver_AUS2)
    virtual PIPE PIPE_intfU;
    PCIe_Seq_Item item;
    
    uvm_tlm_analysis_fifo #(PCIe_Seq_Item) Adapter_To_Up_RX_Tlm_Fifo;
    function new(string name = "PCIe_Driver_AUS2",uvm_component parent);
        super.new(name , parent);
        `uvm_info(get_type_name() ," in constructor of driver ",UVM_HIGH)
    endfunction 

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name() ," in build_phase of driver ",UVM_LOW)
        if(!(uvm_config_db #(virtual PIPE)::get(this,"*","PIPE_intfU",PIPE_intfU))) begin
        `uvm_error(get_type_name(),"Error, DUT interface is not found") 
        end    
        Adapter_To_Up_RX_Tlm_Fifo = new ("Adapter_To_Up_RX_Tlm_Fifo", this);
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
            Adapter_To_Up_RX_Tlm_Fifo.get(item);
            //There is no sequencer
            //seq_item_port.get_next_item(item);
            drive(item);
            //seq_item_port.item_done();
        end
    endtask: run_phase
    task drive (PCIe_Seq_Item item);
        PIPE_intfU.RxData = item.RxData;
        PIPE_intfU.RxDataValid = item.RxDataValid;
        PIPE_intfU.RxDataK = item.RxDataK;
        PIPE_intfU.RxStartBlock = item.RxStartBlock;
        PIPE_intfU.RxSyncHeader = item.RxSyncHeader;
        PIPE_intfU.RxStatus = item.RxStatus;
        PIPE_intfU.RxElectricalIdle = item.RxElectricalIdle;
        

    endtask
/*logic [MAXPIPEWIDTH*LANESNUMBER-1:0] RxData;
logic [LANESNUMBER-1:0] RxDataValid;
logic [(MAXPIPEWIDTH/8)*LANESNUMBER-1:0] RxDataK;
logic [LANESNUMBER-1:0] RxStartBlock;
logic [2*LANESNUMBER -1:0] RxSyncHeader;
logic [3*LANESNUMBER -1:0] RxStatus;
logic [15:0] RxElectricalIdle;*/
endclass