function array_duplicate(src) {
	
	var new_arr = [];
	array_copy(new_arr, 0, src, 0, array_length(src));
	return new_arr;
}