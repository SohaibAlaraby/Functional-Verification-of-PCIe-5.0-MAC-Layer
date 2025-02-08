class TX_Slave_U_Monitor extends uvm_monitor;
  


`uvm_component_utils(TX_Slave_U_Monitor)
    
  
virtual PIPE_if      PIPE_vif_h;

event Receiver_Detected;
event Received_TS2_in_Polling_Configuration;
event Received_2_TS1_in_Config_Link_Width_Start;
event Received_2_TS1_in_Config_Link_Width_Accept;
event Received_2_TS2_in_Config_Lanenum_Wait;  
event Received_2_TS2_in_Config_Lanenum_Accept;
bit   Received_2_TS1_in_Config_Link_Width_Start_f;
bit   Received_2_TS1_in_Config_Link_Width_Accept_f;
bit   Received_2_TS2_in_Config_Lanenum_Wait_f;  
bit   Received_2_TS2_in_Config_Lanenum_Accept_f; 
bit   Received_Idle_in_Config_Idle_f;
event Received_TS2_in_Config_Complete;
event Received_Idle_in_Config_Idle;
event Polling_Active_Substate_Completed;
event Polling_Configuration_Substate_Completed;
event Config_Link_Width_Start_Substate_Completed;
event Config_Complete_Substate_Completed;
event LinkUp_Completed;


bit[5:0] Current_Substate,Next_Substate;
bit[15:0] TS_Count,IDLE_Count;
bit[3:0] Symbol_num;
bit[`MAXPIPEWIDTH-1:0] Lane_Data,Descrambled_Data;
bit[(`MAXPIPEWIDTH/8)-1:0] Lane_DataK;
bit detected_os,reject_os;
bit[1:0] TS_Type;

Descrambler_Scrambler  de_scrambler;

uvm_analysis_port #(PIPE_seq_item) send_ap1;
uvm_analysis_port #(PIPE_seq_item) send_ap2;



    
extern function new(string name = "TX_Slave_U_Monitor",uvm_component parent);
extern function void build_phase (uvm_phase phase);
extern function void connect_phase (uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern task Pass_PIPE_TX_Signals ();
extern task Set_Flags();
extern task Monitoring_Substates_Transition ();
extern task Receiver_Detection ();
extern task Polling_Active ();
extern task Polling_Configuration ();
extern task Config_Link_Width_Start ();
extern task Config_Link_Width_Accept ();
extern task Config_Lanenum_Wait ();
extern task Config_Lanenum_Accept ();
extern task Config_Complete ();
extern task Config_Idle ();


endclass






function TX_Slave_U_Monitor::new(string name = "TX_Slave_U_Monitor",uvm_component parent);
        super.new(name , parent);
        `uvm_info(get_type_name() ," in constructor of driver ",UVM_HIGH)
endfunction 



function void TX_Slave_U_Monitor::build_phase (uvm_phase phase);
  
        super.build_phase(phase);
        
        `uvm_info(get_type_name() ," in build_phase of driver ",UVM_LOW)
        
        send_ap1 = new("send_ap1",this);
        send_ap2 = new("send_ap2",this);   
             
endfunction: build_phase



function void TX_Slave_U_Monitor::connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name() ," in connect_phase of driver ",UVM_LOW)
endfunction: connect_phase





task TX_Slave_U_Monitor::run_phase(uvm_phase phase);
  
        super.run_phase(phase);
        `uvm_info(get_type_name() ," in run_phase of driver ",UVM_LOW)
      
        fork
              begin
                Pass_PIPE_TX_Signals();
              end
              
              begin
                Monitoring_Substates_Transition();
              end
              
              begin
                Set_Flags();
              end
              
        join
        
        wait fork;
        
endtask: run_phase





task TX_Slave_U_Monitor::Pass_PIPE_TX_Signals();
  
  forever begin
    
     PIPE_seq_item  PIPE_seq_item_h;         
     PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
     
     @(posedge PIPE_vif_h.PCLK)   
  
     PIPE_seq_item_h.TxData                  = PIPE_vif_h.TxData;
     PIPE_seq_item_h.TxDataValid             = PIPE_vif_h.TxDataValid;
     PIPE_seq_item_h.TxElecIdle              = PIPE_vif_h.TxElecIdle;
     PIPE_seq_item_h.TxStartBlock            = PIPE_vif_h.TxStartBlock;
     PIPE_seq_item_h.TxDataK                 = PIPE_vif_h.TxDataK;
     PIPE_seq_item_h.TxSyncHeader            = PIPE_vif_h.TxSyncHeader;
     PIPE_seq_item_h.TxDetectRx_Loopback     = PIPE_vif_h.TxDetectRx_Loopback;
     
     send_ap1.write(PIPE_seq_item_h);
    
   end
  
endtask  
  
  
  
  
  




 
  
task TX_Slave_U_Monitor::Monitoring_Substates_Transition();
  
   Next_Substate = `Detect_Active;
   
    forever begin
      
         Current_Substate = Next_Substate;
         
         @(posedge PIPE_vif_h.PCLK);
      
         case(Current_Substate)
        
        
             `Detect_Active:               Receiver_Detection();
        
             `Polling_Active:              Polling_Active();
        
             `Polling_Configuration:       Polling_Configuration();
        
             `Config_Link_Width_Start:     Config_Link_Width_Start();
                
             `Config_Link_Width_Accept:    Config_Link_Width_Accept();
        
             `Config_Lanenum_Wait:         Config_Lanenum_Wait();
        
             `Config_Lanenum_Accept:       Config_Lanenum_Accept();
        
             `Config_Complete:             Config_Complete();
                
             `Config_Idle:                 Config_Idle();
           
       
         endcase
    end  

endtask









task TX_Slave_U_Monitor::Receiver_Detection();

 
    wait(Receiver_Detected);

   `uvm_info(get_type_name() ,"Receiver Detection completed successfully",UVM_LOW)
     
   Next_Substate    = `Polling_Active;
   
  
endtask





task TX_Slave_U_Monitor::Polling_Active();
  
      
      
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
    
  while(TS_Count < 1024*`LANESNUMBER ) begin
      
    @(posedge PIPE_vif_h.PCLK)
    wait(PIPE_vif_h.TxDataValid != 0);
      
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
      @(posedge PIPE_vif_h.PCLK)
        
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];  
          Symbol_num = s*`MAXPIPEWIDTH/8;
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
                                                                      
            if(Symbol_num == 0)begin                             
              
                  if(PIPE_vif_h.TxDataK[i +: 1] == 1'b1)begin
                     assert(Lane_Data[k -: 8] == 8'hBC)  
                     else `uvm_error(get_type_name(),"Missing COM Character") 
                  end
                    
            end
            
            else if((Symbol_num > 5) && (Symbol_num !=15)) begin
                  assert(Lane_Data[k -: 8] == 8'h4A)
                  else `uvm_error(get_type_name(),$sformatf("Not Correct TS Identifier %h !",(Lane_Data[k -: 8])))              
              
            end
            
             
   
            else if(Symbol_num == 15) begin
                         TS_Count = TS_Count + 1;
                         assert(Lane_Data[k -: 8] == 8'h4A)
                         else `uvm_error(get_type_name(),$sformatf("Not Correct TS Identifier %h !",(Lane_Data[k -: 8])))   
                        
            end   
  
            Symbol_num = Symbol_num + 1;
                   

            
           end
      
        end
      
      end
    
    end
     


   `uvm_info(get_type_name() ,"Polling Active substate at Upstream TX side completed successfully",UVM_LOW)
     
     ->Polling_Active_Substate_Completed;
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count;    
     PIPE_seq_item_h.TS_Type = `TS1;
     send_ap2.write(PIPE_seq_item_h);
     
     
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Polling_Configuration;
  
endtask











task TX_Slave_U_Monitor::Polling_Configuration();
  
      
      
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
    
    
  wait(Received_TS2_in_Polling_Configuration);
     
     
  while(TS_Count < 16*`LANESNUMBER ) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
       @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[31:24]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
            
            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;                     
                  
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Lane_Data[k -: 8] != 8'hf7 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Lane_Data[k -: 8] != 8'hf7 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                         reject_os = 1;          
             
            end
            
            
            else if(Symbol_num == 6) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                         reject_os = 1;  
              
            end
            
            
            
            else if((Symbol_num > 6) && (Symbol_num !=15)) begin
                  if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                          reject_os = 1;  
              
            end
            
             
   
            else if(Symbol_num == 15) begin
              
              if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                            reject_os = 1; 
                  
              if(!reject_os)          
                       TS_Count = TS_Count + 1;
              
                     
              reject_os = 0;    
                    
            end   
  
            Symbol_num = Symbol_num + 1;
 
 
 
                   

            
           end
      
        end
      
      end
    
    end
     


   `uvm_info(get_type_name() ,"Polling Configuration substate at Upstream TX side completed successfully",UVM_LOW)
     
     ->Polling_Configuration_Substate_Completed;
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS2;   
     
     send_ap2.write(PIPE_seq_item_h);
     
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Config_Link_Width_Start;
  
endtask










task TX_Slave_U_Monitor::Config_Link_Width_Start();
  
      
      
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
    
     
        
  while(1) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
     
    if(Received_2_TS1_in_Config_Link_Width_Start_f)     break ;
     
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
       @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[31:24]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
            
            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;                     
                  
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Lane_Data[k -: 8] != 8'hf7 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Lane_Data[k -: 8] != 8'hf7 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                         reject_os = 1;          
             
            end
            
            
            else if(Symbol_num == 6) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                         reject_os = 1;  
              
            end
            
            
            
            else if((Symbol_num > 6) && (Symbol_num !=15)) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                          reject_os = 1;  
              
            end
            
             
   
            else if(Symbol_num == 15) begin
              
              if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                            reject_os = 1; 
                  
              if(!reject_os)          
                       TS_Count = TS_Count + 1;
                     
              reject_os = 0;    
                    
            end   
  
            Symbol_num = Symbol_num + 1;
 
 
 
            
           end
      
        end
      
      end
    
    end
     


   `uvm_info(get_type_name() ,"Config_Link_Width_Start substate at Upstream TX side completed successfully",UVM_LOW)
   
     ->Config_Link_Width_Start_Substate_Completed;
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS1;   
     
     send_ap2.write(PIPE_seq_item_h);
     
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Config_Link_Width_Accept;
  
endtask







task TX_Slave_U_Monitor::Config_Link_Width_Accept();
  
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
      
  while(1) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);
    
     if(Received_2_TS1_in_Config_Link_Width_Accept_f)     break ;
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
      @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[31:24]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
            
            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;                     
                  
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Lane_Data[k -: 8] != 8'h01 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Lane_Data[k -: 8] != 8'hf7 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                         reject_os = 1;          
             
            end
            
            
            else if(Symbol_num == 6) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                         reject_os = 1;  
              
            end
            
            
            
            else if((Symbol_num > 6) && (Symbol_num !=15)) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                          reject_os = 1;  
              
            end
            
             
   
            else if(Symbol_num == 15) begin
              
              if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                            reject_os = 1; 
                  
              if(!reject_os)          
                       TS_Count = TS_Count + 1;
                     
              reject_os = 0;    
                    
            end   
  
            Symbol_num = Symbol_num + 1;
                   

            
           end
      
        end
      
      end
    
    end
     


   `uvm_info(get_type_name() ,"Config Link Width Accept substate at Upstream TX side completed successfully",UVM_LOW)
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS1;   
     
     send_ap2.write(PIPE_seq_item_h);
     
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Config_Lanenum_Wait;
  
endtask








task TX_Slave_U_Monitor::Config_Lanenum_Wait();
  
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
      
  while(1) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
     
    if(Received_2_TS2_in_Config_Lanenum_Wait_f)     break ;
     
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
      @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[31:24]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
            
            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;                     
                  
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Lane_Data[k -: 8] != 8'h01 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Lane_Data[k -: 8] != `LANESNUMBER-1-i || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                         reject_os = 1;          
             
            end
            
            
            else if(Symbol_num == 6) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                         reject_os = 1;  
              
            end
            
            
            
            else if((Symbol_num > 6) && (Symbol_num !=15)) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                          reject_os = 1;  
              
            end
            
             
   
            else if(Symbol_num == 15) begin
              
              if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                            reject_os = 1; 
                  
              if(!reject_os)          
                       TS_Count = TS_Count + 1;
                     
              reject_os = 0;    
                    
            end   
  
            Symbol_num = Symbol_num + 1;
                   

           end
      
        end
      
      end
    
    end

   `uvm_info(get_type_name() ,"Config Lanenum Wait substate at Upstream TX side completed successfully",UVM_LOW)
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS1;   
     
     send_ap2.write(PIPE_seq_item_h);
     
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Config_Lanenum_Accept;
  
endtask








task TX_Slave_U_Monitor::Config_Lanenum_Accept ();
  
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
      
  while(1) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
     
    if(Received_2_TS2_in_Config_Lanenum_Accept_f)     break ;
     
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
      @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[31:24]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
            
            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;                     
                  
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Lane_Data[k -: 8] != 8'h01 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Lane_Data[k -: 8] != `LANESNUMBER-1-i || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                         reject_os = 1;          
             
            end
            
            
            else if(Symbol_num == 6) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                         reject_os = 1;  
              
            end
            
            
            
            else if((Symbol_num > 6) && (Symbol_num !=15)) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                          reject_os = 1;  
              
            end
            
             
   
            else if(Symbol_num == 15) begin
              
              if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                            reject_os = 1; 
                  
              if(!reject_os)          
                       TS_Count = TS_Count + 1;
                     
              reject_os = 0;    
                    
            end   
  
            Symbol_num = Symbol_num + 1;
           end
      
        end
      
      end
    
    end

   `uvm_info(get_type_name() ,"Config Lanenum Accept substate at Upstream TX side completed successfully",UVM_LOW)
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS1;   
     
     send_ap2.write(PIPE_seq_item_h);
     
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Config_Complete;
  
endtask








task TX_Slave_U_Monitor::Config_Complete();
  
      
      
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
    
    
  wait(Received_TS2_in_Config_Complete);
     
     
  while(TS_Count < 16*`LANESNUMBER ) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
      @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[31:24]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
            
            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;                     
                  
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Lane_Data[k -: 8] != 8'h01 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Lane_Data[k -: 8] != `LANESNUMBER-1-i || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                         reject_os = 1;          
             
            end
            
            
            else if(Symbol_num == 6) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                         reject_os = 1;  
              
            end
            
            
            
            else if((Symbol_num > 6) && (Symbol_num !=15)) begin
                  if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                          reject_os = 1;  
              
            end
            
             
   
            else if(Symbol_num == 15) begin
              
              if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                            reject_os = 1; 
                  
              if(!reject_os)          
                       TS_Count = TS_Count + 1;
                     
              reject_os = 0;    
                    
            end   
  
            Symbol_num = Symbol_num + 1;

            
           end
      
        end
      
      end
    
    end
     


   `uvm_info(get_type_name() ,"Config Complete substate at Upstream TX side completed successfully",UVM_LOW)
     
     ->Config_Complete_Substate_Completed;
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS2;   
     
     send_ap2.write(PIPE_seq_item_h);
     
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Config_Idle;
     reset_lfsr(de_scrambler,1);
     
endtask








task TX_Slave_U_Monitor::Config_Idle();
  
    
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");    
   
  while(IDLE_Count < 16*`LANESNUMBER) begin 
      
    @(posedge PIPE_vif_h.PCLK)
      
      for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
       
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          
          if(Lane_Data != 32'h0)begin
             Descrambled_Data = apply_descramble(de_scrambler,Lane_Data,i,1);
               
             if(Descrambled_Data == 32'h0 && Received_Idle_in_Config_Idle_f)
            
                   IDLE_Count = IDLE_Count+4;    
                   
          end           
                  
        end
      
      end
    

     

   `uvm_info(get_type_name() ,"Config Idle substate at Upstream TX side completed successfully",UVM_LOW)
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `IDLE;   
     
     send_ap2.write(PIPE_seq_item_h);
     
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `L0;
     ->LinkUp_Completed;
  
endtask










  
task TX_Slave_U_Monitor::Set_Flags();
  
  
    fork
    
       begin         
         wait(Received_2_TS1_in_Config_Link_Width_Start);
         Received_2_TS1_in_Config_Link_Width_Start_f = 1;
       end
    
     
       begin         
         wait(Received_2_TS1_in_Config_Link_Width_Accept);
         Received_2_TS1_in_Config_Link_Width_Accept_f = 1;
       end
         
     
     
       begin
         wait(Received_2_TS2_in_Config_Lanenum_Wait);
         Received_2_TS2_in_Config_Lanenum_Wait_f = 1;         
       end    


       begin
         wait(Received_2_TS2_in_Config_Lanenum_Accept);
         Received_2_TS2_in_Config_Lanenum_Accept_f = 1;        
       end  
       
       begin
        wait(Received_Idle_in_Config_Idle);
          Received_Idle_in_Config_Idle_f = 1;
       end
      
      begin
        wait(LinkUp_Completed);
      end 
         
    join
  
  
  
  Received_2_TS1_in_Config_Link_Width_Start_f = 0;
  Received_2_TS1_in_Config_Link_Width_Accept_f = 0;
  Received_2_TS2_in_Config_Lanenum_Wait_f = 0;    
  Received_2_TS2_in_Config_Lanenum_Accept_f = 0; 
  Received_Idle_in_Config_Idle_f= 0;
  
endtask

