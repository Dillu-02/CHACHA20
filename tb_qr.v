//======================================================================
// tb_qr.v
//======================================================================

`timescale 1ns / 1ps

module tb_qr;

  // Inputs (test vector)
  reg [31:0] a, b, c, d;

  // Outputs from DUT
  wire [31:0] a_out, b_out, c_out, d_out;

  // Instantiate the Unit Under Test (UUT)
  qr uut (
    .a(a), .b(b), .c(c), .d(d),
    .a_out(a_out), .b_out(b_out), .c_out(c_out), .d_out(d_out)
  );

  initial begin
    $display("\n==== Starting ChaCha QR Testbench ====\n");

    // Test vector from RFC 8439, Sec. 2.3.2
    // Input:  a = 0x11111111, b = 0x01020304, c = 0x9b8d6f43, d = 0x01234567
    // Expected: a_out = 0xea2a92f4, b_out = 0xcb1cf8ce, c_out = 0x4581472e, d_out = 0x5881c4bb
    a = 32'h11111111;
    b = 32'h01020304;
    c = 32'h9b8d6f43;
    d = 32'h01234567;

    // Wait 10 ns to allow combinational outputs to settle
    #10;

    // Display Inputs
    $display("Input Values:");
    $display("  a = 0x%08h", a);
    $display("  b = 0x%08h", b);
    $display("  c = 0x%08h", c);
    $display("  d = 0x%08h", d);

    // Display Outputs
    $display("\nOutput Values:");
    $display("  a_out = 0x%08h", a_out);
    $display("  b_out = 0x%08h", b_out);
    $display("  c_out = 0x%08h", c_out);
    $display("  d_out = 0x%08h", d_out);

    // Validate outputs against expected results
    if (a_out === 32'hea2a92f4 && b_out === 32'hcb1cf8ce &&
        c_out === 32'h4581472e && d_out === 32'h5881c4bb)
      $display("\n✅ Test PASSED!");
    else
      $display("\n❌ Test FAILED!");

    $finish;
  end

endmodule