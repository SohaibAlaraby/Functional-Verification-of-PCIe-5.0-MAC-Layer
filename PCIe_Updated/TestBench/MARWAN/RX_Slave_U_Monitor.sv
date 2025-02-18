class RX_Slave_U_Monitor  extends uvm_monitor;
  
`uvm_component_utils(RX_Slave_U_Monitor)


virtual PIPE_if PIPE_vif_h; 

uvm_analysis_port #(PIPE_seq_item) send_ap;
PIPE_seq_item PIPE_Item_h;
//typedef enum bit[1:0] {Not_Defined=0, TS1=1,TS2=2,Idle=3 } LinkUp_Ordersets_en;
bit[16*8-1:0] LinkUp_OS [`LANESNUMBER];
//LinkUp_Ordersets_en LinkUp_OS_Type;
bit start_flag;
Descrambler_Scrambler  de_scrambler;

typedef enum int {
                Reset,
                Detect_Quiet,
                Detect_Active,
                Polling_Active,
                Polling_Active_To_Config,
                Polling_Config,
                Configuration_Linkwidth_Start,
                Configuration_Linkwidth_Accept,
                Configuration_Lanenum_Wait,
                Configuration_Lanenum_Accept,
                Configuration_Complete,
                Configuration_Idle,
                L0_,
                RECOVERY_RcvrLock,
                RECOVERY_Rcvrcfg,
                Recovery_Equalization,
                phase0 ,
                phase1 ,
                RECOVERY_Rcvrspeed,
                RECOVERY_RcvrIdle 
                } LinkUp_States;
LinkUp_States LinkUp_Current_State;
int TS1_Counter, TS2_Counter, Idle_Counter , EIEOS_Counter;
event TS_Receiving_Complete, idle_8_Receiving_Complete; /*TS_Type_Check_Complete, Idle_Type_Check_Complete,*/
event Updata_TS1_Counter_e, Updata_TS2_Counter_e, Updata_Idle_Counter_e, Update_EIEOS_Counter_e;
event Idle_16_Is_Sent,TS1_16_Is_Sent,TS2_16_Is_Sent;
event TS_Configuration_Linkwidth_Accept_sent;
event Received_TS2_in_Polling_Configuration,Received_TS2_in_Config_Complete;
int Negosiated_Link_Number;
int Negosiated_Lane_Number[`LANESNUMBER-1 : 0]='{15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0};
bit Upconfigure_Capability_bit;
bit speed_change_asserted ;
bit [1:0] TS_OK = 2'b00 ;
event Received_2_TS1_in_Config_Link_Width_Start;
event Received_2_TS1_in_Config_Link_Width_Accept;
event Received_2_TS2_in_Config_Lanenum_Wait;
event Received_2_TS2_in_Config_Lanenum_Accept;
event Received_Idle_in_Config_Idle;
event Config_Complete_Substate_Completed;
event Polling_Active_Substate_Completed; 
event Polling_Configuration_Substate_Completed; 
event Config_Link_Width_Start_Substate_Completed;
event LinkUp_Completed_USD;

event Received_TS1_in_L0 ;
//---------------------------------------------------//
event Received_TS1_in_recoveryRcvrLock_Substate;

//---------------------------------------------------//


event Received_TS2_in_recoveryRcvrCfg_Substate ;
event Received_TS1_in_recoveryRcvrCfg_Substate ;

//---------------------------------------------------//
event Device_on_electrical_ideal;
//----------------------------------------------//

event Received_IDLE_in_recoveryIdle_Substate;
event Received_TS1_in_recoveryIdle_Substate;

//----------------------------------------------//
event Received_TS1_in_phase0;
event Received_TS1_in_phase1;


//---------------------------------------------------//
event L0_state_completed ;
event recoveryRcvrLock_Substate_Completed;
event recoveryRcvrCfg_Substate_Completed ;
event recoveryRcvrspeed_Substate_Completed ;
event recoveryIdle_Substate_Completed;
event phase0_Substate_Completed;
event phase1_Substate_Completed;




bit start_equalization_w_preset ,changed_speed_recovery,directed_speed_change;

 
extern function new(string name="RX_Slave_U_Monitor",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task Detect_Data_Idle_generic();
extern task Detect_First_COM_general();
extern task Detect_State_recognition();
extern task Receive_TS_OS_general();
extern task Receive_Data_Idle_generic();
extern task Update_Idle_Counter();
extern task Update_TS1_Counter();
extern task Update_TS2_Counter();
extern task Update_EIEOS_Counter ();
extern task Check_TS_Polling_Active();
extern task Check_TS_Polling_Config();
extern task Check_TS_Configuration_Linkwidth_Start();
extern task Check_TS_Configuration_Linkwidth_Accept();
extern task Check_TS_Configuration_Lanenum_Accept();
extern task Check_TS_Configuration_Lanenum_Wait();
extern task Check_TS_Configuration_Complete();
extern task Check_TS_Configuration_Idle();
extern task Check_TS_L0();
extern task Check_TS_Recovery_RcvrLock(); 
extern task Check_TS_recoveryRcvrCfg();
//extern task Check_TS_recoveryRcvrwait();
extern task Check_TS_recoveryRcvrspeed();
extern task Check_TS_recoveryRcvrIdle();
extern task Check_TS_phase0();
extern task Check_TS_phase1();
extern task Check_TS();
extern task LinkUp_State_recognition();
extern task Main();
extern task run_phase(uvm_phase phase);

endclass



function RX_Slave_U_Monitor::new(string name="RX_Slave_U_Monitor",uvm_component parent);
  
        super.new(name,parent);

        
endfunction 




function void RX_Slave_U_Monitor::build_phase(uvm_phase phase);
  
        super.build_phase(phase);
        `uvm_info(get_type_name() ," in monitor build_phase ",UVM_HIGH)

        send_ap = new("send_ap",this);
                
endfunction




function void RX_Slave_U_Monitor::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name() ," in monitor connect_phase ",UVM_HIGH)
endfunction
   
   
   
   
    
task RX_Slave_U_Monitor::run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name() ," in monitor run_phase ",UVM_HIGH)
        Main ();
endtask


