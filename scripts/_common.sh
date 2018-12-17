ynh_add_fpm5_config () {
	
	local fpm_config_dir="/etc/php/5.6/fpm"
	local fpm_service="php5.6-fpm"
	# Configure PHP-FPM 5 on Debian Jessie
	if [ "$(ynh_get_debian_release)" == "jessie" ]; then
		fpm_config_dir="/etc/php5/fpm"
		fpm_service="php5-fpm"
	fi
	ynh_app_setting_set $app fpm_config_dir "$fpm_config_dir"
	ynh_app_setting_set $app fpm_service "$fpm_service"
	finalphpconf="$fpm_config_dir/pool.d/$app.conf"
	ynh_backup_if_checksum_is_different "$finalphpconf"
	sudo cp ../conf/php-fpm.conf "$finalphpconf"
	ynh_replace_string "__NAMETOCHANGE__" "$app" "$finalphpconf"
	ynh_replace_string "__FINALPATH__" "$final_path" "$finalphpconf"
	ynh_replace_string "__USER__" "$app" "$finalphpconf"
	sudo chown root: "$finalphpconf"
	ynh_store_file_checksum "$finalphpconf"

	if [ -e "../conf/php-fpm.ini" ]
	then
		echo "Please do not use a separate ini file, merge you directives in the pool file instead." &>2
	fi
	sudo systemctl reload $fpm_service
}

# Remove the dedicated php-fpm config
#
# usage: ynh_remove_fpm5_config
ynh_remove_fpm_config () {
	local fpm_config_dir=$(ynh_app_setting_get $app fpm_config_dir)
	local fpm_service=$(ynh_app_setting_get $app fpm_service)
	
	ynh_secure_remove "$fpm_config_dir/pool.d/$app.conf"
	ynh_secure_remove "$fpm_config_dir/conf.d/20-$app.ini" 2>&1
	sudo systemctl reload $fpm_service
}
