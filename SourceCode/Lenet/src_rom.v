`include "global.sv"
`include "timescale.sv"

module src_rom(
	input				clk,
	input				rstn,
	input				en,
	input				key_1,
	input				rpi_out,
	input				GPIO_10,
	input				GPIO_12,
	input				GPIO_14,
	input				GPIO_16,
	input				GPIO_18,
	input				GPIO_20,
	input				GPIO_22,
	input				GPIO_24,
	input				cena,
	input	[11:0]			aa,

	output	reg				ready,
	output	reg	[`WD:0]	qa,
	output	reg				push,
	output	reg				clk_1k
	);
	
	reg	[1:0]			din;
	reg	[`WD:0]		db;
	reg	[10:0]		ab;
	wire					ab_max = ab == 10'd783;
	wire					end_cenb = ab_max;

	reg	[16:0]		cnt_1k;
	always @(posedge clk, negedge rstn) begin
		if (rstn == 0) begin
			cnt_1k	<=	17'd0;
			clk_1k	<=	1'b1;
		end
		else begin
			if(en == 1) begin
				if (cnt_1k == 17'd0) begin
					cnt_1k	<=	17'd24999;
					clk_1k	<=	~clk_1k;
				end
				else begin
					cnt_1k	<=	cnt_1k - 1'b1;
				end
			end
			else begin
				cnt_1k	<=	17'd0;
				clk_1k	<=	1'b1;
			end
		end
	end

	always @(posedge clk_1k, negedge rstn) begin
		if(rstn == 0) begin
			din	<=	2'd0;
			push	<=	1'b0;
		end
		else begin
			if(en == 1) begin
				din[0]	<=	key_1;
				din[1]	<=	din[0];
				if(din[0] == 1 && din[1] == 0) begin
					push	<=	1'b1;
				end
				else begin
					push	<=	1'b0;
				end
			end
			else begin
				din	<=	2'b0;
				push	<=	1'b0;
			end
		end
	end
	
	always @(posedge clk_1k)
		if (`RST)	ab <= 0;
		else if(rpi_out)	ab <= ab_max? 0: ab + 1;
		
	always @(posedge clk_1k)
		if (`RST)	ready <= 0;
		else 		ready <= end_cenb;
		
	always @(posedge clk_1k) begin
		if (`RST)	begin
			db <= 0;
		end
		else	begin
			db[0] <= GPIO_10;
			db[1] <= GPIO_12;
			db[2] <= GPIO_14;
			db[3] <= GPIO_16;
			db[4] <= GPIO_18;
			db[5] <= GPIO_20;
			db[6] <= GPIO_22;
			db[7] <= GPIO_24;
		end
	end
	
	reg				[`WD:0]	mem[0:784];
	
	always @(posedge clk_1k) begin 
		if (rpi_out) begin	
			mem[ab] <= db;
      end			
	end
	always @(posedge clk) if (!cena)	qa <= mem[aa];
	
endmodule