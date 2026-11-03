module signage_control #(parameter FPS=60)(
 input clk,reset,frame_end,input [15:0] keys,input [7:0] switches,
 output reg [2:0] scene,output reg [1:0] period_selector,
 output reg [4:0] volume,
 output reg audio_visible,
 output reg [1:0] layout_mode,group_selector,
 output reg [15:0] countdown_seconds,output reg countdown_running,
 output wire bgm_enabled,muted,schedule_enabled
);
 reg [15:0] event_frames;reg [6:0] seconds_frame;reg [1:0] duration_selector;
 wire [15:0] duration=duration_selector==0 ? 60:duration_selector==1 ? 180:duration_selector==2 ? 300:600;
 assign bgm_enabled=switches[4];assign muted=switches[5];assign schedule_enabled=switches[6];
 wire [2:0] selected_scene=switches[2] ? 3 : switches[1] ? 2 : switches[3] ? 4 : switches[0] ? 1 : event_frames!=0 ? 5:0;
 reg [15:0] pending;
 always @(posedge clk or posedge reset) begin
  if(reset)begin
   scene<=0;period_selector<=0;volume<=16;audio_visible<=1;
   pending<=0;layout_mode<=1;group_selector<=0;countdown_seconds<=60;
   countdown_running<=0;event_frames<=0;seconds_frame<=0;duration_selector<=0;
  end else begin
   pending<=pending | keys;
   if(frame_end)begin
    pending<=keys;
    if(pending[1])layout_mode<=layout_mode==2 ? 0:layout_mode+1'b1;
    if(pending[2])period_selector<=period_selector+1'b1;
    if(pending[3])audio_visible<=!audio_visible;
    if(pending[6])group_selector<=group_selector+1'b1;
    if(pending[10] && !countdown_running)begin
     duration_selector<=duration_selector+1'b1;
     countdown_seconds<=duration_selector==0 ? 180:duration_selector==1 ? 300:duration_selector==2 ? 600:60;
    end
    if(pending[7])begin
     countdown_running<=!countdown_running;seconds_frame<=0;event_frames<=0;
     if(!countdown_running)countdown_seconds<=duration;
    end else if(countdown_running && selected_scene==0)begin
     if(seconds_frame==FPS-1)begin
      seconds_frame<=0;
      if(countdown_seconds>1)countdown_seconds<=countdown_seconds-1'b1;
      else begin countdown_seconds<=0;countdown_running<=0;event_frames<=FPS*20;end
     end else seconds_frame<=seconds_frame+1'b1;
    end
    if(event_frames!=0 && selected_scene==5)event_frames<=event_frames-1'b1;
    if(pending[11])begin
     if(volume==0)volume<=16;else volume<=volume-1'b1;
    end
    scene<=selected_scene;
   end
  end
 end
endmodule
