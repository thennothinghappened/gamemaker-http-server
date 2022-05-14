/// @desc

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_text(room_width/2, room_height/2, "Server Status: " + (server < 0 ? "OFFLINE\nPress CTRL to retry" : ("Online!\nPort: "+string(port))));
