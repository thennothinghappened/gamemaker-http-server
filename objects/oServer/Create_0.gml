/// @desc terrible HTTP web server by thennothing

#macro version "1.0"

draw_enable_drawevent(false);

accepted_methods = [
	"GET", "POST"
];
methods_length = array_length(accepted_methods);

port = 8080;
var config_filename = working_directory+"config.json";

//if (file_exists()

server = network_create_server_raw(network_socket_tcp, port, 1013);

// Create the list of illegal files
forbidden_files = [];
var filename = working_directory+"unauthorized";
if (!file_exists(filename)) {
	show_debug_message(filename+" does not exist. All files are allowed.");
	exit;
}

var file = file_text_open_read(filename);
while (!file_text_eof(file)) {
	
	var l = file_text_readln(file);
	if string_char_at(l, 1) == ";" continue;
	
	if !(string_char_at(l, string_length(l)) == "\n")
		array_push(forbidden_files, l);
	else
		array_push(forbidden_files, string_copy(l, 1, string_length(l)-2));
}

file_text_close(file);

show_debug_message(string(forbidden_files));
