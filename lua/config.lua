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
    ---ghostty colors: https://ghostty.org/docs/reference/config
    colorscheme_config_map = {
        ["default"] = {
            wezterm = "nvim_default_dark",
            ghostty = "default.conf",
        },

        ["black-atom-jpn-koyo-yoru"] = {
            wezterm = "Black Atom — JPN ∷ Koyo Yoru",
            ghostty = "black-atom-jpn-koyo-yoru.conf",
        },
        ["black-atom-jpn-koyo-hiru"] = {
            wezterm = "Black Atom — JPN ∷ Koyo Hiru",
            ghostty = "black-atom-jpn-koyo-hiru.conf",
        },

        ["github_dark_default"] = {
            wezterm = "github_dark_default",
            ghostty = "github-dark.conf",
        },

        ["catppuccin-mocha"] = {
            wezterm = "catppuccin-mocha",
            ghostty = "catppuccin-mocha.conf",
        },

        ["tokyonight-night"] = {
            wezterm = "Tokyo Night",
            ghostty = "tokyonight-night.conf",
        },

        ["rose-pine"] = {
            wezterm = "rose-pine",
            ghostty = "rose-pine.conf",
        },

        ["nord"] = {
            wezterm = "nord",
            ghostty = "nord.conf",
        },

        -- Black Atom Stations themes
        ["black-atom-stations-engineering"] = {
            wezterm = "Black Atom — STA ∷ Engineering",
            ghostty = "black-atom-stations-engineering.conf",
        },
        ["black-atom-stations-operations"] = {
            wezterm = "Black Atom — STA ∷ Operations",
            ghostty = "black-atom-stations-operations.conf",
        },
        ["black-atom-stations-medical"] = {
            wezterm = "Black Atom — STA ∷ Medical",
            ghostty = "black-atom-stations-medical.conf",
        },
        ["black-atom-stations-research"] = {
            wezterm = "Black Atom — STA ∷ Research",
            ghostty = "black-atom-stations-research.conf",
        },

        -- Black Atom Terra themes
        ["black-atom-terra-spring-day"] = {
            wezterm = "Black Atom — TER ∷ Spring Day",
            ghostty = "black-atom-terra-spring-day.conf",
        },
        ["black-atom-terra-spring-night"] = {
            wezterm = "Black Atom — TER ∷ Spring Night",
            ghostty = "black-atom-terra-spring-night.conf",
        },
        ["black-atom-terra-summer-day"] = {
            wezterm = "Black Atom — TER ∷ Summer Day",
            ghostty = "black-atom-terra-summer-day.conf",
        },
        ["black-atom-terra-summer-night"] = {
            wezterm = "Black Atom — TER ∷ Summer Night",
            ghostty = "black-atom-terra-summer-night.conf",
        },
        ["black-atom-terra-fall-day"] = {
            wezterm = "Black Atom — TER ∷ Fall Day",
            ghostty = "black-atom-terra-fall-day.conf",
        },
        ["black-atom-terra-fall-night"] = {
            wezterm = "Black Atom — TER ∷ Fall Night",
            ghostty = "black-atom-terra-fall-night.conf",
        },
        ["black-atom-terra-winter-day"] = {
            wezterm = "Black Atom — TER ∷ Winter Day",
            ghostty = "black-atom-terra-winter-day.conf",
        },
        ["black-atom-terra-winter-night"] = {
            wezterm = "Black Atom - Terra Winter Night",
            ghostty = "black-atom-terra-winter-night.conf",
        },

        -- Black Atom North themes
        ["black-atom-north-night"] = {
            wezterm = "Black Atom — NORTH ∷ Night",
            ghostty = "black-atom-north-night.conf",
        },
        ["black-atom-north-dark-night"] = {
            wezterm = "Black Atom — NORTH ∷ Dark Night",
            ghostty = "black-atom-north-dark-night.conf",
        },
        ["black-atom-north-day"] = {
            wezterm = "Black Atom — NORTH ∷ Day",
            ghostty = "black-atom-north-day.conf",
        },

        -- Black Atom JPN themes
        ["black-atom-jpn-tsuki-yoru"] = {
            wezterm = "Black Atom — JPN ∷ Tsuki Yoru",
            ghostty = "black-atom-jpn-tsuki-yoru.conf",
        },
        ["black-atom-jpn-murasaki-yoru"] = {
            wezterm = "Black Atom — JPN ∷ Murasaki Yoru",
            ghostty = "black-atom-jpn-murasaki-yoru.conf",
        },

        -- Black Atom Minimal themes
        ["black-atom-mnml-mono-dark"] = {
            wezterm = "Black Atom — MNM ∷ Mono Dark",
            ghostty = "black-atom-mnml-mono-dark.conf",
        },
        ["black-atom-mnml-mono-light"] = {
            wezterm = "Black Atom — MNM ∷ Mono Light",
            ghostty = "black-atom-mnml-mono-light.conf",
        },
        ["black-atom-mnml-orange-dark"] = {
            wezterm = "Black Atom — MNM ∷ Orange Dark",
            ghostty = "black-atom-mnml-orange-dark.conf",
        },
        ["black-atom-mnml-orange-light"] = {
            wezterm = "Black Atom — MNM ∷ Orange Light",
            ghostty = "black-atom-mnml-orange-light.conf",
        },
        ["black-atom-mnml-blue-dark"] = {
            wezterm = "Black Atom — MNM ∷ Blue Dark",
            ghostty = "black-atom-mnml-blue-dark.conf",
        },
        ["black-atom-mnml-blue-light"] = {
            wezterm = "Black Atom — MNM ∷ Blue Light",
            ghostty = "black-atom-mnml-blue-light.conf",
        },

        ["github_dark_dimmed"] = { wezterm = "github_dark_dimmed" },
        ["github_light_default"] = { wezterm = "Google Light (Gogh)" },

        ["catppuccin"] = { wezterm = "catppuccin" },
        ["catppuccin-frappe"] = { wezterm = "catppuccin-frappe" },
        ["catppuccin-macchiato"] = { wezterm = "catppuccin-macchiato" },
        ["catppuccin-latte"] = { wezterm = "catppuccin-latte" },

        ["tokyonight-moon"] = { wezterm = "Tokyo Night Moon" },
        ["tokyonight-day"] = { wezterm = "Tokyo Night Day" },
        ["tokyonight-storm"] = { wezterm = "Tokyo Night Storm" },

        ["rose-pine-main"] = { wezterm = "rose-pine" },
        ["rose-pine-moon"] = { wezterm = "rose-pine-moon" },
        ["rose-pine-dawn"] = { wezterm = "rose-pine-dawn" },

        ["kanso-zen"] = { wezterm = "kanso-zen" },
        ["kanso-ink"] = { wezterm = "kanso-ink" },
    },
    open_previous_files_on_startup = false,
    open_neotree_on_startup = false,
    pathes = {
        repos = vim.fn.expand("~/repos"),
        config = {
            nvim = vim.fn.expand("$XDG_CONFIG_HOME") .. "/nvim/lua/config.lua",
            wezterm = vim.fn.expand("$XDG_CONFIG_HOME") .. "/wezterm",
            ghostty = vim.fn.expand("$XDG_CONFIG_HOME") .. "/ghostty",
        },
        notes = {
            personal = vim.fn.expand("~/repos") .. "/nikbrunner/notes",
            the_black_atom = vim.fn.expand("~/repos") .. "/nikbrunner/the-black-atom",
            work = {
                dcd = vim.fn.expand("~/repos") .. "/nikbrunner/dcd-notes",
            },
        },
    },
}

return M.config
