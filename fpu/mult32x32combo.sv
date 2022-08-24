// ============================================================================
//        __
//   \\__/ o\    (C) 2020-2022  Robert Finch, Waterloo
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
//
//	mult32x32combo.sv
//  - Karatsuba multiply
//  - combinational logic only
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

`define KARATSUBA	1

`ifdef KARATSUBA

module mult32x32combo(a, b, o);
input [31:0] a;
input [31:0] b;
output reg [63:0] o='d0;

reg [15:0] a2='d0, b2='d0;
reg [16:0] a1='d0, b1='d0;
reg [31:0] z0, z2, z0a, z2a, z0b, z2b, z0c, z2c, z0d, z2d, p3;
reg [32:0] p4;
reg [32:0] z1;  // extra bit for carry
reg sgn2, sgn3, sgn4;

always_comb
	a1 <= a[15: 0] - a[31:16];  // x0-x1
always_comb
	b1 <= b[31:16] - b[15: 0];  // y1-y0
always_comb
	a2 <= a1[16] ? -a1 : a1;
always_comb
	b2 <= b1[16] ? -b1 : b1;
always_comb
  sgn2 <= a1[16]^b1[16];
always_comb
  sgn3 <= sgn2;
always_comb
  sgn4 <= sgn3;
 
mult16x16combo u1 (
  .a(a[31:16]),
  .b(b[31:16]),
  .o(z2)          // z2 = x1 * y1
);

mult16x16combo u2 (
  .a(a[15:0]),
  .b(b[15:0]),
  .o(z0)          // z0 = x0 * y0
);

mult16x16combo u3 (
  .a(a2[15:0]),
  .b(b2[15:0]),
  .o(p3)        // p3 = abs(x0-x1) * abs(y1-y0)
);

always_comb
	p4 <= sgn3 ? -p3 : p3;

always_comb
  z2a <= z2;
always_comb
  z0a <= z0;
always_comb
  z2b <= z2a;
always_comb
  z0b <= z0a;
always_comb
  z2c <= z2b;
always_comb
  z0c <= z0b;
always_comb
	z1 <= {{32{p4[32]}},p4} + z2c + z0c;

always_comb
  z2d <= z2c;
always_comb
  z0d <= z0c;
always_comb
	o <= {z2d,z0d} + {z1,16'd0};

endmodule

`else

// This version of the multiply has a parameterized pipeline depth and allows
// the tools to perform the multiply. Relies on the ability of tools to retime.

module mult32x32combo(a, b, o);
parameter DEP = 6;
input [31:0] a;
input [31:0] b;
output reg [63:0] o;

reg [63:0] prod [0:DEP-1];
reg [63:0] prd;
integer n;

always_comb
	prd <= a * b;
always_comb
	prod[0] <= prd;
	
always_comb
	for (n = 0; n < DEP - 1; n = n + 1)
		prod[n+1] <= prod[n];

always_comb
	o <= prod[DEP-1];

endmodule

`endif