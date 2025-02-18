class TX_Slave_U_Monitor extends uvm_monitor;
  


`uvm_component_utils(TX_Slave_U_Monitor)
    
  
virtual PIPE_if      PIPE_vif_h;

event Receiver_Detected;
event Received_TS2_in_Polling_Configuration;
event Received_2_TS1_in_Config_Link_Width_Start;
event Received_2_TS1_in_Config_Link_Width_Accept;
event Received_2_TS2_in_Config_Lanenum_Wait;  
event Received_2_TS2_in_Config_Lanenum_Accept;

event Received_TS1_in_L0;

//----------------------------------------------//
event Received_TS1_in_recoveryRcvrLock_Substate;
event Received_8_TS2_in_recoveryRcvrLock_Substate;

//----------------------------------------------//

event Received_TS2_in_recoveryRcvrCfg_Substate;
event Received_TS1_in_recoveryRcvrCfg_Substate;
//------------------------------------------------//

event Device_on_electrical_ideal;
//----------------------------------------------//

event Received_IDLE_in_recoveryIdle_Substate;
event Received_TS1_in_recoveryIdle_Substate;
//----------------------------------------------//




bit   Received_2_TS1_in_Config_Link_Width_Start_f;
bit   Received_2_TS1_in_Config_Link_Width_Accept_f;
bit   Received_2_TS2_in_Config_Lanenum_Wait_f;  
bit   Received_2_TS2_in_Config_Lanenum_Accept_f; 
bit   Received_Idle_in_Config_Idle_f;
bit   LinkUp_Completed_f;
bit   Received_TS1_in_L0_f;  

//------------------------------------------------//
bit   Received_TS1_in_recoveryRcvrLock_Substate_f;
bit   Received_8_TS2_in_recoveryRcvrLock_Substate_f;
//------------------------------------------------//

bit   Received_TS2_in_recoveryRcvrCfg_Substate_f;
bit   Received_TS1_in_recoveryRcvrCfg_Substate_f;

//------------------------------------------------//

bit   Device_on_electrical_ideal_f;

//----------------------------------------------//

bit   Received_IDLE_in_recoveryIdle_Substate_f;
bit   Received_TS1_in_recoveryIdle_Substate_f;
//----------------------------------------------//

event Received_TS2_in_Config_Complete;
event Received_Idle_in_Config_Idle;
event Polling_Active_Substate_Completed;
event Polling_Configuration_Substate_Completed;
event Config_Link_Width_Start_Substate_Completed;
event Config_Complete_Substate_Completed;

event LinkUp_Completed_USD;
event L0_state_completed;
event recoveryRcvrLock_Substate_Completed;
event recoveryRcvrCfg_Substate_Completed;
event recoverySpeed_Substate_Completed;
event recoverywait_Substate_Completed ;
event recoverySpeedeieos_Substate_Completed;
event phase0_Substate_Completed;
event phase1_Substate_Completed;
event recoveryIdle_Substate_Completed;


bit[5:0] Current_Substate,Next_Substate;
bit[15:0] TS_Count,IDLE_Count;
bit[3:0] Symbol_num;
bit[`MAXPIPEWIDTH-1:0] Lane_Data,Descrambled_Data;
bit[(`MAXPIPEWIDTH/8)-1:0] Lane_DataK;
bit detected_os,reject_os;
bit[1:0] TS_Type;
int rejected_TS;
int wanted_count;
Descrambler_Scrambler  de_scrambler;



//--------------//
bit start_equalization_w_preset;
bit directed_speed_change;
bit changed_speed_recovery;
bit start_equalization_w_preset_variable;
bit select_deemphasis;

bit [3:0]TX_Preset_u ;
bit [4:0] next_state;
bit TIME_OUT;
int Time_period = 20;
bit state_completed_successfully;
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
extern task L0();
extern task recoveryRcvrLock();
extern task recoveryRcvrCfg();
extern task recoverySpeed();
//extern task recoverywait();
//extern task recoverySpeedeieos();
extern task phase0();
extern task phase1();
extern task recoveryIdle();
extern task Timer(input bit enaple,input int time_to_wait , output int timeout);
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
  
  
  
task TX_Slave_U_Monitor::Timer(input bit enaple,input int time_to_wait , output int timeout);

  bit [31:0] counter,compared_value;
  case(time_to_wait)

    2:compared_value=2000000 / Time_period; //2ms

    24:compared_value=24000000 / Time_period ;  //24 ms

    48:compared_value=48000000 / Time_period; //48 ms

    800:compared_value=800 / Time_period  ; // 800ns


    default:compared_value=0;

  endcase

  if(enaple)begin
    $display(time_to_wait);
    while(counter < compared_value)begin

      @(posedge PIPE_vif_h.PCLK);
      counter++;
      $display("counter =%0d",counter);

      if(state_completed_successfully)break;

    end
    if(counter >= compared_value)begin
      counter=0;
      timeout=1;
      state_completed_successfully=0 ;
    end 
    else begin
      state_completed_successfully=0 ;
      timeout=0;
      counter=0;
    end

    $display("state_completed_successfully=%0d",state_completed_successfully);
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

             `L0:                          L0();

             `Recovery_RcvrLock:  begin          
              
                fork 
                                            
                  begin

                    recoveryRcvrLock();

                  end

                  begin

                      Timer(1,24,TIME_OUT);
                  end
                
                join

             end

             `Recovery_RcvrCfg:begin          
              
                fork 
                                            
                  begin

                    recoveryRcvrCfg();
                  end

                  begin
                      Timer(1,48,TIME_OUT);
                  end
                
                join

             end            

             `Recovery_Speed:               recoverySpeed();
             
             //`recoverywait:                recoverywait();

             //`recoverySpeedeieos:          recoverySpeedeieos();
             
             `phase0:                      phase0();

             `phase1:                      phase1();

             `Recovery_Idle:begin          
              
                fork 
                                            
                  begin

                    recoveryIdle();
                  end

                  begin
                      Timer(1,2,TIME_OUT);
                  end
                
                join_any

             end                  

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
            
            else if(Symbol_num == 4 ) begin
                PIPE_seq_item_h.supported_speed_in_upstream=Lane_Data[27:25];

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
    
    reset_lfsr(de_scrambler,1);
endtask


task TX_Slave_U_Monitor::L0();

  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 


  wait(LinkUp_Completed_f)

    if(PIPE_seq_item_h.supported_speed_in_upstream > 1 && PIPE_seq_item_h.supported_speed_in_downstream > 1) begin
      directed_speed_change  = 1;
      changed_speed_recovery = 1;
    end

  while(1)begin
    @(posedge PIPE_vif_h.PCLK)


  if(PIPE_seq_item_h.supported_speed_in_upstream > 1 && PIPE_seq_item_h.supported_speed_in_downstream > 1 && PIPE_seq_item_h.Rate <=1) begin
     wait (Received_TS1_in_L0_f) 

     `uvm_info(get_type_name() ," L0 state at Upstream TX side completed successfully ",UVM_LOW) 
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS1;   
     PIPE_seq_item_h.linkup_in_upstream  =  1'b1;
     send_ap2.write(PIPE_seq_item_h);

     ->L0_state_completed;
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Recovery_RcvrLock;
     
     
     break;
  end
  else begin

    `uvm_info(get_type_name() ," at L0 state at Upstream TX side now ",UVM_HIGH)
    
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type =  0       ;   
     PIPE_seq_item_h.linkup_in_upstream  =  1'b1    ;
     send_ap2.write(PIPE_seq_item_h);
     
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `L0;
     
     
  end


  end
  


endtask


task TX_Slave_U_Monitor::recoveryRcvrLock();

  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");


  while(1)begin
      @(posedge PIPE_vif_h.PCLK)

      if(PIPE_seq_item_h.Speed_change_bit_U == 1 && Received_TS1_in_recoveryRcvrLock_Substate_f)begin
          next_state=`Recovery_RcvrCfg;
          wanted_count=8;
          break;
      end
      else if(PIPE_vif_h.Rate == `GEN5 && start_equalization_w_preset_variable)begin
          next_state=`phase0;
          wanted_count=0;
          break;
      end
      else if(PIPE_seq_item_h.Speed_change_bit_U == 0  && Received_TS1_in_recoveryRcvrLock_Substate_f)begin
          next_state=`Config_Link_Width_Start;
          wanted_count=0;
          break;
      end
      else if(!changed_speed_recovery  && PIPE_vif_h.Rate > `GEN1 && Received_TS1_in_recoveryRcvrLock_Substate_f)begin
          next_state=`Recovery_Speed;
          wanted_count=0;
          break;
      end
      else if(TIME_OUT)begin
          next_state=`Detect_Active;
          TIME_OUT=0;
          break;
      end

  end





  while(TS_Count < wanted_count * `LANESNUMBER)begin
    @(posedge PIPE_vif_h.PCLK)

    
    if(wanted_count == 0) break;


    wait(PIPE_vif_h.TxDataValid != 0);


     for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
      @(posedge PIPE_vif_h.PCLK)
         
        if((PIPE_vif_h.TxData[31:24]!= 8'hBC && Symbol_num == 0)) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
          if(reject_os) rejected_TS++;
          reject_os = 0;

          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
            
            if(Symbol_num == 0)begin

                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b1)begin 
                          reject_os = 1;
 
                  end
     
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Lane_Data[k -: 8] != 8'h01 ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)begin 
                          reject_os = 1;
                        
                  end             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Lane_Data[k -: 8] != `LANESNUMBER-1-i||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)begin 
                          reject_os = 1;
                  end   
             
            end
            
            else if(Symbol_num == 4 )begin
                  
                  if(Lane_Data[`MAXPIPEWIDTH-1] != 1'b1 || Lane_Data[(`MAXPIPEWIDTH-5) -: 3] <=1 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)begin 
                          reject_os = 1;           
                  end

            end
            
            else if(Symbol_num == 6) begin

                  if(next_state == `Recovery_Equalization)begin

                      if(start_equalization_w_preset) TX_Preset_u = Lane_Data[k-1 -: 4];

                  end
                  else if(next_state == `Recovery_RcvrCfg)begin

                      if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0 )begin 

                          reject_os = 1;
                      end

                  end

                  
            end
            
            
            
            else if((Symbol_num > 6) && (Symbol_num !=15) && next_state == `Recovery_RcvrCfg) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)begin
                     
                     if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                         reject_os = 1;
                    end

            end
            
             
   
            else if(Symbol_num == 15 && next_state == `Recovery_RcvrCfg) begin
                
                if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)begin
                      
                      if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                          reject_os = 1;
                        
                end
 
                    
            end   
  
            Symbol_num = Symbol_num + 1;


        end

      end
     end
      
      if(rejected_TS<=`LANESNUMBER)begin
          TS_Count=TS_Count+(`LANESNUMBER-rejected_TS);

      end

      rejected_TS=0;
  end

  `uvm_info(get_type_name() ,"recoveryRcvrLock substate at Upstream TX side completed successfully",UVM_LOW)

    ->recoveryRcvrLock_Substate_Completed;
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS1;   
     
     send_ap2.write(PIPE_seq_item_h);
     
     Lane_Data        =  0;
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = next_state;
     rejected_TS      =  0;
     reject_os        =  0; 

     next_state       =  0;
     state_completed_successfully=1; 

endtask

task TX_Slave_U_Monitor:: recoveryRcvrCfg();

  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
    
  start_equalization_w_preset_variable=1;


  while(1)begin
      @(posedge PIPE_vif_h.PCLK) 

      if(PIPE_seq_item_h.Speed_change_bit_U && Received_TS2_in_recoveryRcvrCfg_Substate_f)begin
        next_state  =`Recovery_Speed;
        wanted_count=8;
        PIPE_seq_item_h.TS_Type = `TS2;
        break;

      end
      else if(!PIPE_seq_item_h.Speed_change_bit_U && Received_TS2_in_recoveryRcvrCfg_Substate_f)begin
        next_state  =`Recovery_Idle;
        PIPE_seq_item_h.TS_Type = `TS2;
        wanted_count=16;
        break;
      end

      else if(Received_TS1_in_recoveryRcvrCfg_Substate_f)begin
        next_state  =`Config_Link_Width_Start;
        PIPE_seq_item_h.TS_Type = `TS1;
        wanted_count=8;
        changed_speed_recovery=0;
        directed_speed_change=0;
        break;
      end

      else if(TIME_OUT)begin
        next_state  =`Detect_Active;
        wanted_count=0;
        break;
      end
  end

        
  while(TS_Count < wanted_count *`LANESNUMBER ) begin 
    
    @(posedge PIPE_vif_h.PCLK)

    if(wanted_count == 0) break;
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
       @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
          
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
          if(reject_os) rejected_TS++;

          reject_os = 0;
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin

          
            if(Symbol_num == 0)begin
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b1)
                          reject_os = 1;  
            
            end

            else if(Symbol_num == 1) begin 

              if(next_state == `Recovery_Idle )begin 
                if(Lane_Data[k -: 8] == 8'h7c ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)
                          TS_Count=0; 

              end
              else if( next_state == `Config_Link_Width_Start)begin
                if(Lane_Data[k -: 8] == 8'h01 ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)
                          reject_os = 1; 

              end 
              else if(next_state == `Recovery_Speed)begin
                if(Lane_Data[k -: 8] != 8'h01 ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)
                          reject_os = 1; 

              end     
                    

            end
            
            
            else if(Symbol_num == 2 ) begin
                  
              if(next_state == `Recovery_Idle )begin

                if(Lane_Data[k -: 8] == 8'h7c ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)
                          TS_Count=0; 

              end
              else if( next_state == `Config_Link_Width_Start)begin

                if(Lane_Data[k -: 8] == `LANESNUMBER-1-i ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))]!= 1'b0)
                          reject_os = 1;

              end

              else if(next_state == `Recovery_Speed)begin

                if(Lane_Data[k -: 8] != `LANESNUMBER-1-i ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))]!= 1'b0)
                          reject_os = 1; 

              end               

            end

            else if(Symbol_num == 4 )begin
              if(next_state == `Recovery_Speed)begin
                if(Lane_Data[k -: 8] != PIPE_seq_item_h.rate_identifier_U || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0
                  || PIPE_seq_item_h.rate_identifier_U  <= 1)

                          reject_os = 1; 
              end
              else if (next_state == `Recovery_Idle)begin
                  if(Lane_Data[k] != 0 || Lane_Data[k-4 -: 3] > 1 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)
                  
                          reject_os = 1; 

              end
            
            end

            
            
            else if(Symbol_num == 6) begin
              if(next_state == `Recovery_Speed)begin
                
                if(Lane_Data[k -: 8] != PIPE_seq_item_h.symbol_6_U || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))]!= 1'b0)
                          reject_os = 1;

              end    
       
            end
            
            
            
            else if(Symbol_num > 6) begin


                  if(next_state == `Recovery_Idle || next_state == `Recovery_Speed)begin

                     PIPE_seq_item_h.TS_Type = `TS2; 
                     if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)
                          reject_os = 1;



                  end
                  else if( next_state == `Config_Link_Width_Start)begin

                    PIPE_seq_item_h.TS_Type = `TS1; 
                    if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)
                          reject_os = 1;
                    

                  end

         
            end
            
             
   
  
  
            Symbol_num = Symbol_num + 1;
 

           end

        end
        end
        if(rejected_TS <= `LANESNUMBER)begin
          TS_Count=TS_Count+(`LANESNUMBER-rejected_TS);
        end

        rejected_TS=0;

      end
    
     


   `uvm_info(get_type_name() ," recovery RcvrCfg substate at Upstream TX side completed successfully",UVM_LOW)
     
     ->recoveryRcvrCfg_Substate_Completed;
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count;  
     
     send_ap2.write(PIPE_seq_item_h);
    

  

    Next_Substate    = next_state;

    Symbol_num       =  0;
    TS_Count         =  0;
    rejected_TS      =  0;
    reject_os        =  0;
    wanted_count     =  0;

    state_completed_successfully=1;
    TIME_OUT=0;

endtask

task TX_Slave_U_Monitor::recoverySpeed();

  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
    
    

  
  while(TS_Count < 1 *`LANESNUMBER ) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
       @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
          
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
          if(reject_os) rejected_TS++;

          reject_os = 0;
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin

            
            if(Symbol_num == 0)begin
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxSyncHeader != {((2*`LANESNUMBER)/4)*{4'ha}})
                          reject_os = 1;  
            
            end
            else if(Symbol_num > 0) begin      
                  if(Lane_Data[k -: 8] != 8'h7C)
                          reject_os = 1;  

            end

            Symbol_num = Symbol_num + 1;
 

           end
        end
        end
        if(rejected_TS <= `LANESNUMBER)begin
          TS_Count=TS_Count+(`LANESNUMBER-rejected_TS);
        end

        rejected_TS=0;

      end
     
    wait(Device_on_electrical_ideal_f);


    fork
      begin
        Timer(1,800,TIME_OUT);

      end

      begin

        while( ! TIME_OUT )begin

           
      
          @(posedge PIPE_vif_h.PCLK)
          
          wait(PIPE_vif_h.TxDataValid != 0);
          
          for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
            
            @(posedge PIPE_vif_h.PCLK)
              
              if(PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'h00 && Symbol_num == 0) break;
              
              for(int i = 0 ; i<`LANESNUMBER ; i++)begin
              
                
                Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
                Symbol_num = s*`MAXPIPEWIDTH/8;
                  
                if(reject_os) rejected_TS++;

                reject_os = 0;
              
                for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin

                  if(Symbol_num % 2 == 0)begin

                    if(Symbol_num == 0 && PIPE_vif_h.TxSyncHeader != {((2*`LANESNUMBER)/4)*{4'ha}}) begin
                        reject_os = 1;
                    end

                    if(Lane_Data[k -: 8] != 8'h00)begin
                        reject_os = 1;
                    end
                                  
                  
                  end
                  else if(Symbol_num % 2 == 1) begin      
                    if(Lane_Data[k -: 8] != 8'hff)
                        reject_os = 1;  

                  end
        
                  Symbol_num = Symbol_num + 1;
      

                end

              end

          end

          if(rejected_TS <= `LANESNUMBER)begin

            TS_Count=TS_Count+(`LANESNUMBER-rejected_TS);

          end

              rejected_TS=0;

            end


      end


    join

    if(TIME_OUT && PIPE_vif_h.PCLKRate == 4)begin
      Next_Substate=`Recovery_RcvrLock;

    end
    else begin
      Next_Substate=`Detect_Active;

    end
   `uvm_info(get_type_name() ," recovery Speed substate at Upstream TX side completed successfully",UVM_LOW)
     
     ->recoverySpeed_Substate_Completed;
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `EIOS;   
     
     send_ap2.write(PIPE_seq_item_h);
     
     Symbol_num       =  0;
     TS_Count         =  0;

endtask


task TX_Slave_U_Monitor::phase0();


  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");

  start_equalization_w_preset_variable=0;

  while(TS_Count < 2 * `LANESNUMBER)begin

    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);


    for(int s = 0; s< 128/`MAXPIPEWIDTH ; s++)begin

      @(posedge PIPE_vif_h.PCLK)

      if(PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'h1E && Symbol_num == 0) break;

      if(PIPE_vif_h.TxSyncHeader != {((2*`LANESNUMBER)/4)*{4'ha}} && s == 0 )begin
        reject_os=1;
      end

      for(int i = 0; i< `LANESNUMBER ; i++)begin

        Lane_Data=PIPE_vif_h.TxData[i*`LANESNUMBER +: `LANESNUMBER];
        Symbol_num = s*`MAXPIPEWIDTH/8;

        Descrambled_Data = apply_descramble(de_scrambler,Lane_Data,i,`GEN5);


        if(reject_os) rejected_TS++;

            reject_os = 0;

        for(int k = (`MAXPIPEWIDTH / 8) -1 ; k >0;k=k-8)begin

            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'h1E  )
                          reject_os = 1;
     
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Descrambled_Data[k -: 8] != 8'h01 )
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Descrambled_Data[k -: 8] != `LANESNUMBER-1-i)
                         reject_os = 1;          
             
            end
            
            else if(Symbol_num == 4 )begin
                  if(Descrambled_Data[k-4 -: 3] <=1 )
                         reject_os = 1;

            end
            
            else if(Symbol_num == 6) begin
                  if(Descrambled_Data[k] != 1'b1 || Descrambled_Data[ k-1 -: 4] != PIPE_vif_h.LocalPresetIndex[i*4 +: 3] 
                     || Descrambled_Data[ k-6 -: 2 ] != 2'b01) 
                         reject_os = 1;

            end
            
            
            
            else if(Symbol_num == 7) begin
                  if(Descrambled_Data[k-2 -: 6] != PIPE_vif_h.FS[i*6 +: 5] )begin
                         reject_os = 1;
                    end

            end
            else if(Symbol_num == 8) begin
                  if(Descrambled_Data[k-2  -: 6] != PIPE_vif_h.LF[i*6 +: 5])begin
                         reject_os = 1;
                    end

            end

            else if(Symbol_num == 9) begin
                  if(Descrambled_Data[k-2  -: 6] != PIPE_vif_h.LF[i*6 +: 5] )begin
                         reject_os = 1;
                    end

            end

            else if((Symbol_num > 9) && (Symbol_num !=15)) begin
                  if(Descrambled_Data[k -: 8] != 8'h4A )begin
                         reject_os = 1;
                    end

            end
            
             
   
            else if(Symbol_num == 15) begin
                if(Descrambled_Data[k -: 8] != 8'h4A )begin
                          reject_os = 1;
                end

            end   
  
            Symbol_num = Symbol_num + 1;


        end
      end

    end

    if(rejected_TS <= `LANESNUMBER)begin
          TS_Count=TS_Count+(`LANESNUMBER-rejected_TS);
        end

        rejected_TS=0;


  end

  `uvm_info(get_type_name() ,"phase 0 substate at Upstream TX side completed successfully",UVM_LOW)

    ->phase0_Substate_Completed;
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS1;   
     
     send_ap2.write(PIPE_seq_item_h);
     
     Symbol_num       =  0;
     TS_Count         =  0;
     rejected_TS      =  0;
     Next_Substate    = `phase1;

     reset_lfsr(de_scrambler,`GEN5);
endtask

task TX_Slave_U_Monitor::phase1();


  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");


  while(TS_Count < 2 * `LANESNUMBER)begin

    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);


    for(int s = 0; s< 128/`MAXPIPEWIDTH ; s++)begin

      if(PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'h1E && Symbol_num == 0) break;

      if(PIPE_vif_h.TxSyncHeader != {((2*`LANESNUMBER)/4)*{4'ha}} && s == 0 )
        reject_os=1;


      for(int i = 0; i< `LANESNUMBER ; i++)begin

        Lane_Data=PIPE_vif_h.TxData[i*`LANESNUMBER +: `LANESNUMBER];
        Symbol_num = s*`MAXPIPEWIDTH/8;

        Descrambled_Data = apply_descramble(de_scrambler,Lane_Data,i,`GEN5);

        if(reject_os) rejected_TS++;

            reject_os = 0;

        for(int k = (`MAXPIPEWIDTH / 8) -1 ; k >0;k=k-8)begin

            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'h1E  )
                          reject_os = 1;
     
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Descrambled_Data[k -: 8] != 8'h01 )
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Descrambled_Data[k -: 8] != `LANESNUMBER-1-i)
                         reject_os = 1;          
             
            end
            
            else if(Symbol_num == 4 )begin
                  if( Descrambled_Data[k-4 -: 3] <=1 )
                         reject_os = 1;

            end
            
            else if(Symbol_num == 6) begin
                  if(Descrambled_Data[ k-6 -: 2 ] != 2'b00 )
                         reject_os = 1;

            end
            

            else if((Symbol_num > 9) && (Symbol_num !=15)) begin
                  if(Descrambled_Data[k -: 8] != 8'h4A )begin
                         reject_os = 1;
                    end

            end
            
             
   
            else if(Symbol_num == 15) begin
                if(Descrambled_Data[k -: 8] != 8'h4A )begin
                          reject_os = 1;
                end
                    
            end   
  
            Symbol_num = Symbol_num + 1;


        end
      end

    end

    if(rejected_TS <= `LANESNUMBER) begin

      TS_Count=TS_Count+(`LANESNUMBER-rejected_TS);

    end

        rejected_TS=0;

  end

  `uvm_info(get_type_name() ,"phase 1 substate at Upstream TX side completed successfully",UVM_LOW)

    ->phase1_Substate_Completed;
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS1;   
     
     send_ap2.write(PIPE_seq_item_h);
     
     Symbol_num       =  0;
     TS_Count         =  0;
     rejected_TS      =  0;
     Next_Substate    = `Recovery_RcvrLock;

     reset_lfsr(de_scrambler,`GEN5);
endtask

task TX_Slave_U_Monitor::recoveryIdle();

  PIPE_seq_item  PIPE_seq_item_h;         



      while(1)begin

      if(Received_IDLE_in_recoveryIdle_Substate_f)begin
        next_state  =`L0;
        wanted_count=16;
        PIPE_seq_item_h.TS_Type = `IDLE; 
        break;

      end
      else if(Received_TS1_in_recoveryIdle_Substate_f)begin
        next_state  =`Config_Link_Width_Start;
        wanted_count=2;
        PIPE_seq_item_h.TS_Type = `TS1; 
        break;
      end

      else if(TIME_OUT)begin
        next_state  =`Detect_Active;
        wanted_count=0;
        break;
      end
  end

        
  while(TS_Count  < wanted_count * `LANESNUMBER ) begin 
    
    @(posedge PIPE_vif_h.PCLK)

    if(wanted_count == 0) break;
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
       @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'h55 && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
          
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
        
          Symbol_num = s*`MAXPIPEWIDTH/8;

          Descrambled_Data = apply_descramble(de_scrambler,Lane_Data,i,`GEN5);

          if(reject_os) rejected_TS++;

          reject_os = 0;
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin

           
            if(Symbol_num == 0)begin  
              if(next_state == `L0 )begin 

                  if(Lane_Data[k -: 8] != 8'h55 || PIPE_vif_h.TxSyncHeader != {((2*`LANESNUMBER)/4)*{4'ha}})
                          reject_os = 1;

              end
              else if( next_state == `Config_Link_Width_Start)begin

                if(Lane_Data[k -: 8] == 8'hBC || PIPE_vif_h.TxSyncHeader != {((2*`LANESNUMBER)/4)*{4'ha}})
                          reject_os = 1; 

              end 
            
            end

            else if(Symbol_num == 1) begin 

              if(next_state == `L0 )begin 

                if(Lane_Data[k -: 8] != 8'h1E )
                          reject_os = 1; 

              end
              else if( next_state == `Config_Link_Width_Start)begin

                if(Descrambled_Data[k -: 8] != 8'hf7 )
                          reject_os = 1; 

              end 
                    

            end
            
            
            else if(Symbol_num  == 2 ) begin
                  
              if(next_state == `L0 )begin

                if(Descrambled_Data[k -: 8] != 8'hf7 )
                          reject_os=0; 

              end
              else if( next_state == `Config_Link_Width_Start)begin

                if(Descrambled_Data[k -: 8] != 8'h00 )
                          reject_os = 1;

              end
               

            end

            else if(Symbol_num > 2 )begin

                if(next_state == `L0)begin

                  if(Descrambled_Data[k -: 8] != 8'h00 )
                            reject_os = 1;
                            
                end
              
            end
         
          end
            
            Symbol_num = Symbol_num + 1;
 

        end

    end
       
        if(rejected_TS <= `LANESNUMBER)begin
          TS_Count=TS_Count+(`LANESNUMBER-rejected_TS);
        end

        rejected_TS=0;

  end
    

     

   `uvm_info(get_type_name() ,"recovery Idle substate at Upstream TX side completed successfully",UVM_LOW)
     
    ->recoveryIdle_Substate_Completed;

     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `IDLE;   
     
     send_ap2.write(PIPE_seq_item_h);
     
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    =  next_state;
     next_state       =  0;
    
    reset_lfsr(de_scrambler,`GEN5);

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
        wait(LinkUp_Completed_USD);
        LinkUp_Completed_f=1;
      end 
        
      begin
          wait(Received_TS1_in_L0);
          Received_TS1_in_L0_f=1;
      end

      begin
        wait(Received_TS1_in_recoveryRcvrLock_Substate);
        Received_TS1_in_recoveryRcvrLock_Substate_f=1;
      end

      begin
        wait(Received_8_TS2_in_recoveryRcvrLock_Substate);
        Received_8_TS2_in_recoveryRcvrLock_Substate_f=1;
      end

      begin 
        wait(Received_TS2_in_recoveryRcvrCfg_Substate);
        Received_TS2_in_recoveryRcvrCfg_Substate_f=1;
      end

      begin
        wait(Received_TS1_in_recoveryRcvrCfg_Substate);
        Received_TS1_in_recoveryRcvrCfg_Substate_f=1;
      end


      begin
        wait(Device_on_electrical_ideal);
        Device_on_electrical_ideal_f=1;
      end

      begin
         wait(Received_IDLE_in_recoveryIdle_Substate);
         Received_IDLE_in_recoveryIdle_Substate_f=1;
      end

      begin
        wait(Received_TS1_in_recoveryIdle_Substate);
        Received_TS1_in_recoveryIdle_Substate_f=1;
      end
         
    join
  
  
  
  Received_2_TS1_in_Config_Link_Width_Start_f = 0;
  Received_2_TS1_in_Config_Link_Width_Accept_f = 0;
  Received_2_TS2_in_Config_Lanenum_Wait_f = 0;    
  Received_2_TS2_in_Config_Lanenum_Accept_f = 0; 
  Received_Idle_in_Config_Idle_f= 0;
  LinkUp_Completed_f=0;
  Received_TS1_in_L0_f=0;
  Received_TS1_in_recoveryRcvrLock_Substate_f=0;
  Received_TS2_in_recoveryRcvrCfg_Substate_f=0;

  Device_on_electrical_ideal_f=0;
  Received_IDLE_in_recoveryIdle_Substate_f=0;
  Received_TS1_in_recoveryIdle_Substate_f=0;
endtask

