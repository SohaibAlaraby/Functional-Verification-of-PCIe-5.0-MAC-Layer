class RX_Passive_D_Monitor extends uvm_monitor;

        `uvm_component_utils(RX_Passive_D_Monitor)
        
        uvm_analysis_port #(TX_Master_seq_item) send_ap;
        
        virtual LPIF_if LPIF_vif_h;

        TX_Master_seq_item TX_Master_seq_item_h;
        


        int counter = 63;

        // Handling DLLP //
        typedef enum {DLLP_WAIT = 1'b0,DLLP_DONE} DLLP_Status;
        DLLP_Status DLLP_status;
        bit [7:0] DLLP_Byte;
        bit detect_DLLP ; 

        // Handling TLP //
        typedef enum {TLP_WAIT = 1'b0,TLP_DONE} TLP_Status;
        TLP_Status TLP_status;
        bit [7:0] TLP_Byte;
        bit detect_TLP; 

        

        extern function new (string name = "RX_Passive_D_Monitor", uvm_component parent = null);
        
        extern function void build_phase (uvm_phase phase);
        
        extern function void connect_phase (uvm_phase phase);
        
        extern task run_phase (uvm_phase phase);

        extern task Link_Ready ();

        extern task check_if_valid_data ();

        extern task Handle_TLP_DLLP ();

        extern task Broadcast_DLLP ();

        extern task Broadcast_TLP ();


endclass



        function RX_Passive_D_Monitor::new (string name = "RX_Passive_D_Monitor", uvm_component parent = null);
            
            super.new(name,parent);

        endfunction




        function void RX_Passive_D_Monitor::build_phase (uvm_phase phase);
        
            super.build_phase(phase);
            
            send_ap = new("send_ap",this);
        
        endfunction



        function void RX_Passive_D_Monitor::connect_phase (uvm_phase phase);
        
            super.connect_phase(phase);

        endfunction



        task RX_Passive_D_Monitor::run_phase (uvm_phase phase);

            super.run_phase(phase);

            forever begin
            
                TX_Master_seq_item_h = TX_Master_seq_item::type_id::create("TX_Master_seq_item_h");  
                
                @(negedge LPIF_vif_h.LCLK);

                TX_Master_seq_item_h.pl_trdy = LPIF_vif_h.pl_trdy;
                TX_Master_seq_item_h.pl_dlpstart = LPIF_vif_h.pl_dlpstart;
                TX_Master_seq_item_h.pl_dlpend = LPIF_vif_h.pl_dlpend;
                TX_Master_seq_item_h.pl_tlpstart = LPIF_vif_h.pl_tlpstart;
                TX_Master_seq_item_h.pl_tlpend = LPIF_vif_h.pl_tlpend;
                TX_Master_seq_item_h.pl_tlpedb = LPIF_vif_h.pl_tlpedb;
                TX_Master_seq_item_h.pl_valid = LPIF_vif_h.pl_valid;    
                
                Link_Ready();

                
                
            end
                
        endtask
        
        task RX_Passive_D_Monitor::Link_Ready();
        
            if(LPIF_vif_h.pl_trdy) begin
                
                check_if_valid_data();

                end
        
        endtask

        task RX_Passive_D_Monitor::check_if_valid_data();
        
            if(LPIF_vif_h.pl_valid) begin
 
                    
                 Handle_TLP_DLLP();
                    
                   
            end

        
        endtask


        task RX_Passive_D_Monitor::Handle_TLP_DLLP();

                while ( ( counter >= 0 ) &&  ( counter < 64 ) ) begin

                            TLP_Byte = LPIF_vif_h.pl_data  >> (8*counter) ;
                            DLLP_Byte = LPIF_vif_h.pl_data >> (8*counter) ;                          

                            if( LPIF_vif_h.pl_tlpstart[counter] == 1 ) begin
                                
                                TLP_status = TLP_WAIT;
                                
                                detect_TLP = 1'b1;
                                
                                if( LPIF_vif_h.pl_valid[counter] == 1 ) begin
                                    
                                    TX_Master_seq_item_h.TLP.push_back(TLP_Byte);
                                
                                end
                            
                            end

                            else if( LPIF_vif_h.pl_tlpend[counter] == 1 ) begin
                                
                                TLP_status = TLP_DONE;
                                
                                detect_TLP = 1'b0;

                                if(LPIF_vif_h.pl_valid[counter] == 1 ) begin
                                    
                                    TX_Master_seq_item_h.TLP.push_back(TLP_Byte);
                                    
                                    Broadcast_TLP();

                                end
                            
                            end

                            else if ( detect_TLP ) begin
                                
                                if( LPIF_vif_h.pl_valid[counter] == 1 ) begin
                                    
                                    TX_Master_seq_item_h.TLP.push_back(TLP_Byte);

                                end 
                            
                            end

                            if( LPIF_vif_h.pl_dlpstart[counter] == 1 ) begin
                                
                                DLLP_status = DLLP_WAIT;
                                
                                detect_DLLP = 1'b1;
                                
                                if(LPIF_vif_h.pl_valid[counter] == 1 ) begin
                                    
                                    TX_Master_seq_item_h.DLLP.push_back(DLLP_Byte);
                                
                                end
                            
                            end

                            else if( LPIF_vif_h.pl_dlpend[counter] == 1 ) begin
                                
                                DLLP_status = DLLP_DONE;

                                detect_DLLP = 1'b0;

                                if(LPIF_vif_h.pl_valid[counter] == 1 ) begin
                                    
                                    TX_Master_seq_item_h.DLLP.push_back(DLLP_Byte);
                                    
                                    Broadcast_DLLP();

                                end
                            
                            end

                            else if ( detect_DLLP ) begin
                                
                                if( LPIF_vif_h.pl_valid[counter] == 1 ) begin
                                    
                                    TX_Master_seq_item_h.DLLP.push_back(DLLP_Byte);

                                end 
                            
                            end
                            
                            counter--;                         
                end
        
        counter = 63;
        
        endtask


        task RX_Passive_D_Monitor::Broadcast_TLP ();

                TX_Master_seq_item_h.number_of_TLP_D++;

                TX_Master_seq_item_h.packet_type = 2'b00;
                
                send_ap.write(TX_Master_seq_item_h);

                TLP_status = TLP_WAIT;

                TX_Master_seq_item_h.TLP.delete();

        endtask

         task RX_Passive_D_Monitor::Broadcast_DLLP ();

                TX_Master_seq_item_h.number_of_DLLP_D++;

                TX_Master_seq_item_h.packet_type = 2'b10;
                
                send_ap.write(TX_Master_seq_item_h);

                DLLP_status = DLLP_WAIT;

                TX_Master_seq_item_h.DLLP.delete();

        endtask


