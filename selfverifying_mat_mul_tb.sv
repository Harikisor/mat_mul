
module tb();
    logic signed [7:0] a,b,c,d,e,f,g,h, a1,b1,c1,d1,e1,f1,g1,h1, 
                       a2,b2,c2,d2,e2,f2,g2,h2, a3,b3,c3,d3,e3,f3,g3,h3;
    logic clk, reset_mul, reset_add;
    logic signed [19:0] out;
    logic signed[17:0]t,t1,t2,t3;
    logic signed [19:0] expected_q;
    int i,j;
    mac aer (
        .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g), .h(h),
        .a1(a1), .b1(b1), .c1(c1), .d1(d1), .e1(e1), .f1(f1), .g1(g1), .h1(h1),
        .a2(a2), .b2(b2), .c2(c2), .d2(d2), .e2(e2), .f2(f2), .g2(g2), .h2(h2),
        .a3(a3), .b3(b3), .c3(c3), .d3(d3), .e3(e3), .f3(f3), .g3(g3), .h3(h3),
        .clk(clk), .reset_mul(reset_mul), .reset_add(reset_add),
        .out(out)
    );

    function automatic logic signed [17:0] calc_pe(
        input logic signed [7:0] i1, i2, i3, i4, i5, i6, i7, i8
    );
        calc_pe = (i1 * i2) + (i3 * i4) + (i5 * i6) + (i7 * i8);
    endfunction

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset_mul = 1;
        reset_add = 1;
        {a,b,c,d,e,f,g,h,a1,b1,c1,d1,e1,f1,g1,h1,a2,b2,c2,d2,e2,f2,g2,h2,a3,b3,c3,d3,e3,f3,g3,h3} = '0;
        
        #20;
        reset_mul = 0;
        reset_add = 0;

        repeat (100) begin
            @(negedge clk);
            a = $random; b = $random; c = $random; d = $random;
            e = $random; f = $random; g = $random; h = $random;
            a1 = $random; b1 = $random; c1 = $random; d1 = $random;
            e1 = $random; f1 = $random; g1 = $random; h1 = $random;
            a2 = $random; b2 = $random; c2 = $random; d2 = $random;
            e2 = $random; f2 = $random; g2 = $random; h2 = $random;
            a3 = $random; b3 = $random; c3 = $random; d3 = $random;
            e3 = $random; f3 = $random; g3 = $random; h3 = $random;
                    t=calc_pe(a,b,c,d,e,f,g,h) ;
                    t1=calc_pe(a1,b1,c1,d1,e1,f1,g1,h1);
                    t2=calc_pe(a2,b2,c2,d2,e2,f2,g2,h2) ;
                    t3= calc_pe(a3,b3,c3,d3,e3,f3,g3,h3);
               expected_q = $signed(t) + $signed(t1) + $signed(t2) + $signed(t3);
            repeat(2) @(posedge clk);
            #1; 
            if (out === expected_q) begin
                $display("[PASS] Expected: %d | Got: %d", expected_q, out);
                 i=i+1;
            end else begin
                $display("[FAIL] Expected: %d | Got: %d", expected_q, out);
                j=j+1;
                    $display("a=%0d  b=%0d c=%0d  d=%0d e=%0d  f=%0d g=%0d  h=%0d  => out=%0d", a, b,c,d,e,f,g,h,t);
                   $display("a=%0d  b=%0d c=%0d  d=%0d e=%0d  f=%0d g=%0d  h=%0d  => out=%0d", a1, b1,c1,d1,e1,f1,g1,h1,t1);
                   $display("a=%0d  b=%0d c=%0d  d=%0d e=%0d  f=%0d g=%0d  h=%0d  => out=%0d", a2, b2,c2,d2,e2,f2,g2,h2,t2);
                  $display("a=%0d  b=%0d c=%0d  d=%0d e=%0d  f=%0d g=%0d  h=%0d  => out=%0d", a3, b3,c3,d3,e3,f3,g3,h3,t3);
            end
         $display("the no of times module failed is%d",j);
         $display("the no of times module passed is%d",i);
        end
     
        $finish;
    end
endmodule
