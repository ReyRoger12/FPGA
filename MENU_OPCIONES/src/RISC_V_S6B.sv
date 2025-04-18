module top(input logic clk, reset,
output logic [13:0]leds,
input logic [3:0]A,B,M);
logic [31:0] WriteData, DataAdr;
logic MemWrite;
logic [31:0] PC, Instr, ReadData;
    // instantiate processor and memories
riscvsingle rvsingle( clk, reset, PC, Instr, MemWrite, DataAdr,  WriteData, ReadData);
imem imem(PC, Instr);
dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData,leds, A, B, M);
 
endmodule
 
 
module riscvsingle(input logic clk, reset,
output   logic   [31:0]   PC,
input     logic   [31:0]   Instr,
output  logic              MemWrite,
output  logic  [31:0]  ALUResult, WriteData,
input    logic  [31:0]  ReadData);
logic ALUSrc, RegWrite, Jump, Zero;
logic [1:0] ResultSrc, ImmSrc;
logic [2:0] ALUControl;
controller c(Instr[6:0], Instr[14:12], Instr[30], Zero,ResultSrc, MemWrite, PCSrc,ALUSrc, RegWrite, Jump,ImmSrc, ALUControl);
datapath dp(clk, reset, ResultSrc, PCSrc,ALUSrc, RegWrite,ImmSrc, ALUControl,Zero, PC, Instr,ALUResult, WriteData, ReadData);
endmodule
module datapath(input    logic             clk, reset,
                            input    logic [1:0]    ResultSrc,
input    logic              PCSrc, ALUSrc,
input    logic             RegWrite,
input    logic [1:0]    ImmSrc,
input    logic [2:0]    ALUControl,
output logic              Zero,
output logic [31:0] PC,
input    logic [31:0] Instr,
output logic [31:0] ALUResult, WriteData,
input    logic [31:0] ReadData);
    logic [31:0] PCNext, PCPlus4, PCTarget;
    logic [31:0] ImmExt;
    logic [31:0] SrcA, SrcB;
    logic [31:0] Result;
    // next PC logic
    flopr #(32) pcreg(clk, reset, PCNext, PC);
    adder           pcadd4(PC, 32'd4, PCPlus4);
    adder           pcaddbranch(PC, ImmExt, PCTarget);
    mux2 #(32)    pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
    // register file logic
     regfile         rf(clk, RegWrite, Instr[19:15], Instr[24:20],Instr[11:7], Result, SrcA, WriteData);
     extend         ext(Instr[31:7], ImmSrc, ImmExt);
    // ALU logic
    mux2 #(32)   srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
    alu              alu(SrcA, SrcB, ALUControl, ALUResult, Zero);
    mux3 #(32)   resultmux( ALUResult, ReadData, PCPlus4, ResultSrc, Result);
endmodule
module alu(input logic [31:0] A, B,input logic [2:0] F,output logic [31:0] Y, output Zero);
logic [31:0] S, Bout;
assign Bout = F[0] ? ~B : B;
assign S = A + Bout + F[0];
always_comb
case (F[2:1])
3'b00: Y <= S;
3'b01: Y <=F[0]?(A|B):(A&B);
3'b10: Y <= S[31];
3'b11: Y <= 0;
endcase
assign Zero = (Y == 32'b0);
endmodule
//regfile rf(clk, RegWrite, Instr[19:15], Instr[24:20],Instr[11:7], Result, SrcA, WriteData);
module regfile(input logic clk,
input logic we3,
input logic [4:0] a1, a2, a3,
input logic [31:0] wd3,
output logic [31:0] rd1, rd2);
logic [31:0] rf[31:0];
// three ported register file
// read two ports combinationally (A1/RD1, A2/RD2)
// write third port on rising edge of clock (A3/WD3/WE3)
// register 0 hardwired to 0
always_ff @(posedge clk)
if (we3) rf[a3] <= wd3;
assign rd1 =(a1!=0)?rf[a1]:0;
assign rd2 =(a2!=0)?rf[a2]:0;
endmodule
module mux3 #(parameter WIDTH = 8)
                     (input    logic [WIDTH-1:0] d0, d1, d2,
                        input    logic [1:0]             s,
                        output logic [WIDTH-1:0] y);
     assign y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule
module mux2 #(parameter WIDTH = 8)
                      (input    logic [WIDTH-1:0] d0, d1,
                       input    logic                     s,
                       output logic [WIDTH-1:0] y);
     assign y = s ? d1 : d0;
endmodule
module flopr #(parameter WIDTH = 8)
                        (input    logic                     clk, reset,
                         input    logic [WIDTH-1:0] d,
                         output logic [WIDTH-1:0] q);
    always_ff @(posedge clk, negedge reset)
                       if (!reset) q <= 0;
                       else           q <= d;
endmodule
module adder(input   [31:0] a, b,
                      output [31:0] y);
     assign y = a + b;
endmodule
module extend(input   logic [31:7] instr,
                        input   logic [1:0]   immsrc,
                       output logic [31:0] immext);
    always_comb
       case(immsrc)
                         // I−type
           2'b00:     immext = {{20{instr[31]}}, instr[31:20]};
                         // S−type (stores)
            2'b01:     immext = {{20{instr[31]}}, instr[31:25],  
instr[11:7]};
                         // B−type (branches)
           2'b10:      immext = {{20{instr[31]}}, instr[7],  
instr[30:25], instr[11:8], 1'b0};                                        
                         // J−type (jal)
           2'b11:      immext = {{12{instr[31]}}, instr[19:12],  
instr[20], instr[30:21], 1'b0};
           default: immext = 32'bx; // undefined
        endcase
endmodule
module controller(input    logic [6:0] op,
                      input    logic [2:0] funct3,
                      input    logic           funct7b5,
                      input    logic           Zero,
                      output logic [1:0] ResultSrc,
                      output logic           MemWrite,
                      output logic           PCSrc, ALUSrc,
                      output logic           RegWrite, Jump,
                      output logic [1:0] ImmSrc,
                      output logic [2:0] ALUControl);
logic [1:0] ALUOp;
logic Branch;
maindec md(op, ResultSrc, MemWrite, Branch,ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
aludec   ad(op[5], funct3, funct7b5, ALUOp, ALUControl);
assign PCSrc = Branch & Zero | Jump;
endmodule
module aludec(input    logic           opb5,
                        input    logic [2:0] funct3,
                        input    logic           funct7b5,
                        input    logic [1:0] ALUOp,
                        output logic [2:0] ALUControl);
    logic   RtypeSub;
    assign RtypeSub = funct7b5 & opb5;  // TRUE for R–type subtract
    always_comb
       case(ALUOp)
           2'b00:                        ALUControl = 3'b000; // addition
           2'b01:                        ALUControl = 3'b001; // subtraction
           default: case(funct3) // R–type or I–type ALU
                            3'b000:    if (RtypeSub)
                                                 ALUControl = 3'b001; // sub
                                            else
                                                ALUControl = 3'b000; // add, addi
                            3'b010:       ALUControl = 3'b101; // slt, slti
                            3'b110:       ALUControl = 3'b011; // or, ori
                            3'b111:       ALUControl = 3'b010; // and, andi
                            default:      ALUControl = 3'bxxx; // ???
                      endcase
         endcase
endmodule
module maindec(input    logic [6:0] op,
                           output logic [1:0] ResultSrc,
                           output logic           MemWrite,
                           output logic           Branch, ALUSrc,
                           output logic           RegWrite, Jump,
                           output logic [1:0] ImmSrc,
                           output logic [1:0] ALUOp);
    logic [10:0] controls;
    assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
                  ResultSrc, Branch, ALUOp, Jump} = controls;
    always_comb
       case(op)
       // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
            7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
          7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
          7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R–type
          7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
          7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I–type ALU
          7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
           default:      controls = 11'bx_xx_x_x_xx_x_xx_x; // ???
        endcase
endmodule
module dmem(input logic clk, we,
input    logic [31:0] a, wd,
output logic [31:0] rd,
output logic [13:0]leds,
input logic [3:0]A, B, M);
assign leds=RAM[32'd25][13:0];
logic [31:0] RAM[63:0];
assign rd = RAM[a[31:2]]; // word aligned
always_ff @(posedge clk)
if (we) RAM[a[31:2]] <= wd;
else begin
    RAM[32'd24][3:0]<=A; //96
    RAM[32'd23][3:0]<=B; //92
    RAM[32'd22][3:0]<=M; //88
end
endmodule
  
module imem(input    logic [31:0] a,
                    output logic [31:0] rd);
    logic [31:0] RAM[255:0];
    initial
       $readmemh("riscvtest.txt",RAM);
    assign rd = RAM[a[31:2]]; // word aligned
endmodule