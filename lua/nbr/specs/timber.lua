-- TODO: Add file name to log string
---@type LazyPluginSpec
return {
    "Goose97/timber.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {
        log_templates = {
            default = {
                javascript = [[console.log("DEBUG: %log_target", %log_target)]],
                typescript = [[console.log("DEBUG: %log_target", %log_target)]],
                jsx = [[console.log("DEBUG: %log_target", %log_target)]],
                tsx = [[console.log("DEBUG: %log_target", %log_target)]],
                lua = [[print("DEBUG: %log_target", vim.inspect(%log_target))]],
            },
        },
        batch_log_templates = {
            default = {
                javascript = [[console.log("DEBUG:", { %repeat<"%log_target": %log_target><, > })]],
                typescript = [[console.log("DEBUG:", { %repeat<"%log_target": %log_target><, > })]],
                jsx = [[console.log("DEBUG:", { %repeat<"%log_target": %log_target><, > })]],
                tsx = [[console.log("DEBUG:", { %repeat<"%log_target": %log_target><, > })]],
                lua = [[print(string.format("DEBUG: %repeat<%log_target=%s><, >", %repeat<%log_target><, >))]],
            },
        },
        keymaps = {
            insert_log_below = "<leader>sll",
            insert_batch_log = "<leader>slb",
            add_log_targets_to_batch = nil,
            insert_log_below_operator = nil,
            insert_log_above_operator = nil,
            insert_batch_log_operator = nil,
            add_log_targets_to_batch_operator = nil,
        },
        default_keymaps_enabled = false,
    },
}
