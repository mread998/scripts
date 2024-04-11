#!/bin/bash
for i in "${script_arr[@]}"
do
	./$i
done

# reboot is reqired
echo "---> a reboot is required to enable selinux <---"
