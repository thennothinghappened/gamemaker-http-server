function array_join(arr, sep){
	
	var s = "";
	var len = array_length(arr);
	for (var i = 0; i < len; i ++) {
		s += arr[i];
		if (i < len-1) s += sep;
	}
	
	return s;
}