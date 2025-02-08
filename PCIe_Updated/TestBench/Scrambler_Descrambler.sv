
typedef struct {
  bit [15:0] lfsr_gen_1_2  [`LANESNUMBER];
  bit [22:0] lfsr_gen_3    [`LANESNUMBER];
} Descrambler_Scrambler;


function automatic void reset_lfsr(ref Descrambler_Scrambler scrambler, input int cur_gen);
  integer idx, jdx;
  if (cur_gen == `GEN1 || cur_gen == `GEN2) begin
    foreach (scrambler.lfsr_gen_1_2[idx]) begin
      scrambler.lfsr_gen_1_2[idx] = 16'hFFFF;
    end
  end
  else if (cur_gen == `GEN3 || cur_gen == `GEN4 || cur_gen == `GEN5) begin
    foreach (scrambler.lfsr_gen_3[idx]) begin
      jdx = idx;
      if (idx > 7) begin
        jdx = idx - 8;
      end
      case (jdx)
        0: scrambler.lfsr_gen_3[idx] = 'h1DBFBC;
        1: scrambler.lfsr_gen_3[idx] = 'h0607BB;
        2: scrambler.lfsr_gen_3[idx] = 'h1EC760;
        3: scrambler.lfsr_gen_3[idx] = 'h18C0DB;
        4: scrambler.lfsr_gen_3[idx] = 'h010F12;
        5: scrambler.lfsr_gen_3[idx] = 'h19CFC9;
        6: scrambler.lfsr_gen_3[idx] = 'h0277CE;
        7: scrambler.lfsr_gen_3[idx] = 'h1BB807;
      endcase
    end
  end
endfunction




function  automatic void set_bit(ref int data, input int index, input int value);
  data = data | (value << index);
endfunction

function automatic bit get_bit( int data, input int index);
  return (data >> index) & 1;
endfunction




function automatic bit [31:0] apply_scramble(ref Descrambler_Scrambler scrambler,
                                            input bit [31:0] data_in,
                                            int lanenum,
                                            input int cur_gen);
  if (cur_gen == `GEN1 || cur_gen == `GEN2)
    return scramble_gen_1_2(scrambler, data_in, lanenum);
  else if (cur_gen == `GEN3 || cur_gen == `GEN4 || cur_gen == `GEN5)
    return scramble_gen_3(scrambler, data_in, lanenum);
endfunction


