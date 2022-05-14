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


// Interpret headers
var h = [];
var htemp = data;
var headers_allowed = 50;

while (htemp != "") {
	
	var pos = string_pos("\n", htemp);
	array_push(h, string_copy(htemp, 1, pos-1));
	htemp = string_delete(htemp, 1, pos);
	headers_allowed --;
	
	if (headers_allowed == 0) {
		
		http_send_error(socket, 431, "There are too many headers on the request.");
		exit;
	}
}

// Find method
var http_method = undefined;
for (var i = 0; i < methods_length; i ++) {
	if (string_copy(h[0], 1, string_length(accepted_methods[i])) == accepted_methods[i]) {
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
	
	var dir_begin = string_pos("/", h[0]);
	var filename = string_copy(h[0], dir_begin, string_last_pos("HTTP", h[0])-dir_begin-1);
	var url_args = [];
	var args_pos = string_pos("?", filename);
	
	if (args_pos != 0) {
		
		// We have ? stuff
		var args_remain = string_copy(filename, args_pos+1, string_length(filename)-args_pos);
		
		url_args = string_slice(args_remain, "&");
		filename = string_copy(filename, 1, args_pos-1);
	}
	
	if (!file_exists(working_directory+filename)) {
		
		// check if it is a directory
		if (string_char_at(filename, string_length(filename)) == "/" && file_exists(working_directory+filename+"index.html")) {
			filename = filename+"index.html";
		} else {
			http_send_error(socket, 404, filename);
			exit;
		}
		
	}
	
	// if the file is on the forbidden list, send a 403.
	if (array_find(forbidden_files, filename) != -1) {
		http_send_error(socket, 403, filename);
		exit
	}
	
	var buf = buffer_load(working_directory+filename);
	
	http_send_packet(socket, 200, [
		"Content-Type:" + content_type(filename)
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
}
