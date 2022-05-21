function struct_set_if_exists(key, struct, def){
	
	if variable_struct_exists(struct, key) return struct[$ key];
	return def;
}