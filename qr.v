//======================================================================
// qr.v
//======================================================================

module qr(
    input  wire [31:0] a,    // QR input: word a
    input  wire [31:0] b,    // QR input: word b
    input  wire [31:0] c,    // QR input: word c
    input  wire [31:0] d,    // QR input: word d

    output wire [31:0] a_out, // QR output: updated word a
    output wire [31:0] b_out, // QR output: updated word b
    output wire [31:0] c_out, // QR output: updated word c
    output wire [31:0] d_out  // QR output: updated word d
);

  // Intermediate signals for each transformation stage
  reg [31:0] a_add1, a_add2;
  reg [31:0] b_xor1, b_rot12, b_xor2, b_rot7;
  reg [31:0] c_add1, c_add2;
  reg [31:0] d_xor1, d_rot16, d_xor2, d_rot8;

  
  // QR Combinational logic 
  always @(*)
    begin : qr_logic
    // Step 1: a = a + b
    a_add1 = a + b;

    // Step 2: d = d ^ a
    d_xor1 = d ^ a_add1;

    // Step 3: d = (d <<< 16)
    d_rot16 = {d_xor1[15:0], d_xor1[31:16]};

    // Step 4: c = c + d
    c_add1 = c + d_rot16;

    // Step 5: b = b ^ c
    b_xor1 = b ^ c_add1;

    // Step 6: b = (b <<< 12)
    b_rot12 = {b_xor1[19:0], b_xor1[31:20]};

    // Step 7: a = a + b
    a_add2 = a_add1 + b_rot12;

    // Step 8: d = d ^ a
    d_xor2 = d_rot16 ^ a_add2;

    // Step 9: d = (d <<< 8)
    d_rot8 = {d_xor2[23:0], d_xor2[31:24]};

    // Step 10: c = c + d
    c_add2 = c_add1 + d_rot8;

    // Step 11: b = b ^ c
    b_xor2 = b_rot12 ^ c_add2;

    // Step 12: b = (b <<< 7)
    b_rot7 = {b_xor2[24:0], b_xor2[31:25]};
  end

  
  // Assign final results to outputs
  assign a_out = a_add2;
  assign b_out = b_rot7;
  assign c_out = c_add2;
  assign d_out = d_rot8;

endmodule