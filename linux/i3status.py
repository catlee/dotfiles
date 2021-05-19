#!/usr/bin/env python
from i3pystatus import Status

status = Status(standalone=True)

status.register("clock", format="%a %-d %b %X %Z",)
status.register("clock", format=("%X %Z", "US/Pacific"))
status.register("clock", format=("%X %Z", "UTC"))
status.register("clock", format=("%X %Z", "NZ"))
#status.register("weather",
                #format=u"\u263C:{current_temp} hi:{max_temp} lo:{min_temp}",
                #location_code="CAXX0333:1:CA")

# Shows the average load of the last minute and the last 5 minutes
# (the default value for format is used)
status.register("load", format="Load: {avg1} {avg5}")

# Shows your CPU temperature, if you have a Intel CPU
status.register("temp", format="CPU TEMP:{temp:.0f}°C",)

# The battery monitor has many formatting options, see README for details

# This would look like this, when discharging (or charging)
# ↓14.22W 56.15% [77.81%] 2h:41m
# And like this if full:
# =14.22W 100.0% [91.21%]
#
# This would also display a desktop notification (via D-Bus) if the percentage
# goes below 5 percent while discharging. The block will also color RED.
# If you don't have a desktop notification demon yet, take a look at dunst:
#   http://www.knopwob.org/dunst/
status.register(
    "battery",
    format=("{status}/{consumption:.2f}W {percentage:.2f}% "
            "[{percentage_design:.2f}%] {remaining:%E%hh:%Mm}"),
    alert=True,
    alert_percentage=5,
    status={
        "DIS": "↓",
        "CHR": "↑",
        "FULL": "=",
    },)

# Displays whether a DHCP client is running
status.register(
    "runwatch",
    name="DHCP",
    path="/var/run/dhclient*.pid",)

# Shows the address and up/down state of eth0. If it is up the address is shown
# in green (the default value of color_up) and the CIDR-address is shown
# (i.e. 10.10.10.42/24).
# If it's down just the interface name (eth0) will be displayed in red
# (defaults of format_down and color_down)
#
# Note: the network module requires PyPI package netifaces
status.register(
    "network",
    interface="eth0",
    format_up="{v4cidr}",)

# Note: requires both netifaces and basiciw (for essid and quality)
status.register(
    "network",
    interface="wlan0",
    format_up="{essid} {quality:03.0f}%",)

# Shows disk usage of /
# Format:
# 42/128G [86G]
status.register(
    "disk",
    path="/",
    format="{used}/{total}G [{avail}G]",)

# Shows pulseaudio default sink volume
#
# Note: requires libpulseaudio from PyPI
status.register(
    "pulseaudio",
    format="♪{volume}",)

status.run()
