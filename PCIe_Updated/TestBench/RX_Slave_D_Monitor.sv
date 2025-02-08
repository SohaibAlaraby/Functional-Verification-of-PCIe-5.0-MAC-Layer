class RX_Slave_D_Monitor  extends uvm_monitor;
  
`uvm_component_utils(RX_Slave_D_Monitor)


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
                L0_
                } LinkUp_States;
LinkUp_States LinkUp_Current_State;
int TS1_Counter, TS2_Counter, Idle_Counter;
event TS_Receiving_Complete, idle_8_Receiving_Complete; /*TS_Type_Check_Complete, Idle_Type_Check_Complete,*/
event Updata_TS1_Counter_e, Updata_TS2_Counter_e, Updata_Idle_Counter_e;
event Idle_16_Is_Sent,TS1_16_Is_Sent,TS2_16_Is_Sent;
event TS_Configuration_Linkwidth_Accept_sent;
event Received_TS2_in_Polling_Configuration,Received_TS2_in_Config_Complete;
int Negosiated_Link_Number;
int Negosiated_Lane_Number[`LANESNUMBER-1 : 0]='{15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0};
bit Upconfigure_Capability_bit;
event Received_2_TS1_in_Config_Link_Width_Start;
event Received_2_TS1_in_Config_Link_Width_Accept;
event Received_2_TS1_in_Config_Lanenum_Wait;
event Received_2_TS1_in_Config_Lanenum_Accept;
event Received_Idle_in_Config_Idle;
event Config_Complete_Substate_Completed;
event Polling_Active_Substate_Completed; 
event Polling_Configuration_Substate_Completed; 
event Config_Link_Width_Start_Substate_Completed;
 
 
extern function new(string name="RX_Slave_D_Monitor",uvm_component parent);
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
extern task Check_TS_Polling_Active();
extern task Check_TS_Polling_Config();
extern task Check_TS_Configuration_Linkwidth_Start();
extern task Check_TS_Configuration_Lanenum_Accept();
extern task Check_TS_Configuration_Lanenum_Wait();
extern task Check_TS_Configuration_Complete();
extern task Check_TS_Configuration_Idle();
extern task Check_TS();
extern task LinkUp_State_recognition();
extern task Main();
extern task run_phase(uvm_phase phase);

endclass



function RX_Slave_D_Monitor::new(string name="RX_Slave_D_Monitor",uvm_component parent);
  
        super.new(name,parent);

        
endfunction 




