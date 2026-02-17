module booth (a,b,pp1,pp2,pp3,pp4);
input signed[7:0]a,b;
output signed  [15:0]pp1,pp2,pp3,pp4;
reg[2:0]e[3:0];
reg signed [8:0]c;
reg signed [15:0]pp[3:0];
reg signed  [15:0]sum=16'h000;
reg signed  [15:0]sum1=16'h000;
reg signed [15:0]p;
integer j,i;
always@(*)begin
c={a,1'b0};
 for(j=1;j<8;j=j+2)begin
 case({c[j+1],c[j],c[j-1]})
 3'b000,3'b111:e[(j-1)/2]=3'b000;
 3'b001,3'b010:e[(j-1)/2]=3'b001;
 3'b110,3'b101:e[(j-1)/2]=3'b101;
 3'b011:e[(j-1)/2]=3'b010;
 3'b100:e[(j-1)/2]=3'b110;
 default:e[(j-1)/2]=3'b000;
 endcase
 end
// $display("%b",e[0]);
// $display("%b",e[1]);
// $display("%b",e[2]);
// $display("%b",e[3]);
for(i=0;i<4;i=i+1)begin
 case(e[i])
 3'b000:pp[i]=16'h0000;
 3'b001:pp[i]=b;
 3'b101:pp[i]=-b;
 3'b010:pp[i]=b<<1;
 3'b110:pp[i]=-(b<<1);
 endcase
  if(e[i]==010||e[i]==110)begin
 p=pp[i];
 p={{3{p[8]}},p[8:0]};
 end
 else begin
 p={{4{p[7]}},p[7:0]};
 end
 p=pp[i];
 pp[i]=$signed(pp[i])<<(2*i);
  end
 end
 assign pp1=pp[0];
 assign pp2=pp[1];
 assign pp3=pp[2];
 assign pp4=pp[3];
endmodule

module mul(
    input signed [7:0] a, b,
    input clk, reset_mul, reset_add,
    output signed [15:0] out
);
    wire signed [15:0] w[3:0];
    reg signed [15:0] r[3:0];
    wire signed [15:0] sum_wire;

    booth b_inst(a, b, w[0], w[1], w[2], w[3]);

    
    always @(posedge clk) begin
        if (reset_mul) begin
            r[0] <= 0; r[1] <= 0; r[2] <= 0; r[3] <= 0;
        end else begin
            r[0] <= w[0]; r[1] <= w[1]; r[2] <= w[2]; r[3] <= w[3];
        end
    end

    assign sum_wire = r[0] + r[1] + r[2] + r[3];
    reg signed [15:0] out_reg;
    always @(posedge clk) begin
        if (reset_add) out_reg <= 0;
        else           out_reg <= sum_wire;
    end
    assign out = out_reg;
endmodule

module pe(
    input signed [7:0] a,b,c,d,e,f,g,h,
    input clk, reset_mul, reset_add,
    output signed [17:0] out 
);
     reg signed [15:0] r[3:0];
    wire signed [15:0] m_out[3:0];
    
    mul m1(a, b, clk, reset_mul, reset_add, m_out[0]);
    mul m2(c, d, clk, reset_mul, reset_add, m_out[1]);
    mul m3(e, f, clk, reset_mul, reset_add, m_out[2]);
    mul m4(g, h, clk, reset_mul, reset_add, m_out[3]);
   

    assign out = $signed(m_out[0]) + $signed(m_out[1]) + 
                 $signed(m_out[2]) + $signed(m_out[3]);
endmodule

module mac(
    input signed [7:0] a,b,c,d,e,f,g,h, 
                       a1,b1,c1,d1,e1,f1,g1,h1, 
                       a2,b2,c2,d2,e2,f2,g2,h2, 
                       a3,b3,c3,d3,e3,f3,g3,h3,
    input clk, reset_mul, reset_add,
    output signed [19:0] out 
);
    wire signed [17:0] q1, q2, q3, q4;
    pe p1(a,  b,  c,  d,  e,  f,  g,  h,  clk, reset_mul, reset_add, q1);
    pe p2(a1, b1, c1, d1, e1, f1, g1, h1, clk, reset_mul, reset_add, q2);
    pe p3(a2, b2, c2, d2, e2, f2, g2, h2, clk, reset_mul, reset_add, q3);
    pe p4(a3, b3, c3, d3, e3, f3, g3, h3, clk, reset_mul, reset_add, q4);    
    assign out = $signed(q1) + $signed(q2) + $signed(q3) + $signed(q4);
endmodule

