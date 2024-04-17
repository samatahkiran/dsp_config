`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2024 14:25:48
// Design Name: 
// Module Name: packet_data
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module packet_data #(
    parameter data_width = 8,
    parameter depth = 64
)(
    input wire clk,
    input wire rst,
   
    input wire [data_width-1:0] s_axis_data,  
    input wire s_axis_valid,
    output reg s_axis_ready,
    input wire s_axis_last,
    
    input wire [data_width + data_width-1 :0] packet_config,
  
    output reg [data_width-1 : 0] m_axis_data,
    output reg m_axis_valid,
    input wire m_axis_ready,
    output reg m_axis_last,
   
    output  full,
    output  empty
);

   
    reg [data_width-1:0] mem_1 [depth-1:0];
    reg [data_width-1:0] mem_2 [depth-1:0];
    reg mem_3 [depth-1:0];
    
   
    reg [data_width-1:0] wr_ptr;
    reg [data_width-1:0] rd_ptr;
    reg [data_width:0] wr_ptr2;
    //reg [5:0] rd_ptr2;
    
    
    assign full = (wr_ptr == depth)?1:0;
    assign empty = (wr_ptr == 0)?1:0;

   
    wire [data_width-1:0] k;
    wire [data_width-1:0] len;
    assign {k, len} = packet_config;
    
    integer i;

  initial
  begin
    for(i = 0; i < depth; i = i + 1)
    begin
      mem_1[i] = 0;
      mem_2[i] = 0;
      mem_3[i] = 0;
    end
  end
     
     always@(posedge clk) begin
       if(rst) begin
         s_axis_ready <= 0;
       end else begin
         s_axis_ready <= 1;
       end
     end

  
    always @(posedge clk or posedge rst) begin
        if (rst) begin
           
            wr_ptr <= 0;
          
        end else begin
          
            
            if (s_axis_valid && s_axis_ready && ~full) begin
                mem_1[wr_ptr] <= s_axis_data;
                mem_3[wr_ptr] <= s_axis_last;
                
                if (wr_ptr > len-1-k) begin
                    mem_2[wr_ptr2] <= s_axis_data;
                    wr_ptr2 <= wr_ptr2 + 1;
                end else begin
                wr_ptr2 <= 0;
                end
                
                wr_ptr <= wr_ptr + 1;
            end
            
            if (s_axis_last) begin
                wr_ptr <= 0;
              //  wr_ptr2 <= 0;
            end
        end
    end
    
   
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            m_axis_data <= 0;
            m_axis_valid <= 0;
            m_axis_last <= 0;
            rd_ptr <= 0;
           // rd_ptr2 <= 0;
        end else begin
            if (m_axis_ready && ~empty) begin
                m_axis_valid <= 1;
                m_axis_data <= mem_1[rd_ptr] + mem_2[rd_ptr];
                m_axis_last <= mem_3[rd_ptr];
                
                rd_ptr <= rd_ptr + 1;
                if (rd_ptr == len - 1) begin
                    rd_ptr <= 0;
                
                
            end else begin
                m_axis_valid <= 0;
                m_axis_data  <= 0;
            end
        end
    end
 end
endmodule