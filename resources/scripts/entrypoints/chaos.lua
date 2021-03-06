-- this entrypoint is a mess, which is used mostly for concepts test purposes

package.path = package.path .. ';' .. getResourcePath('scripts/?.lua') ..
                               ';' .. getResourcePath('behaviors/trees/?.lua') ..
                               ";" .. getResourcePath('behaviors/?.lua') .. ";"

require 'math'
require 'helpers.base'
require 'lib.behaviors'
require 'actions'
require 'factories.camera'
require 'factories.emitters'
require 'imgui.gizmo'
require 'imgui.console'
require 'imgui.stats'

local event = require 'lib.event'
local eal = require 'lib.eal.manager'
local async = require "lib.async"

imguiConsole = Console()

function context()
  return rocket.contexts["main"]
end

function startup()
  if rocket == nil then
    return
  end

  local fonts =
  {
    "Delicious-Roman.otf",
    "Delicious-BoldItalic.otf",
    "Delicious-Bold.otf",
    "Delicious-Italic.otf",
    "lucida.ttf"
  }
  for _, font in pairs(fonts) do
    resource.loadFont(font)
  end

  main = resource.loadDocument(context(), "minimal.rml")
  console = resource.loadDocument(context(), "console_document.rml")
  healthbar = resource.loadDocument(context(), "healthbar.rml")

  cursor = resource.loadCursor(context(), "cursor.rml")

  main:Show()
  healthbar:Show()
  main:AddEventListener('keydown', onKeyEvent, true)

  console:AddEventListener('keydown', onKeyEvent, true)
end

function setOrbitalCam(id, cameraID)
  camera:createAndAttach('orbit', 'orbo', {target='sinbad', cameraOffset=Vector3.new(0, 4, 0), distance=20, policy=EntityFactory.REUSE})
end

function spawnMore(count)
  for i=1, count do
    spawn()
  end
end

function spawn()
  data:createEntity(getResourcePath('characters/ninja.json'), {movement = {speed = 10}})
end

function onKeyEvent(event)
  if context() == nil then
    return
  end

  if event.parameters['key_identifier'] == rocket.key_identifier.F9 then
    if console_visible then
      console:Hide()
      main:Focus()
    else
      console:Show(DocumentFocus.NONE)
    end
    console_visible = not console_visible
  end
end

local selectTransform = false

function handleKeyEvent(e)
  if e.type == KeyboardEvent.KEY_UP then
    selectTransform = false
    return
  end

  if e.key == Keys.KC_T and e.type == KeyboardEvent.KEY_DOWN then
    selectTransform = true
  end
end

event:onKeyboard(core, KeyboardEvent.KEY_DOWN, handleKeyEvent)
event:onKeyboard(core, KeyboardEvent.KEY_UP, handleKeyEvent)

local gizmo = Gizmo()

function onSelect(e)
  local target = eal:getEntity(e.entity)

  if selectTransform then
    gizmo:setTarget(target)
    return
  end

  if e:hasFlags(OgreSceneNode.DYNAMIC) then
    if actions.attackable(player, target) then
      player.script.state.target = target
    end
  elseif e:hasFlags(OgreSceneNode.STATIC) then
    player.script.state.target = nil
    if player.movement == nil or player.render == nil then
      return
    end
    player.movement:go(e.intersection)
  end
end

function onRoll(e)
  if e.type == OgreSelectEvent.ROLL_OVER then
    local target = eal:getEntity(e.entity)
    if e:hasFlags(OgreSceneNode.DYNAMIC) then
      cursor:GetElementById("cursorIcon"):SetClass("attack", actions.attackable(player, target))
    end
  else
    cursor:GetElementById("cursorIcon"):SetClass("attack", false)
  end
end

local initialized = false

function onReady(e)
  if initialized then
    return
  end

  initialized = true
  player = eal:getEntity("sinbad")
  core:movement():setControlledEntity(player.id)

  event:onOgreSelect(core, SelectEvent.OBJECT_SELECTED, onSelect)
  if rocket ~= nil then
    event:onOgreSelect(core, SelectEvent.ROLL_OVER, onRoll)
    event:onOgreSelect(core, SelectEvent.ROLL_OUT, onRoll)
  end

  spawn()
  spawnMore(10)
end

event:bind(core, Facade.LOAD, onReady)
console_visible = false
startup()
game:loadSave('gameStart')

imguiConsole:setOpen(true)

if imgui then
  imgui.render:addView("gizmo", gizmo)
  imgui.render:addView("console", imguiConsole)
  stats = Stats()
  imgui.render:addView("stats", stats)
end
