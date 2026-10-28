#!/usr/bin/env python3
"""Start an agent in Herdr, reusing a uniquely identifiable local client."""

import json
import os
import re
import shlex
import subprocess
import sys


def call(args, *, check=True, capture_output=True):
    return subprocess.run(args, check=check, capture_output=capture_output, text=True, timeout=2)


def config_path(env, cwd=None):
    path = os.path.expanduser(env.get("HERDR_CONFIG_PATH", "~/.config/herdr/config.toml"))
    return os.path.realpath(path if os.path.isabs(path) else os.path.join(cwd or os.getcwd(), path))


def process_info(pid, proc_root):
    base = os.path.join(proc_root, str(pid))
    try:
        exe = os.path.basename(os.readlink(os.path.join(base, "exe")))
        with open(os.path.join(base, "cmdline"), "rb") as stream:
            args = stream.read().split(b"\0")
        args = [arg.decode(errors="replace") for arg in args if arg]
        with open(os.path.join(base, "stat"), encoding="ascii") as stream:
            stat = stream.read()
        ppid = int(stat[stat.rfind(")") + 2 :].split()[1])
        return exe, args, ppid
    except (OSError, ValueError, IndexError):
        return None


def process_config(pid, proc_root):
    base = os.path.join(proc_root, str(pid))
    try:
        cwd = os.readlink(os.path.join(base, "cwd"))
        values = {}
        with open(os.path.join(base, "environ"), "rb") as stream:
            environment = stream.read().split(b"\0")
        for item in environment:
            key, sep, value = item.partition(b"=")
            if sep and key == b"HERDR_CONFIG_PATH":
                values["HERDR_CONFIG_PATH"] = value.decode(errors="replace")
        return config_path(values, cwd)
    except OSError:
        return None


def matching_window(windows, proc_root="/proc", env=None):
    env = os.environ if env is None else env
    expected_config = config_path(env)
    matches = []
    try:
        pids = os.listdir(proc_root)
    except OSError:
        return None

    processes = {}
    for entry in pids:
        if not entry.isdecimal():
            continue
        info = process_info(entry, proc_root)
        if info is None:
            continue
        processes[int(entry)] = info

    clients = []
    for pid, (exe, args, _) in processes.items():
        if exe == "herdr" and len(args) == 1 and os.path.basename(args[0]) == "herdr":
            if process_config(pid, proc_root) == expected_config:
                clients.append(pid)

    for window in windows:
        if not isinstance(window, dict):
            continue
        pid = window.get("pid")
        address = window.get("address")
        if not isinstance(pid, int) or not isinstance(address, str) or not re.fullmatch(r"0x[0-9a-fA-F]+", address):
            continue
        descendants = []
        for client in clients:
            parent = processes[client][2]
            seen = {client}
            while parent in processes and parent not in seen:
                if parent == pid:
                    descendants.append(client)
                    break
                seen.add(parent)
                parent = processes[parent][2]
        if len(descendants) == 1:
            matches.append(address)
    return matches[0] if len(matches) == 1 else None


def attached_window():
    try:
        windows = json.loads(call(["hyprctl", "-j", "clients"]).stdout)
    except (OSError, subprocess.SubprocessError, json.JSONDecodeError):
        return None
    return matching_window(windows) if isinstance(windows, list) else None


def focus_workspace(workspace_id, address):
    try:
        call(["herdr", "workspace", "focus", workspace_id])
        call(["hyprctl", "dispatch", f'hl.dsp.focus({{ window = "address:{address}" }})'])
        active = json.loads(call(["hyprctl", "-j", "activewindow"]).stdout)
        return active.get("address") == address
    except (OSError, subprocess.SubprocessError, json.JSONDecodeError, AttributeError):
        return False


def launch(args):
    cwd = os.getcwd()
    try:
        terminal_cwd = call(["omarchy-cmd-terminal-cwd"]).stdout.strip()
        if terminal_cwd and os.path.isdir(terminal_cwd):
            cwd = terminal_cwd
    except (OSError, subprocess.SubprocessError):
        pass
    if cwd == os.path.expanduser("~") and os.path.isdir(os.path.expanduser("~/Work")):
        cwd = os.path.expanduser("~/Work")

    workspace = json.loads(call(["herdr", "workspace", "create", "--cwd", cwd, "--focus"]).stdout)
    result = workspace.get("result", {})
    workspace_id = result.get("workspace", {}).get("workspace_id")
    pane_id = result.get("root_pane", {}).get("pane_id")
    if not isinstance(workspace_id, str) or not isinstance(pane_id, str):
        raise RuntimeError("Herdr did not return a workspace and root pane")

    shell_command = shlex.join(["/usr/bin/omarchy-agent", "--inline", *args])
    try:
        call(["herdr", "pane", "run", pane_id, shell_command])
    except subprocess.CalledProcessError:
        call(["herdr", "workspace", "close", workspace_id], check=False)
        raise

    address = attached_window()
    if address and focus_workspace(workspace_id, address):
        return
    subprocess.Popen(["omarchy-launch-terminal", "herdr"])


if __name__ == "__main__":
    try:
        launch(sys.argv[1:])
    except (OSError, RuntimeError, subprocess.SubprocessError, json.JSONDecodeError) as error:
        print(f"omarchy-agent: {error}", file=sys.stderr)
        sys.exit(1)
