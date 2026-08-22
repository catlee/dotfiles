-- Keep the Show Me The Key overlay visible at the bottom of the screen.
o.window({
  class = "^one\\.alynx\\.showmethekey$",
  title = "^Floating Window - Show Me The Key$",
}, {
  float = true,
  pin = true,
  no_initial_focus = true,
  no_dim = true,
  move = { "(monitor_w-window_w)/2", "monitor_h-window_h-40" },
})
