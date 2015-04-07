#!/bin/sh
bugid=$(xclip -o | tr -d -c '[0-9]')
exec firefox "https://bugzilla.mozilla.org/show_bug.cgi?id=${bugid}"
