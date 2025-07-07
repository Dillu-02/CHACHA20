//======================================================================
// top.v 
// Top-level wrapper for the ChaCha stream cipher core with clean and
// descriptive signal naming for clarity and maintainability.
//======================================================================

module top (
  input wire         clk,
  input wire         reset_n,
  input wire         cs,
  input wire         we,
  input wire [7:0]   addr,
  input wire [31:0]  write_data,
  output wire [31:0] read_data
);

  // Local Parameters for Addresses and Constants
  localparam ADDR_CORE_ID0        = 8'h00;
  localparam ADDR_CORE_ID1        = 8'h01;
  localparam ADDR_CORE_VERSION    = 8'h02;

  localparam ADDR_CONTROL_FLAGS   = 8'h08;
  localparam BIT_INIT_FLAG        = 0;
  localparam BIT_NEXT_FLAG        = 1;

  localparam ADDR_CORE_STATUS     = 8'h09;
  localparam BIT_READY_FLAG       = 0;

  localparam ADDR_KEY_LENGTH      = 8'h0a;
  localparam ADDR_ROUND_COUNT     = 8'h0b;
  localparam ROUNDS_HIGH_BIT      = 4;
  localparam ROUNDS_LOW_BIT       = 0;

  localparam ADDR_KEY_WORD0       = 8'h10;
  localparam ADDR_KEY_WORD7       = 8'h17;

  localparam ADDR_NONCE_WORD0     = 8'h20;
  localparam ADDR_NONCE_WORD1     = 8'h21;
  localparam ADDR_NONCE_WORD2     = 8'h22;

  localparam ADDR_INPUT_BLOCK0    = 8'h40;
  localparam ADDR_INPUT_BLOCK15   = 8'h4f;

  localparam ADDR_OUTPUT_BLOCK0   = 8'h80;
  localparam ADDR_OUTPUT_BLOCK15  = 8'h8f;

  localparam CORE_ID0             = 32'h63686163; // "chac"
  localparam CORE_ID1             = 32'h68612020; // "ha  "
  localparam CORE_VERSION         = 32'h302e3830; // "0.80"

  localparam DEFAULT_COUNTER_INIT = 64'h0;


  // Internal Registers
  reg          ctrl_init_flag;
  reg          ctrl_next_flag;
  reg          ctrl_init_next_val;
  reg          ctrl_next_next_val;

  reg          key_length_flag;
  reg          key_length_we;

  reg [4:0]    round_count_reg;
  reg          round_count_we;

  reg [31:0]   key_words [0:7];
  reg          key_words_we;

  reg [31:0]   nonce_words [0:2];
  reg          nonce_words_we;

  reg [31:0]   plaintext_words [0:15];
  reg          plaintext_we;
  
  
  // Wires and Internal Signals
  wire [255:0] core_key;
  wire [95:0]  core_nonce;
  wire         core_ready;
  wire [511:0] core_data_in;
  wire [511:0] core_data_out;
  wire         core_data_out_valid;

  reg  [31:0]  read_data_buffer;


  // Assignments
  assign core_key     = {key_words[0], key_words[1], key_words[2], key_words[3],
                         key_words[4], key_words[5], key_words[6], key_words[7]};

  assign core_nonce   = {nonce_words[0], nonce_words[1], nonce_words[2]};

  assign core_data_in = {plaintext_words[0], plaintext_words[1], plaintext_words[2], plaintext_words[3],
                         plaintext_words[4], plaintext_words[5], plaintext_words[6], plaintext_words[7],
                         plaintext_words[8], plaintext_words[9], plaintext_words[10], plaintext_words[11],
                         plaintext_words[12], plaintext_words[13], plaintext_words[14], plaintext_words[15]};

  assign read_data = read_data_buffer;


  // Core Instantiation
  core c1 (
    .clk(clk),
    .reset_n(reset_n),
    .init(ctrl_init_flag),
    .next(ctrl_next_flag),
    .key(core_key),
    .nonce(core_nonce),
    .ctr(DEFAULT_COUNTER_INIT),
    .rounds(round_count_reg),
    .data_in(core_data_in),
    .ready(core_ready),
    .data_out(core_data_out),
    .data_out_valid(core_data_out_valid)
  );


  // Register Update Logic
  always @(posedge clk) 
    begin: register_update_logic
      integer i;
      if (!reset_n) 
        begin
          ctrl_init_flag <= 0;
          ctrl_next_flag <= 0;
      	  key_length_flag <= 0;
      	  round_count_reg <= 5'h0;

      	  for (i = 0; i < 3; i = i + 1)
        	nonce_words[i] <= 32'h0;
          
      	  for (i = 0; i < 8; i = i + 1)
        	key_words[i] <= 32'h0;
          
      	  for (i = 0; i < 16; i = i + 1)
        	plaintext_words[i] <= 32'h0;
        end

	  else 
        begin
          ctrl_init_flag <= ctrl_init_next_val;
      	  ctrl_next_flag <= ctrl_next_next_val;

      	  if (key_length_we)
        	key_length_flag <= write_data[0];
          
      	  if (round_count_we)
        	round_count_reg <= write_data[ROUNDS_HIGH_BIT:ROUNDS_LOW_BIT];
          
      	  if (key_words_we)
        	key_words[addr[2:0]] <= write_data;
          
      	  if (nonce_words_we)
        	nonce_words[addr[1:0]] <= write_data;
          
      	  if (plaintext_we)
        	plaintext_words[addr[3:0]] <= write_data;
        end
    end


  // Address Decoder Logic
  always @(*) 
    begin
      key_length_we     = 0;
      round_count_we    = 0;
      key_words_we      = 0;
      nonce_words_we    = 0;
      plaintext_we      = 0;
      ctrl_init_next_val = 0;
      ctrl_next_next_val = 0;
      read_data_buffer   = 32'h0;
      
      if (cs) 
        begin
          if (we)
            begin
              if (addr == ADDR_CONTROL_FLAGS) 
                begin
                  ctrl_init_next_val = write_data[BIT_INIT_FLAG];
                  ctrl_next_next_val = write_data[BIT_NEXT_FLAG];
                end
              
              if (addr == ADDR_KEY_LENGTH)
                key_length_we = 1;
              
              if (addr == ADDR_ROUND_COUNT)
                round_count_we = 1;
              
              if (addr >= ADDR_KEY_WORD0 && addr <= ADDR_KEY_WORD7)
                key_words_we = 1;
              
              if (addr >= ADDR_NONCE_WORD0 && addr <= ADDR_NONCE_WORD2)
                nonce_words_we = 1;
              
              if (addr >= ADDR_INPUT_BLOCK0 && addr <= ADDR_INPUT_BLOCK15)
                plaintext_we = 1;
            end
          
          else 
            begin
              if (addr >= ADDR_KEY_WORD0 && addr <= ADDR_KEY_WORD7)
                read_data_buffer = key_words[addr[2:0]];
              
              else if (addr >= ADDR_OUTPUT_BLOCK0 && addr <= ADDR_OUTPUT_BLOCK15)
                read_data_buffer = core_data_out[(15 - (addr - ADDR_OUTPUT_BLOCK0)) * 32 +: 32];

              case (addr)
                ADDR_CORE_ID0:        read_data_buffer = CORE_ID0;
                ADDR_CORE_ID1:        read_data_buffer = CORE_ID1;
                ADDR_CORE_VERSION:    read_data_buffer = CORE_VERSION;
                ADDR_CONTROL_FLAGS:   read_data_buffer = {30'h0, ctrl_next_flag, ctrl_init_flag};
                ADDR_CORE_STATUS:     read_data_buffer = {30'h0, core_data_out_valid, core_ready};
                ADDR_KEY_LENGTH:      read_data_buffer = {31'h0, key_length_flag};
                ADDR_ROUND_COUNT:     read_data_buffer = {27'h0, round_count_reg};
                ADDR_NONCE_WORD0:     read_data_buffer = nonce_words[0];
                ADDR_NONCE_WORD1:     read_data_buffer = nonce_words[1];
                ADDR_NONCE_WORD2:     read_data_buffer = nonce_words[2];
                default:              read_data_buffer = 32'h0;
              endcase
            end
        end
    end

endmodule