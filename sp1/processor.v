module processor(state, out, clk, instr, pc);
  input reg [10:0] instr;//9 total instructions
  reg [7:0] a = 8'h00;
  reg [7:0] b = 8'h01;
  output reg [7:0] pc = 8'h00;
  input clk;
  reg sel; //1 for add, 0 for sub (ALU)
  output reg [7:0] out; //for debug only (?)
  output reg [2:0] state; //0: carry, 1: zero, 2: memreq(SR)

  always @ (posedge clk) begin
    pc++;
    case (instr[2:0])
      3'h1: begin //ADD
        assign out = a+b;
        a = out;
        state[0] <= (a+b > 255) ? 1 : 0;
        state[1] <= (out == 0 && 255 > a+b) ? 1 : 0;
      end
      3'h2: begin //SUB
        assign out = a-b;
        a = out;
        state[0] <= (a+b > 255) ? 1 : 0;
        state[1] <= (out == 0 && 255 > a+b) ? 1 : 0;
      end
     // 3'h03: begin //LDL!!!
     //   a <= instr[10:3];
     // end
      3'h4: begin //JC
        if (state[0] == 1) begin
          pc <= instr[10:3];
        end
      end
      3'h5: begin //JZ
        if (state[1] == 1) begin
          pc <= instr[10:3];
        end
      end
      3'h6: begin //JMP
        pc <= instr[10:3];
      end
      3'h7: begin //LD
        a <= instr[10:3];
      end
      3'h8: begin //ST
        assign out = a;
        state[2] <= 1'b1;
      end
      default: begin //HLT
       // assign out = 8'h3D; //magic end value
       end

     endcase
  end
endmodule
