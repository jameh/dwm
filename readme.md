# dwm

This is my build of dwm.

There is a `master` branch which is kept up-to-date with [upstream](git://git.suckless.org/dwm), separate feature branches off of `master` for each user-contributed patch I use, a `master-patched` branch which contains only merge commits on top of `master`, and finally my `custom` branch which is based on `master-patched`, with additional personal commits.

## patches

* [attachbottom][1]
  * adds newly spawned windows to bottom right
* [centeredmaster][2]
  * adds 2 extra layouts
* fsignal-named (based on [fsignal][3]
  * adds named signals for external programs to control dwm
* [fullgaps][4]
  * adds gaps
* [hide vacant tags][5]
  * hides tags in bar when no windows are in them
* [scratchpad][6]
  * adds a scratchpad (dropdown) terminal
* [systray][7]
  * adds a system tray to the bar
* [xrdb][8]
  * colours the bar with Xresources

[1]: https://dwm.suckless.org/patches/attachbottom/
[2]: https://dwm.suckless.org/patches/centeredmaster/
[3]: https://dwm.suckless.org/patches/fsignal/
[4]: https://dwm.suckless.org/patches/fullgaps/
[5]: https://dwm.suckless.org/patches/hide_vacant_tags/
[6]: https://dwm.suckless.org/patches/scratchpad/
[7]: https://dwm.suckless.org/patches/systray/
[8]: https://dwm.suckless.org/patches/xrdb/
