`timescale 1ns / 1ps
// ============================================================================
//        __
//   \\__/ o\    (C) 2006-2020  Robert Finch, Waterloo
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
//
//	fpAddsub_tb.v
//		- floating point divider test bench
//
// BSD 3-Clause License
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//                                                                          
// ============================================================================

module fpAddsub_tb();
reg rst;
reg clk;
reg [15:0] adr;
reg [63:0] a,b;
wire [63:0] o;
reg [63:0] ad,bd;
reg [63:0] od;
reg [3:0] rm;

wire [63:0] doubleA = {a[31], a[30], {3{~a[30]}}, a[29:23], a[22:0], {29{1'b0}}};
wire [63:0] doubleB = {b[31], b[30], {3{~b[30]}}, b[29:23], b[22:0], {29{1'b0}}};

integer outfile;

initial begin
	rst = 1'b0;
	clk = 1'b0;
	adr = 0;
	a = $urandom(1);
	b = 1;
	#20 rst = 1;
	#50 rst = 0;
	#10000000  $fclose(outfile);
	#10 $finish;
end

always #5
	clk = ~clk;

reg [7:0] count;
always @(posedge clk)
if (rst) begin
	adr <= 0;
	count <= 0;
end
else
begin
  if (adr==0) begin
    outfile = $fopen("d:/cores2020/rtf64/v2/rtl/verilog/cpu/fpu/test_bench/fpAddsub_tvo.txt", "wb");
    $fwrite(outfile, " rm ------- A ------  ------- B ------  ------ sum -----  -- SIM Sum --\n");
  end
	count <= count + 1;
	if (count > 32)
		count <= 1'd1;
	if (count==2) begin	
		a[31:0] <= $urandom();
		b[31:0] <= $urandom();
		a[63:32] <= $urandom();
		b[63:32] <= $urandom();
		rm <= adr[14:12];
		//ad <= memd[adr][63: 0];
		//bd <= memd[adr][127:64];
	end
	if (count==31) begin
		if (adr[11]) begin
		  od = $realtobits($bitstoreal(a) - $bitstoreal(b));
	  	$fwrite(outfile, "%c%h\t%h\t%h\t%h\t%h%c\n", "-",rm, a, b, o, od,od!=o ? "*":" ");
	  end
	  else begin
		  od = $realtobits($bitstoreal(a) + $bitstoreal(b));
	  	$fwrite(outfile, "%c%h\t%h\t%h\t%h\t%h%c\n", "+",rm, a, b, o, od,od!=o ? "*":" ");
	  end
		adr <= adr + 1;
	end
end

//fpMulnr #(64) u1 (clk, 1'b1, a, b, o, rm);//, sign_exe, inf, overflow, underflow);
fpAddsubnr u6 (
  .clk(clk),
  .ce(1'b1),
  .op(adr[11]),
  .a(a),
  .b(b),
  .o(o),
  .rm(rm)
  );

endmodule
