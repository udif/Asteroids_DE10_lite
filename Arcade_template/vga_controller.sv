// VGA Sync machine
//
// 4/11/2021 Compiled from various sources

module vga_controller #(
   parameter h_pixels   = 640,   // horizontal display
   parameter h_fp       = 16,    // horizontal Front Porch
   parameter h_pulse    = 96,    // horizontal sync pulse
   parameter h_bp       = 48,    // horizontal back porch
   parameter h_pol      = 1'b0,  // horizontal sync polarity (1 = positive, 0 = negative)
   parameter v_pixels   = 480,   // vertical display
   parameter v_fp       = 10,    // vertical front porch
   parameter v_pulse    = 2,     // vertical pulse
   parameter v_bp       = 33,    // vertical back porch
   parameter v_pol      = 1'b0   // vertical sync polarity (1 = positive, 0 = negative)
) (
   input pixel_clk,           // Pixel clock
   input reset_n,             // Active low synchronous reset
   vga   vga_gen
);

   // Get total number of row and column pixel clocks
   localparam h_period = h_pulse + h_bp + h_pixels + h_fp;
   localparam v_period = v_pulse + v_bp + v_pixels + v_fp;

   // Full range counters
   reg [$clog2(h_period)-1:0] h_count;
   reg [$clog2(v_period)-1:0] v_count;

   always @(posedge pixel_clk) begin
      // Perform reset operations if needed
      if (reset_n == 1'b0) begin
         h_count  <= 0;
         v_count  <= 0;
         vga_gen.t       <= '0;
         vga_gen.t.hsync <= ~ h_pol;
         vga_gen.t.vsync <= ~ v_pol;
         vga_gen.t.en    <= 1'b0;
         vga_gen.t.pxl_x <= 0;
         vga_gen.t.pxl_y <= 0;
      end else begin

         // Pixel Counters
         if (h_count < h_period - 1) begin
            h_count <= h_count + 1'd1;
         end else begin
            h_count <= 0;
            if (v_count < v_period - 1) begin
               v_count <= v_count + 1'd1;
            end else begin
               v_count <= 0;
            end
         end

         // Horizontal Sync Signal
         if ( (h_count < h_pixels + h_fp) || (h_count > h_pixels + h_fp + h_pulse) ) begin
            vga_gen.t.hsync <= ~ h_pol;
         end else begin
            vga_gen.t.hsync <= h_pol;
         end

         // Vertical Sync Signal
         if ( (v_count < v_pixels + v_fp) || (v_count > v_pixels + v_fp + v_pulse) ) begin
            vga_gen.t.vsync <= ~ v_pol;
         end else begin
            vga_gen.t.vsync <= v_pol;
         end

         // Update Pixel Coordinates
         if (h_count < h_pixels) begin
            vga_gen.t.pxl_x <= h_count[$clog2(h_pixels)-1:0];
         end

         if (v_count < v_pixels) begin
            vga_gen.t.pxl_y <= v_count[$clog2(v_pixels)-1:0];
         end

         // Set display enable output
         if (h_count < h_pixels && v_count < v_pixels) begin
            vga_gen.t.en <= 1'b1;
         end else begin
            vga_gen.t.en <= 1'b0;
         end
      end
   end

endmodule
