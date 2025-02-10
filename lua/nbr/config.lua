local M = {}

---@class VinConfig
M.config = {
    colorscheme = "black-atom-crbn-null",
    ---@type "dark" | "light"
    background = "dark",
    ---see for wezterm themes: https://wezfurlong.org/wezterm/colorschemes/index.html
    colorscheme_config_map = {
        ["default"] = { wezterm = "nvim_default_dark" },

        ["terra-spring-night"] = { wezterm = "Black Atom - Terra Spring Night" },
        ["terra-spring-day"] = { wezterm = "Black Atom - Terra Spring Day" },
        ["terra-summer-night"] = { wezterm = "Black Atom - Terra Summer Night" },
        ["terra-summer-day"] = { wezterm = "Google Light (Gogh)" },
        ["terra-fall-night"] = { wezterm = "Black Atom - Terra Fall Night" },
        ["terra-winter-night"] = { wezterm = "Black Atom - Terra Winter Night" },

        ["black-atom-engineering"] = { wezterm = "Black Atom - Engineering" },
        ["black-atom-operations"] = { wezterm = "Black Atom - Operations" },
        ["black-atom-medical"] = { wezterm = "Black Atom - Medical" },
        ["black-atom-research"] = { wezterm = "Black Atom - Research" },
        ["black-atom-jpn-koyo-yoru"] = { wezterm = "Black Atom - JPN - Koyo Yoru" },
        ["black-atom-jpn-koyo-hiru"] = { wezterm = "Black Atom - JPN - Koyo Hiru" },
        ["black-atom-jpn-tsuki-yoru"] = { wezterm = "Black Atom - JPN - Tsuki Yoru" },
        ["black-atom-mono-one-dark"] = { wezterm = "Black Atom - MONO - 1 [DARK]" },
        ["black-atom-crbn-supr"] = { wezterm = "Black Atom - CRBN [SUPR]" },
        ["black-atom-crbn-null"] = { wezterm = "Black Atom - CRBN [NULL]" },

        ["github_dark_default"] = { wezterm = "github_dark_default" },
        ["github_dark_dimmed"] = { wezterm = "github_dark_dimmed" },
        ["github_light_default"] = { wezterm = "Google Light (Gogh)" },

        ["catppuccin"] = { wezterm = "catppuccin" },
        ["catppuccin-mocha"] = { wezterm = "catppuccin-mocha" },
        ["catppuccin-frappe"] = { wezterm = "catppuccin-frappe" },
        ["catppuccin-macchiato"] = { wezterm = "catppuccin-macchiato" },
        ["catppuccin-latte"] = { wezterm = "catppuccin-latte" },

        ["tokyonight-moon"] = { wezterm = "Tokyo Night Moon" },
        ["tokyonight-day"] = { wezterm = "Tokyo Night Day" },
        ["tokyonight-storm"] = { wezterm = "Tokyo Night Storm" },
        ["tokyonight-night"] = { wezterm = "Tokyo Night" },

        ["rose-pine"] = { wezterm = "rose-pine" },
        ["rose-pine-main"] = { wezterm = "rose-pine" },
        ["rose-pine-moon"] = { wezterm = "rose-pine-moon" },
        ["rose-pine-dawn"] = { wezterm = "rose-pine-dawn" },

        ["nord"] = { wezterm = "nord" },
    },
    open_previous_files_on_startup = false,
    open_neotree_on_startup = false,
    pathes = {
        repos = vim.fn.expand("~/repos"),
        config = {
            nbr = vim.fn.expand("$XDG_CONFIG_HOME") .. "/nvim/lua/nbr/config.lua",
            wezterm = vim.fn.expand("$XDG_CONFIG_HOME") .. "/wezterm",
        },
        notes = {
            personal = vim.fn.expand("~/repos") .. "/nikbrunner/notes",
            the_black_atom = vim.fn.expand("~/repos") .. "/nikbrunner/the-black-atom",
            work = {
                dcd = vim.fn.expand("~/repos") .. "/nikbrunner/dcd-notes",
            },
        },
    },
    ensure_installed = {
        -- :h mason-lspconfig-server-map
        servers = {
            "astro",
            "bashls",
            "cssls",
            "gopls",
            "html",
            "jsonls",
            "lua_ls",
            "yamlls",
            "rust_analyzer",
            "vtsls",
        },
        -- :h mason-tool-installer
        tools = {
            "stylua",
            "luacheck",
            "shellcheck",
            "prettierd",
            "black",
            "yamllint",
            "shfmt",
        },
    },
}

return M.config
