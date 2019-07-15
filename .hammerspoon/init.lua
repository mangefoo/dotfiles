local mouse = require 'hs.mouse'

local hostConfig = {
  C02S60VDG8WL = {
    intellij = 'IntelliJ IDEA'
  }
}

hyper = hs.hotkey.modal.new({}, 'f17')
local hyperModifier = {"cmd", "alt", "shift", "ctrl"}

-- Enter Hyper Mode when F18 (Hyper/Capslock) is pressed
function enterHyperMode()
  hyper.triggered = false
  hyper:enter()
end

-- Leave Hyper Mode when F18 (Hyper/Capslock) is pressed,
-- send ESCAPE if no other keys are pressed.
function exitHyperMode()
  hyper:exit()
  if not hyper.triggered then
    hs.eventtap.keyStroke({}, 'ESCAPE')
  end
end

-- Bind the Hyper key
f18 = hs.hotkey.bind({}, 'F18', enterHyperMode, exitHyperMode)

hyperBindings = {'x', 'c', 'f', 'h', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'r', 'v', 'w', '0', '8', '9', ';'}

for i,key in ipairs(hyperBindings) do
  hyper:bind({}, key, function()
    hs.eventtap.keyStroke({'cmd','alt','shift','ctrl'}, key)
    hyper.triggered = true
  end)
end

hs.window.animationDuration = 0

hs.hotkey.bind(hyperModifier, "w", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end)

hs.hotkey.bind(hyperModifier, "m", function()
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  win:moveToScreen(screen:next())
end)

hs.hotkey.bind(hyperModifier, "r", function()
  hs.reload()
end)

hs.hotkey.bind(hyperModifier, '0', function () hs.application.launchOrFocus("iTerm") end)
hs.hotkey.bind(hyperModifier, 'j', function () hs.application.launchOrFocus("iTerm") end)
hs.hotkey.bind(hyperModifier, '9', function () hs.application.launchOrFocus("Google Chrome") end)
hs.hotkey.bind(hyperModifier, 'k', function () hs.application.launchOrFocus("Google Chrome") end)
hs.hotkey.bind(hyperModifier, ';', function () hs.application.launchOrFocus("Slack") end)
hs.hotkey.bind(hyperModifier, '8', function () launchOrFocusIntelliJ() end)
hs.hotkey.bind(hyperModifier, 'l', function () launchOrFocusIntelliJ() end)

function launchOrFocusIntelliJ()
  local hostname = hs.host.localizedName()
  local intellij = "IntelliJ IDEA CE"
  if (hostConfig[hostname] ~= nil) and (hostConfig[hostname]['intellij'] ~= nil) then
    intellij = hostConfig[hostname]['intellij']
  end

  hs.application.launchOrFocus(intellij)
end

hs.hotkey.bind(hyperModifier, 'h', function()
  hs.osascript.applescript([[
    ignoring application responses
      tell application "System Events" to tell process "Hammerspoon"
        click menu bar item 1 of menu bar 2
      end tell
    end ignoring
  ]])
end)

hs.hotkey.bind(hyperModifier, 'f', function()
  local app = hs.application.frontmostApplication()
  local menuItem = "File"

  if (app:title() == "iTerm2") then
    menuItem = "Shell"
  end

  print(app:title())

  if app:selectMenuItem({menuItem}, true) then
    print("found it")
  else
    print("did not find it")
  end
end)

hs.hotkey.bind(hyperModifier, 'c', function()
  local currentScreen = mouse.getCurrentScreen()
  local currentPos = mouse.getRelativePosition()
  local targetScreen = currentScreen:next()
  local targetPos = { x = targetScreen:frame().w / 2, y = targetScreen:frame().h / 2}

  mouse.setRelativePosition(targetPos, targetScreen)
  mouseHighlight()
end)

hs.hotkey.bind(hyperModifier, 'v', function()
  local currentScreen = mouse.getCurrentScreen()
  local currentPos = mouse.getRelativePosition()
  local targetScreen = currentScreen:next()
  local targetPos = { x = targetScreen:frame().w / 6, y = targetScreen:frame().h / 4}

  mouse.setRelativePosition(targetPos, targetScreen)
  mouseHighlight()
end)

local mouseCircle = nil
local mouseCircleTimer = nil
function mouseHighlight()
  -- Delete an existing highlight if it exists
  if mouseCircle then
    mouseCircle:delete()
    if mouseCircleTimer then
      mouseCircleTimer:stop()
    end
  end
  -- Get the current co-ordinates of the mouse pointer
  mousepoint = hs.mouse.getAbsolutePosition()
  -- Prepare a big red circle around the mouse pointer
  mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x - 20, mousepoint.y - 20, 40, 40))
  mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=0.8})
  mouseCircle:setFill(true)
  mouseCircle:setFillColor({["red"]=1,["blue"]=1,["green"]=0,["alpha"]=0.8})
  mouseCircle:setStrokeWidth(5)
  mouseCircle:bringToFront(true)

  mouseCircle:show()

  -- Set a timer to delete the circle after 3 seconds
  mouseCircleTimer = hs.timer.doAfter(1, function()
                                        mouseCircle:hide(0.2)
                                        hs.timer.doAfter(0.6, function() mouseCircle:delete() end)
  end)
end

local wifiMenu = hs.menubar.new()
function ssidChangedCallback()
    SSID = hs.wifi.currentNetwork()
    if SSID == nil then
        SSID = "Disconnected"
    end

    title = hs.styledtext.new("[" .. SSID .. "]",{font={size=11}})
    wifiMenu:setTitle(title);
end
wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()
ssidChangedCallback()

function pingResult(object, message, seqnum, error)
    if message == "didFinish" then
        avg = tonumber(string.match(object:summary(), '/(%d+.%d+)/'))
        if avg == 0.0 then
            hs.alert.show("No network")
        else
            hs.alert.show("Ping " .. avg .. "ms")
        end
    end
end
hs.hotkey.bind(hyperModifier, "p", function()hs.network.ping.ping("8.8.8.8", 1, 0.01, 1.0, "any", pingResult)end)

hs.hotkey.bind(hyperModifier, "n", function()
  config = hs.network.configuration.open()
  value = config:computerName()
  print(value)
  value = config:contents('.*/Interface/en0/.*IPv4.*', true)
  for key,value in pairs(value) do
    print(key)
    for k, v in pairs(value['Addresses']) do
      hs.alert.show("WiFi IP: " .. v, hs.alert.defaultStyle, hs.window.focusedWindow():screen(), 5) 
    end
  end
end)

hs.hotkey.bind(hyperModifier, "x", function()
    hs.eventtap.leftClick(mouse.getRelativePosition(), 0)
end)

hs.alert.show("Config loaded")

