`define size 8
`define p_width (`size*2)
`define p_no (`size/2)
`define reg_wire (`p_no/2)
`define matrix_size 4
`define matrix_col 4
`define NUM_PE (`matrix_size*`matrix_col)/4
`define TOTAL (`matrix_size * `matrix_col)
module booth (a,b,pp_out,clk,reset);
  input signed[`size-1:0]a,b;
  input clk,reset;
  output reg signed  [`p_width-1:0]pp_out[`p_no-1:0];
  reg[2:0]e[`p_no-1:0];
  reg signed [`size:0]c;
  reg signed [`p_width-1:0]pp[`p_no-1:0];
  reg signed [`p_width-1:0] r[`p_no-1:0];
reg signed [`p_width-1:0]p;
integer j,i;
  always@(*)begin
c={a,1'b0};
  for(j=1;j<`size;j=j+2)begin
 case({c[j+1],c[j],c[j-1]})
 3'b000,3'b111:e[(j-1)/2]=3'b000;
 3'b001,3'b010:e[(j-1)/2]=3'b001;
 3'b110,3'b101:e[(j-1)/2]=3'b101;
 3'b011:e[(j-1)/2]=3'b010;
 3'b100:e[(j-1)/2]=3'b110;
 default:e[(j-1)/2]=3'b000;
 endcase
 end
//$display("%b",e[0]);
//$display("%b",e[1]);
//$display("%b",e[2]);
//$display("%b",e[3]);
  for(int i=0;i<`p_no;i=i+1)begin
 case(e[i])
   3'b000:pp[i]='0;
 3'b001:pp[i]=b;
 3'b101:pp[i]=-b;
 3'b010:pp[i]=b<<1;
 3'b110:pp[i]=-(b<<1);
 endcase
 pp[i]=$signed(pp[i])<<(2*i);
  //  $display("pp%d is %d",i,pp[i]);
  end
  end
  always @(posedge clk) begin
    if(reset) begin
      for(int i=0;i<`p_no;i++) r[i] <= 0;
    end else begin
      for(int i=0;i<`p_no;i++) r[i] <= pp[i];
    end
  end

  always@(posedge clk)begin
    for(int i=0;i<`p_no;i++)begin
      pp_out[i]<=r[i];
   // $display("pp_out%d is %d",i,pp_out[i]);
  end
  end
endmodule

/*
module tb();
   logic signed[`size-1:0]a,b;
  logic clk,reset;
   logic signed [`p_width-1:0]pp_out[`p_no-1:0];
  booth dut(a,b,pp_out,clk,reset);
initial begin
  clk=0;
  forever #5 clk=~clk;
end
  initial begin
    reset=1;
    #1
    reset=0;
  repeat(1)begin
  a=$random;b=$random;
    @(posedge clk);
     #12;
     $display("a=%d|b=%d|out=%p",a,b,pp_out);
    #30 $finish;
end
end
endmodule
 */
module mul(
  clk,
  reset,
  a,
  b,
  out
);

  `define size 8
  `define p_width (`size*2)
  `define p_no (`size/2)
  `define reg_wire (`p_no/2)

  input clk;
  input reset;
  input signed [`size-1:0] a;
  input signed [`size-1:0] b;
  output signed [`p_width+1:0] out;

  wire signed [`p_width-1:0] w[`p_no-1:0];

  reg signed [`p_width:0] temp_sum[`reg_wire-1:0];
  reg signed [`p_width:0] out_sum[`reg_wire-1:0];
  reg signed [`p_width+1:0] sum;
  reg signed [`p_width+1:0] out_reg;

  integer i;

  booth m(a, b, w, clk, reset);

  always @(*) begin
    for (i = 0; i < `reg_wire; i = i + 1)
      temp_sum[i] = w[2*i] + w[2*i+1];
  end

  always @(posedge clk) begin
    if (reset) begin
      for (i = 0; i < `reg_wire; i = i + 1)
        out_sum[i] <= 0;
    end
    else begin
      for (i = 0; i < `reg_wire; i = i + 1)
        out_sum[i] <= temp_sum[i];
    end
  end

  always @(*) begin
    sum = 0;   
    for (i = 0; i < `reg_wire; i = i + 1)
      sum = sum + out_sum[i];
  end

  always @(posedge clk) begin
    if (reset)
      out_reg <= 0;
    else
      out_reg <= sum;
  end

  assign out = out_reg;

endmodule

`timescale 1ns/1ps
/*
module tb;
  logic clk;
  logic reset;
  logic signed [`size-1:0] a, b;
  logic signed [`p_width+1:0] out;

  logic signed [`p_width+1:0] expected;

  mul dut (
    .clk(clk),
    .reset(reset),
    .a(a),
    .b(b),
    .out(out)
  );


  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    reset = 1;
    repeat(4) @(posedge clk);  
    reset = 0;
  end

  initial begin
    @(negedge reset);

    repeat (10) begin
      a = $random;
      b = $random;
      expected = a * b;

      @(posedge clk);   
      repeat (4) @(posedge clk);

      if (out === expected)
        $display("PASS : a=%0d b=%0d out=%0d", a, b, out);
      else
        $display("FAIL : a=%0d b=%0d out=%0d expected=%0d", 
                  a, b, out, expected);

    end

    $finish;
  end

endmodule
*/
module pe(
  input signed [`size-1:0] a[`matrix_size-1:0],
  input signed [`size-1:0] b[`matrix_size-1:0],
    input clk,input reset,
  output signed [`p_width+3:0] out 
);
  reg signed [`p_width+2:0] r[`matrix_size-1:0];
  wire signed [`p_width+1:0] m_out[`matrix_size-1:0];
  reg signed [`p_width+2:0] sum_wire[(`matrix_size/2)-1:0];
  reg signed [`p_width+3:0] sum;
  reg signed [`p_width+3:0] out_f;
  reg signed [`p_width+2:0] out_reg[(`matrix_size/2)-1:0];
   generate
  genvar k;
  for (k = 0; k < `matrix_size; k = k + 1) begin : MUL_ARRAY
    mul u_m1 (
      .clk(clk),
      .reset(reset),
      .a(a[k]),
      .b(b[k]),
      .out(m_out[k])
    );
  end
endgenerate
  
  
    always @(posedge clk) begin
        if (reset) begin
          for(int i=0;i<`matrix_size;i++)begin
            r[i] <= '0;
        end
    end 
      else begin
        for(int i=0;i<`matrix_size;i++)begin
          r[i] <= m_out[i];
          
        end
 //   $display("m_out[i] is %p",m_out);
      end
    end
  
  always@(*)begin
    for(int l=0;l<`matrix_size/2;l++)begin
       sum_wire[l]=r[2*l]+r[2*l+1];
    end
  end
    always @(posedge clk) begin
       if (reset) begin
         for(int i=0;i<`matrix_size/2;i++)begin
            out_reg[i] <= '0;
        end
    end 
      else begin
        for(int i=0;i<`matrix_size/2;i++)begin
        out_reg[i] <= sum_wire[i];
         end
        end
    end
  always @(*) begin
   sum = 0;
    for(int i=0;i<`matrix_size/2;i++)begin
    sum = sum + out_reg[i];
  end
  end
  always@(posedge clk)begin
    if(reset)begin
      out_f<=0;
    end
    else begin
      out_f<=sum;
  end
  end
assign out = out_f;
endmodule
/*
module tb();
  logic signed [`size-1:0] a[`matrix_size-1:0];
  logic signed [`size-1:0] b[`matrix_size-1:0];
  logic clk, reset;
  logic signed [`p_width+3:0] out ;
  logic signed [`p_width+2:0] expected;
  initial begin
    clk=0;
    forever #5 clk=~clk;
  end
     pe mod(a,b,clk, reset,out);   
  initial begin
    reset = 1;expected =0;
    repeat(8) @(posedge clk);  
    reset = 0;
  end
  initial begin
    @(negedge reset);
    repeat (10) begin
      expected=0;
      for(int i=0;i<`matrix_size;i++)begin
        a[i] = $random;
        b[i] = $random;
        expected=(a[i]*b[i])+expected;
    end
      @(posedge clk);   
      repeat (8) @(posedge clk);

      if (out === expected)
        $display("PASS : a=%0d b=%0d out=%0d", a, b, out);
      else
        $display("FAIL : a=%0p b=%0p out=%0d expected=%0d", 
                  a, b, out, expected);
    end

    $finish;
  end
endmodule
*/
module mac(
  input signed [`size-1:0] a[(`matrix_size*`matrix_col)-1:0],
  input signed [`size-1:0] b[(`matrix_size*`matrix_col)-1:0],
    input clk, reset,
  output reg signed [`p_width+3:0] out[`NUM_PE-1:0]
);
  
  wire signed [`p_width+3:0] q[`NUM_PE-1:0];
  reg signed [`p_width+3:0] out_reg[`NUM_PE-1:0];
generate
  genvar i;
  for(i=0;i<`TOTAL;i=i+4)begin
  pe p1(
  '{a[i], a[i+1], a[i+2], a[i+3]},
  '{b[i], b[i+1], b[i+2], b[i+3]},
  clk, reset,
    q[i/4]
);
  end
endgenerate

    always @(posedge clk) begin
      for(int i=0;i<`NUM_PE;i++)begin
      if (reset) 
        out_reg[i] <= 0;
      else         
        out_reg[i] <= q[i];
    end
    end
  always@(*)begin
    for(int i;i<`NUM_PE;i++)begin
      out[i]=out_reg[i]; 
    end
  end
endmodule
