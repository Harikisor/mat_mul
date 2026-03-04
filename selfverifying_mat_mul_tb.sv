
module tb();
  logic signed [`size-1:0] a[(`TOTAL)-1:0];
  logic signed [`size-1:0] b[(`TOTAL)-1:0];
  logic clk, reset;
  logic signed [`p_width+3:0] out[`NUM_PE-1:0];  
  logic signed [`p_width+3:0] expected[`NUM_PE-1:0];
int j;
  initial begin
  clk=0;
  forever #5 clk=~clk;
end
  mac dut(a,b,clk,reset,out);
initial begin
  reset=1;
  #1;
  repeat(10)@(posedge clk);
    reset=0;
    
  repeat(8)begin
    @(negedge clk);
    j=0;
    for(int i=0;i<`NUM_PE;i++)begin
    expected[i]=0;
  end
    for(int i=0;i<=`TOTAL;i++)begin
      a[i]=$random;b[i]=$random;
    end
   for(int i=0;i<`TOTAL;i++) begin
     j= i % `NUM_PE;
     expected[j] += a[i] * b[i];
  end
     @(posedge clk);   
    repeat (8) @(posedge clk);
      if (out === expected)
        $display("PASS : a=%0p b=%0p out=%0p expected=%0p", a, b, out, expected);
      else
        $display("FAIL : a=%0p b=%0p out=%0p expected=%0p", 
                  a, b, out, expected);
    end

    $finish;
  end
endmodule
    
