#!/bin/sh

patches_url="https://dwm.suckless.org/patches/$1/"

[ -n "$DWM_GIT_DIR" ] && cd $DWM_GIT_DIR

git checkout master > /dev/null
[ $? -ne 0 ] && exit $?

git status | grep "Changes not staged for commit:" > /dev/null
[ $? -eq 0 ] && echo "Unstaged changes exist. Exiting." && exit $?

echo "Downloading patch list from $patches_url:"
patches_html=$(curl "$patches_url")
exit_code=$?
[ "$exit_code" -ne 0 ] && echo "Download error. Exiting." && exit "$exit_code"

patches_list=$(echo "$patches_html" | pup 'div#main li > a attr{href}')
[ -z "$patches_list" ] && echo "No patches found at $patches_url" && exit 1

# determine which patch is wanted
n_lines=$(echo "$patches_list" | wc -l)
echo ""
echo "Found $n_lines patches:"
echo "$patches_list" | awk '{print NR ": " $1 }'
echo ""
read -p "selection[1..$n_lines]: " selection
selected_patch=$(echo "$patches_list" | head -$selection | tail -1)

# download patch
patch_url="$patches_url/$selected_patch"
echo "Downloading $patch_url"
patch=$(curl "$patch_url")

revision=$(echo "$selected_patch" | sed 's/.diff$//' | rev | cut -d '-' -f1 | rev)
branch_name=$(echo "$selected_patch" | sed 's/^dwm-*//' | sed 's/.diff$//')

git checkout "$revision" 2> /dev/null
[ $? -ne 0 ] && exit $?

git checkout -b "$branch_name" > /dev/null
if [ $? -eq 128 ]; then
	read -p "delete existing branch $branch_name? [n] " delete
	[ "$delete" != "y" ] && [ "$delete" != "Y" ] && echo "Exiting." && exit 1
fi

git branch -D "$branch_name"
git checkout -b "$branch_name"

echo "$patch" | patch -p1

commit_message=$(printf "Apply patch %s.\n\n%s\n" $selected_patch $patches_url)
git commit -am "$commit_message"
