-- ExpeditionNotifier — publish expedition-complete events to PalEventDrop.
local config = require("config")

local MOD = "[ExpeditionNotifier]"
local VERSION = "1.0.0"
local SOURCE = "ExpeditionNotifier"

local EXPEDITION_LOG =
    "/Game/Pal/Blueprint/UI/Log/WBP_ExpeditionCompleteLog.WBP_ExpeditionCompleteLog_C"

local G = _G.__EXPEDITION_NOTIFIER or {}
_G.__EXPEDITION_NOTIFIER = G
G.hook_registry = G.hook_registry or {}

local enabled = config.enabled == true
local last_emit_key = nil
local last_emit_at = 0

local function log(msg)
    print(MOD .. " " .. msg .. "\n")
end

local function debug_log(msg)
    if config.debug then
        log(msg)
    end
end

local function safe(fn, fallback)
    local ok, result = pcall(fn)
    if ok then return result end
    return fallback
end

local function unwrap(value)
    if value == nil then return nil end
    return safe(function() return value:get() end, nil) or value
end

local function ftext_to_string(value)
    value = unwrap(value)
    if value == nil then return "" end
    if type(value) == "string" then return value end
    return safe(function()
        if value.ToString then
            return value:ToString()
        end
        return tostring(value)
    end, "")
end

local function bus()
    return _G.PalEventDrop
end

local function publish_expedition(message)
    if not enabled then return end

    message = ftext_to_string(message)
    if message == "" then return end

    local dedupe_sec = math.max(1, tonumber(config.dedupe_seconds) or 8)
    local key = message
    local now = os.clock()
    if last_emit_key == key and (now - last_emit_at) < dedupe_sec then
        debug_log("dedupe expedition_complete")
        return
    end
    last_emit_key = key
    last_emit_at = now

    local drop = bus()
    if not drop or type(drop.publish) ~= "function" then
        log("PalEventDrop not loaded — enable PalEventDrop above this mod in mods.txt")
        return
    end

    local id, err = drop.publish({
        source = SOURCE,
        type = "expedition_complete",
        title = "Expedition complete",
        message = message,
    })

    if err then
        log("publish failed: " .. tostring(err))
        return
    end
    debug_log("published " .. tostring(id))
end

local function unregister_all_tracked_hooks()
    for path, ids in pairs(G.hook_registry) do
        pcall(function()
            UnregisterHook(path, ids.pre, ids.post)
        end)
    end
    G.hook_registry = {}
end

unregister_all_tracked_hooks()
G.is_lua_reload = G.loaded_once == true
G.loaded_once = true

local function register_hook(path, label, callback)
    if G.hook_registry[path] then
        return true
    end

    local pre, post
    local ok = safe(function()
        if path:sub(1, 8) == "/Script/" then
            pre, post = RegisterHook(path, function() end, callback)
        else
            pre, post = RegisterHook(path, callback)
        end
        return pre ~= nil or post ~= nil
    end, false)

    if ok then
        G.hook_registry[path] = { pre = pre, post = post }
        debug_log("hooked " .. label)
        return true
    end

    return false
end

local function register_all_hooks()
    return register_hook(
        EXPEDITION_LOG .. ":SetLogText",
        "WBP_ExpeditionCompleteLog.SetLogText",
        function(_context, in_text)
            publish_expedition(in_text)
        end
    )
end

local function retry_hooks(attempt, wait_ms)
    local ms = math.max(1, math.floor((tonumber(wait_ms) or 7000) + 0.5))
    ExecuteInGameThreadWithDelay(ms, function()
        if register_all_hooks() then
            return
        end
        if attempt < 4 then
            retry_hooks(attempt + 1, ms * 2)
        else
            log("hook registration failed")
        end
    end)
end

if not register_all_hooks() then
    retry_hooks(1, 7000)
end

RegisterKeyBind(Key.F8, { ModifierKey.ALT }, function()
    enabled = not enabled
    log("expedition notifications " .. (enabled and "ON" or "OFF"))
end)

log("v" .. VERSION .. " loaded; requires PalEventDrop")
if not bus() then
    log("WARN: PalEventDrop missing — load PalEventDrop first in mods.txt")
else
    log("hook target: WBP_ExpeditionCompleteLog.SetLogText (Alt+F8 toggles publish)")
end