function automatic bit [31:0] apply_descramble(ref Descrambler_Scrambler scrambler,
                                              input bit [31:0] data_in,
                                              int lanenum,
                                              input int cur_gen);
  if (cur_gen == `GEN1 || cur_gen == `GEN2)
    return scramble_gen_1_2(scrambler, data_in, lanenum);
  else if (cur_gen == `GEN3 || cur_gen == `GEN4 || cur_gen == `GEN5)
    return scramble_gen_3(scrambler, data_in, lanenum);
endfunction


function automatic bit [31:0] scramble_gen_1_2(ref Descrambler_Scrambler scrambler,
                                              input bit [31:0] data_in,
                                              int lanenum);
  bit [15:0] new_lfsr;
  bit [31:0] data_out;
 
new_lfsr[0]  = scrambler.lfsr_gen_1_2[lanenum][0] ^ scrambler.lfsr_gen_1_2[lanenum][6] ^ scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][10];
new_lfsr[1]  = scrambler.lfsr_gen_1_2[lanenum][1] ^ scrambler.lfsr_gen_1_2[lanenum][7] ^ scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][11];
new_lfsr[2]  = scrambler.lfsr_gen_1_2[lanenum][2] ^ scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][10] ^ scrambler.lfsr_gen_1_2[lanenum][12];
new_lfsr[3]  = scrambler.lfsr_gen_1_2[lanenum][3] ^ scrambler.lfsr_gen_1_2[lanenum][6] ^ scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][10] ^ scrambler.lfsr_gen_1_2[lanenum][11] ^ scrambler.lfsr_gen_1_2[lanenum][13];
new_lfsr[4]  = scrambler.lfsr_gen_1_2[lanenum][4] ^ scrambler.lfsr_gen_1_2[lanenum][6] ^ scrambler.lfsr_gen_1_2[lanenum][7] ^ scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][11] ^ scrambler.lfsr_gen_1_2[lanenum][12] ^ scrambler.lfsr_gen_1_2[lanenum][14];
new_lfsr[5]  = scrambler.lfsr_gen_1_2[lanenum][5] ^ scrambler.lfsr_gen_1_2[lanenum][6] ^ scrambler.lfsr_gen_1_2[lanenum][7] ^ scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][12] ^ scrambler.lfsr_gen_1_2[lanenum][13] ^ scrambler.lfsr_gen_1_2[lanenum][15];
new_lfsr[6]  = scrambler.lfsr_gen_1_2[lanenum][0] ^ scrambler.lfsr_gen_1_2[lanenum][6] ^ scrambler.lfsr_gen_1_2[lanenum][7] ^ scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][10] ^ scrambler.lfsr_gen_1_2[lanenum][13] ^ scrambler.lfsr_gen_1_2[lanenum][14];
new_lfsr[7]  = scrambler.lfsr_gen_1_2[lanenum][1] ^ scrambler.lfsr_gen_1_2[lanenum][7] ^ scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][11] ^ scrambler.lfsr_gen_1_2[lanenum][14] ^ scrambler.lfsr_gen_1_2[lanenum][15];
new_lfsr[8]  = scrambler.lfsr_gen_1_2[lanenum][0] ^ scrambler.lfsr_gen_1_2[lanenum][2] ^ scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][10] ^ scrambler.lfsr_gen_1_2[lanenum][12] ^ scrambler.lfsr_gen_1_2[lanenum][15];
new_lfsr[9]  = scrambler.lfsr_gen_1_2[lanenum][1] ^ scrambler.lfsr_gen_1_2[lanenum][3] ^ scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][10] ^ scrambler.lfsr_gen_1_2[lanenum][11] ^ scrambler.lfsr_gen_1_2[lanenum][13];
new_lfsr[10] = scrambler.lfsr_gen_1_2[lanenum][0] ^ scrambler.lfsr_gen_1_2[lanenum][2] ^ scrambler.lfsr_gen_1_2[lanenum][4] ^ scrambler.lfsr_gen_1_2[lanenum][10] ^ scrambler.lfsr_gen_1_2[lanenum][11] ^ scrambler.lfsr_gen_1_2[lanenum][12] ^ scrambler.lfsr_gen_1_2[lanenum][14];
new_lfsr[11] = scrambler.lfsr_gen_1_2[lanenum][1] ^ scrambler.lfsr_gen_1_2[lanenum][3] ^ scrambler.lfsr_gen_1_2[lanenum][5] ^ scrambler.lfsr_gen_1_2[lanenum][11] ^ scrambler.lfsr_gen_1_2[lanenum][12] ^ scrambler.lfsr_gen_1_2[lanenum][13] ^ scrambler.lfsr_gen_1_2[lanenum][15];
new_lfsr[12] = scrambler.lfsr_gen_1_2[lanenum][2] ^ scrambler.lfsr_gen_1_2[lanenum][4] ^ scrambler.lfsr_gen_1_2[lanenum][6] ^ scrambler.lfsr_gen_1_2[lanenum][12] ^ scrambler.lfsr_gen_1_2[lanenum][13] ^ scrambler.lfsr_gen_1_2[lanenum][14];
new_lfsr[13] = scrambler.lfsr_gen_1_2[lanenum][3] ^ scrambler.lfsr_gen_1_2[lanenum][5] ^ scrambler.lfsr_gen_1_2[lanenum][7] ^ scrambler.lfsr_gen_1_2[lanenum][13] ^ scrambler.lfsr_gen_1_2[lanenum][14] ^ scrambler.lfsr_gen_1_2[lanenum][15];
new_lfsr[14] = scrambler.lfsr_gen_1_2[lanenum][4] ^ scrambler.lfsr_gen_1_2[lanenum][6] ^ scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][14] ^ scrambler.lfsr_gen_1_2[lanenum][15];
new_lfsr[15] = scrambler.lfsr_gen_1_2[lanenum][5] ^ scrambler.lfsr_gen_1_2[lanenum][7] ^ scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][15];

data_out[0]  = scrambler.lfsr_gen_1_2[lanenum][15];
data_out[1]  = scrambler.lfsr_gen_1_2[lanenum][14];
data_out[2]  = scrambler.lfsr_gen_1_2[lanenum][13];
data_out[3]  = scrambler.lfsr_gen_1_2[lanenum][12];
data_out[4]  = scrambler.lfsr_gen_1_2[lanenum][11];
data_out[5]  = scrambler.lfsr_gen_1_2[lanenum][10];
data_out[6]  = scrambler.lfsr_gen_1_2[lanenum][9];
data_out[7]  = scrambler.lfsr_gen_1_2[lanenum][8];
data_out[8]  = scrambler.lfsr_gen_1_2[lanenum][7];
data_out[9]  = scrambler.lfsr_gen_1_2[lanenum][6];
data_out[10] = scrambler.lfsr_gen_1_2[lanenum][5];
data_out[11] = scrambler.lfsr_gen_1_2[lanenum][4] ^ scrambler.lfsr_gen_1_2[lanenum][15];
data_out[12] = scrambler.lfsr_gen_1_2[lanenum][3] ^ scrambler.lfsr_gen_1_2[lanenum][14] ^ scrambler.lfsr_gen_1_2[lanenum][15];
data_out[13] = scrambler.lfsr_gen_1_2[lanenum][2] ^ scrambler.lfsr_gen_1_2[lanenum][13] ^ scrambler.lfsr_gen_1_2[lanenum][14] ^ scrambler.lfsr_gen_1_2[lanenum][15];
data_out[14] = scrambler.lfsr_gen_1_2[lanenum][1] ^ scrambler.lfsr_gen_1_2[lanenum][12] ^ scrambler.lfsr_gen_1_2[lanenum][13] ^ scrambler.lfsr_gen_1_2[lanenum][14];
data_out[15] = scrambler.lfsr_gen_1_2[lanenum][0] ^ scrambler.lfsr_gen_1_2[lanenum][11] ^ scrambler.lfsr_gen_1_2[lanenum][12] ^ scrambler.lfsr_gen_1_2[lanenum][13];
data_out[16] = scrambler.lfsr_gen_1_2[lanenum][10] ^ scrambler.lfsr_gen_1_2[lanenum][11] ^ scrambler.lfsr_gen_1_2[lanenum][12] ^ scrambler.lfsr_gen_1_2[lanenum][15];
data_out[17] = scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][10] ^ scrambler.lfsr_gen_1_2[lanenum][11] ^ scrambler.lfsr_gen_1_2[lanenum][14];
data_out[18] = scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][10] ^ scrambler.lfsr_gen_1_2[lanenum][13];
data_out[19] = scrambler.lfsr_gen_1_2[lanenum][7] ^ scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][12];
data_out[20] = scrambler.lfsr_gen_1_2[lanenum][6] ^ scrambler.lfsr_gen_1_2[lanenum][7] ^ scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][11];
data_out[21] = scrambler.lfsr_gen_1_2[lanenum][5] ^ scrambler.lfsr_gen_1_2[lanenum][6] ^ scrambler.lfsr_gen_1_2[lanenum][7] ^ scrambler.lfsr_gen_1_2[lanenum][10];
data_out[22] = scrambler.lfsr_gen_1_2[lanenum][4] ^ scrambler.lfsr_gen_1_2[lanenum][5] ^ scrambler.lfsr_gen_1_2[lanenum][6] ^ scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][15];
data_out[23] = scrambler.lfsr_gen_1_2[lanenum][3] ^ scrambler.lfsr_gen_1_2[lanenum][4] ^ scrambler.lfsr_gen_1_2[lanenum][5] ^ scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][14];
data_out[24] = scrambler.lfsr_gen_1_2[lanenum][2] ^ scrambler.lfsr_gen_1_2[lanenum][3] ^ scrambler.lfsr_gen_1_2[lanenum][4] ^ scrambler.lfsr_gen_1_2[lanenum][7] ^ scrambler.lfsr_gen_1_2[lanenum][13] ^ scrambler.lfsr_gen_1_2[lanenum][15];
data_out[25] = scrambler.lfsr_gen_1_2[lanenum][1] ^ scrambler.lfsr_gen_1_2[lanenum][2] ^ scrambler.lfsr_gen_1_2[lanenum][3] ^ scrambler.lfsr_gen_1_2[lanenum][6] ^ scrambler.lfsr_gen_1_2[lanenum][12] ^ scrambler.lfsr_gen_1_2[lanenum][14];
data_out[26] = scrambler.lfsr_gen_1_2[lanenum][0] ^ scrambler.lfsr_gen_1_2[lanenum][1] ^ scrambler.lfsr_gen_1_2[lanenum][2] ^ scrambler.lfsr_gen_1_2[lanenum][5] ^ scrambler.lfsr_gen_1_2[lanenum][11] ^ scrambler.lfsr_gen_1_2[lanenum][13] ^ scrambler.lfsr_gen_1_2[lanenum][15];
data_out[27] = scrambler.lfsr_gen_1_2[lanenum][0] ^ scrambler.lfsr_gen_1_2[lanenum][1] ^ scrambler.lfsr_gen_1_2[lanenum][4] ^ scrambler.lfsr_gen_1_2[lanenum][10] ^ scrambler.lfsr_gen_1_2[lanenum][12] ^ scrambler.lfsr_gen_1_2[lanenum][14];
data_out[28] = scrambler.lfsr_gen_1_2[lanenum][0] ^ scrambler.lfsr_gen_1_2[lanenum][3] ^ scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][11] ^ scrambler.lfsr_gen_1_2[lanenum][13];
data_out[29] = scrambler.lfsr_gen_1_2[lanenum][2] ^ scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][10] ^ scrambler.lfsr_gen_1_2[lanenum][12];
data_out[30] = scrambler.lfsr_gen_1_2[lanenum][1] ^ scrambler.lfsr_gen_1_2[lanenum][7] ^ scrambler.lfsr_gen_1_2[lanenum][9] ^ scrambler.lfsr_gen_1_2[lanenum][11];
data_out[31] = scrambler.lfsr_gen_1_2[lanenum][0] ^ scrambler.lfsr_gen_1_2[lanenum][6] ^ scrambler.lfsr_gen_1_2[lanenum][8] ^ scrambler.lfsr_gen_1_2[lanenum][10];
  
   data_out = data_out^data_in;
   scrambler.lfsr_gen_1_2[lanenum] = new_lfsr;  

  
  return data_out;
  
endfunction


function automatic bit [31:0] scramble_gen_3(ref Descrambler_Scrambler scrambler,
                                            input bit [31:0] plain_data,
                                            int lanenum);
  bit [31:0] data_out;
  data_out = scramble_byte_gen_3(scrambler.lfsr_gen_3[lanenum], plain_data);
  scrambler.lfsr_gen_3[lanenum] = advance_lfsr_gen_3(scrambler.lfsr_gen_3[lanenum]);
  return data_out;
endfunction


// Function to advance the 23-bit LFSR value by 8 bits, given the current value.
function int advance_lfsr_gen_3(int current_lfsr);
  automatic int next_state = 0;
  set_bit(next_state, 22, get_bit(current_lfsr, 14) ^ get_bit(current_lfsr, 16) ^ get_bit(current_lfsr, 18) ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 21) ^ get_bit(current_lfsr, 22));
  set_bit(next_state, 21, get_bit(current_lfsr, 13) ^ get_bit(current_lfsr, 15) ^ get_bit(current_lfsr, 17) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 21));
  set_bit(next_state, 20, get_bit(current_lfsr, 12) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 21));
  set_bit(next_state, 19, get_bit(current_lfsr, 11) ^ get_bit(current_lfsr, 18) ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 22));
  set_bit(next_state, 18, get_bit(current_lfsr, 10) ^ get_bit(current_lfsr, 17) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 21));
  set_bit(next_state, 17, get_bit(current_lfsr, 9)  ^ get_bit(current_lfsr, 16) ^ get_bit(current_lfsr, 18) ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 22));
  set_bit(next_state, 16, get_bit(current_lfsr, 8)  ^ get_bit(current_lfsr, 15) ^ get_bit(current_lfsr, 17) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 21) ^ get_bit(current_lfsr, 22));
  set_bit(next_state, 15, get_bit(current_lfsr, 7)  ^ get_bit(current_lfsr, 22));
  set_bit(next_state, 14, get_bit(current_lfsr, 6)  ^ get_bit(current_lfsr, 21));
  set_bit(next_state, 13, get_bit(current_lfsr, 5)  ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 22));
  set_bit(next_state, 12, get_bit(current_lfsr, 4)  ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 21) ^ get_bit(current_lfsr, 22));
  set_bit(next_state, 11, get_bit(current_lfsr, 3)  ^ get_bit(current_lfsr, 18) ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 21) ^ get_bit(current_lfsr, 22));
  set_bit(next_state, 10, get_bit(current_lfsr, 2)  ^ get_bit(current_lfsr, 17) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 21) ^ get_bit(current_lfsr, 22));
  set_bit(next_state, 9,  get_bit(current_lfsr, 1)  ^ get_bit(current_lfsr, 16) ^ get_bit(current_lfsr, 18) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 21));
  set_bit(next_state, 8,  get_bit(current_lfsr, 0)  ^ get_bit(current_lfsr, 15) ^ get_bit(current_lfsr, 17) ^ get_bit(current_lfsr, 18) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 20));
  set_bit(next_state, 7,  get_bit(current_lfsr, 17) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 21));
  set_bit(next_state, 6,  get_bit(current_lfsr, 16) ^ get_bit(current_lfsr, 18) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 22));
  set_bit(next_state, 5,  get_bit(current_lfsr, 15) ^ get_bit(current_lfsr, 17) ^ get_bit(current_lfsr, 18) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 21) ^ get_bit(current_lfsr, 22));
  set_bit(next_state, 4,  get_bit(current_lfsr, 17));
  set_bit(next_state, 3,  get_bit(current_lfsr, 16));
  set_bit(next_state, 2,  get_bit(current_lfsr, 15) ^ get_bit(current_lfsr, 22));
  set_bit(next_state, 1,  get_bit(current_lfsr, 16) ^ get_bit(current_lfsr, 18) ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 22));
  set_bit(next_state, 0,  get_bit(current_lfsr, 15) ^ get_bit(current_lfsr, 17) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 21) ^ get_bit(current_lfsr, 22));
  return next_state;
endfunction


// Function to scramble a byte using the 23-bit LFSR value.
function automatic bit [31:0] scramble_byte_gen_3(int current_lfsr, bit [31:0] data_in);
  automatic int data_out = 0;
  set_bit(data_out, 7, get_bit(data_in, 7) ^ get_bit(current_lfsr, 15) ^ get_bit(current_lfsr, 17) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 21) ^ get_bit(current_lfsr, 22));
  set_bit(data_out, 6, get_bit(data_in, 6) ^ get_bit(current_lfsr, 16) ^ get_bit(current_lfsr, 18) ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 22));
  set_bit(data_out, 5, get_bit(data_in, 5) ^ get_bit(current_lfsr, 17) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 21));
  set_bit(data_out, 4, get_bit(data_in, 4) ^ get_bit(current_lfsr, 18) ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 22));
  set_bit(data_out, 3, get_bit(data_in, 3) ^ get_bit(current_lfsr, 19) ^ get_bit(current_lfsr, 21));
  set_bit(data_out, 2, get_bit(data_in, 2) ^ get_bit(current_lfsr, 20) ^ get_bit(current_lfsr, 22));
  set_bit(data_out, 1, get_bit(data_in, 1) ^ get_bit(current_lfsr, 21));
  set_bit(data_out, 0, get_bit(data_in, 0) ^ get_bit(current_lfsr, 22));
  return data_out;
endfunction
