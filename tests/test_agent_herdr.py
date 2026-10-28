import importlib.util
import json
import os
from pathlib import Path
import shlex
import subprocess
import tempfile
import unittest
from unittest.mock import patch


MODULE_PATH = Path(__file__).parents[1] / "linux/omarchy/agent-herdr.py"
spec = importlib.util.spec_from_file_location("agent_herdr", MODULE_PATH)
agent = importlib.util.module_from_spec(spec)
spec.loader.exec_module(agent)


def add_process(root, pid, ppid, args, *, exe="herdr", env=b"", cwd="/"):
    base = Path(root, str(pid))
    base.mkdir()
    (base / "exe").symlink_to(f"/usr/bin/{exe}")
    (base / "cwd").symlink_to(cwd)
    (base / "cmdline").write_bytes(b"\0".join(arg.encode() for arg in args) + b"\0")
    (base / "stat").write_text(f"{pid} (process name) S {ppid} 1 1 0 0 0\n")
    (base / "environ").write_bytes(env)


class MatchingWindowTests(unittest.TestCase):
    def test_follows_client_ancestry_and_ignores_server_and_named_session(self):
        with tempfile.TemporaryDirectory() as root:
            add_process(root, 10, 1, ["ghostty"], exe="ghostty")
            add_process(root, 11, 10, ["shell"], exe="bash")
            add_process(root, 12, 11, ["herdr"])
            add_process(root, 13, 10, ["herdr", "server"])
            add_process(root, 14, 10, ["herdr", "--session", "other"])
            self.assertEqual(agent.matching_window([{"pid": 10, "address": "0xabc"}], root, {}), "0xabc")

    def test_rejects_other_config_ambiguous_windows_and_malformed_data(self):
        with tempfile.TemporaryDirectory() as root:
            add_process(root, 20, 1, ["herdr"], env=b"HERDR_CONFIG_PATH=/tmp/other.toml\0")
            windows = [{"pid": 1, "address": "0x1"}, {"pid": 1, "address": "0x2"}, None]
            self.assertIsNone(agent.matching_window(windows, root, {}))
            self.assertIsNone(agent.matching_window([{"pid": 20, "address": "not-an-address"}], root, {}))
        self.assertIsNone(agent.matching_window([], "/proc/missing", {}))

    def test_rejects_multiple_clients_attached_to_one_terminal(self):
        with tempfile.TemporaryDirectory() as root:
            add_process(root, 30, 1, ["terminal"], exe="ghostty")
            add_process(root, 31, 30, ["herdr"])
            add_process(root, 32, 30, ["herdr"])
            self.assertIsNone(agent.matching_window([{"pid": 30, "address": "0xab"}], root, {}))

    def test_rejects_two_windows_for_one_eligible_client(self):
        with tempfile.TemporaryDirectory() as root:
            add_process(root, 40, 1, ["ghostty"], exe="ghostty")
            add_process(root, 41, 40, ["herdr"])
            windows = [{"pid": 40, "address": "0x1"}, {"pid": 40, "address": "0x2"}]
            self.assertIsNone(agent.matching_window(windows, root, {}))


