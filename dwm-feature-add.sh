#!/bin/sh

PATCHES_URL="https://dwm.suckless.org/patches/$1/"

[ -n "$DWM_GIT_DIR" ] && cd "$DWM_GIT_DIR"

err_log() {
	echo "$@" 1>&2
}

out_log() {
	echo "$@"
}

exit_on_fail() {
	exit_code="$?"
	[ "$exit_code" -eq 0 ] && return 0
	[ -n "$2" ] && exit_code="$2"

	[ -n "$3" ] && error_handler="$3"
	err_log $@
	[ $("$error_handler" "$exit_code") -eq 0 ] && return 0

	exit_msg="$1"
	[ -n "$exit_msg" ] && err_log "$exit_msg"
	err_log "Exiting."
	exit "$exit_code"
}

check_git() {
	git status &> /dev/null
	exit_on_fail "Not in a git repository."

	[ -z "$(git status | grep "Changes not staged for commit:")" ]
	exit_on_fail "Unstaged changes exist."
}

get_patch_list() {

	_patches_html=$(curl "$PATCHES_URL")
	exit_on_fail "Download error."

	_patches_list=$(echo "$_patches_html" | pup 'div#main ul:first-of-type li > a attr{href}')
	[ -n "$_patches_list" ]
	exit_on_fail "No patches found at $PATCHES_URL"

	echo "$_patches_list"
}

select_patch() {
	_patches_list="$1"
	_n_lines=$(echo "$patches_list" | wc -l)
	echo ""
	echo "Found $_n_lines patches:"
	echo "$_patches_list" | awk '{print NR ": " $1 }'
	echo ""
	read -p "selection[1..$_n_lines]: " _selection
	return $(echo "$_patches_list" | head -$_selection | tail -1)
}

download_patch() {
	_patch_url="$PATCHES_URL/$1"
	return $(curl "$_patch_url")
}

get_base_revision() {
	return $(echo "$1" | sed 's/.diff$//' | rev | cut -d '-' -f1 | rev)
}

get_feature_branch_name() {
	return $(echo "$1" | sed 's/^dwm-*//' | sed 's/.diff$//')
}

checkout_handler() {
	if [ $1 -eq 128 ]; then
		[ -z $2 ] && return 128
		_branch_name=$2

		read -p "delete existing branch $_branch_name? [n] " _delete
		if [ "$_delete" = "y" ] && [ "$_delete" = "Y" ]; then
			out_log "Not deleting $_branch_name"
			return 128
		else
			git branch -D "$_branch_name"
			git checkout -b "$_branch_name"
			return 0
		fi
	fi
}

check_git

out_log "Downloading patch list from $PATCHES_URL:"
patch_name=$(select_patch $(get_patch_list))

out_log "Downloading patch"
patch=$(download_patch "$patch_name")
revision=$(get_base_revision "$patch_name")

git checkout "$revision"
exit_on_fail "Could not checkout $revision"

branch_name=$(get_feature_branch_name "$patch_name")

git checkout -b "$branch_name"
exit_on_fail "Could not check out $branch_name" 128 checkout_handler "$branch_name"


echo "$patch" | patch -p1

commit_message=$(printf "Apply patch %s.\n\n%s\n" $patch_name $PATCHES_URL)
git commit -am "$commit_message"
