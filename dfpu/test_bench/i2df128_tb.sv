// ============================================================================
//        __
//   \\__/ o\    (C) 2022  Robert Finch, Waterloo
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
//
//	iTodf128_tb.sv
//  - test convert integer to decimal floating point
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

module i2df128_tb();

reg rst;
reg clk;
reg [15:0] adr;
wire [127:0] flt;
reg [7:0] count;

reg [127:0] bin;

integer outfile;

initial begin
	rst = 1'b0;
	clk = 1'b0;
	adr = 0;
	bin = $urandom(1);
	#20 rst = 1;
	#50 rst = 0;
	#10000000  $fclose(outfile);
	#10 $finish;
end

always #5
	clk = ~clk;

genvar g;
generate begin : gRand
	for (g = 0; g < 128; g = g + 4) begin
		always @(posedge clk) begin
			if (count==2)
				bin[g+3:g] <= $urandom() % 16;
		end
	end
end
endgenerate

always @(posedge clk)
if (rst) begin
	adr <= 0;
	count <= 0;
end
else
begin
  if (adr==0) begin
    outfile = $fopen("f:/cores2022/float/dfpu/test_bench/i2df128_tvo.txt", "wb");
    $fwrite(outfile, "s ------ bin ------  ------ flt ------  \n");
  end
	count <= count + 1;
	if (count > 140)
		count <= 1'd1;
	if (adr==1) begin
		bin <= 128'h01;
	end
	if (adr==2) begin
		bin <= 128'h0A;
	end
	if (adr==3) begin
		bin <= 128'd100;
	end
	if (adr==4) begin
		bin <= 128'd1000;
	end
	if (adr==5) begin
		bin <= 128'd1000000;
	end
	if (adr==6) begin
		bin <= 128'd12345678;
	end
	if (count==140) begin
  	$fwrite(outfile, "%c %h\t%h\n", adr[11] ? "s" : "u", bin, flt);
		adr <= adr + 1;
	end
end

i2df128 u6 (
	.rst(rst),
  .clk(clk),
  .ce(1'b1),
  .op(adr[11]),
  .rm(3'd0),
  .ld(count==3),
  .i(bin),
  .o(flt),
  .done()
);

endmodule