class LaunchTests(unittest.TestCase):
    def prepare(self):
        responses = iter([
            subprocess.CompletedProcess([], 0, "", ""),
            subprocess.CompletedProcess([], 0, json.dumps({"result": {
                "workspace": {"workspace_id": "w1"}, "root_pane": {"pane_id": "w1:p1"}
            }}), ""),
            subprocess.CompletedProcess([], 0, "", ""),
        ])
        return responses

    def test_reuses_client_without_opening_terminal_and_starts_args_once(self):
        responses = self.prepare()
        args = ["--pick", "--prompt", "quote ' \"\n; `touch /tmp/nope` $(touch /tmp/nope)"]
        with patch.object(agent, "call", side_effect=lambda *a, **kw: next(responses)) as call, \
             patch.object(agent, "attached_window", return_value="0xab"), \
             patch.object(agent, "focus_workspace", return_value=True), \
             patch.object(agent.subprocess, "Popen") as popen:
            agent.launch(args)
        self.assertEqual(call.call_count, 3)
        run_args = call.call_args_list[2].args[0]
        self.assertEqual(run_args[:3], ["herdr", "pane", "run"])
        self.assertEqual(
            shlex.split(run_args[4]), ["exec", "/usr/bin/omarchy-agent", "--inline", *args]
        )
        popen.assert_not_called()

    def test_missing_client_opens_terminal_after_one_agent_start(self):
        responses = self.prepare()
        with patch.object(agent, "call", side_effect=lambda *a, **kw: next(responses)) as call, \
             patch.object(agent, "attached_window", return_value=None), \
             patch.object(agent.subprocess, "Popen") as popen:
            agent.launch(["--pick"])
        self.assertEqual(call.call_count, 3)
        popen.assert_called_once_with(["omarchy-launch-terminal", "herdr"])

    def test_failed_focus_falls_back_without_restarting_agent(self):
        responses = self.prepare()
        with patch.object(agent, "call", side_effect=lambda *a, **kw: next(responses)) as call, \
             patch.object(agent, "attached_window", return_value="0xab"), \
             patch.object(agent, "focus_workspace", return_value=False), \
             patch.object(agent.subprocess, "Popen") as popen:
            agent.launch(["--pick"])
        self.assertEqual(call.call_count, 3)
        popen.assert_called_once_with(["omarchy-launch-terminal", "herdr"])

    def test_lua_focus_command_reuses_client_without_terminal_fallback(self):
        def run(args, **kwargs):
            if args == ["omarchy-cmd-terminal-cwd"]:
                return subprocess.CompletedProcess(args, 0, "", "")
            if args[:4] == ["herdr", "workspace", "create", "--cwd"]:
                return subprocess.CompletedProcess(args, 0, json.dumps({"result": {
                    "workspace": {"workspace_id": "w1"}, "root_pane": {"pane_id": "w1:p1"}
                }}), "")
            if args[:3] == ["herdr", "pane", "run"]:
                return subprocess.CompletedProcess(args, 0, "", "")
            if args == ["herdr", "workspace", "focus", "w1"]:
                return subprocess.CompletedProcess(args, 0, "", "")
            if args == ["hyprctl", "dispatch", 'hl.dsp.focus({ window = "address:0xab" })']:
                return subprocess.CompletedProcess(args, 0, "ok", "")
            if args == ["hyprctl", "-j", "activewindow"]:
                return subprocess.CompletedProcess(args, 0, json.dumps({"address": "0xab"}), "")
            self.fail(f"unexpected subprocess argv: {args!r}")

        with patch.object(agent.subprocess, "run", side_effect=run) as run_call, \
             patch.object(agent, "attached_window", return_value="0xab"), \
             patch.object(agent.subprocess, "Popen") as popen:
            agent.launch(["--pick"])

        self.assertIn(
            ["hyprctl", "dispatch", 'hl.dsp.focus({ window = "address:0xab" })'],
            [call.args[0] for call in run_call.call_args_list],
        )
        self.assertIn(["herdr", "workspace", "focus", "w1"], [call.args[0] for call in run_call.call_args_list])
        self.assertIn(["hyprctl", "-j", "activewindow"], [call.args[0] for call in run_call.call_args_list])
        popen.assert_not_called()

    def test_compositor_rejection_falls_back_once(self):
        def run(args, **kwargs):
            if args == ["omarchy-cmd-terminal-cwd"]:
                return subprocess.CompletedProcess(args, 0, "", "")
            if args[:4] == ["herdr", "workspace", "create", "--cwd"]:
                return subprocess.CompletedProcess(args, 0, json.dumps({"result": {
                    "workspace": {"workspace_id": "w1"}, "root_pane": {"pane_id": "w1:p1"}
                }}), "")
            if args[:3] == ["herdr", "pane", "run"] or args == ["herdr", "workspace", "focus", "w1"]:
                return subprocess.CompletedProcess(args, 0, "", "")
            if args[:2] == ["hyprctl", "dispatch"]:
                self.assertTrue(kwargs.get("check"))
                raise subprocess.CalledProcessError(
                    7,
                    args,
                    output='error: [string "return hl.dispatch(focuswindow address:0xab)..."]:1: \')\' expected near \'address\'',
                )
            self.fail(f"unexpected subprocess argv: {args!r}")

        with patch.object(agent.subprocess, "run", side_effect=run) as run_call, \
             patch.object(agent, "attached_window", return_value="0xab"), \
             patch.object(agent.subprocess, "Popen") as popen:
            agent.launch(["--pick"])

        self.assertEqual(
            sum(call.args[0][:2] == ["hyprctl", "dispatch"] for call in run_call.call_args_list), 1
        )
        popen.assert_called_once_with(["omarchy-launch-terminal", "herdr"])

    def test_missing_hyprctl_and_herdr_focus_commands_fail_closed(self):
        with patch.object(agent, "call", side_effect=FileNotFoundError):
            self.assertIsNone(agent.attached_window())
            self.assertFalse(agent.focus_workspace("w1", "0xab"))

    def test_attach_focuses_existing_window_without_workspace_or_agent_mutation(self):
        with patch.object(agent, "attached_window", return_value="0xab"), \
             patch.object(agent, "call", return_value=subprocess.CompletedProcess([], 0, json.dumps({"address": "0xab"}), "")) as call, \
             patch.object(agent.subprocess, "Popen") as popen:
            agent.attach()
        self.assertEqual([c.args[0] for c in call.call_args_list], [
            ["hyprctl", "dispatch", 'hl.dsp.focus({ window = "address:0xab" })'],
            ["hyprctl", "-j", "activewindow"],
        ])
        popen.assert_not_called()

    def test_attach_missing_or_failed_focus_opens_one_terminal_without_mutation(self):
        for address, active in [(None, None), ("0xab", {"address": "0xcd"})]:
            with self.subTest(address=address), \
                 patch.object(agent, "attached_window", return_value=address), \
                 patch.object(agent, "call", return_value=subprocess.CompletedProcess([], 0, json.dumps(active or {}), "")) as call, \
                 patch.object(agent.subprocess, "Popen") as popen:
                agent.attach()
            self.assertEqual(call.call_count, 0 if address is None else 2)
            self.assertTrue(all(c.args[0][0] != "herdr" for c in call.call_args_list))
            popen.assert_called_once_with(["omarchy-launch-terminal", "herdr"])

    def test_attach_mode_requires_exact_argv(self):
        with patch.object(agent, "attach") as attach, patch.object(agent, "launch") as launch:
            agent.main(["--attach"])
            attach.assert_called_once_with()
            launch.assert_not_called()

        with patch.object(agent, "attach") as attach, patch.object(agent, "launch") as launch:
            args = ["--prompt", "--attach"]
            agent.main(args)
            attach.assert_not_called()
            launch.assert_called_once_with(args)

    def test_uncertain_pane_run_timeout_preserves_workspace_and_does_not_fallback(self):
        responses = self.prepare()
        def run(*args, **kwargs):
            command = args[0]
            if command[:3] == ["herdr", "pane", "run"]:
                raise subprocess.TimeoutExpired(command, 2)
            return next(responses)

        with patch.object(agent, "call", side_effect=run) as call, \
             patch.object(agent, "attached_window") as detect, \
             patch.object(agent.subprocess, "Popen") as popen:
            with self.assertRaises(subprocess.TimeoutExpired):
                agent.launch(["--pick"])
        self.assertFalse(any(c.args[0][:3] == ["herdr", "workspace", "close"] for c in call.call_args_list))
        detect.assert_not_called()
        popen.assert_not_called()