task RX_Slave_U_Monitor::Detect_Data_Idle_generic();
        //Watching the link for any COM character coming
        int idle = 8'h00;
        int lane_number=`LANESNUMBER;
        case (lane_number)
                 1: begin
                        // assumed that the first lane connected
                        
                        wait( idle == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]);
                 end
                 2: begin 
                        /*
                        assumsion: the 2 connected lanes is the first 2 lanes lane0 and lane1
                        we can extend this case
                        the other cases of lane number have the same assumsion above
                        */
                        wait(      idle == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]);
                 end
                 4: begin 
                        wait(      idle == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );
                 end
                 8: begin     wait(      idle == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 8]
                                && idle == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );
                 end
                 16: begin   wait(      0 != PIPE_vif_h.RxData[((16*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((15*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((14*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((13*`MAXPIPEWIDTH)-1) -: 8]
                                && 0 != PIPE_vif_h.RxData[((12*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((11*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((10*`MAXPIPEWIDTH)-1) -: 8]  
                                && 0 != PIPE_vif_h.RxData[((9*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 8]
                                && 0 != PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8]
                                && 0 != PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]&& 8'h45 != PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );
                 end
                default: wait(     idle == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]);
        endcase



        
endtask
task RX_Slave_U_Monitor::Detect_First_COM_general();
        //generic for all lanes
        //Watching the link for any COM character coming
        int COM = 8'hBC;
        int lane_number=`LANESNUMBER;
        case (lane_number)
                 1:begin 
                        // assumed that the first lane connected    
                        wait( COM == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]);
                end
                 2: begin 
                        /*
                        assumsion: the 2 connected lanes is the first 2 lanes lane0 and lane1
                        we can extend this case
                        the other cases of lane number have the same assumsion above
                        */
                        wait(      COM == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8]
                                && COM == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]);
                 end
                 4: begin 
                        wait(      COM == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );
                 end
                 8: begin     wait(      COM == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 8]
                                && COM == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );
                 end
                16: begin    wait(      COM == PIPE_vif_h.RxData[((16*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((15*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((14*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((13*`MAXPIPEWIDTH)-1) -: 8]
                                && COM == PIPE_vif_h.RxData[((12*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((11*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((10*`MAXPIPEWIDTH)-1) -: 8]  
                                && COM == PIPE_vif_h.RxData[((9*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 8]
                                && COM == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );
                 end
                default: wait(     COM == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]);
        endcase
                

endtask
task RX_Slave_U_Monitor::Detect_State_recognition();
        if(!start_flag) begin
                //from reset to Detect State
                @(posedge PIPE_vif_h.phy_reset);        //Detect.Quiet begins directly after reset
                
                LinkUp_Current_State = Detect_Quiet;
                @(PIPE_vif_h.TxDetectRx_Loopback);      //Detect.Active need to start detection (or periodicly try to predict receiver)
                
                LinkUp_Current_State = Detect_Active;

                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                PIPE_Item_h.Current_Substate=`Detect_Active;
                PIPE_Item_h.Next_Substate=`Polling_Active;
                send_ap.write(PIPE_Item_h);

                Detect_First_COM_general();
                
                LinkUp_Current_State =  Polling_Active;
                start_flag = 1'b1; //the complete of the starting of the linkup
        end else begin
                //if we returned to the Detect State from other state

        end
        
endtask

task RX_Slave_U_Monitor::Receive_TS_OS_general ();
        //generic for all lanes
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit[0:((`MAXPIPEWIDTH/8)-1)] control_character=0;

        forever begin

                if((LinkUp_Current_State >=  Polling_Active) && (LinkUp_Current_State <= RECOVERY_RcvrIdle) ) begin
                        Detect_First_COM_general();
                        for(int i=(16*8);i>0;i=i-`MAXPIPEWIDTH)begin 

                                for ( int j=0 ; j<`LANESNUMBER; j=j+1  ) begin
                                        control_character=0;
                                        LinkUp_OS[j][(i-1) -: `MAXPIPEWIDTH] = PIPE_vif_h.RxData[((j+1)*`MAXPIPEWIDTH-1) -: `MAXPIPEWIDTH];
                                        for (int M=0 ;M < (`MAXPIPEWIDTH/8) ;M =M+1 ) begin
                                                if((COM_Gen_1_2 == PIPE_vif_h.RxData[((j+1)*`MAXPIPEWIDTH-(M*8)-1) -: 8]) || (PAD_Gen_1_2 == PIPE_vif_h.RxData[((j+1)*`MAXPIPEWIDTH-(M*8)-1) -: 8])) begin
                                                        control_character[M] = 1; 
                                                end else begin
                                                        control_character[M] = 0; 
                                                end
                                        end
                                        /*assert(control_character == PIPE_vif_h.RxDataK[((j+1)*(`MAXPIPEWIDTH/8)-1) -: 4])
                                        
                                        
                                        else begin
                                                `uvm_info(get_type_name (),"RXDATAK Is not Correct!!", UVM_LOW)
                                                $display("control_character = %b  DataK = %b",control_character ,PIPE_vif_h.RxDataK[((j+1)*(`MAXPIPEWIDTH/8)-1) -: 4]);
                                        end*/
                                end
                                if(i > `MAXPIPEWIDTH) begin //do not wait a clk cycle to trigger the TS_Receiving_Complete event
                                                @(posedge PIPE_vif_h.PCLK);
                                                #1;
                                end

                        end
                ->TS_Receiving_Complete;
                end else begin
                        wait(LinkUp_Current_State >= Polling_Active && LinkUp_Current_State < Configuration_Idle);
                end
        end

        
endtask

task RX_Slave_U_Monitor::Receive_Data_Idle_generic ();
        // for lane 0
        forever begin
                
                if(Configuration_Idle == LinkUp_Current_State)begin //only care about idles in configuration_idle
                        Detect_Data_Idle_generic();
                        //LinkUp_OS=~('h0);//FF..F to make a clear contrast between idle bits and other bits
                        /*
                        Receiving pipewidth/8 idle symbols in one lane transmission  
                        so idle counter increased by pipewidth/8 every time
                        */
                        ->Received_Idle_in_Config_Idle;
                        for(int i = (8/(`MAXPIPEWIDTH/8));i>0;i=i-1) begin//how much cycles 
                                for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin//how much lanes
                                        // LinkUp_OS[j][(i*(`MAXPIPEWIDTH)+`MAXPIPEWIDTH-1) : i*(`MAXPIPEWIDTH)] = PIPE_vif_h.RxData[(j*`MAXPIPEWIDTH + `MAXPIPEWIDTH-1) : (j*`MAXPIPEWIDTH)];
                                        //linkup_os [63:32] = RxData[32:0]
                                        LinkUp_OS[j][(i*`MAXPIPEWIDTH-1) -: `MAXPIPEWIDTH] = PIPE_vif_h.RxData[((j+1)*`MAXPIPEWIDTH-1) -: `MAXPIPEWIDTH ];
                                end
                                if( i > 1) begin //do not wait a clk cycle to trigger the idle_8_Receiving_Complete event
                                                @(posedge PIPE_vif_h.PCLK);
                                                #1;
                                end
                        end
                        
                        ->idle_8_Receiving_Complete;
                end 

                else if (RECOVERY_RcvrIdle == LinkUp_Current_State)begin
                     Detect_Data_Idle_generic();  
                     for(int i = (8/(`MAXPIPEWIDTH/8));i>0;i=i-1) begin//how much cycles 
                                for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin//how much lanes
                                        // LinkUp_OS[j][(i*(`MAXPIPEWIDTH)+`MAXPIPEWIDTH-1) : i*(`MAXPIPEWIDTH)] = PIPE_vif_h.RxData[(j*`MAXPIPEWIDTH + `MAXPIPEWIDTH-1) : (j*`MAXPIPEWIDTH)];
                                        //linkup_os [63:32] = RxData[32:0]
                                        LinkUp_OS[j][(i*`MAXPIPEWIDTH-1) -: `MAXPIPEWIDTH] = PIPE_vif_h.RxData[((j+1)*`MAXPIPEWIDTH-1) -: `MAXPIPEWIDTH ];
                                end
                                if( i > 1) begin //do not wait a clk cycle to trigger the idle_8_Receiving_Complete event
                                                @(posedge PIPE_vif_h.PCLK);
                                                #1;
                                end
                        end
                end 
                
                else begin
                        wait(Configuration_Idle == LinkUp_Current_State || RECOVERY_RcvrIdle == LinkUp_Current_State);
                end
        end
endtask 

task RX_Slave_U_Monitor::Update_EIEOS_Counter ();
        forever begin
                wait(Update_EIEOS_Counter_e.triggered);
                EIEOS_Counter+=1;
                
                #1;
        end
        
endtask


task RX_Slave_U_Monitor::Update_Idle_Counter ();
        forever begin
                wait(Updata_Idle_Counter_e.triggered);
                Idle_Counter+=1;
               
                if(Idle_Counter==1) ->Received_Idle_in_Config_Idle;
               
                #1;
        end
endtask

task RX_Slave_U_Monitor::Update_TS1_Counter ();
        forever begin
                wait(Updata_TS1_Counter_e.triggered);
                TS1_Counter+=1;
                
                #1;
        end
        
endtask

task RX_Slave_U_Monitor::Update_TS2_Counter ();
        forever begin
                wait(Updata_TS2_Counter_e.triggered);
                TS2_Counter+=1;
                
                #1;
        end 
        
endtask

task RX_Slave_U_Monitor::Check_TS_Polling_Active();
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                if((COM_Gen_1_2 == LinkUp_OS[j][127:120]) //S0
                                && (PAD_Gen_1_2 == LinkUp_OS[j][119:112]) //S1
                                && (PAD_Gen_1_2 == LinkUp_OS[j][111:104]) //S2
                                //&& idle != LinkUp_OS[j][103:96] //N_FTS S3
                                && ((5'b00001 == LinkUp_OS[j][93:89])
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) //rate bits check
                                && (1'b0 == LinkUp_OS[j][95]) //  speed_change. This bit can be set to 1b only in theRecovery.RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.
                                //&& 1'b1 == LinkUp_OS[j][83] //S5 //Disable Scrambling (for Gen1 and 2)
                                && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                  
                                  
                                       -> Updata_TS1_Counter_e;
                                 
                                        
                                end
        end 

        
endtask

task RX_Slave_U_Monitor::Check_TS_Polling_Config();
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS2=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                if(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                && PAD_Gen_1_2 == LinkUp_OS[j][119:112] //S1
                                && PAD_Gen_1_2 == LinkUp_OS[j][111:104] //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                && ((5'b00001 == LinkUp_OS[j][93:89])
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) //rate bits check
                                && 1'b0 == LinkUp_OS[j][95] //  speed_change. This bit can be set to 1b only in theRecovery.RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                //&& TS2_ID == LinkUp_OS[j][79:72] //S6
                                && (TS2_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS2_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS2_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS2_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS2_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS2_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS2_ID == LinkUp_OS[j][23:16])//S13
                                && (TS2_ID == LinkUp_OS[j][15:8])//S14
                                && (TS2_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                  
                                  
                                  
                                  
                                  if(TS2_Counter==0)begin
                                    
                                           ->Received_TS2_in_Polling_Configuration; //This event for the Tx
                                           
                                  end
                                       
                                  
                                 -> Updata_TS2_Counter_e;     
                                     
                                  
                                end
              end 

endtask


task RX_Slave_U_Monitor::Check_TS_Configuration_Linkwidth_Start();//Upstream
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                if(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number
                                with the link number Tx transmitted in TS1 it sends*/
                                //&& Negosiated_Link_Number== LinkUp_OS[j][119:112] //S1 
                                && PAD_Gen_1_2 != LinkUp_OS[j][119:112] //S1
                                && PAD_Gen_1_2 == LinkUp_OS[j][111:104] //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && 1'b0 == LinkUp_OS[j][95] //S4
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                ) begin
                                  
                                  
                                  -> Updata_TS1_Counter_e;
                                  Negosiated_Link_Number =   LinkUp_OS[j][119:112];                              
                                end
                                       

        end 




endtask






task RX_Slave_U_Monitor::Check_TS_Configuration_Linkwidth_Accept();//Upstreamam
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
        bit [`LANESNUMBER-1:0] reversed_lane_number=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                if(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && (PAD_Gen_1_2 != LinkUp_OS[j][111:104]) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && 1'b0 == LinkUp_OS[j][95] //S4
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                
                                -> Updata_TS1_Counter_e;
                                
                                
                                end
        end 
  
        
endtask




task RX_Slave_U_Monitor::Check_TS_Configuration_Lanenum_Accept();//Upstreamam
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
        bit [`LANESNUMBER-1:0] reversed_lane_number=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                assert(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && 1'b0 == LinkUp_OS[j][95] //S4
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                //&& (TS2_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS2_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS2_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS2_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS2_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS2_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS2_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS2_ID == LinkUp_OS[j][23:16])//S13
                                && (TS2_ID == LinkUp_OS[j][15:8])//S14
                                && (TS2_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                  
                                  -> Updata_TS2_Counter_e;
                                  
                                end
        end 
       
       
endtask

task RX_Slave_U_Monitor::Check_TS_Configuration_Lanenum_Wait();//Upstream
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
        
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                if((COM_Gen_1_2 == LinkUp_OS[j][127:120]) //S0
                                
                                && (PAD_Gen_1_2 != LinkUp_OS[j][119:112]) //S1
                                
                                && (PAD_Gen_1_2 != LinkUp_OS[j][111:104]) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && 1'b0 == LinkUp_OS[j][95] //S4
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                //&& (TS2_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS2_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS2_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS2_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS2_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS2_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS2_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS2_ID == LinkUp_OS[j][23:16])//S13
                                && (TS2_ID == LinkUp_OS[j][15:8])//S14
                                && (TS2_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                
                                         -> Updata_TS2_Counter_e;
                                        
                                end
        end 

        
endtask


task RX_Slave_U_Monitor::Check_TS_Configuration_Complete();
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS2=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                if((COM_Gen_1_2 == LinkUp_OS[j][127:120]) //S0
                
                && (Negosiated_Link_Number != LinkUp_OS[j][119:112]) //S1
                
                && (Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104]) //S2
                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                /*rate bits check*/
                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                ||(5'b01111 == LinkUp_OS[j][93:89])
                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                //Upconfigure Capability bit
                &&( Upconfigure_Capability_bit == LinkUp_OS[j][94])
                /*  speed_change. This bit can be set to 1b only in theRecovery.
                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                && 1'b0 == LinkUp_OS[j][95] //S4
                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                //&& TS2_ID == LinkUp_OS[j][55:48] //S6
                && (TS2_ID == LinkUp_OS[j][71:64]) //S7
                && (TS2_ID == LinkUp_OS[j][63:56])  //S8
                && (TS2_ID == LinkUp_OS[j][55:48]) //S9
                && (TS2_ID == LinkUp_OS[j][47:40]) //S10
                && (TS2_ID == LinkUp_OS[j][39:32]) //S11
                && (TS2_ID == LinkUp_OS[j][31:24]) //S12
                && (TS2_ID == LinkUp_OS[j][23:16])//S13
                && (TS2_ID == LinkUp_OS[j][15:8])//S14
                && (TS2_ID == LinkUp_OS[j][7:0])//S15
                )begin
                  
                   if(TS2_Counter==0)begin
                                ->Received_TS2_in_Config_Complete;
                   end
                   -> Updata_TS2_Counter_e;
                        
                end
        end 

        
endtask



task RX_Slave_U_Monitor::Check_TS_Configuration_Idle();
  
       
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2 = 8'hBC;
        bit [7:0] PAD_Gen_1_2 = 8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [31:0] Lane_Data,Descrambled_Data1 ,Descrambled_Data2;
        bit [`LANESNUMBER-1:0] error_idle=0;
        
      
                
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
              Lane_Data = PIPE_vif_h.RxData[j*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
              if( (Lane_Data != 0)  && (Lane_Data  != {4{TS2_ID}}) ) begin
                Descrambled_Data1 = apply_descramble(de_scrambler,Lane_Data,j,1);
                if({4{idle}} == Descrambled_Data1) -> Updata_Idle_Counter_e;
                            
              end
  
      end
endtask


task RX_Slave_U_Monitor::Check_TS_L0();//Upstream
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
                if(PIPE_seq_item_h.supported_speed_in_upstream > 1 &&PIPE_seq_item_h.supported_speed_in_downstream > 1) begin
                                           directed_speed_change  = 1;
                                           changed_speed_recovery=1;
                end
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                assert(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && 1'b1 == LinkUp_OS[j][95] //speed change is required..........
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                //&& (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                         PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                         PIPE_Item_h.Speed_change_bit_U= LinkUp_OS[j][95];
                                         PIPE_Item_h.rate_identifier_U= LinkUp_OS[j][95:88];
                                         PIPE_Item_h.symbol_6_U= LinkUp_OS[j][79:72];
                                         send_ap.write(PIPE_Item_h);
                                  
                                  -> Updata_TS1_Counter_e;
                                  -> Received_TS1_in_L0 ;

                                  
                                end

                                       

        end 
endtask

task RX_Slave_U_Monitor::Check_TS_recoveryRcvrCfg();//Upstream
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;


        start_equalization_w_preset =1 ;

        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                if (1'b1 == LinkUp_OS[j][95]) begin
                                assert(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && 1'b1 == LinkUp_OS[j][95] //speed change is required..........
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                //&& (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS2_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS2_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS2_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS2_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS2_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS2_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS2_ID == LinkUp_OS[j][23:16])//S13
                                && (TS2_ID == LinkUp_OS[j][15:8])//S14
                                && (TS2_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                         PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                         PIPE_Item_h.Speed_change_bit_U= LinkUp_OS[j][95];
                                        PIPE_Item_h.rate_identifier_U= LinkUp_OS[j][95:88];
                                         PIPE_Item_h.symbol_6_U= LinkUp_OS[j][79:72];
                                         send_ap.write(PIPE_Item_h);
                                  
                                  -> Updata_TS2_Counter_e;
                                  -> Received_TS2_in_recoveryRcvrCfg_Substate ;
                                  //$display("number of TS2 = %d ",TS2_Counter);
                                 // speed_change_asserted = 1'b1 ;
                                  TS_OK = 2'b10;
                                  
                                end
                end 
                else if (1'b0 == LinkUp_OS[j][95]) begin
                                assert(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && 1'b0 == LinkUp_OS[j][95] //speed change is required..........
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                               // && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS2_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS2_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS2_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS2_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS2_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS2_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS2_ID == LinkUp_OS[j][23:16])//S13
                                && (TS2_ID == LinkUp_OS[j][15:8])//S14
                                && (TS2_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                         PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                         PIPE_Item_h.Speed_change_bit_U= LinkUp_OS[j][95];
                                        PIPE_Item_h.rate_identifier_U= LinkUp_OS[j][95:88];
                                         PIPE_Item_h.symbol_6_U= LinkUp_OS[j][79:72];
                                         send_ap.write(PIPE_Item_h);
                                  
                                  -> Updata_TS2_Counter_e;
                                  -> Received_TS2_in_recoveryRcvrCfg_Substate ;
                                 // speed_change_asserted = 1'b0 ;
                                  TS_OK = 2'b10;
                                  
                                end
                end 

                else if (COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                               // && 1'b0 == LinkUp_OS[j][95] //speed change is required..........
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                               // && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                         PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                         PIPE_Item_h.Speed_change_bit_U= LinkUp_OS[j][95];
                                        PIPE_Item_h.rate_identifier_U= LinkUp_OS[j][95:88];
                                         PIPE_Item_h.symbol_6_U= LinkUp_OS[j][79:72];
                                         send_ap.write(PIPE_Item_h);
                                  
                                  -> Updata_TS1_Counter_e;
                                  -> Received_TS1_in_recoveryRcvrCfg_Substate ;
                                 // speed_change_asserted = 1'b0 ;
                                 TS_OK = 2'b01;
                                  
                                end

        end 

        assert(LinkUp_OS[0][79:72] == LinkUp_OS[1][79:72] == LinkUp_OS[2][79:72] == LinkUp_OS[3][79:72] ==
         LinkUp_OS[4][79:72] == LinkUp_OS[5][79:72] == LinkUp_OS[6][79:72] == LinkUp_OS[7][79:72] ==
         LinkUp_OS[8][79:72] == LinkUp_OS[9][79:72] == LinkUp_OS[10][79:72] == LinkUp_OS[11][79:72] == 
         LinkUp_OS[12][79:72] == LinkUp_OS[13][79:72] == LinkUp_OS[14][79:72] == LinkUp_OS[15][79:72] );
endtask

task RX_Slave_U_Monitor::Check_TS_Recovery_RcvrLock();

        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                        if( (COM_Gen_1_2 == LinkUp_OS[j][127:120]) //S0
                        
                        && (Negosiated_Link_Number != LinkUp_OS[j][119:112]) //S1
                        
                        && (Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104]) //S2
                        //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                        /*rate bits check*/
                        && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                        ||(5'b00011 == LinkUp_OS[j][93:89]) 
                        ||(5'b00111 == LinkUp_OS[j][93:89]) 
                        ||(5'b01111 == LinkUp_OS[j][93:89])
                        ||(5'b11111 == LinkUp_OS[j][93:89])) 
                        //Upconfigure Capability bit
                        &&( Upconfigure_Capability_bit == LinkUp_OS[j][94])
                        /*  speed_change. This bit can be set to 1b only in theRecovery.
                        RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                       // && 1'b1 == LinkUp_OS[j][95] //S4
                        //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                        //&& TS2_ID == LinkUp_OS[j][55:48] //S6
                        && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                        && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                        && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                        && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                        && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                        && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                        && (TS1_ID == LinkUp_OS[j][23:16])//S13
                        && (TS1_ID == LinkUp_OS[j][15:8])//S14
                        && (TS1_ID == LinkUp_OS[j][7:0])//S15
                        )begin
                          
                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                        PIPE_Item_h.Speed_change_bit_U = LinkUp_OS[j][95];
                                        PIPE_Item_h.rate_identifier_U= LinkUp_OS[j][95:88];
                                         PIPE_Item_h.symbol_6_U= LinkUp_OS[j][79:72];
                                        send_ap.write(PIPE_Item_h);
                                        -> Updata_TS1_Counter_e;
                                        -> Received_TS1_in_recoveryRcvrLock_Substate;
                                        TS_OK = 2'b01;
                                end


                        else if ((COM_Gen_1_2 == LinkUp_OS[j][127:120]) //S0
                        
                        && (Negosiated_Link_Number != LinkUp_OS[j][119:112]) //S1
                        
                        && (Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104]) //S2
                        //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                        /*rate bits check*/
                        && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                        ||(5'b00011 == LinkUp_OS[j][93:89]) 
                        ||(5'b00111 == LinkUp_OS[j][93:89]) 
                        ||(5'b01111 == LinkUp_OS[j][93:89])
                        ||(5'b11111 == LinkUp_OS[j][93:89])) 
                        //Upconfigure Capability bit
                        &&( Upconfigure_Capability_bit == LinkUp_OS[j][94])
                        /*  speed_change. This bit can be set to 1b only in theRecovery.
                        RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                       // && 1'b0 == LinkUp_OS[j][95] //S4
                        //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                        //&& TS2_ID == LinkUp_OS[j][55:48] //S6
                        && (TS2_ID == LinkUp_OS[j][71:64]) //S7
                        && (TS2_ID == LinkUp_OS[j][63:56])  //S8
                        && (TS2_ID == LinkUp_OS[j][55:48]) //S9
                        && (TS2_ID == LinkUp_OS[j][47:40]) //S10
                        && (TS2_ID == LinkUp_OS[j][39:32]) //S11
                        && (TS2_ID == LinkUp_OS[j][31:24]) //S12
                        && (TS2_ID == LinkUp_OS[j][23:16])//S13
                        && (TS2_ID == LinkUp_OS[j][15:8])//S14
                        && (TS2_ID == LinkUp_OS[j][7:0])//S15
                        )begin
                                
                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                        PIPE_Item_h.Speed_change_bit_U = LinkUp_OS[j][95];
                                        PIPE_Item_h.rate_identifier_U= LinkUp_OS[j][95:88];
                                         PIPE_Item_h.symbol_6_U= LinkUp_OS[j][79:72];
                                        send_ap.write(PIPE_Item_h);
                                        -> Updata_TS2_Counter_e;
                                        -> Received_TS1_in_recoveryRcvrLock_Substate;
                                        TS_OK = 2'b10;
                        end
        end
endtask
/*
task RX_Slave_U_Monitor::Check_TS_recoveryRcvrwait();
     bit [31:0] EIEOS = 32'hBC7C7C7C ;
     int lane_number=`LANESNUMBER;
        case (lane_number)
                 1: begin
                        // assumed that the first lane connected
                        
                        if( EIEOS == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 32]) begin

                                     -> Update_EIEOS_Counter_e;
                                     -> Received_EIEOS_in_recoveryRcvrwait_Substate ;
                                end 
                 end
                 2: begin 
                        /*
                        assumsion: the 2 connected lanes is the first 2 lanes lane0 and lane1
                        we can extend this case
                        the other cases of lane number have the same assumsion above
                        */
                        /*if(      EIEOS == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 32]
                                )begin

                                     -> Update_EIEOS_Counter_e;
                                     -> Received_EIEOS_in_recoveryRcvrwait_Substate ;
                                end 
                 end
                 4: begin 
                        if(      EIEOS == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 32] 
                                )begin

                                     -> Update_EIEOS_Counter_e;
                                     -> Received_EIEOS_in_recoveryRcvrwait_Substate ;
                                end 
                 end
                 8: begin     if(      EIEOS == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 32]
                                && EIEOS == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 32]
                                 )begin

                                     -> Update_EIEOS_Counter_e;
                                     -> Received_EIEOS_in_recoveryRcvrwait_Substate ;
                                end 
                 end
                 16: begin   if(      EIEOS == PIPE_vif_h.RxData[((16*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((15*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((14*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((13*`MAXPIPEWIDTH)-1) -: 32]
                                && EIEOS == PIPE_vif_h.RxData[((12*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((11*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((10*`MAXPIPEWIDTH)-1) -: 32]  
                                && EIEOS == PIPE_vif_h.RxData[((9*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 32]
                                && EIEOS == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 32]
                                && EIEOS == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 32]
                                 ) begin

                                     -> Update_EIEOS_Counter_e;
                                     -> Received_EIEOS_in_recoveryRcvrwait_Substate ;
                                end 
                 end
                default: if(     EIEOS == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 32]
                ) begin

                                     -> Update_EIEOS_Counter_e;
                                     -> Received_EIEOS_in_recoveryRcvrwait_Substate ;
                                end 
        endcase

endtask*/

task RX_Slave_U_Monitor::Check_TS_recoveryRcvrspeed();
     bit [31:0] EIEOS = 32'hBC7C7C7C ;
     int lane_number=`LANESNUMBER;


        if (PIPE_vif_h.RXElecldle == 16'hFFFF ) -> Device_on_electrical_ideal ;
        case (lane_number)
                 1: begin
                        // assumed that the first lane connected
                        
                        if( EIEOS == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 32]) begin

                                     -> Update_EIEOS_Counter_e;
                            
                                end 
                 end
                 2: begin 
                        /*
                        assumsion: the 2 connected lanes is the first 2 lanes lane0 and lane1
                        we can extend this case
                        the other cases of lane number have the same assumsion above
                        */
                        if(      EIEOS == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 32]
                                )begin

                                     -> Update_EIEOS_Counter_e;
                                     
                                end 
                 end
                 4: begin 
                        if(      EIEOS == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 32] 
                                )begin

                                     -> Update_EIEOS_Counter_e;
                                     
                                end 
                 end
                 8: begin     if(      EIEOS == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 32]
                                && EIEOS == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 32]
                                 )begin

                                     -> Update_EIEOS_Counter_e;
                                     
                                end 
                 end
                 16: begin   if(      EIEOS == PIPE_vif_h.RxData[((16*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((15*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((14*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((13*`MAXPIPEWIDTH)-1) -: 32]
                                && EIEOS == PIPE_vif_h.RxData[((12*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((11*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((10*`MAXPIPEWIDTH)-1) -: 32]  
                                && EIEOS == PIPE_vif_h.RxData[((9*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 32]
                                && EIEOS == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 32]
                                && EIEOS == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 32] 
                                && EIEOS == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 32]
                                 ) begin

                                     -> Update_EIEOS_Counter_e;
                                     
                                end 
                 end
                default: if(     EIEOS == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 32]
                ) begin

                                     -> Update_EIEOS_Counter_e;
                                     
                                end 
        endcase

endtask

task RX_Slave_U_Monitor::Check_TS_recoveryRcvrIdle();

 bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2 = 8'hBC;
        bit [7:0] PAD_Gen_1_2 = 8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [31:0] Lane_Data,Descrambled_Data1 ,Descrambled_Data2;
        bit [`LANESNUMBER-1:0] error_idle=0;
        
      
                
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
              Lane_Data = PIPE_vif_h.RxData[j*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
              if( (Lane_Data != 0)  && (Lane_Data  != {4{TS2_ID}}) ) begin
                Descrambled_Data1 = apply_descramble(de_scrambler,Lane_Data,j,1);
                if({4{idle}} == Descrambled_Data1) begin
                -> Updata_Idle_Counter_e;
                ->Received_IDLE_in_recoveryIdle_Substate; 
                end 
              end
  
      end

for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
      if (COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                              //  && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && (PAD_Gen_1_2 == LinkUp_OS[j][111:104]) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                               // && 1'b0 == LinkUp_OS[j][95] //speed change is required..........
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                               // && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                         PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                         PIPE_Item_h.Speed_change_bit_U= LinkUp_OS[j][95];
                                        PIPE_Item_h.rate_identifier_U= LinkUp_OS[j][95:88];
                                         PIPE_Item_h.symbol_6_U= LinkUp_OS[j][79:72];
                                         send_ap.write(PIPE_Item_h);
                                  
                                  -> Updata_TS1_Counter_e;
                                  -> Received_TS1_in_recoveryIdle_Substate ;
                                 // speed_change_asserted = 1'b0 ;
                                 TS_OK = 2'b01;
                                  
                                end
end

endtask

task RX_Slave_U_Monitor::Check_TS_phase0();//Upstream
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
 
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                assert(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                               // && 1'b1 == LinkUp_OS[j][95] //speed change is required..........
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                && (2'b01 == LinkUp_OS[j][73:72]) //EC bits checker for phase0
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                         PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                         PIPE_Item_h.Speed_change_bit_U= LinkUp_OS[j][95];
                                         PIPE_Item_h.rate_identifier_U= LinkUp_OS[j][95:88];
                                         PIPE_Item_h.symbol_6_U= LinkUp_OS[j][79:72];
                                         send_ap.write(PIPE_Item_h);
                                  
                                  -> Updata_TS1_Counter_e;
                                  -> Received_TS1_in_phase0 ;

                                  
                                end

                                       

        end 
endtask

task RX_Slave_U_Monitor::Check_TS_phase1();//Upstream
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
 
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                assert(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                               // && 1'b1 == LinkUp_OS[j][95] //speed change is required..........
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                && (2'b10 == LinkUp_OS[j][73:72]) //EC bits checker for phase1
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                         PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                         PIPE_Item_h.Speed_change_bit_U= LinkUp_OS[j][95];
                                         PIPE_Item_h.rate_identifier_U= LinkUp_OS[j][95:88];
                                         PIPE_Item_h.symbol_6_U= LinkUp_OS[j][79:72];
                                         send_ap.write(PIPE_Item_h);
                                  
                                  -> Updata_TS1_Counter_e;
                                  -> Received_TS1_in_phase1 ;

                                  
                                end

                                       

        end 
endtask




task RX_Slave_U_Monitor::Check_TS ();//according to state
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        forever begin
                wait(LinkUp_Current_State >= Polling_Active && LinkUp_Current_State <= RECOVERY_RcvrIdle);
                case (LinkUp_Current_State)
                        Polling_Active:begin
                                wait(TS_Receiving_Complete.triggered);
                                Check_TS_Polling_Active();
                                #1;
                                
                                                              
                        end 
                        
                        Polling_Config:begin
                                wait(TS_Receiving_Complete.triggered);
                                Check_TS_Polling_Config();
                                #1;
                        end 
                        Configuration_Linkwidth_Start:begin
                                wait(TS_Receiving_Complete.triggered);
                                Check_TS_Configuration_Linkwidth_Start();
                                #1;
                        end 
                        Configuration_Linkwidth_Accept:begin
                        
                                wait(TS_Receiving_Complete.triggered);
                                Check_TS_Configuration_Linkwidth_Accept();
                                #1;
                                
                        end 
                        Configuration_Lanenum_Wait:begin
                                wait(TS_Receiving_Complete.triggered);
                                Check_TS_Configuration_Lanenum_Wait();
                                #1;
                        end 
                        Configuration_Lanenum_Accept:begin
                                wait(TS_Receiving_Complete.triggered);
                                Check_TS_Configuration_Lanenum_Accept();
                                #1;
                        end 
                        Configuration_Complete:begin
                                wait(TS_Receiving_Complete.triggered);
                                Check_TS_Configuration_Complete();
                                #1;
                        end 
                        Configuration_Idle:begin
                                //wait(idle_8_Receiving_Complete.triggered);
                                @(posedge PIPE_vif_h.PCLK)
                                Check_TS_Configuration_Idle();
                                #1;
                        end 
                        L0_:begin
                                @(posedge PIPE_vif_h.PCLK)
                                wait(TS_Receiving_Complete.triggered);
                                Check_TS_L0();
                                #1;
                        end  
                        RECOVERY_RcvrLock:begin
                                wait(TS_Receiving_Complete.triggered);
                                Check_TS_Recovery_RcvrLock();
                                #1;
                        end 
                        RECOVERY_Rcvrcfg:begin
                                wait(TS_Receiving_Complete.triggered);
                                Check_TS_recoveryRcvrCfg();
                                #1;
                        end  

                        RECOVERY_Rcvrspeed:begin
                                @(posedge PIPE_vif_h.PCLK)
                                Check_TS_recoveryRcvrspeed();
                                #1;
                        end 
  
                        RECOVERY_RcvrIdle:begin

                                @(posedge PIPE_vif_h.PCLK)
                                Check_TS_recoveryRcvrIdle();
                                #1;

                         end

                         phase0:begin

                                wait(TS_Receiving_Complete.triggered);
                                Check_TS_phase0();
                                #1;

                        end

                        phase1:begin

                                wait(TS_Receiving_Complete.triggered);
                                Check_TS_phase1();
                                #1;
                                
                        end

                
                endcase
        end
        
endtask

task RX_Slave_U_Monitor::LinkUp_State_recognition ();//parallel
        forever begin
                wait(LinkUp_Current_State >= Polling_Active && LinkUp_Current_State <= RECOVERY_RcvrIdle);
                 case (LinkUp_Current_State)
                        Polling_Active:begin
                                
                                wait(8==TS1_Counter);
                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Polling_Active;
                                PIPE_Item_h.Next_Substate=`Polling_Configuration;
                                PIPE_Item_h.TS_Count = 8;
                                PIPE_Item_h.TS_Type = `TS1;
                                send_ap.write(PIPE_Item_h);
                                wait(Polling_Active_Substate_Completed);
                                TS1_Counter=0;//its better to reset counter here 
                                LinkUp_Current_State = Polling_Config;
                                `uvm_info(get_type_name (),"Polling Active substate at Upstream RX side completed successfully", UVM_LOW)
                              
                        end 
                        Polling_Config:begin
                                
                                wait(8 == TS2_Counter);
                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Polling_Configuration;
                                PIPE_Item_h.Next_Substate=`Config_Link_Width_Start;
                                PIPE_Item_h.TS_Count = 8;
                                PIPE_Item_h.TS_Type = `TS2;
                                send_ap.write(PIPE_Item_h);
                                
                                wait(Polling_Configuration_Substate_Completed);
                                
                                TS2_Counter=0;
                                TS1_Counter=0;
                                LinkUp_Current_State = Configuration_Linkwidth_Start ;
                                `uvm_info(get_type_name() ,"Polling Configuration substate at Upstream RX side completed successfully",UVM_LOW)
                        end 
                        Configuration_Linkwidth_Start:begin
                                
                                wait(2==TS1_Counter);

                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Config_Link_Width_Start;
                                PIPE_Item_h.Next_Substate=`Config_Link_Width_Accept;
                                PIPE_Item_h.TS_Count = 2;
                                PIPE_Item_h.TS_Type = `TS1;
                                send_ap.write(PIPE_Item_h);

                                ->Received_2_TS1_in_Config_Link_Width_Start;
                                wait(Config_Link_Width_Start_Substate_Completed);
                                TS1_Counter=0;
                                TS2_Counter=0;
                                LinkUp_Current_State = Configuration_Linkwidth_Accept;
                                `uvm_info(get_type_name() ,"Config Link Width Start substate at Upstream RX side completed successfully",UVM_LOW)
                        end 
                        Configuration_Linkwidth_Accept:begin
                          
                                
                                 
                                 wait(2==TS1_Counter);
                                 
                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Config_Link_Width_Accept;
                                PIPE_Item_h.Next_Substate=`Config_Lanenum_Wait;
                                PIPE_Item_h.TS_Count = 2;
                                PIPE_Item_h.TS_Type = `TS1;
                                send_ap.write(PIPE_Item_h);                                

                               ->Received_2_TS1_in_Config_Link_Width_Accept;
                                TS1_Counter=0;
                                LinkUp_Current_State = Configuration_Lanenum_Wait;
                                `uvm_info(get_type_name() ,"Config Link Width Accept substate at Upstream RX side completed successfully",UVM_LOW)
                        end 
                        Configuration_Lanenum_Wait:begin
                                //if Upstream
                                
                                wait(2==TS2_Counter);


                                ->Received_2_TS2_in_Config_Lanenum_Wait ;
                                TS1_Counter=0;
                                TS2_Counter=0;
                                

                                LinkUp_Current_State = Configuration_Lanenum_Accept;
                                `uvm_info(get_type_name() ,"Config Lanenum Wait substate at Upstream RX side completed successfully",UVM_LOW)
                        end 
                        Configuration_Lanenum_Accept:begin
                                //if Upstream
                                
                                wait(2==TS2_Counter);

                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Config_Lanenum_Accept;
                                PIPE_Item_h.Next_Substate=`Config_Complete;
                                PIPE_Item_h.TS_Count = 2;
                                PIPE_Item_h.TS_Type = `TS2;
                                send_ap.write(PIPE_Item_h);

                               ->Received_2_TS2_in_Config_Lanenum_Accept;
                                TS1_Counter=0;
                                TS2_Counter=0;
                                

                                LinkUp_Current_State = Configuration_Complete;
                                `uvm_info(get_type_name() ,"Config Lanenum Accept substate at Upstream RX side completed successfully",UVM_LOW)
                        end 
                        Configuration_Complete:begin
                          
                                wait(8==TS2_Counter);
                               

                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Config_Complete;
                                PIPE_Item_h.Next_Substate=`Config_Idle;
                                PIPE_Item_h.TS_Count = 8;
                                PIPE_Item_h.TS_Type = `TS2;
                                send_ap.write(PIPE_Item_h);
                              
                                 wait(Config_Complete_Substate_Completed);
                                
                                TS2_Counter=0;
                                LinkUp_Current_State = Configuration_Idle;
                                `uvm_info(get_type_name() ,"Config Complete substate at Upstream RX side completed successfully",UVM_LOW)
                              
                                reset_lfsr(de_scrambler,1);
                                
                        end 
                        Configuration_Idle:begin
                                wait(8==Idle_Counter);

                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Config_Idle;
                                PIPE_Item_h.Next_Substate=`L0;
                                PIPE_Item_h.TS_Count = 8;
                                PIPE_Item_h.TS_Type = `IDLE;
                                send_ap.write(PIPE_Item_h);
                                ->LinkUp_Completed_USD;

                                Idle_Counter=0;
                                LinkUp_Current_State = L0_;
                                `uvm_info(get_type_name() ,"Config Idle substate at Upstream RX side completed successfully",UVM_LOW)
                        end 
                        L0_:begin
                                //data exchange
                                 wait(1==TS1_Counter);
                                 $display("TS1_Counter =%0d",TS1_Counter);       
                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`L0;
                                PIPE_Item_h.Next_Substate=`Recovery_RcvrLock;
                                PIPE_Item_h.TS_Count = 2;
                                PIPE_Item_h.TS_Type = `TS1;
                                send_ap.write(PIPE_Item_h);

                                TS1_Counter=0;
                                TS2_Counter=0;
                                
                                wait(L0_state_completed);
                                LinkUp_Current_State = RECOVERY_RcvrLock;
                                `uvm_info(get_type_name() ,"L0 STATE at Upstream RX side completed successfully",UVM_LOW)
                        end 
                        RECOVERY_RcvrLock:begin

                        if(PIPE_seq_item_h.Speed_change_bit_U == directed_speed_change && TS_OK == 2'b01 && TS1_Counter==8 )begin
                             // next_state=`Recovery_RcvrCfg;
                               PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Recovery_RcvrLock;
                                PIPE_Item_h.Next_Substate=`Recovery_RcvrCfg;
                                PIPE_Item_h.TS_Count = 8;
                                PIPE_Item_h.TS_Type = `TS1;
                                send_ap.write(PIPE_Item_h);

                                TS1_Counter=0;
                                TS2_Counter=0;
                                
                                wait(recoveryRcvrLock_Substate_Completed);
                                LinkUp_Current_State = RECOVERY_Rcvrcfg;
                                `uvm_info(get_type_name() ,"RECOVERY_RcvrLock STATE at Upstream RX side completed successfully",UVM_LOW)


                              break;
                        end
                        else if(PIPE_vif_h.Rate == `GEN5 && start_equalization_w_preset && TS_OK == 2'b10 && TS2_Counter==8)begin
                              //  next_state=`Recovery_Equalization;
                                 PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Recovery_RcvrLock;
                                PIPE_Item_h.Next_Substate=`phase0;
                                PIPE_Item_h.TS_Count = 8;
                                PIPE_Item_h.TS_Type = `TS2;
                                send_ap.write(PIPE_Item_h);

                                TS1_Counter=0;
                                TS2_Counter=0;
                                
                                wait(recoveryRcvrLock_Substate_Completed);
                                LinkUp_Current_State = phase0;
                                `uvm_info(get_type_name() ,"RECOVERY_RcvrLock STATE at Upstream RX side completed successfully",UVM_LOW)


                                break;
                        end
                        else if(PIPE_seq_item_h.Speed_change_bit_U == 0  && TS1_Counter==1 && TS_OK == 2'b01)begin 
                               // next_state=`Config_Link_Width_Start;

                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Recovery_RcvrLock;
                                PIPE_Item_h.Next_Substate=`Config_Link_Width_Start;
                                PIPE_Item_h.TS_Count = 1;
                                PIPE_Item_h.TS_Type = `TS1;
                                send_ap.write(PIPE_Item_h);

                                TS1_Counter=0;
                                TS2_Counter=0;
                                
                                wait(recoveryRcvrLock_Substate_Completed);
                                LinkUp_Current_State = Configuration_Linkwidth_Start;
                                `uvm_info(get_type_name() ,"RECOVERY_RcvrLock STATE at Upstream RX side completed successfully",UVM_LOW)

                                break;
                        end
                        else if(!changed_speed_recovery  && PIPE_vif_h.Rate > `GEN1 && TS1_Counter==1 && TS_OK == 2'b01)begin
                               // next_state=`Recovery_Speed;

                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Recovery_RcvrLock;
                                PIPE_Item_h.Next_Substate=`Recovery_Speed;
                                PIPE_Item_h.TS_Count = 1;
                                PIPE_Item_h.TS_Type = `TS1;
                                send_ap.write(PIPE_Item_h);

                                TS1_Counter=0;
                                TS2_Counter=0;
                                
                                wait(recoveryRcvrLock_Substate_Completed);
                                LinkUp_Current_State = RECOVERY_Rcvrspeed;
                                `uvm_info(get_type_name() ,"RECOVERY_RcvrLock STATE at Upstream RX side completed successfully",UVM_LOW)

                                break;
                        end
                        /*else if(TIME_OUT)begin
                                next_state=`Detect_Active;
                                TIME_OUT=0;
                                break;
                        end */
                                end 
                                
                       // end 

                         RECOVERY_Rcvrcfg:begin

                                if(PIPE_seq_item_h.Speed_change_bit_U && TS_OK == 2'b10 && TS2_Counter==8 )begin
                                        //next_state  =`Recovery_Speed;
                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                        PIPE_Item_h.Current_Substate=`Recovery_RcvrCfg;
                                        PIPE_Item_h.Next_Substate=`Recovery_Speed;
                                        PIPE_Item_h.TS_Count = 8;
                                        PIPE_Item_h.TS_Type = `TS2;
                                        send_ap.write(PIPE_Item_h);

                                        TS1_Counter=0;
                                        TS2_Counter=0;

                                         wait( recoveryRcvrCfg_Substate_Completed);
                                        LinkUp_Current_State = RECOVERY_Rcvrspeed;
                                       `uvm_info(get_type_name() ,"RECOVERY_Rcvrcfg STATE at Upstream RX side completed successfully",UVM_LOW)

                                        break;

                                end
                                else if(!PIPE_seq_item_h.Speed_change_bit_U && TS_OK == 2'b10 && TS2_Counter==16 )begin
                                        //next_state  =`Recovery_Idle;
                                         PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                        PIPE_Item_h.Current_Substate=`Recovery_RcvrCfg;
                                        PIPE_Item_h.Next_Substate=`Recovery_Idle;
                                        PIPE_Item_h.TS_Count = 16;
                                        PIPE_Item_h.TS_Type = `TS2;
                                        send_ap.write(PIPE_Item_h);
                                         TS1_Counter=0;
                                        TS2_Counter=0;

                                         wait( recoveryRcvrCfg_Substate_Completed);
                                        LinkUp_Current_State = RECOVERY_RcvrIdle;
                                       `uvm_info(get_type_name() ,"RECOVERY_Rcvrcfg STATE at Upstream RX side completed successfully",UVM_LOW)

 
                                        break;
                                end

                                else if(TS_OK == 2'b01 && TS1_Counter==8)begin
                                        //next_state  =`Config_Link_Width_Start;
                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                        PIPE_Item_h.Current_Substate=`Recovery_RcvrCfg;
                                        PIPE_Item_h.Next_Substate=`Config_Link_Width_Start;
                                        PIPE_Item_h.TS_Count = 8;
                                        PIPE_Item_h.TS_Type = `TS1;
                                        send_ap.write(PIPE_Item_h);
 
                                        changed_speed_recovery=0;
                                        directed_speed_change=0;
                                        TS1_Counter=0;
                                        TS2_Counter=0;

                                        wait( recoveryRcvrCfg_Substate_Completed);
                                        LinkUp_Current_State = Configuration_Linkwidth_Start;
                                       `uvm_info(get_type_name() ,"RECOVERY_Rcvrcfg STATE at Upstream RX side completed successfully",UVM_LOW)
                                        break;
                                end

                                /*else if(TIME_OUT)begin
                                        next_state  =`Detect_Active;
                                        wanted_count=0;
                                        break;
                                end*/
                                end

                         RECOVERY_Rcvrspeed:begin

                                 if( (1==EIEOS_Counter  && changed_speed_recovery==1 && PIPE_vif_h.Rate == `GEN5)
                                  || (1==EIEOS_Counter  && changed_speed_recovery==0 && PIPE_vif_h.Rate == `GEN1)) begin   
                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Recovery_Speed;
                                PIPE_Item_h.Next_Substate=`Recovery_RcvrLock;
                                PIPE_Item_h.TS_Count = 1;
                                PIPE_Item_h.TS_Type = `EIEOS;
                                send_ap.write(PIPE_Item_h);

                                EIEOS_Counter=0;
                                
                                wait(recoveryRcvrspeed_Substate_Completed);
                                LinkUp_Current_State = RECOVERY_RcvrLock;
                                `uvm_info(get_type_name() ,"recoveryspeed STATE at Upstream RX side completed successfully",UVM_LOW)
                                 end 

                        end  

                        RECOVERY_RcvrIdle:begin
                                if(8==Idle_Counter)begin

                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Recovery_Idle;
                                PIPE_Item_h.Next_Substate=`L0;
                                PIPE_Item_h.TS_Count = 8;
                                PIPE_Item_h.TS_Type = `IDLE;
                                send_ap.write(PIPE_Item_h);
                                //->LinkUp_Completed_USD;

                                Idle_Counter=0;
                                wait(recoveryIdle_Substate_Completed);
                                LinkUp_Current_State = L0_;
                                `uvm_info(get_type_name() ,"RECOVERY_RcvrIdle substate at Upstream RX side completed successfully",UVM_LOW)
                                end 
                                else if (TS1_Counter==2 && TS_OK == 2'b01)begin

                                 PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Recovery_Idle;
                                PIPE_Item_h.Next_Substate=`Config_Link_Width_Start;
                                PIPE_Item_h.TS_Count = 2;
                                PIPE_Item_h.TS_Type = `TS1;
                                send_ap.write(PIPE_Item_h);
                                //->LinkUp_Completed_USD;

                                TS1_Counter=0;
                                wait(recoveryIdle_Substate_Completed);
                                LinkUp_Current_State = Configuration_Linkwidth_Start;
                                `uvm_info(get_type_name() ,"RECOVERY_RcvrIdle substate at Upstream RX side completed successfully",UVM_LOW)
                                end 

                        end

                        phase0:begin

                                wait(2==TS1_Counter);
                               

                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`phase0;
                                PIPE_Item_h.Next_Substate=`phase1;
                                PIPE_Item_h.TS_Count = 2;
                                PIPE_Item_h.TS_Type = `TS1;
                                send_ap.write(PIPE_Item_h);
                              
                                 wait(phase0_Substate_Completed);
                                
                                TS1_Counter=0;
                                LinkUp_Current_State = phase0;
                                `uvm_info(get_type_name() ,"phase0 substate at Upstream RX side completed successfully",UVM_LOW)
                              

                        end

                        phase1:begin

                                wait(2==TS1_Counter);
                               

                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`phase1;
                                PIPE_Item_h.Next_Substate=`Recovery_RcvrLock;
                                PIPE_Item_h.TS_Count = 2;
                                PIPE_Item_h.TS_Type = `TS1;
                                send_ap.write(PIPE_Item_h);
                              
                                 wait(phase1_Substate_Completed);
                                
                                TS1_Counter=0;
                                LinkUp_Current_State = RECOVERY_RcvrLock;
                                `uvm_info(get_type_name() ,"phase1 substate at Upstream RX side completed successfully",UVM_LOW)
                              
                                
                        end

                        

                       
                endcase
        end
endtask

task RX_Slave_U_Monitor::Main ();
        fork
             Detect_State_recognition();   
             LinkUp_State_recognition ();
             Check_TS ();
             Receive_TS_OS_general ();
             //Receive_Data_Idle_generic ();
             Update_EIEOS_Counter ();
             Update_Idle_Counter ();
             Update_TS1_Counter ();
             Update_TS2_Counter ();

        join
endtask

        