/// @desc

if (async_load[? "type"] != network_type_data) exit;

// Who we are getting the data from.
var socket = ds_map_find_value(async_load, "id");

// Handle incoming data
var buffer = ds_map_find_value(async_load, "buffer");

try {

// Reject too big requests.
var buffer_size = buffer_get_size(buffer);
if (buffer_size > max_request_bytes) {
	http_send_error(socket, 413, "Request of size " + string(buffer_size) + " is too big. Max request size is " + string(max_request_bytes));
	return;
}

buffer_seek(buffer, buffer_seek_start, 0);
var data = buffer_read(buffer, buffer_string);

show_debug_message("-- Incoming Data ("+async_load[? "ip"]+") --\n\n"+data+"\n-- End Data --");

var pl = new String(data);
var h = pl.slice("\r\n");

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
	
	http_send_error(socket, 501, "The protocol is not implemented", [
		"Allow: " + array_join(accepted_methods, ", ")
	]);
	exit;
}

// Parse other headers
var len = array_length(h);
var hd = {};

for (var i = 1; i < len; i ++) {
	
	var temp_str = new String(h[i]);
	var temp_arr = temp_str.slice(":");
	
	// Check if invalid
	if (array_length(temp_arr) < 2) {
		
		show_debug_message("Skipping invalid header: " + string(temp_arr));
		continue;
	}
	
	var name = make_safe_for_struct(temp_arr[0].to_lower().val);
	array_delete(temp_arr, 0, 1);
	hd[$ name] = array_join_String(temp_arr, ":").trim(" ");
}

// Check that it has a host header
if (!variable_struct_exists(hd, "host")) {
	show_debug_message("Discarding HTTP 1.0 request.\n");
	http_send_error(socket, 400, "Requests lacking a Host header are not accepted.");
	exit;
}

// Check if host is allowed
if (array_find(allowed_hostnames, hd[$ "host"].val) == -1) {
	
	show_debug_message("Discarding request trying to reach from non-listed Host.\n");
	http_send_error(socket, 470, "This Domain is not on the whitelist.");
	exit;
}

// Process GET requests
if (http_method == "GET") {
	
	// Find the directory they want
	
	var dir_begin = h[0].first_pos("/");
	var filename = h[0].substring(dir_begin, h[0].last_pos("HTTP")-dir_begin-1);
	
	//// Don't allow requests with double slashes!
	//if (filename.first_pos("//") != -1) {
	//	http_send_error(socket, 400, "The file path must not contain multiple successive slashes!");
	//	exit;
	//}
	
	// Sanitize the file string
	while (filename.first_pos("//") != -1) {
		filename.val = string_replace_all(filename.val, "//", "/");
	}
	filename.val = string_replace_all(filename.val, "%20", " ");
	
	var url_args = [];
	var args_pos = filename.first_pos("?");
	
	if (args_pos != -1) {
		
		// We have URL params
		var args_string = new String(filename.substring(args_pos+1));
		url_args = args_string.slice("&");
		filename = filename.substring(0, args_pos);
	}
	
	if (directory_exists(working_directory+filename.val)) {
		
			filename.val += "/";
			filename.val = string_replace_all(filename.val, "//", "/");
			if (file_exists(working_directory+filename.val+"index.html")) {
				filename.val += "index.html";
			}
			else if use_directory_viewer {
				// Directory viewer!
				var dir_arr = [];
				if (filename.length()>1) dir_arr[0] = "../";
				var f = file_find_first(working_directory+filename.val+"/*", 0);
			
				while (f != "") {
					if !(array_find(forbidden_files, filename.val+f) != -1) array_push(dir_arr, f);
					f = file_find_next();
				}
			
				var dir_arr_len = array_length(dir_arr);
				var dir_list = "";
			
				for (var i = 0; i < dir_arr_len; i ++) {
					dir_list += "<li><a href=\"./"+dir_arr[i]+"\">"+dir_arr[i]+"</a></li>";
				}
			
				http_send_packet(socket, 200, [
					"Content-Type: text/html; charset=utf-8"
				], html_template("Directory Listing for "+filename.val, "<h1>Directory listing for "+filename.val+"</h1><hr><ul>"+dir_list+"</ul><hr>", unformatted_page_css));
			
				exit;
			} else {
				http_send_error(socket, 404, filename.val);
				exit;
			}
		
	} else if !(file_exists(working_directory+filename.val)) {
		http_send_error(socket, 404, filename.val);
		exit;
	}
	
	// if the file is on the forbidden list, send a 403.
	if (array_find(forbidden_files, filename.val) != -1) {
		http_send_error(socket, 403, filename.val);
		exit
	}
	
	var buf = buffer_load(working_directory+filename.val);
	//if buf == -1
	
	http_send_packet(socket, 200, [
		"Content-Type:" + content_type(filename.val)
	], buf);
	
	buffer_delete(buf);
	
}

else if (http_method == "POST") {
	// this doesn't seem to work, not sure why atm.
	http_send_packet(socket, 200, [
		"Content-Type: application/json"
	], json_stringify({response: "Request received. No further processing."}));
}


} catch(e) {
	
	// show the end user a GML error :P
	http_send_error(socket, 500, "Server Error:\n\n===\n"+e.longMessage+"===\n\nPlease report this error to the server admin or https://github.com/thennothinghappened/gamemaker-http-server");
	show_debug_message("=== ERROR ===\n"+e.longMessage+"\n=== END ERROR ===");
}
