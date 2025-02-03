class PCIe_Test  extends uvm_test;



  `uvm_component_utils(PCIe_Test)
  
  
  
  PCIe_Env          PCIe_Env_h;
  
  
  LinkUp1_vseq      LinkUp1_vseq_h;
  LinkUp2_vseq      LinkUp2_vseq_h;

  DLLP_TLP_vSeq_TX_MASTER DLLP_TLP_vSeq_TX_MASTER_h;
  TLP_vSeq_TX_MASTER TLP_vSeq_TX_MASTER_h;
  DLLP_vSeq_TX_MASTER DLLP_vSeq_TX_MASTER_h;
	
 
  TX_Slave_Config   TX_Slave_U_Config_h;
  RX_Slave_Config   RX_Slave_U_Config_h;
  

  LTSSM1_Config     LTSSM1_U_Config_h;
  LTSSM2_Config     LTSSM2_U_Config_h;
 

  TX_Slave_Config   TX_Slave_D_Config_h;
  RX_Slave_Config   RX_Slave_D_Config_h;
 

  LTSSM1_Config     LTSSM1_D_Config_h;
  LTSSM2_Config     LTSSM2_D_Config_h; 

  TX_Slave_Config   TX_Slave_D_Config_h;
  RX_Slave_Config   RX_Slave_D_Config_h;
 

  LTSSM1_Config     LTSSM1_D_Config_h;
  LTSSM2_Config     LTSSM2_D_Config_h; 
  
  TX_Master_Config  TX_Master_D_Config_h;
  TX_Master_Config  TX_Master_U_Config_h;

  RX_Passive_Config RX_Passive_D_Config_h;
  RX_Passive_Config RX_Passive_U_Config_h;



  function new(string name = "PCIe_Test" ,uvm_component parent);
  
  
    super.new(name,parent);
  
    `uvm_info(get_type_name(),"Inside constructor of PCIe Test Class",UVM_LOW)
  
  
  endfunction :new
  
  
  
  
  
  
  
  
  
  function void build_phase(uvm_phase phase);
  
  
    super.build_phase(phase);
    
	 
	 `uvm_info(get_type_name(),"Inside build phase of PCIe Test Class",UVM_LOW)

	 
	 PCIe_Env_h = PCIe_Env::type_id::create("PCIe_Env_h",this);

         LinkUp1_vseq_h = LinkUp1_vseq::type_id::create("LinkUp1_vseq_h");
	 LinkUp2_vseq_h = LinkUp2_vseq::type_id::create("LinkUp2_vseq_h");

	 DLLP_vSeq_TX_MASTER_h = DLLP_vSeq_TX_MASTER::type_id::create("DLLP_vSeq_TX_MASTER_h");
	 TLP_vSeq_TX_MASTER_h = TLP_vSeq_TX_MASTER::type_id::create("TLP_vSeq_TX_MASTER_h");
	 DLLP_TLP_vSeq_TX_MASTER_h = DLLP_TLP_vSeq_TX_MASTER::type_id::create("DLLP_TLP_vSeq_TX_MASTER_h");  
	  
	 LTSSM1_U_Config_h = LTSSM1_Config::type_id::create("LTSSM1_U_Config_h");
	 LTSSM2_U_Config_h = LTSSM2_Config::type_id::create("LTSSM2_U_Config_h");

	 LTSSM1_D_Config_h = LTSSM1_Config::type_id::create("LTSSM1_D_Config_h");
	 LTSSM2_D_Config_h = LTSSM2_Config::type_id::create("LTSSM2_D_Config_h");

	 TX_Slave_D_Config_h = TX_Slave_Config::type_id::create("TX_Slave_D_Config_h");
	 RX_Slave_D_Config_h = RX_Slave_Config::type_id::create("RX_Slave_D_Config_h");

	 TX_Slave_U_Config_h = TX_Slave_Config::type_id::create("TX_Slave_U_Config_h");
	 RX_Slave_U_Config_h = RX_Slave_Config::type_id::create("RX_Slave_U_Config_h");
	  	  
	 TX_Master_D_Config_h=TX_Master_Config::type_id::create("TX_Master_D_Config_h");
	 TX_Master_U_Config_h=TX_Master_Config::type_id::create("TX_Master_U_Config_h");

	 RX_Passive_D_Config_h = RX_Passive_Config::type_id::create("RX_Passive_D_Config_h"); 
	 RX_Passive_U_Config_h = RX_Passive_Config::type_id::create("RX_Passive_U_Config_h");
	 
	 if(!uvm_config_db #(virtual PIPE_if)::get(this,"","PIPE_if_U_h",LTSSM1_U_Config_h.PIPE_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")
  
	 if(!uvm_config_db #(virtual LPIF_if)::get(this,"","LPIF_if_U_h",LTSSM2_U_Config_h.LPIF_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the LPIF interface")

	 if(!uvm_config_db #(virtual PIPE_if)::get(this,"","PIPE_if_D_h",LTSSM1_D_Config_h.PIPE_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")
  
	 if(!uvm_config_db #(virtual LPIF_if)::get(this,"","LPIF_if_D_h",LTSSM2_D_Config_h.LPIF_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the LPIF interface")

		 
	 if(!uvm_config_db #(virtual LPIF_if)::get(this,"","LPIF_if_D_h",TX_Master_D_Config_h.LPIF_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the LPIF interface")
	 
	 if(!uvm_config_db #(virtual LPIF_if)::get(this,"","LPIF_if_U_h",TX_Master_U_Config_h.LPIF_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the LPIF interface")


		 
    	if(!uvm_config_db #(virtual LPIF_if)::get(this,"","LPIF_if_U_h",RX_Passive_U_Config_h.LPIF_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the LPIF interface")
	
	
	if(!uvm_config_db #(virtual LPIF_if)::get(this,"","LPIF_if_D_h",RX_Passive_D_Config_h.LPIF_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the LPIF interface")

		
	 if(!uvm_config_db #(virtual PIPE_if)::get(this,"","PIPE_if_D_h",TX_Slave_D_Config_h.PIPE_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")
  
	 if(!uvm_config_db #(virtual PIPE_if)::get(this,"","PIPE_if_D_h",RX_Slave_D_Config_h.PIPE_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")
  
	 if(!uvm_config_db #(virtual PIPE_if)::get(this,"","PIPE_if_U_h",TX_Slave_U_Config_h.PIPE_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")
  
	 if(!uvm_config_db #(virtual PIPE_if)::get(this,"","PIPE_if_U_h",RX_Slave_U_Config_h.PIPE_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")
     


   uvm_config_db #(LTSSM1_Config)::set(this,"*","LTSSM1_D_Config_h",LTSSM1_D_Config_h);
   uvm_config_db #(LTSSM2_Config)::set(this,"*","LTSSM2_D_Config_h",LTSSM2_D_Config_h);

   uvm_config_db #(TX_Slave_Config)::set(this,"*","TX_Slave_D_Config_h",TX_Slave_D_Config_h);
   uvm_config_db #(RX_Slave_Config)::set(this,"*","RX_Slave_D_Config_h",RX_Slave_D_Config_h);


   uvm_config_db #(LTSSM1_Config)::set(this,"*","LTSSM1_U_Config_h",LTSSM1_U_Config_h);
   uvm_config_db #(LTSSM2_Config)::set(this,"*","LTSSM2_U_Config_h",LTSSM2_U_Config_h);

   uvm_config_db #(TX_Slave_Config)::set(this,"*","TX_Slave_U_Config_h",TX_Slave_U_Config_h);
   uvm_config_db #(RX_Slave_Config)::set(this,"*","RX_Slave_U_Config_h",RX_Slave_U_Config_h);

	   
   uvm_config_db #(TX_Master_Config)::set(this,"*","TX_Master_D_Config_h",TX_Master_D_Config_h);
   uvm_config_db #(TX_Master_Config)::set(this,"*","TX_Master_U_Config_h",TX_Master_U_Config_h);
  

   uvm_config_db #(RX_Passive_Config)::set(this,"*","RX_Passive_D_Config_h",RX_Passive_D_Config_h);
   uvm_config_db #(RX_Passive_Config)::set(this,"*","RX_Passive_U_Config_h",RX_Passive_U_Config_h);

   
  endfunction :build_phase 
  
  
  
  
  
  
  
  
  function void connect_phase (uvm_phase phase);
  
  
    super.connect_phase(phase);
	 
	 
	 `uvm_info(get_type_name(),"Inside connect phase of PCIe Test Class",UVM_LOW)
	 
  
  endfunction :connect_phase
  
  
  
  
  
  
  
  
  
  task  run_phase(uvm_phase phase);
  
  
    super.run_phase(phase);
  
  
	 `uvm_info(get_type_name(),"Inside run phase of PCIe Test Class",UVM_LOW)
  
   
	
	 phase.raise_objection(this);
  
	  	  
	  	  LinkUp1_vseq_h.sqr_u1 = PCIe_Env_h.LTSSM1_D_Agent_h.LTSSM1_D_Sequencer_h;
	  	  LinkUp1_vseq_h.sqr_u2 = PCIe_Env_h.LTSSM1_U_Agent_h.LTSSM1_U_Sequencer_h;

	  	  LinkUp2_vseq_h.sqr_u1 = PCIe_Env_h.LTSSM2_D_Agent_h.LTSSM2_D_Sequencer_h;
	  	  LinkUp2_vseq_h.sqr_u2 = PCIe_Env_h.LTSSM2_U_Agent_h.LTSSM2_U_Sequencer_h;	  	  
	  	  
	  	  DLLP_vSeq_TX_MASTER_h.sqr_d = PCIe_Env_h.TX_Master_D_Agent_h.TX_Master_D_Sequencer_h ;
		  DLLP_vSeq_TX_MASTER_h.sqr_u = PCIe_Env_h.TX_Master_U_Agent_h.TX_Master_U_Sequencer_h ;

		  TLP_vSeq_TX_MASTER_h.sqr_d = PCIe_Env_h.TX_Master_D_Agent_h.TX_Master_D_Sequencer_h ;
		  TLP_vSeq_TX_MASTER_h.sqr_u = PCIe_Env_h.TX_Master_U_Agent_h.TX_Master_U_Sequencer_h ;

		  DLLP_TLP_vSeq_TX_MASTER_h.sqr_d = PCIe_Env_h.TX_Master_D_Agent_h.TX_Master_D_Sequencer_h ;
		  DLLP_TLP_vSeq_TX_MASTER_h.sqr_u = PCIe_Env_h.TX_Master_U_Agent_h.TX_Master_U_Sequencer_h ;

	  	 fork
	  	 
	  	      LinkUp1_vseq_h.start(null);
	              LinkUp2_vseq_h.start(null);
	     
	         join
	    
	    	//TLP_vSeq_TX_MASTER_h.start(null);	
	    	//DLLP_vSeq_TX_MASTER_h.start(null);
		//DLLP_TLP_vSeq_TX_MASTER_h.start(null);
	  
	 phase.drop_objection(this);
  
  
  
  
 
  endtask :run_phase
  
  
  
  
  
  
  
  
endclass :PCIe_Test
