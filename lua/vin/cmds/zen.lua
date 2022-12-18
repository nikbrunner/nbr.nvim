local status_ok, zen_mode = pcall(require, "zen-mode")
if not status_ok then
    return
end

vin.cmds.zen = {}

vin.cmds.zen.toggle_full_screen = function()
    -- Default without opts is full screen
    zen_mode.toggle({
        window = {
            width = 0.5,
        },
    })
end

-- This would be cool, but the backdrop doesnt get transparent
vin.cmds.zen.toggle_small_screen = function()
    -- Default without opts is full screen
    zen_mode.toggle({
        window = {
            backdrop = 0.65,
            width = 0.75,
            height = 0.75,
        },
    })
end
