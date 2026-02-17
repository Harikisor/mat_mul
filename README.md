it is a verilog code for matrix 4x4 multiplication block with a self verifying sytem verilog testbench
 __________
|          |
| mulblock | performs multiplication of two elements
|__________|       
 __________
|          |
| pe block | contains 4 mul block and a adder.It performs multiplication of 4 elements of row and 4 elements of column and add them to get a single element of output matrix
|__________|
 __________
|          |
| macblock | It contains 4 peblocks which is used to calculate a row or 4 elements of output matrix parallelly. 
|__________|
