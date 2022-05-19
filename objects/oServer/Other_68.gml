/// @desc

if (async_load[? "type"] != network_type_data) exit;

// Who we are getting the data from.
var socket = ds_map_find_value(async_load, "id");

// Handle incoming data
var buffer = ds_map_find_value(async_load, "buffer");
buffer_seek(buffer, buffer_seek_start, 0);
var data = buffer_read(buffer, buffer_string);

show_debug_message("-- Incoming Data --\n\n"+data+"\n-- End Data --");

try {

var pl = new String(data);
var h = pl.slice("\n");

show_debug_message(string(h))

// Find method
var http_method = undefined;
var first_header = h[0];

for (var i = 0; i < methods_length; i ++) {
	
	if first_header.starts_with(accepted_methods[i]) {
		http_method = accepted_methods[i];
		break;
	}
}
if (http_method == undefined) {
	http_send_error(socket, 501, "The protocol is not implemented");
	exit;
}

if (http_method == "GET") {
	
	// Find the directory they want
	
	//var dir_begin = string_pos("/", h[0]);
	//var filename = string_copy(h[0], dir_begin, string_last_pos("HTTP", h[0])-dir_begin-1);
	var dir_begin = h[0].first_pos("/");
	var filename = h[0].substring(dir_begin, h[0].last_pos("HTTP")-dir_begin-1);
	
	var url_args = [];
	var args_pos = filename.first_pos("?");
	
	if (args_pos != -1) {
		
		// We have ? stuff
		//var args_remain = string_copy(filename, args_pos+1, string_length(filename)-args_pos);
		
		//url_args = string_slice(args_remain, "&");
		//filename = string_copy(filename, 1, args_pos-1);
		var args_string = new String(filename.substring(args_pos+1));
		url_args = args_string.slice("&");
		filename.val = filename.substring(0, args_pos).val;
	}
	
	if (!file_exists(working_directory+filename.val)) {
		
		// check if it is a directory
		if (filename.char_at(filename.length()) == "/" && file_exists(working_directory+filename.val+"index.html")) {
			filename.val += "index.html";
		} else {
			http_send_error(socket, 404, filename.val);
			exit;
		}
		
	}
	
	// if the file is on the forbidden list, send a 403.
	if (array_find(forbidden_files, filename.val) != -1) {
		http_send_error(socket, 403, filename.val);
		exit
	}
	
	var buf = buffer_load(working_directory+filename.val);
	
	http_send_packet(socket, 200, [
		"Content-Type:" + content_type(filename.val)
	], buf);
	
	buffer_delete(buf);
	
}

if (http_method == "POST") {
	// this doesn't seem to work, not sure why atm.
	http_send_packet(socket, 200, [
		"Content-Type: application/json"
	], json_stringify({response: "Request received. No further processing."}));
}


} catch(e) {
	
	// show the end user a GML error :P
	http_send_error(socket, 500, e.longMessage);
	show_debug_message("=== ERROR ===\n"+e.longMessage+"\n=== END ERROR ===");
}
