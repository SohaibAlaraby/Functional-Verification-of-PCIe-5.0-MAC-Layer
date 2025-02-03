class TX_Master_U_Driver extends uvm_driver#(TX_Master_seq_item);
  
`uvm_component_utils(TX_Master_U_Driver)

virtual LPIF_if LPIF_vif_h;
TX_Master_seq_item item;
static bit detect_DLLP ; // use this var to detect start and end
static bit detect_TLP;  // use this var to detect start and end
static int counter=63;
bit done_TLP,done_DLLP;

bit [7:0] TLLP_data,DLLP_data;
uvm_analysis_port #(TX_Master_seq_item) send_ap;

        
        
extern function new(string name = "TX_Master_U_Driver",uvm_component parent);
extern task run_phase(uvm_phase phase);
extern task drive (TX_Master_seq_item item);
extern task set_valid_bits(TX_Master_seq_item item);
extern task send_TLP_DLLP(TX_Master_seq_item item);
endclass




function TX_Master_U_Driver::new(string name = "TX_Master_U_Driver",uvm_component parent);
        super.new(name , parent);
        send_ap = new("send_ap",this);

endfunction 


task TX_Master_U_Driver::run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name() ," in run_phase of driver of TX Master U ",UVM_HIGH)

        forever begin
                
                if(`MAX_GEN_PCIE_D> `MAX_GEN_PCIE_U)begin
                        wait(LPIF_vif_h.pl_state_sts == 1 && LPIF_vif_h.pl_speedmode == `MAX_GEN_PCIE_D -1 &&LPIF_vif_h.pl_linkUp );
                        item = TX_Master_seq_item::type_id::create("item");
                        seq_item_port.get_next_item(item);
                        drive(item);

                        @(negedge LPIF_vif_h.LCLK);
                        `uvm_info(get_type_name() ," In TX_Master_U_Driver ",UVM_HIGH)


                        seq_item_port.item_done();
                end
                else begin
                        wait(LPIF_vif_h.pl_state_sts == 1 && LPIF_vif_h.pl_speedmode == `MAX_GEN_PCIE_U -1 &&LPIF_vif_h.pl_linkUp );
                        item = TX_Master_seq_item::type_id::create("item");
                        seq_item_port.get_next_item(item);
                        drive(item);

                        @(negedge LPIF_vif_h.LCLK);
                        `uvm_info(get_type_name() ," In TX_Master_U_Driver ",UVM_HIGH)
                        seq_item_port.item_done();
                end
               
        end
endtask: run_phase

// in this task we send TLP and DLLP to scoreboard 
task TX_Master_U_Driver::send_TLP_DLLP(TX_Master_seq_item item);  


        if(done_TLP)begin
                item.number_of_TLP_U++;
                `uvm_info(get_type_name() ,$sformatf("number of TLP  from Upstream device NOW = %0d ",item.number_of_TLP_U),UVM_LOW)

                        item.packet_type=2'b00;
                        //send_ap.write(item);
                        item.TLP.delete();
                        done_TLP=0;
                        item.packet_type=2'b11;
                        end
        else if(done_DLLP)begin

                item.number_of_DLLP_U++;

                `uvm_info(get_type_name() ,$sformatf("number of DLLP from Upstream device now=  %0d",item.number_of_DLLP_U),UVM_LOW);
                        item.packet_type=2'b10;
                        //send_ap.write(item);
                        done_DLLP=0;
                        item.DLLP.delete();
                        item.packet_type=2'b11;
                        end

endtask

// in this task i send TLP and DLLP and assign valid bits

task TX_Master_U_Driver::set_valid_bits(TX_Master_seq_item item);
        while(counter<64 && counter>=0)begin
                // set valid bits for TLP
                TLLP_data=item.lp_data >> (8*counter);
                DLLP_data=item.lp_data >> (8*counter);

                if(item.lp_tlpstart[counter]==1)begin
                        
                        detect_TLP=1;
                        item.lp_valid[counter]=1;
                        item.TLP.push_back(TLLP_data);

                end
                else if(item.lp_tlpend[counter]==1)begin
                        detect_TLP=0;
                        item.lp_valid[counter]=1;
                        item.TLP.push_back(TLLP_data);
                        done_TLP=1;
                        send_TLP_DLLP(item);
                        
                end
                else if(detect_TLP)begin
                        
                        item.lp_valid[counter]=1;
                        item.TLP.push_back(TLLP_data);
                end
                
                
                // set valid bits for DLLP
                if(item.lp_dlpstart[counter]==1)begin
                        detect_DLLP=1;
                        item.lp_valid[counter]=1;
                        item.DLLP.push_back(DLLP_data);
                end
                else if(item.lp_dlpend[counter]==1)begin
                        detect_DLLP=0;
                        item.lp_valid[counter]=1;
                        item.DLLP.push_back(DLLP_data);
                        done_DLLP=1;
                        send_TLP_DLLP(item);
                end
                else if(detect_DLLP)begin
                        item.lp_valid[counter]=1;
                        item.DLLP.push_back(DLLP_data);
                end
                

                counter--;
        end   
        
         
        counter=63;

endtask


task TX_Master_U_Driver::drive (TX_Master_seq_item item);
     `uvm_info(get_type_name() ," in run_phase of driver of TX Master U",UVM_HIGH)
        if( item.lp_tlpstart || item.lp_dlpstart)begin
                LPIF_vif_h.lp_irdy=1 ; 
        end

        item.lp_valid=0;
        set_valid_bits(item);
        LPIF_vif_h.lp_dlpstart=item.lp_dlpstart  ;
        LPIF_vif_h.lp_dlpend=item.lp_dlpend  ;
        LPIF_vif_h.lp_tlpstart=item.lp_tlpstart  ;
        LPIF_vif_h.lp_tlpend=item.lp_tlpend  ;
        LPIF_vif_h.lp_data=item.lp_data  ;
        LPIF_vif_h.lp_valid=  item.lp_valid;      
               
endtask
