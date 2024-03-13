
function lovr.conf(t)

  t.headset.drivers = { 'desktop' }
  --t.window.width = 1120 -- The window height (number)
  --t.window.height = 630 -- The window height (number),
  t.window.width = 1920 -- The window height (number)
  t.window.height = 1080 -- The window height (number),
  --16 by 9
  t.modules.headset = false
  t.graphics.stencil = true
  --t.graphics.debug = true -- This breaks it

  -- additional window parameters , not useful for now till i get window module fixed 
  t.window.fullscreentype = "desktop"	-- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
  t.window.x = 0			-- The x-coordinate of the window's position  in the specified display (number)
  t.window.y = 0			-- The y-coordinate of the window's position in the specified display (number)
  t.window.minwidth = 711			-- Minimum window width if the window is resizable (number)
  t.window.minheight = 400			-- Minimum window height if the window is resizable (number)
  --t.window.display = 2			-- Index of the monitor to show the window in (number)
 -- t.window.centered = true		-- Align window on the center of the monitor (boolean)
  t.window.topmost = true		-- Show window on top (boolean)
  t.window.borderless = false		-- Remove all border visuals from the window (boolean)
  t.window.resizable = true		-- Let the window be user-resizable (boolean)
  t.window.opacity = 1			-- Window opacity value (number)
  
  conf = t.window
end