class WrapperTests(unittest.TestCase):
    def run_wrapper(self, args):
        temporary = tempfile.TemporaryDirectory()
        root = Path(temporary.name)
        home_bin = root / "home/.local/bin"
        fake_bin = root / "fake-bin"
        home_bin.mkdir(parents=True)
        fake_bin.mkdir()
        agent_log = root / "agent.json"
        terminal_log = root / "terminal.json"
        logger = "#!/usr/bin/env python3\nimport json, os, sys\nwith open(os.environ['AGENT_LOG'], 'w') as f: json.dump(sys.argv[1:], f)\n"
        terminal = "#!/usr/bin/env python3\nimport json, os, sys\nwith open(os.environ['TERMINAL_LOG'], 'w') as f: json.dump(sys.argv[1:], f)\n"
        helper = home_bin / "omarchy-agent-herdr"
        fallback = fake_bin / "omarchy-launch-terminal"
        for path, source in ((helper, logger), (fallback, terminal)):
            path.write_text(source)
            path.chmod(0o755)
        env = os.environ | {
            "HOME": str(root / "home"),
            "PATH": f"{fake_bin}:{os.environ['PATH']}",
            "AGENT_LOG": str(agent_log),
            "TERMINAL_LOG": str(terminal_log),
        }
        result = subprocess.run(
            [str(MODULE_PATH.parent / "agent.sh"), *args], env=env, capture_output=True, text=True, timeout=5
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        received = json.loads(agent_log.read_text())
        terminal_was_launched = terminal_log.exists()
        temporary.cleanup()
        return received, terminal_was_launched

    def test_wrapper_preserves_literal_arguments_without_terminal_fallback(self):
        with tempfile.TemporaryDirectory() as root:
            marker = Path(root) / "should-not-run"
            payload = f"quote ' \"\n; $(touch {marker}) `touch {marker}`"
            received, terminal_was_launched = self.run_wrapper(["--pick", "--prompt", payload])
            self.assertEqual(received, ["--pick", "--prompt", payload])
            self.assertFalse(terminal_was_launched)
            self.assertFalse(marker.exists())

    def test_inline_prompt_value_does_not_activate_inline_mode(self):
        received, terminal_was_launched = self.run_wrapper(["--prompt", "--inline"])
        self.assertEqual(received, ["--prompt", "--inline"])
        self.assertFalse(terminal_was_launched)


if __name__ == "__main__":
    unittest.main()
