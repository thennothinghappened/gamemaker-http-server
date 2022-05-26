function make_safe_for_struct(string){
	return (new String(string_replace_all(string_replace_all(string, "-", "_"), "\n", "")).trim(" ")).val;
}