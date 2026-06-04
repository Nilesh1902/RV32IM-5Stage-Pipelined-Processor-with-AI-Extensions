`timescale 1ns/1ps

module muldiv_unit (
  input  logic        clk,
  input  logic        rst_n,

  input  logic        req_valid,
  input  logic [5:0]  req_op,     // alu_op_t encoded (from mycoreai32_pkg)
  input  logic [31:0] req_a,
  input  logic [31:0] req_b,

  output logic        resp_ready,
  output logic        resp_done,
  output logic [31:0] resp_result
);

  import mycoreai32_pkg::*;

  typedef enum logic [1:0] { IDLE, RUN, DONE } state_t;
  state_t state;

  // latched request
  logic [31:0] a_reg, b_reg;
  logic [5:0]  op_reg;

  // op classification
  logic is_mul, is_mulh, is_mulhsu, is_mulhu;
  logic is_div, is_divu, is_rem, is_remu;

  // handshake
  assign resp_ready  = (state == IDLE);
  assign resp_done   = (state == DONE);

  // common counter
  logic [5:0] cnt;

  // =========================
  // MUL ITERATIVE ENGINE
  // =========================
  logic [63:0] mul_acc;
  logic [63:0] mul_mcand;
  logic [31:0] mul_mplier;
  logic        mul_neg;       // final sign for signed*signed
  logic [63:0] mul_prod_final;

  // =========================
  // DIV/REM RESTORING ENGINE
  // =========================
  logic [63:0] div_rem;       // {remainder[31:0], extra/working bits}
  logic [31:0] div_quot;
  logic [31:0] div_divisor;

  logic        div_signed;
  logic        div_out_neg;   // quotient sign (signed div)
  logic        rem_out_neg;   // remainder sign (signed rem)
  logic [31:0] a_abs, b_abs;

  // outputs
  logic [31:0] result_reg;
  assign resp_result = result_reg;

  // decode ops (match your pkg names)
  always_comb begin
    is_mul    = (req_op == ALU_MUL);
    is_mulh   = (req_op == ALU_MULH);
    is_mulhsu = (req_op == ALU_MULHSU);
    is_mulhu  = (req_op == ALU_MULHU);

    is_div    = (req_op == ALU_DIV);
    is_divu   = (req_op == ALU_DIVU);
    is_rem    = (req_op == ALU_REM);
    is_remu   = (req_op == ALU_REMU);
  end

  // helper: abs for signed 32-bit
  function automatic logic [31:0] abs32(input logic [31:0] x);
    abs32 = x[31] ? (~x + 32'd1) : x;
  endfunction

  // helper: apply sign to 64-bit
  function automatic logic [63:0] neg64_if(input logic do_neg, input logic [63:0] x);
    neg64_if = do_neg ? (~x + 64'd1) : x;
  endfunction

  // helper: apply sign to 32-bit
  function automatic logic [31:0] neg32_if(input logic do_neg, input logic [31:0] x);
    neg32_if = do_neg ? (~x + 32'd1) : x;
  endfunction

  // ============================================================
  // SEQUENTIAL CONTROL
  // ============================================================
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state      <= IDLE;
      a_reg      <= 32'd0;
      b_reg      <= 32'd0;
      op_reg     <= 6'd0;
      cnt        <= 6'd0;
      result_reg <= 32'd0;

      // mul regs
      mul_acc    <= 64'd0;
      mul_mcand  <= 64'd0;
      mul_mplier <= 32'd0;
      mul_neg    <= 1'b0;

      // div regs
      div_rem    <= 64'd0;
      div_quot   <= 32'd0;
      div_divisor<= 32'd0;

      div_signed <= 1'b0;
      div_out_neg<= 1'b0;
      rem_out_neg<= 1'b0;
      a_abs      <= 32'd0;
      b_abs      <= 32'd0;

    end else begin
      case (state)

        // -----------------
        // IDLE: latch request
        // -----------------
        IDLE: begin
          if (req_valid) begin
            a_reg  <= req_a;
            b_reg  <= req_b;
            op_reg <= req_op;

            // classify based on req_op (use req_op directly here)
            if (req_op == ALU_MUL || req_op == ALU_MULH || req_op == ALU_MULHSU || req_op == ALU_MULHU) begin
              // ---- MUL init (32 cycles) ----
              cnt <= 6'd32;
              mul_acc <= 64'd0;

              if (req_op == ALU_MULHU) begin
                // unsigned * unsigned
                mul_mcand  <= {32'd0, req_a};
                mul_mplier <= req_b;
                mul_neg    <= 1'b0;
              end
              else if (req_op == ALU_MULHSU) begin
                // signed * unsigned
                mul_mcand  <= {32'd0, abs32(req_a)};
                mul_mplier <= req_b;
                mul_neg    <= req_a[31];
              end
              else begin
                // signed * signed (MUL/MULH)
                mul_mcand  <= {32'd0, abs32(req_a)};
                mul_mplier <= abs32(req_b);
                mul_neg    <= (req_a[31] ^ req_b[31]);
              end

              state <= RUN;

            end else begin
              // ---- DIV/REM init (32 cycles) ----
              // Handle divide-by-zero + overflow immediately (RISC-V rules)
              if ((req_op == ALU_DIV || req_op == ALU_DIVU) && (req_b == 0)) begin
                result_reg <= 32'hFFFF_FFFF;
                state <= DONE;
              end
              else if ((req_op == ALU_REM || req_op == ALU_REMU) && (req_b == 0)) begin
                result_reg <= req_a;
                state <= DONE;
              end
              else if ((req_op == ALU_DIV || req_op == ALU_REM) &&
                       (req_a == 32'h8000_0000) && (req_b == 32'hFFFF_FFFF)) begin
                // overflow case: DIV => 0x80000000, REM => 0
                result_reg <= (req_op == ALU_DIV) ? 32'h8000_0000 : 32'h0000_0000;
                state <= DONE;
              end
              else begin
                cnt <= 6'd32;

                div_signed  <= (req_op == ALU_DIV || req_op == ALU_REM);
                a_abs       <= (req_op == ALU_DIV || req_op == ALU_REM) ? abs32(req_a) : req_a;
                b_abs       <= (req_op == ALU_DIV || req_op == ALU_REM) ? abs32(req_b) : req_b;

                div_out_neg <= (req_op == ALU_DIV) ? (req_a[31] ^ req_b[31]) : 1'b0;
                rem_out_neg <= (req_op == ALU_REM) ? (req_a[31]) : 1'b0;

                div_divisor <= (req_op == ALU_DIV || req_op == ALU_REM) ? abs32(req_b) : req_b;

                div_quot <= 32'd0;
                div_rem  <= 64'd0;  // remainder starts 0

                state <= RUN;
              end
            end
          end
        end

        // -----------------
        // RUN: either mul-step or div-step based on latched op_reg
        // -----------------
        RUN: begin
          // MUL path
          if (op_reg == ALU_MUL || op_reg == ALU_MULH || op_reg == ALU_MULHSU || op_reg == ALU_MULHU) begin
            if (cnt != 0) begin
              // classic shift-add: if LSB=1 add multiplicand
              if (mul_mplier[0]) mul_acc <= mul_acc + mul_mcand;
              mul_mcand  <= (mul_mcand << 1);
              mul_mplier <= (mul_mplier >> 1);
              cnt        <= cnt - 1'b1;
            end else begin
              // finalize sign
              mul_prod_final = neg64_if(mul_neg, mul_acc);

              // select output word
              unique case (op_reg)
                ALU_MUL:    result_reg <= mul_prod_final[31:0];
                ALU_MULH:   result_reg <= mul_prod_final[63:32];
                ALU_MULHSU: result_reg <= mul_prod_final[63:32];
                ALU_MULHU:  result_reg <= mul_prod_final[63:32];
                default:    result_reg <= 32'd0;
              endcase

              state <= DONE;
            end
          end
          // DIV/REM path
          else begin
            if (cnt != 0) begin
              // restoring division (unsigned core)
              // shift remainder left, bring next dividend bit in
              div_rem <= (div_rem << 1) | {63'd0, a_abs[31]};     // bring MSB
              a_abs   <= (a_abs << 1);

              // trial subtract
              if ( (div_rem[63:32] >= div_divisor) ) begin
                div_rem[63:32] <= div_rem[63:32] - div_divisor;
                div_quot <= (div_quot << 1) | 32'd1;
              end else begin
                div_quot <= (div_quot << 1);
              end

              cnt <= cnt - 1'b1;
            end else begin
              // apply sign corrections if signed
              if (op_reg == ALU_DIV) begin
                result_reg <= neg32_if(div_out_neg, div_quot);
              end else if (op_reg == ALU_DIVU) begin
                result_reg <= div_quot;
              end else if (op_reg == ALU_REM) begin
                result_reg <= neg32_if(rem_out_neg, div_rem[63:32]);
              end else begin // ALU_REMU
                result_reg <= div_rem[63:32];
              end

              state <= DONE;
            end
          end
        end

        // -----------------
        // DONE: 1-cycle done pulse
        // -----------------
        DONE: begin
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule