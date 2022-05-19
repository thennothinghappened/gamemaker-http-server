function String(val) constructor {
	
	self.val = val;
	
	if instanceof(val) == "String" self.val = val.val;
	if !(is_string(self.val))
		self.val = string(self.val);
	
	static first_pos = function(substr) {
		substr = make_String(substr);
		return string_pos(substr.val, self.val)-1;
	}
	
	static last_pos = function(substr) {
		substr = make_String(substr);
		return string_last_pos(substr.val, self.val)-1;
	}
	
	static char_at = function(pos) {
		return string_char_at(self.val, pos+1);
	}
	
	static length = function() {
		return string_length(self.val)-1;
	}
	
	static substring = function(index, count=-1) {
		if count == -1 return string_copy(self.val, index+1, length()-index+1);
		return new String(string_copy(self.val, index+1, count));
	}
	
	static starts_with = function(substr) {
		substr = make_String(substr);
		return (substring(0, substr.length()+1).val == substr.val);
	}
	
	static parse_int = function() {
		if string_digits(self.val) != self.val throw self.val+" not an integer!";
		return int64(self.val);
	}
	
	static make_String = function(variable) {
		if (instanceof(variable) != "String") variable = new String(variable);
		return variable;
	}
	
	static slice = function(slicer) {
		
		slicer = make_String(slicer);
		
		var arr = [];
		var temp_str = new String(self);
		
		if (first_pos(slicer) == -1)
			return [self];
		
		while (temp_str.first_pos(slicer) != -1) {
			
			var pos = temp_str.first_pos(slicer);
			array_push(arr, temp_str.substring(0, pos));
			temp_str.val = temp_str.substring(pos+1);
			
		}
		
		array_push(arr, temp_str);
		
		return arr;
	}
}