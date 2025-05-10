local M = {}

---@class VinConfig
M.config = {
    ---@type boolean
    dev_mode = false,
    ---@type "dark" | "light"
    background = "dark",
    ---@type string
    colorscheme_light = "black-atom-jpn-koyo-hiru",
    ---@type string
    colorscheme_dark = "black-atom-jpn-koyo-yoru",

    ---see for wezterm themes: https://wezfurlong.org/wezterm/colorschemes/index.html
    colorscheme_config_map = {
        ["default"] = { wezterm = "nvim_default_dark" },

        ["black-atom-stations-engineering"] = { wezterm = "Black Atom — STA ∷ Engineering" },
        ["black-atom-stations-operations"] = { wezterm = "Black Atom — STA ∷ Operations" },
        ["black-atom-stations-medical"] = { wezterm = "Black Atom — STA ∷ Medical" },
        ["black-atom-stations-research"] = { wezterm = "Black Atom — STA ∷ Research" },

        ["black-atom-terra-spring-day"] = { wezterm = "Black Atom — TER ∷ Spring Day" },
        ["black-atom-terra-spring-night"] = { wezterm = "Black Atom — TER ∷ Spring Night" },
        ["black-atom-terra-summer-day"] = { wezterm = "Black Atom — TER ∷ Summer Day" },
        ["black-atom-terra-summer-night"] = { wezterm = "Black Atom — TER ∷ Summer Night" },
        ["black-atom-terra-fall-day"] = { wezterm = "Black Atom — TER ∷ Fall Day" },
        ["black-atom-terra-fall-night"] = { wezterm = "Black Atom — TER ∷ Fall Night" },
        ["black-atom-terra-winter-day"] = { wezterm = "Black Atom — TER ∷ Winter Day" },
        ["black-atom-terra-winter-night"] = { wezterm = "Black Atom - Terra Winter Night" },

        ["black-atom-jpn-koyo-yoru"] = { wezterm = "Black Atom — JPN ∷ Koyo Yoru" },
        ["black-atom-jpn-koyo-hiru"] = { wezterm = "Black Atom — JPN ∷ Koyo Hiru" },
        ["black-atom-jpn-tsuki-yoru"] = { wezterm = "Black Atom — JPN ∷ Tsuki Yoru" },
        ["black-atom-jpn-murasaki-yoru"] = { wezterm = "Black Atom — JPN ∷ Murasaki Yoru" },

        ["black-atom-crbn-supr"] = { wezterm = "Black Atom — CRB ∷ SUPR" },
        ["black-atom-crbn-null"] = { wezterm = "Black Atom — CRB ∷ NULL" },

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

        ["kanso-zen"] = { wezterm = "kanso-zen" },
        ["kanso-ink"] = { wezterm = "kanso-ink" },

        ["nord"] = { wezterm = "nord" },
    },
    open_previous_files_on_startup = false,
    open_neotree_on_startup = false,
    pathes = {
        repos = vim.fn.expand("~/repos"),
        config = {
            nvim = vim.fn.expand("$XDG_CONFIG_HOME") .. "/nvim/lua/config.lua",
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
            "tailwindcss",
            "marksman",
            "vtsls",
            "yamlls",
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