function void RX_Slave_D_Monitor::build_phase(uvm_phase phase);
  
        super.build_phase(phase);
        `uvm_info(get_type_name() ," in monitor build_phase ",UVM_HIGH)

        send_ap = new("send_ap",this);
                
endfunction




function void RX_Slave_D_Monitor::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name() ," in monitor connect_phase ",UVM_HIGH)
endfunction
   
   
   
   
    
task RX_Slave_D_Monitor::run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name() ," in monitor run_phase ",UVM_HIGH)
        Main ();
endtask


task RX_Slave_D_Monitor::Detect_Data_Idle_generic();
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
                                && 0 != PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );
                 end
                default: wait(     idle == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]);
        endcase



        
endtask
task RX_Slave_D_Monitor::Detect_First_COM_general();
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
task RX_Slave_D_Monitor::Detect_State_recognition();
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

task RX_Slave_D_Monitor::Receive_TS_OS_general ();
        //generic for all lanes
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit[0:((`MAXPIPEWIDTH/8)-1)] control_character=0;

        forever begin

                if((LinkUp_Current_State >=  Polling_Active) && LinkUp_Current_State <  Configuration_Idle) begin
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
                                        assert(control_character == PIPE_vif_h.RxDataK[((j+1)*(`MAXPIPEWIDTH/8)-1) -: 4])
                                        
                                        
                                        else begin
                                                `uvm_info(get_type_name (),"RXDATAK Is not Correct!!", UVM_LOW)
                                                $display("control_character = %b  DataK = %b",control_character ,PIPE_vif_h.RxDataK[((j+1)*(`MAXPIPEWIDTH/8)-1) -: 4]);
                                        end
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

task RX_Slave_D_Monitor::Receive_Data_Idle_generic ();
        // for lane 0
        forever begin
                
                if(Configuration_Idle == LinkUp_Current_State)begin//only care about idles in configuration_idle
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
                end else begin
                        wait(Configuration_Idle == LinkUp_Current_State);
                end
        end
endtask

task RX_Slave_D_Monitor::Update_Idle_Counter ();
        forever begin
                wait(Updata_Idle_Counter_e.triggered);
                Idle_Counter+=1;
                
                if(Idle_Counter==1) ->Received_Idle_in_Config_Idle;
               
                #1;
        end
endtask
task RX_Slave_D_Monitor::Update_TS1_Counter ();
        forever begin
                wait(Updata_TS1_Counter_e.triggered);
                TS1_Counter+=1;
                
                #1;
        end
        
endtask
task RX_Slave_D_Monitor::Update_TS2_Counter ();
        forever begin
                wait(Updata_TS2_Counter_e.triggered);
                TS2_Counter+=1;
                
                #1;
        end 
        
endtask

task RX_Slave_D_Monitor::Check_TS_Polling_Active();
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                assert((COM_Gen_1_2 == LinkUp_OS[j][127:120]) //S0
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
                                )
                                       
                                 else begin
                                        `uvm_info(get_type_name (),"TS1 does not meet the specs of polling.Active!!", UVM_LOW)
                                        error_TS1[j]=1'b1;
                                        
                                end
        end 
        if('b0 == error_TS1)begin
                if(TS1_Counter<8)begin
                        -> Updata_TS1_Counter_e;
        
                end 
        end
        
endtask

task RX_Slave_D_Monitor::Check_TS_Polling_Config();
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS2=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                assert(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
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
                                )
                                      
                               else begin
                                        `uvm_info(get_type_name (),"TS2 does not meet the specs of polling.Config!!", UVM_LOW)
                                        error_TS2[j]=1'b1;
                                        //wait(0);
                                end
        end 
        if('b0 == error_TS2)begin
                
                if(TS2_Counter<8)begin
                        if(TS2_Counter==0)begin
                                ->Received_TS2_in_Polling_Configuration; //This event for the Tx
                               
                        end
                        -> Updata_TS2_Counter_e;
                end 
        end
        
endtask
task RX_Slave_D_Monitor::Check_TS_Configuration_Linkwidth_Start();//downstream
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
                                                                  
                                end
                                       

        end 




endtask

task RX_Slave_D_Monitor::Check_TS_Configuration_Lanenum_Accept();//downstream
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
                                )
                                        
                                else begin
                                        `uvm_info(get_type_name (),"TS1 does not meet the specs of downstream Configuration_Lanenum_Accept!!", UVM_LOW)
                                        error_TS1[j]=1'b1;
                                        //wait(0);
                                end
        end 
        if('b0 == error_TS1)begin
                if(TS1_Counter<2)begin
                        -> Updata_TS1_Counter_e;
                end 
        end
        
endtask

task RX_Slave_D_Monitor::Check_TS_Configuration_Lanenum_Wait();//downstream
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
                                         Negosiated_Link_Number = LinkUp_OS[0][119:112];
                                end
        end 

        
endtask


task RX_Slave_D_Monitor::Check_TS_Configuration_Complete();
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



task RX_Slave_D_Monitor::Check_TS_Configuration_Idle();
  
  
       
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



task RX_Slave_D_Monitor::Check_TS ();//according to state
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        forever begin
                wait(LinkUp_Current_State >= Polling_Active && LinkUp_Current_State <= Configuration_Idle);
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
                        
                                @(posedge PIPE_vif_h.PCLK);
                                
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
                                wait(TS_Receiving_Complete.triggered || LinkUp_Current_State == Configuration_Idle);
                                Check_TS_Configuration_Complete();
                                #1;
                        end 
                        Configuration_Idle:begin
                                @(posedge PIPE_vif_h.PCLK);
                                Check_TS_Configuration_Idle ();
                                
                                
                        end 
                        L0_:begin
                               #1;
                        end  
                endcase
        end
        
endtask
task RX_Slave_D_Monitor::LinkUp_State_recognition ();//parallel
        forever begin
                wait(LinkUp_Current_State >= Polling_Active && LinkUp_Current_State <= L0_);
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
                                `uvm_info(get_type_name (),"Polling Active substate at Downstream RX side completed successfully", UVM_LOW)
                              
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
                                `uvm_info(get_type_name() ,"Polling Configuration substate at Downstream RX side completed successfully",UVM_LOW)
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
                                TS1_Counter=0;
                                TS2_Counter=0;
                                LinkUp_Current_State = Configuration_Linkwidth_Accept;
                                `uvm_info(get_type_name() ,"Config Link Width Start substate at Downstream RX side completed successfully",UVM_LOW)
                        end 
                        Configuration_Linkwidth_Accept:begin
                                 wait(Config_Link_Width_Start_Substate_Completed);
                                
                                //wait(1==TS1_Counter);
                                @(posedge PIPE_vif_h.PCLK);
                                TS1_Counter=0;
                                LinkUp_Current_State = Configuration_Lanenum_Wait;
                                `uvm_info(get_type_name() ,"Config Link Width Accept substate at Downstream RX side completed successfully",UVM_LOW)
                        end 
                        Configuration_Lanenum_Wait:begin
                                //if downstream
                                
                                wait(2==TS1_Counter);
                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Config_Lanenum_Wait;
                                PIPE_Item_h.Next_Substate=`Config_Lanenum_Accept;
                                PIPE_Item_h.TS_Count = 2;
                                PIPE_Item_h.TS_Type = `TS1;
                                send_ap.write(PIPE_Item_h);

                                ->Received_2_TS1_in_Config_Lanenum_Wait ;
                                TS1_Counter=0;
                                TS2_Counter=0;
                                

                                LinkUp_Current_State = Configuration_Lanenum_Accept;
                                `uvm_info(get_type_name() ,"Config Lanenum Wait substate at Downstream RX side completed successfully",UVM_LOW)
                        end 
                        Configuration_Lanenum_Accept:begin
                                //if downstream
                                
                                wait(2==TS1_Counter);

                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                PIPE_Item_h.Current_Substate=`Config_Lanenum_Accept;
                                PIPE_Item_h.Next_Substate=`Config_Complete;
                                PIPE_Item_h.TS_Count = 2;
                                PIPE_Item_h.TS_Type = `TS1;
                                send_ap.write(PIPE_Item_h);

                               ->Received_2_TS1_in_Config_Lanenum_Accept;
                                TS1_Counter=0;
                                TS2_Counter=0;
                                

                                LinkUp_Current_State = Configuration_Complete;
                                `uvm_info(get_type_name() ,"Config Lanenum Accept substate at Downstream RX side completed successfully",UVM_LOW)
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
                                `uvm_info(get_type_name() ,"Config Complete substate at Downstream RX side completed successfully",UVM_LOW)
                                
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

                                Idle_Counter=0;
                                LinkUp_Current_State = L0_;
                                `uvm_info(get_type_name() ,"Config Idle substate at Downstream RX side completed successfully",UVM_LOW)
                        end 
                        L0_:begin
                                //data exchange
                            #1;
                        end 
                       
                endcase
        end
endtask

task RX_Slave_D_Monitor::Main ();
        fork
             Detect_State_recognition();   
             LinkUp_State_recognition ();
             Check_TS ();
             Receive_TS_OS_general ();
            // Receive_Data_Idle_generic ();
             Update_Idle_Counter ();
             Update_TS1_Counter ();
             Update_TS2_Counter ();
        join
endtask

    