/// @desc terrible HTTP web server by thennothing

#macro version "1.2.1"

////////////////////////
//   STRING TESTING   //
////////////////////////
/*
var t1 = new String("Thisss iss a tessst! Wow!");
show_debug_message(t1.starts_with("This"));
show_debug_message(string(t1.slice(" ")));
show_debug_message(t1.substring(2));
show_debug_message(t1.ends_with("Wow!"));
show_debug_message(t1.length());
//show_debug_message(t1.remove_duplicates("s"));
*/
////////////////////////
// END STRING TESTING //
////////////////////////

accepted_methods = [
	"GET"//, "POST"
];
methods_length = array_length(accepted_methods);

// Set default configuration
port = 8080;
use_forbidden = false;
use_directory_viewer = true;
draw_game_window = false;
unformatted_page_css = "";
server_speed = 60;

// Attempt to load config file
var config_filename = working_directory+"config.json";
if (file_exists(config_filename)) {
	var buf = buffer_load(config_filename);
	
	try {
		var config = json_parse(buffer_read(buf, buffer_text));
		
		// If the keys don't exist, use fallback configuration.
		use_forbidden = struct_set_if_exists("use_forbidden", config, use_forbidden);
		use_directory_viewer = struct_set_if_exists("use_directory_viewer", config, use_directory_viewer);
		port = struct_set_if_exists("port", config, port);
		draw_game_window = struct_set_if_exists("draw_game_window", config, draw_game_window);
		unformatted_page_css = struct_set_if_exists("unformatted_page_css", config, unformatted_page_css);
		server_speed = struct_set_if_exists("server_speed", config, server_speed);
	
	} catch(e) {
		// Somebody sucks at JSON.
		show_debug_message("Failed to parse "+config_filename+" as JSON! Using default configuration.");
	}
	
	buffer_delete(buf);
	
} else {
	// No config, so use default.
	show_debug_message(config_filename+" does not exist! Using default configuration.");
}

// Disable the window if drawing is disabled. Drawing the window is only for debugging and will lag the server more.
application_surface_draw_enable(draw_game_window);
draw_enable_drawevent(draw_game_window);

// Set the speed of the server.
game_set_speed(server_speed, gamespeed_fps);

show_debug_message("Attempting to make a server on port " + string(port));
// This one line has caused me hell with all the bugs on ARM64 GameMaker.
server = network_create_server_raw(network_socket_tcp, port, 3);

if (server < 0)
	throw "FATAL: FAILED TO CREATE SERVER!";
else
	show_debug_message("\n----------------\nSuccessfully started GML HTTP Server v"+version+"\nPort="+string(port)+", server_speed="+string(server_speed)+", use_forbidden="+(use_forbidden?"yes":"no\n----------------\n")+"\n");

// Create the list of forbidden files
forbidden_files = [];

var filename = working_directory+"forbidden";
if (!file_exists(filename)) {
	show_debug_message(filename+" does not exist. All files are allowed.");
	exit;
}

var file = file_text_open_read(filename);

// Iterate over and find all files that should be forbidden
while (!file_text_eof(file)) {
	
	var l = new String(file_text_readln(file));
	if !(l.starts_with("/")) continue;
	
	if (l.ends_with("\n"))
		array_push(forbidden_files, l.substring(0, l.length()-1).val);
	else
		array_push(forbidden_files, l.val);
}

file_text_close(file);
show_debug_message("Forbidden Files:\n"+array_join(forbidden_files, "\n")+"\n----------------\n");
