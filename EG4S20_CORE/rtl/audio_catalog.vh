function [31:0] track_offset; input [2:0] id; begin case(id)
3'd0:track_offset=32'd1;
3'd1:track_offset=32'd230727;
3'd2:track_offset=32'd235592;
3'd3:track_offset=32'd242498;
3'd4:track_offset=32'd250503;
3'd5:track_offset=32'd257525;
default:track_offset=0;endcase end endfunction
function [31:0] track_sectors; input [2:0] id; begin case(id)
3'd0:track_sectors=32'd230726;
3'd1:track_sectors=32'd4865;
3'd2:track_sectors=32'd6906;
3'd3:track_sectors=32'd8005;
3'd4:track_sectors=32'd7022;
3'd5:track_sectors=32'd6257;
default:track_sectors=0;endcase end endfunction
localparam BGM_AVAILABLE=1'b1;
