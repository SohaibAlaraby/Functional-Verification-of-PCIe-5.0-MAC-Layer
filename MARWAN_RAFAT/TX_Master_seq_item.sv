class TX_Master_seq_item extends uvm_sequence_item;
`uvm_object_utils(TX_Master_seq_item)


bit  lp_irdy;    
rand bit[64-1:0] lp_dlpstart;
rand bit[64-1:0] lp_dlpend;
rand bit[64-1:0] lp_tlpstart;
rand bit[64-1:0] lp_tlpend;
rand bit[512-1:0] lp_data;
bit[64-1:0] lp_valid;




// ---------------//
rand bit [511:0] payload[];

bit [7:0] TLP[$]; 
bit [7:0] DLLP[$]; 

bit [1:0] packet_type;         // tlp 00
                               // DLLP 10
                               // invalid 11
rand bit [5:0] no_of_shift_start ;               
rand bit [5:0] no_of_shift_end ;            

rand bit [15:0] start_arr[4];
rand bit [15:0] end_arr[4];
rand bit [4:0] x [4];

// ---------------//

static int number_of_TLP_D,number_of_DLLP_D,number_of_TLP_U,number_of_DLLP_U;

// RX Related Signals // 
bit pl_trdy;
bit[64-1:0] pl_dlpstart;
bit[64-1:0] pl_dlpend;
bit[64-1:0] pl_tlpstart;
bit[64-1:0] pl_tlpend;
bit[64-1:0] pl_tlpedb;
bit[512-1:0] pl_data;
bit[64-1:0] pl_valid;


// ---------------//
constraint TLP_const {
    lp_dlpstart==0;
    lp_dlpend==0;
    // max size 1024 dw and min size 3 to 4 


    // when randomize make higher distribution for low size data transfer
    
    payload.size() dist { [1:10] := 20, [11:65] := 80 };

    if(payload.size()>1){ 
        // to make only 1 bit is set in start and end  
        // if i want to send alot of TLP per transfer -> overwrite with in line constraint 

        no_of_shift_start dist {[50:63] := 70 ,[0:49] := 30 };
        lp_tlpstart == 1 << no_of_shift_start;

        no_of_shift_end dist {[50:63] := 70 ,[0:49] := 30 };
        lp_tlpend == 1 << no_of_shift_end;               
    }
    

    if(payload.size()==1){ 
        foreach(x[i]){
            x[i] inside {[11:16]};
        }
        foreach(x[i]){
            start_arr[i] == 1<< x[i];
        }

        lp_tlpstart[63:48]==start_arr[0];
        lp_tlpstart[47:32]==start_arr[1];
        lp_tlpstart[31:16]==start_arr[2];
        lp_tlpstart[15:0] ==start_arr[3];

        lp_tlpend ==64'h0001000100010001;
                            
    }
    
}


constraint DLLP_const {
    lp_tlpstart==0;
    lp_tlpend==0;
    //  size 2 dw 
    payload.size() ==1 ;

    foreach(start_arr[i]){

        no_of_shift_start inside {[11 :16] };
        start_arr[i] == 1 << (no_of_shift_start-i);

        end_arr[i]   == 1 << (no_of_shift_start-7-i) ;
        
       
    }
   
        lp_dlpstart[63:48]==start_arr[0];
        lp_dlpstart[47:32]==start_arr[1];
        lp_dlpstart[31:16]==start_arr[2];
        lp_dlpstart[15:0] ==start_arr[3];

        lp_dlpend[63:48]==end_arr[0];
        lp_dlpend[47:32]==end_arr[1];
        lp_dlpend[31:16]==end_arr[2];
        lp_dlpend[15:0] ==end_arr[3];

     
}

constraint DLLP_TLP_const {
    payload.size() inside {[1:65]} ;


    no_of_shift_start inside {[0:63]};
    lp_tlpstart == 1 << no_of_shift_start;

    no_of_shift_end inside {[0:63]};
    lp_tlpend == 1 << no_of_shift_end;

    no_of_shift_start inside {[0:63]};
    lp_dlpstart == 1 << no_of_shift_start;

    no_of_shift_end inside {[0:63]};
    lp_dlpend == 1 << no_of_shift_end;


    (lp_dlpstart / lp_dlpend) == 128 ;
     (lp_tlpstart / lp_tlpend) >= 2048 ;

   if(payload.size()==1){ 
        if(lp_tlpstart>lp_dlpstart){
            lp_tlpend>lp_dlpstart;
            lp_dlpstart>lp_dlpend;
        }
        if(lp_tlpstart<lp_dlpstart){
            lp_dlpend>lp_tlpstart;
            lp_tlpstart>lp_tlpend;
        }
    }

       if(payload.size()>1){ 
        if(lp_tlpstart<lp_dlpstart){
            lp_dlpend>lp_tlpstart;
        }

        if(lp_tlpstart>lp_dlpstart){
            lp_tlpend>255;
            lp_dlpstart>=255;
            lp_tlpend>lp_dlpstart;
            lp_dlpstart>lp_dlpend;
        }
    }

     
}


function new(string name = "TX_Master_seq_item");
    super.new(name);
endfunction



endclass