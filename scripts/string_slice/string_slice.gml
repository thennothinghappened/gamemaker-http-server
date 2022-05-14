function string_slice(str, slicer){
	
	var temp_str = str;
	var arr = [];
	
	if (string_pos(slicer, temp_str) == 0) {
		
		return [temp_str];
	}
	while (string_pos(slicer, temp_str) != 0) {
		var pos = string_pos(slicer, temp_str);
		array_push(arr, string_copy(temp_str, 1, pos-1));
		temp_str = string_delete(temp_str, pos, 1);
	}
	
	return arr;
}