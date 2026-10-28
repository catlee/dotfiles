import importlib.util
import json
from pathlib import Path
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
        with patch.object(agent, "call", side_effect=lambda *a, **kw: next(responses)) as call, \
             patch.object(agent, "attached_window", return_value="0xab"), \
             patch.object(agent, "focus_workspace", return_value=True), \
             patch.object(agent.subprocess, "Popen") as popen:
            agent.launch(["--pick", "--prompt", "hello world"])
        self.assertEqual(call.call_count, 3)
        run_args = call.call_args_list[2].args[0]
        self.assertEqual(run_args[:3], ["herdr", "pane", "run"])
        self.assertIn("'hello world'", run_args[4])
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

    def test_missing_hyprctl_and_herdr_focus_commands_fail_closed(self):
        with patch.object(agent, "call", side_effect=FileNotFoundError):
            self.assertIsNone(agent.attached_window())
            self.assertFalse(agent.focus_workspace("w1", "0xab"))

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


if __name__ == "__main__":
    unittest.main()
