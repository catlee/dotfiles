#!/bin/sh
set -e
I3=i3-msg

# if external display attached...
$I3 workspace 1 && $I3 move workspace to output DP1
$I3 workspace 2 && $I3 move workspace to output DP1
