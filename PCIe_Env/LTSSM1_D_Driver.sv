class LTSSM1_D_Driver  extends uvm_driver #(LTSSM1_seq_item);
`uvm_component_utils(LTSSM1_D_Driver)

LTSSM1_seq_item driver_seq_item;
virtual PIPE driver_vif;

function new(string name = "LTSSM1_D_Driver",uvm_component parent = null);
        super.new(name , parent);
endfunction 


function build_phase (uvm_phase phase);
super.build_phase(phase);
endfunction

function connect_phase (uvm_phase phase);
super.connect_phase(phase);
endfunction


task run_phase (uvm_phase phase);
forever begin
driver_seq_item =  LTSSM1_seq_item::type_id::create::("driver_seq_item",this);
seq_item_port.get_next_item(driver_seq_item);
drive_stim(driver_seq_item);
seq_item_port.item_done(driver_seq_item);

end

endtask

task drive_stim (LTSSM1_seq_item);
case (driver_seq_item.OP) 
2'b00: begin
    @(posedge driver_vif.phy_reset);
    driver_vif.PhyStatus = 1'b1;
    @(posedge driver_vif.CLK);
    driver_vif.PhyStatus = 1'b0;
    
end

2'b01: begin
    wait(driver_vif.TxDetectRx_Loopback);
    driver_vif.PhyStatus = 1'b1;
    driver_vif.RxStatus=3'b011;
    @(posedge driver_vif.CLK);
    driver_vif.PhyStatus = 1'b0;
    driver_vif.RxStatus=3'b000;
end
endcase

endtask

endclass
