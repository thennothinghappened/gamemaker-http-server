function String(val) constructor {
	
	self.val = val;
	
	if instanceof(val) == "String" self.val = val.val;
	if !(is_string(self.val))
		self.val = string(self.val);
	
	static first_pos = function(substr) {
		substr = self.make_String(substr);
		return string_pos(substr.val, self.val)-1;
	}
	
	static last_pos = function(substr) {
		substr = self.make_String(substr);
		return string_last_pos(substr.val, self.val)-1;
	}
	
	static char_at = function(pos) {
		return new String(string_char_at(self.val, pos+1));
	}
	
	static length = function() {
		return string_length(self.val)-1;
	}
	
	static substring = function(index, count=-1) {
		if count == -1 return new String(string_copy(self.val, index+1, self.length()-index+1));
		return new String(string_copy(self.val, index+1, count));
	}
	
	static starts_with = function(substr) {
		substr = self.make_String(substr);
		return (self.substring(0, substr.length()+1).val == substr.val);
	}
	
	static ends_with = function(substr) {
		substr = make_String(substr);
		return (self.substring(self.length()-substr.length()).val == substr.val);
	}
	
	static parse_int = function() {
		if string_digits(self.val) != self.val throw self.val+" not an integer!";
		return int64(self.val);
	}
	
	static remove = function(index, count=1) {
		return new String(self.substring(0, index-1).val+self.substring(index+count+1).val);
	}
	
	/*static remove_duplicates = function(char) {
		char = make_String(char);
		if (char.length() > 1) throw "Attempted to remove duplicate character of multiple length.";
		
		var found_char = false;
		var temp_str = new String(self);
		
		for (var i = 0; i < temp_str.length(); i ++) {
			if (temp_str.char_at(i).eq(char)) {
				if (found_char) {
					show_message("found char @ " + string(i))
					temp_str.val = temp_str.remove(i).val;
				}
				found_char = true;
			} else found_char = false;
		}
		
		return temp_str;
		
	}*/
	
	// ASSIMILATE >:)
	static make_String = function(variable) {
		return new String(variable);
	}
	
	static eq = function(other_string) {
		return self.val == other_string.val;
	}
	
	static slice = function(slicer) {
		
		slicer = self.make_String(slicer);
		
		var arr = [];
		var temp_str = new String(self);
		
		if (self.first_pos(slicer) == -1)
			return [self];
		
		while (temp_str.first_pos(slicer) != -1) {
			
			var pos = temp_str.first_pos(slicer);
			array_push(arr, temp_str.substring(0, pos));
			temp_str = temp_str.substring(pos+1);
			
		}
		
		array_push(arr, temp_str);
		
		return arr;
	}
	
	static toString = function() {
		return self.val;
	}
}