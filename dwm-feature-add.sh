#!/bin/sh

PATCHES_URL="https://dwm.suckless.org/patches/$1/"

log() {
	echo "$@" 1>&2
}

exit_on_fail() {
	_exit_code="$?"
	[ "$_exit_code" -eq 0 ] && return 0
	[ -n "$2" ] && _exit_code="$2"

	[ -n "$3" ] && _error_handler="$3"
	if [ -n "$3" ]; then
		_error_handler="$3"
		[ "$("$_error_handler" "$_exit_code")" -eq 0 ] && return 0
	fi

	_exit_msg="$1"
	[ -n "$_exit_msg" ] && log "$_exit_msg"
	log "Exiting."
	exit "$_exit_code"
}

check_git() {
	git status 1>&2 > /dev/null
	exit_on_fail "Not in a git repository."

	git status | grep -q "Changes not staged for commit:"
	[ ! "$?" ]
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
	_n_lines=$(echo "$_patches_list" | wc -l)
	log ""
	log "Found $_n_lines patches:"
	log "$_patches_list" | awk '{print NR ": " $1 }'
	log ""
	read -p "selection[1..$_n_lines]: " _selection
	echo "$(echo "$_patches_list" | head -"$_selection" | tail -1)"
}

download_patch() {
	_patch_url="$PATCHES_URL/$1"
	echo "$(curl "$_patch_url")"
}

get_base_revision() {
	echo "$1" | sed 's/.diff$//' | rev | cut -d '-' -f1 | rev
}

get_feature_branch_name() {
	echo "$1" | sed 's/^dwm-*//' | sed 's/.diff$//'
}

checkout_handler() {
	if [ "$1" -eq 128 ]; then
		[ -z "$2" ] && return 128
		_branch_name="$2"

		read -p "delete existing branch $_branch_name? [n] " _delete
		if [ "$_delete" = "y" ] && [ "$_delete" = "Y" ]; then
			log "Not deleting $_branch_name"
			return 128
		else
			git branch -D "$_branch_name"
			git checkout -b "$_branch_name"
			return 0
		fi
	fi
}

check_git

log "Downloading patch list from $PATCHES_URL:"
patch_name=$(select_patch "$(get_patch_list)")

log "Downloading patch"
patch=$(download_patch "$patch_name")
revision=$(get_base_revision "$patch_name")

git checkout "$revision"
exit_on_fail "Could not checkout $revision"

branch_name=$(get_feature_branch_name "$patch_name")

git checkout -b "$branch_name"
exit_on_fail "Could not check out $branch_name" 128 checkout_handler "$branch_name"


echo "$patch" | patch -p1

commit_message=$(printf "Apply patch %s.\n\n%s\n" "$patch_name" "$PATCHES_URL")
git commit -am "$commit_message"
