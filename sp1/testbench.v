module test();
  reg [10:0] mem[1023:0];
  wire [2:0] state;
  wire [7:0] out;
  wire [7:0] pc;
  reg clk = 1'b0;

  processor Processor(.state(state), .out(out), .clk(clk), .instr(mem[pc]), .pc(pc));

  //parameter clkspeed = 10;

  initial begin
    $display("Running!");
    mem[pc][10:3] <= 8'h5; //vv
    clk = ~clk;
    #2
    mem[pc][2:0] <= 3'h1; //add A+B
    clk = ~clk;
    #2
    mem[pc][2:0] <= 3'h8; //store it in current PC location
    clk = ~clk;
    #2
    mem[pc][2:0] <= 3'h4; //vv
    mem[pc][10:3] <= 8'h66; //load $66 into current address
    clk = ~clk;
    #2
    $display("PC: %0h, Addr at PC: %0h", pc, mem[pc][10:3]);
  end

  always @ (posedge state[2]) begin
    mem[pc][10:3] <= out;
  end
endmodule
