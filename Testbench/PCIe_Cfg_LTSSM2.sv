////////////////////////////////////////////////////////////////////////////////
// Author: Marwan mohamed
// Description: configuration object for down stream LTSSM 2
// 
////////////////////////////////////////////////////////////////////////////////
package PCIe_Cfg_LTSSM2_pkg ;
    import uvm_pkg::*;
        `include "uvm_macros.svh"
    class PCIe_Cfg_LTSSM2 extends  uvm_object ;
        `uvm_object_utils(PCIe_Cfg_LTSSM2)

        virtual LPIF_if vif;
        function new (string name ="PCIe_Cfg_LTSSM2");
            super.new(name);
        endfunction
    endclass

endpackage