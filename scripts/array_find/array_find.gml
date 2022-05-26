function array_find(arr, element){
	
	var len = array_length(arr);
	for (var i = 0; i < len; i ++) {
		show_debug_message("checking " + element + " against " + arr[i]);
		if arr[i] == element return i;
	}
	return -1;
}