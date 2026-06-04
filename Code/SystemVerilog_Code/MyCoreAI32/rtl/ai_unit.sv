module ai_unit (
  input  logic [31:0] rs1,
  input  logic [31:0] rs2,
  input  logic        do_vdot4,
  input  logic        do_vmax4,
  output logic [31:0] result
);

  // Treat rs1/rs2 as 4 lanes of unsigned 8-bit values:
  // lane0 = [7:0], lane1 = [15:8], lane2 = [23:16], lane3 = [31:24]
  logic [7:0] a0,a1,a2,a3;
  logic [7:0] b0,b1,b2,b3;

  assign a0 = rs1[7:0];
  assign a1 = rs1[15:8];
  assign a2 = rs1[23:16];
  assign a3 = rs1[31:24];

  assign b0 = rs2[7:0];
  assign b1 = rs2[15:8];
  assign b2 = rs2[23:16];
  assign b3 = rs2[31:24];

  // ---- VDOT4: sum of 4 byte-products (unsigned) ----
  logic [15:0] p0,p1,p2,p3;
  logic [31:0] dot;

  assign p0  = a0 * b0;
  assign p1  = a1 * b1;
  assign p2  = a2 * b2;
  assign p3  = a3 * b3;
  assign dot = {16'd0,p0} + {16'd0,p1} + {16'd0,p2} + {16'd0,p3};

  // ---- VMAX4: per-lane max (unsigned), packed back ----
  logic [7:0] m0,m1,m2,m3;
  assign m0 = (a0 >= b0) ? a0 : b0;
  assign m1 = (a1 >= b1) ? a1 : b1;
  assign m2 = (a2 >= b2) ? a2 : b2;
  assign m3 = (a3 >= b3) ? a3 : b3;

  logic [31:0] vmax;
  assign vmax = {m3,m2,m1,m0};

  // Output select
  always_comb begin
    result = 32'h0;
    if (do_vdot4)      result = dot;
    else if (do_vmax4) result = vmax;
    else               result = 32'h0;
  end

`ifndef SYNTHESIS
  initial $display("INFO: Using NEW ai_unit.sv (VDOT4/VMAX4 packed-byte version)");
`endif

endmodule