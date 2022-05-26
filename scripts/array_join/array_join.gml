function array_join(arr, sep){
	
	var s = "";
	var len = array_length(arr);
	for (var i = 0; i < len; i ++) {
		s += arr[i];
		if (i < len-1) s += sep;
	}
	
	return s;
}

function array_join_String(arr, sep){
	
	var s = new String();
	var len = array_length(arr);
	for (var i = 0; i < len; i ++) {
		s.val += arr[i].val;
		if (i < len-1) s.val += sep;
	}
	
	return s;
}
