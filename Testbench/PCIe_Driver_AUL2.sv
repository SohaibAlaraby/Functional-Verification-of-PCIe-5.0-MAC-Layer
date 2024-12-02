////////////////////////////////////////////////////////////////////////////////
// Author: Marwan mohamed
// Description: driver for up stream LTSSM 2
// 
////////////////////////////////////////////////////////////////////////////////
    class PCIe_Driver_AUL2 extends uvm_driver#(PCIe_Seq_Item);
        `uvm_component_utils(PCIe_Driver_AUL2)

        virtual LPIF_if LPIF_vif;
        PCIe_Seq_Item item;
        extern function new(string name = "PCIe_Driver_AUL2",uvm_component parent);

        extern task run_phase(uvm_phase phase);

        extern task drive (PCIe_Seq_Item item);

    endclass

    function PCIe_Driver_AUL2::new(string name = "PCIe_Driver_AUL2",uvm_component parent);
        super.new(name , parent);
    endfunction 

    task PCIe_Driver_AUL2::run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name() ," in run_phase of driver of LTSSM2 ",UVM_LOW)
        forever begin
            item = PCIe_Seq_Item::type_id::create("item");
            seq_item_port.get_next_item(item);
            drive(item);
            seq_item_port.item_done();
        end
    endtask: run_phase

    task PCIe_Driver_AUL2::drive (PCIe_Seq_Item item);
        
        LPIF_vif.lpreset=item.lpreset;

        if(item.operation==2'b00)begin
            LPIF_vif.lp_state_req=active_;
        end
    endtask


