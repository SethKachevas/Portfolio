/*
Code by Seth Kachevas
Capstone.v
Verilog code for a serial subtractor 
*/
//Module for our serial subtractor
module serial_sub(a,b,c_nxt,clk,shift_ctrl,d_a,d_b);

//declare all input and output registers and wires
output reg [7:0] a,b;
output c_nxt;
input [7:0] d_a,d_b;
input clk,shift_ctrl;
wire diff,c_now,w;

//assign w which is used in dff
assign w=shift_ctrl&clk;

//call the modules for the full subtractor and the dflipflop
dff d (c_nxt,c_now,w,~shift_ctrl);
fullsub fa (diff,c_now,a[0],b[0],c_nxt);

always@(posedge clk) begin

//shift control to shift the binary number into the serial subtractor 
if(!shift_ctrl)begin

//assigning the data to its proper bit position into the accumulator register
    a[0]<=d_a[0];
    a[1]<=d_a[1];
    a[2]<=d_a[2];
    a[3]<=d_a[3];
	a[4]<=d_a[4];
	a[5]<=d_a[5];
    a[6]<=d_a[6];
	a[7]<=d_a[7];


    b[0]<=d_b[0];
    b[1]<=d_b[1];
    b[2]<=d_b[2];
    b[3]<=d_b[3];
	b[4]<=d_b[4];
	b[5]<=d_b[5];
    b[6]<=d_b[6];
	b[7]<=d_b[7];


end

else if(shift_ctrl)begin
//assigning the data to its proper bit position into the accumulator register
	a[7]<=diff;
    a[6]<=a[7];
    a[5]<=a[6];
    a[4]<=a[5];
    a[3]<=a[4];
    a[2]<=a[3];
    a[1]<=a[2];
    a[0]<=a[1];

	b[7]<=b[0];
    b[6]<=b[7];
    b[5]<=b[6];
    b[4]<=b[5];
    b[3]<=b[4];
    b[2]<=b[3];
    b[1]<=b[2];
    b[0]<=b[1];

end

end

endmodule

//d flipflop
module dff(q,d,clk,rst);

input clk,rst,d;
output reg q;

always@(posedge clk or posedge rst)begin
    if(rst)
        q<=1'b0;
    else
        q<=d;
end

endmodule

//Module for our full subtractor
module fullsub(diff, c_out, a, b, c_in);
//declare all input and output registers and wires
output diff, c_out;
input a, b, c_in;
wire s1, c1, c2;

//full logic circuit for subtractor
xor (s1, a, b);
and (c1, ~a, b);
xor (diff, s1, c_in);
and (c2, ~s1, c_in);
or  (c_out, c2, c1);

endmodule

//Test bench
module top; 

//declare all input and output registers and wires
reg clk,shift_ctrl;
wire [7:0] a,b;
reg [7:0] d_a,d_b;
integer i;
reg z;
reg n;
reg v;

//calls our serial subtractor
serial_sub sa (a,b,c_nxt,clk,shift_ctrl,d_a,d_b);

initial 
begin

//initalize variables
clk=0;
z=0;
n=0;
v=0;


//for loop to print various outputs for our subtractor to process
for(i=50;i<=255;i=i+50)begin

    d_b=i;
	d_a=2*i-1;

    shift_ctrl=0;
    #10;

    shift_ctrl=1;
    #80;
	if (a == 0) begin
	z=1;
	end
	if (c_nxt == 1) begin
	n=1;
	end
    $display("\n a=%b=%d b=%b=%d \n diff=%b=%d borrow= %b\n z=%d\n n=%d\n v=%d\n",d_a,d_a,d_b,d_b,a,a,c_nxt,z,n,v);

end
	d_b=5;
	d_a=5;

    shift_ctrl=0;
    #10;

    shift_ctrl=1;
    #80;
	if (a <= 0) begin
	z=1;
	end
	if (c_nxt == 1) begin
	n=1;
	end
    $display("\n a=%b=%d b=%b=%d \n diff=%b=%d borrow= %b\n z=%d\n n=%d\n v=%d\n",d_a,d_a,d_b,d_b,a,a,c_nxt,z,n,v);

	
$finish;

end
always #5 clk=~clk;

endmodule