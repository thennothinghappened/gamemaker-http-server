// have to put "s(status)" because gamemaker no likey
global.statuses = {
	"s200": "200 OK",
		
	"s400": "400 Bad Request",
	"s403": "403 Forbidden",
	"s404": "404 Not Found",
	"s405": "405 Method Not Allowed",
	"s413": "413 Payload Too Large",
	"s429": "429 Too Many Requests",
	"s431": "431 Request Header Fields Too Large",
	"s470": "470 Domain Not Whitelisted", // I made this one up :P
		
	"s500": "500 Internal Server Error",
	"s501": "501 Not Implemented",
	"s508": "508 Loop Detected"
};

function http_create_packet(status, headers, body) {
	
	var body_is_raw = !is_string(body);
	var b;
	
	if !body_is_raw {
		var payload = "HTTP/1.1 " + get_status_name(status) + "\r\n" + array_join(headers, "\r\n") + "\r\nContent-Length: " + string(string_length(body));
		payload += "\r\n\r\n"+body;
	
		b = buffer_create(string_byte_length(payload)+1, buffer_fixed, 1);
		buffer_write(b, buffer_text, payload);
	} else {
		
		var payload = "HTTP/1.1 " + get_status_name(status) + "\r\n" + array_join(headers, "\r\n") + "\r\nContent-Length: " + string(buffer_get_size(body))+"\r\n\r\n";
		
		b = buffer_create(string_byte_length(payload)+buffer_get_size(body), buffer_fixed, 1);
		buffer_write(b, buffer_text, payload);
		buffer_copy(body, 0, buffer_get_size(body), b, string_byte_length(payload));
	}
	
	return b;
}

function http_send_packet(socket, status, headers, body) {
	
	// auto apply these epic headers :)
	array_push(headers, "Server: GameMaker HTTP Server "+version);
	array_push(headers, "Connection: Keep-Alive");
	
	var packet = http_create_packet(status, headers, body);
	network_send_raw(socket, packet, buffer_get_size(packet));
	buffer_delete(packet);
}

function http_send_error(socket, status, error="", headers=[]) {
	
	var _h = headers;
	
	if (status != 501) {
		array_push(_h, "Content-Type: text/html; charset=utf-8");
		http_send_packet(socket, status, _h, error == "" ? "" : html_template(get_status_name(status), "<h1>"+get_status_name(status)+(error==""?"":":</h1><pre>"+error+"</pre>"), unformatted_page_css));
	}
	else {
		array_push(_h, "Content-Type: application/json; charset=utf-8");
		http_send_packet(socket, status, _h, json_stringify({"Error":{"Code":501,"Message":error}}));
	}
}

function html_template(title, body, style=false) {
	// Use this for displaying non 200 HTTP codes.
	var s = style == false ? "" : "<style>"+style+"</style>";
	return "<!DOCTYPE html><html><head><title>"+title+"</title>"+s+"</head><body>"+body+"</body></html>";
}

function content_type(filename) {
	
	static types = [
		// Data/Text
		{ext: ["html", "htm"], type: "text/html; charset=utf-8"},
		{ext: ["css"], type: "text/css; charset=utf-8"},
		{ext: ["js"], type: "text/javascript"},
		{ext: ["txt"], type: "text/plain; charset=utf-8"},
		{ext: ["log"], type: "text/plain; charset=utf-8"},
		{ext: ["pdf"], type: "application/pdf"},
		{ext: ["zip"], type: "application/zip"},
		{ext: ["json"], type: "application/json"},
		
		// Images
		{ext: ["png"], type: "image/png"},
		{ext: ["jpeg", "jpg"], type: "image/jpeg"},
		{ext: ["gif"], type: "image/gif"},
		{ext: ["ico"], type: "image/x-icon"},
		
		// Audio/Video
		{ext: ["ogg"], type: "audio/vorbis"},
		{ext: ["mp3"], type: "audio/mpeg"},
		{ext: ["mp4"], type: "video/mp4"},
	];
	static len = array_length(types);
	
	for (var i = 0; i < len; i ++) {
		
		var t = types[i];
		var ext_len = array_length(t.ext);
		for (var o = 0; o < ext_len; o ++) {
			var c_ext = t.ext[o];
			var ext_tester = string_copy(filename, string_length(filename)-string_length(c_ext), string_length(c_ext)+1);
			
			//show_debug_message("Checking extension "+c_ext+": " + ext_tester);
			
			if (ext_tester == "."+c_ext) return t.type;
		}
	}
	
	return "application/octet-stream";
}

function get_status_name(status) {
	return global.statuses[$ "s"+string(status)];
}
