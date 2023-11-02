`default_nettype  wire


module usb_cdc_apb
  (

        input  wire             PCLK, // 12MHz Clock
        input  wire             PRESETn,
   
        input   wire [31:0]     PADDR,
        input   wire            PWRITE,
        input   wire            PSEL,
        input   wire            PENABLE,
        input   wire [31:0]     PWDATA,
        output  wire [31:0]     PRDATA,
        output                  PREADY,

        output  wire            dp_pu_o,
        input   wire            dp_rx_i,
        input   wire            dn_rx_i,
        output  wire            dp_tx_o,
        output  wire            dn_tx_o,
        output  wire            tx_en_o,

        output wire             irq

   );

        localparam BIT_SAMPLES = 'd4;
        localparam [6:0] DIVF = 12*BIT_SAMPLES-1;

        localparam[15:0] TX_DATA_REG_ADDR = 16'h0000; //tx usb transmiting to host and getting this data from soc
        localparam[15:0] RX_DATA_REG_ADDR = 16'h0004; //rx usb recieveing from host and outpting this data to soc
        localparam[15:0] TX_FIFO_LEVEL_REG_ADDR = 16'h0008;
localparam[15:0] RX_FIFO_LEVEL_REG_ADDR = 16'h00C;
        localparam[15:0] TX_FIFO_TH_REG_ADDR = 16'h0010;
localparam[15:0] RX_FIFO_TH_REG_ADDR = 16'h0014;
        localparam[15:0] ICR_REG_ADDR = 16'h0018;
        localparam[15:0] RIS_REG_ADDR = 16'h001C;
        localparam[15:0] IM_REG_ADDR = 16'h0020;
        localparam[15:0] MIS_REG_ADDR = 16'h0024;



        wire  [7:0]      TX_DATA_REG;
        wire  [7:0]      RX_DATA_REG;
        wire  [3:0]      TX_FIFO_LEVEL_REG;
        wire  [3:0]      RX_FIFO_LEVEL_REG;
        reg   [3:0]      TX_FIFO_TH_REG;
        reg   [3:0]      RX_FIFO_TH_REG;
        wire  [3:0]      MIS_REG;
        reg   [3:0]      RIS_REG;
        reg   [3:0]      ICR_REG;
        reg   [3:0]      IM_REG;



        wire             TX_FIFO_EMPTY_FLAG;
        wire             RX_FIFO_FULL_FLAG;
        wire             RX_FIFO_LEVEL_ABOVE_TH_FLAG;
        wire             TX_FIFO_LEVEL_BELOW_TH_FLAG;


        wire [7:0]       out_data_o;
        wire             out_valid_o;
        wire             out_ready_i;

        wire [7:0]       in_data_i;
        wire             in_valid_i;
        wire             in_ready_o;

        wire one = 1'b1;

       
        wire             read;
        wire             out_data_fifo_full;
        wire             out_data_fifo_empty;
        wire [3:0]       out_data_fifo_level;
        wire [7:0]       fifo_data_out;


        wire             write;
        wire             in_data_fifo_full;
        wire             in_data_fifo_empty;
        wire [3:0]       in_data_fifo_level;
        wire [7:0]       fifo_data_in;


        wire   apb_valid    = PSEL & PENABLE;
        wire   apb_re   = ~PWRITE & apb_valid;
        assign read = apb_re & (PADDR[15:0]==RX_DATA_REG_ADDR);
        assign out_ready_i = ~out_data_fifo_full;
        assign RX_DATA_REG = fifo_data_out;
        assign RX_FIFO_FULL_FLAG = out_data_fifo_full;
        assign RX_FIFO_LEVEL_REG = out_data_fifo_level;
        wire [3:0] rx_fifo_th  = RX_FIFO_TH_REG;
        assign RX_FIFO_LEVEL_ABOVE_TH_FLAG = (out_data_fifo_level > rx_fifo_th);


        wire   apb_we = PWRITE & apb_valid;
        assign write = apb_we & (PADDR[15:0]==TX_DATA_REG_ADDR);
        assign in_valid_i = ~in_data_fifo_empty;
        assign TX_DATA_REG = PWDATA;
        assign fifo_data_in = TX_DATA_REG;
        assign TX_FIFO_EMPTY_FLAG = in_data_fifo_empty;
        assign TX_FIFO_LEVEL_REG = in_data_fifo_level;
        wire [3:0] tx_fifo_th  = TX_FIFO_TH_REG;
        assign TX_FIFO_LEVEL_BELOW_TH_FLAG = (in_data_fifo_level < tx_fifo_th);



        always @(posedge PCLK or negedge PRESETn) if(~PRESETn) TX_FIFO_TH_REG <= 0; else if(apb_we & (PADDR[15:0]==TX_FIFO_TH_REG_ADDR)) TX_FIFO_TH_REG <= PWDATA[4-1:0];
        always @(posedge PCLK or negedge PRESETn) if(~PRESETn) RX_FIFO_TH_REG <= 0; else if(apb_we & (PADDR[15:0]==RX_FIFO_TH_REG_ADDR)) RX_FIFO_TH_REG <= PWDATA[4-1:0];
       
        always @(posedge PCLK or negedge PRESETn) if(~PRESETn) IM_REG <= 0; else if(apb_we & (PADDR[15:0]==IM_REG_ADDR)) IM_REG <= PWDATA[4-1:0];
        always @(posedge PCLK or negedge PRESETn) if(~PRESETn) ICR_REG <= 4'b0; else if(apb_we & (PADDR[15:0]==ICR_REG_ADDR)) ICR_REG <= PWDATA[4-1:0]; else ICR_REG <= 4'd0;

        always @(posedge PCLK or negedge PRESETn)
        if(~PRESETn) RIS_REG <= 32'd0;
        else begin
            if(TX_FIFO_EMPTY_FLAG) RIS_REG[0] <= 1'b1; else if(ICR_REG[0]) RIS_REG[0] <= 1'b0;
            if(TX_FIFO_LEVEL_BELOW_TH_FLAG) RIS_REG[1] <= 1'b1; else if(ICR_REG[1]) RIS_REG[1] <= 1'b0;
            if(RX_FIFO_FULL_FLAG) RIS_REG[2] <= 1'b1; else if(ICR_REG[2]) RIS_REG[2] <= 1'b0;
            if(RX_FIFO_LEVEL_ABOVE_TH_FLAG) RIS_REG[3] <= 1'b1; else if(ICR_REG[3]) RIS_REG[3] <= 1'b0;

        end

        assign MIS_REG  = RIS_REG & IM_REG;
        assign irq = |MIS_REG;


        assign  PRDATA =    (PADDR[15:0] == RX_DATA_REG_ADDR) ? RX_DATA_REG :
                            (PADDR[15:0] == TX_FIFO_LEVEL_REG_ADDR) ? TX_FIFO_LEVEL_REG :
   (PADDR[15:0] == RX_FIFO_LEVEL_REG_ADDR) ? RX_FIFO_LEVEL_REG :
                            (PADDR[15:0] == TX_FIFO_TH_REG_ADDR) ? TX_FIFO_TH_REG :
           (PADDR[15:0] == RX_FIFO_TH_REG_ADDR) ? RX_FIFO_TH_REG :
                            (PADDR[15:0] == RIS_REG_ADDR) ? RIS_REG :
                            (PADDR[15:0] == ICR_REG_ADDR) ? ICR_REG :
                            (PADDR[15:0] == IM_REG_ADDR) ? IM_REG :
                            (PADDR[15:0] == MIS_REG_ADDR) ? MIS_REG :
                            32'hDEADBEEF;

       

       usb_cdc #(.VENDORID(16'h1D50),
             .PRODUCTID(16'h6130),
             .IN_BULK_MAXPACKETSIZE('d8),
             .OUT_BULK_MAXPACKETSIZE('d8),
             .BIT_SAMPLES(BIT_SAMPLES),
             //.USE_APP_CLK(1),
             //.APP_CLK_RATIO(BIT_SAMPLES*12/2))  // BIT_SAMPLES * 12MHz / 2MHz
             .USE_APP_CLK(0))
   u_usb_cdc (.frame_o(),
              .configured_o(),
              //.app_clk_i(clk_2mhz),
              //.clk_i(clk_pll),
              .app_clk_i(1'b0),
              //.clk_i(clk_48MHz),
              .clk_i(PCLK),
              .rstn_i(PRESETn),
              .out_ready_i(out_ready_i),
              .in_data_i(in_data_i),
              .in_valid_i(in_valid_i),
              .dp_rx_i(dp_rx_i),
              .dn_rx_i(dn_rx_i),
              .out_data_o(out_data_o),
              .out_valid_o(out_valid_o),
              .in_ready_o(in_ready_o),
              .dp_pu_o(dp_pu_o),
              .tx_en_o(tx_en_o),
              .dp_tx_o(dp_tx_o),
              .dn_tx_o(dn_tx_o));

    FIFO out_data_fifo (
        .clk(PCLK),
        .rst_n(PRESETn),
        .rd(read),
        .wr(out_valid_o),  
        .w_data(out_data_o),  //data coming from usb cdc
        .empty(out_data_fifo_empty),
        .full(out_data_fifo_full),
        .r_data(fifo_data_out), // data going to prdata
        .level(out_data_fifo_level)
    );

    wire fifo_in_read = in_ready_o & ~in_data_fifo_empty;
    //wire fifo_in_read = ~in_data_fifo_empty;

    FIFO in_data_fifo (
        .clk(PCLK),
        .rst_n(PRESETn),
        .rd(fifo_in_read),
        .wr(write),
        .w_data(fifo_data_in), //data coming from pwdata
        .empty(in_data_fifo_empty),
        .full(in_data_fifo_full),
        .r_data(in_data_i),  //data going to usb cdc
        .level(in_data_fifo_level)
    );

   
    assign PREADY = 1'b1;
     

endmodule