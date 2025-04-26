---@type LazyPluginSpec
return {
    "Goose97/timber.nvim",
    event = "VeryLazy",
    opts = {
        log_templates = {
            default = {
                javascript = [[console.log("DEBUG(%filename%parent_node): %log_target", %log_target)]],
                typescript = [[console.log("DEBUG(%filename%parent_node): %log_target", %log_target)]],
                jsx = [[console.log("DEBUG(%filename%parent_node): %log_target", %log_target)]],
                tsx = [[console.log("DEBUG(%filename%parent_node): %log_target", %log_target)]],
                lua = [[print("DEBUG(%filename%parent_node): %log_target", vim.inspect(%log_target))]],
            },
        },
        batch_log_templates = {
            default = {
                javascript = [[console.log("DEBUG(%filename):", { %repeat<"%log_target": %log_target><, > })]],
                typescript = [[console.log("DEBUG(%filename):", { %repeat<"%log_target": %log_target><, > })]],
                jsx = [[console.log("DEBUG(%filename):", { %repeat<"%log_target": %log_target><, > })]],
                tsx = [[console.log("DEBUG(%filename):", { %repeat<"%log_target": %log_target><, > })]],
                lua = [[print(string.format("DEBUG(%filename): %repeat<%log_target=%s><, >", %repeat<%log_target><, >))]],
            },
        },
        template_placeholders = {
            filename = function()
                return vim.fn.expand("%:t")
            end,
            ---@module "timber"
            ---@param ctx Timber.Actions.Context
            parent_node = function(ctx)
                if not ctx.log_target then
                    return ""
                end

                -- Helper function to check if we're at root level
                local function is_root_level(node)
                    local parent = node:parent()
                    while parent do
                        local type = parent:type()
                        if type == "program" then
                            return true
                        elseif type == "statement_block" then
                            return false
                        end
                        parent = parent:parent()
                    end
                    return true
                end

                -- Extract text from a node
                local function get_node_text(node)
                    local start_row, start_col, _ = node:start()
                    local end_row, end_col, _ = node:end_()
                    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
                    if #lines > 0 then
                        return lines[1]:sub(start_col + 1, end_col)
                    end
                    return nil
                end

                -- Find the closest relevant function-like container
                local function find_closest_container(node)
                    local current = node
                    local containers = {}

                    while current do
                        local type = current:type()

                        if type == "arrow_function" then
                            local parent = current:parent()
                            if parent and parent:type() == "variable_declarator" then
                                for child, _ in parent:iter_children() do
                                    if child:type() == "identifier" then
                                        local name = get_node_text(child)
                                        if name then
                                            table.insert(containers, {
                                                name = name,
                                                is_root = is_root_level(current),
                                            })
                                        end
                                    end
                                end
                            end
                        elseif type == "method_definition" then
                            for child, _ in current:iter_children() do
                                if child:type() == "property_identifier" then
                                    local name = get_node_text(child)
                                    if name then
                                        table.insert(containers, {
                                            name = name,
                                            is_root = is_root_level(current),
                                        })
                                    end
                                end
                            end
                        elseif type == "function_declaration" then
                            for child, _ in current:iter_children() do
                                if child:type() == "identifier" then
                                    local name = get_node_text(child)
                                    if name then
                                        table.insert(containers, {
                                            name = name,
                                            is_root = is_root_level(current),
                                        })
                                    end
                                end
                            end
                        end

                        current = current:parent()
                    end

                    -- If we have no containers, return empty string
                    if #containers == 0 then
                        return ""
                    end

                    -- If we're in a root level function, return that
                    for _, container in ipairs(containers) do
                        if container.is_root then
                            return " | " .. container.name
                        end
                    end

                    -- Otherwise return the innermost (first) container
                    return " | " .. containers[1].name
                end

                return find_closest_container(ctx.log_target)
            end,
        },
        keymaps = {
            insert_log_above = "slk",
            insert_log_below = "slj",
            insert_batch_log = "slb",
            add_log_targets_to_batch = nil,
            insert_log_below_operator = nil,
            insert_log_above_operator = nil,
            insert_batch_log_operator = nil,
            add_log_targets_to_batch_operator = nil,
        },
        default_keymaps_enabled = false,
    },
}
