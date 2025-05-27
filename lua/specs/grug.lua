---@diagnostic disable: missing-fields
local M = {}

---@type LazyPluginSpec
M.spec = {
    "MagicDuck/grug-far.nvim",
    ---@type GrugFarOptions
    ---@diagnostic disable-next-line: missing-fields
    opts = {
        windowCreationCommand = "topleft vsplit",
        engines = {
            ripgrep = {
                placeholders = {
                    search = "ex: foo    foo([a-z0-9]*)    fun\\(",
                    replacement = "ex: bar    ${1}_foo    $$MY_ENV_VAR ",
                    filesFilter = "ex: *.lua     *.{css,js}    **/docs/*.md",
                    flags = "ex: --help, Ignore Case (-i), Match Whole World (-w), --replace= (empty replace) --multiline (-U)",
                    paths = "ex: /foo/bar   ../   ./hello\\ world/   ./src/foo.lua",
                },
            },
        },

        openTargetWindow = {
            preferredLocation = "right",
        },

        keymaps = {
            replace = { n = "<localleader>r" },
            qflist = { n = "<localleader>q" },
            syncLocations = { n = "<localleader>a" },
            syncLine = { n = "<localleader>l" },
            close = { n = "<localleader>c" },
            historyOpen = { n = "<localleader>h" },
            historyAdd = { n = "<localleader>H" },
            refresh = { n = "<localleader>R" },
            openLocation = { n = "<localleader>o" },
            openNextLocation = { n = "<down>" },
            openPrevLocation = { n = "<up>" },
            gotoLocation = { n = "<enter>" },
            pickHistoryEntry = { n = "<enter>" },
            abort = { n = "<localleader>b" },
            help = { n = "g?" },
            toggleShowCommand = { n = "<localleader>p" },
            swapEngine = { n = "<localleader>e" },
            previewLocation = { n = "<localleader>i" },
            swapReplacementInterpreter = { n = "<localleader>x" },
        },
    },
    keys = {
        {
            "<leader>dr",
            mode = { "n", "x" },
            function()
                require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
            end,
            desc = "[F]ind",
        },
        {
            "<leader>wf",
            mode = { "n", "x" },
            function()
                require("grug-far").open()
            end,
            desc = "[F]ind",
        },
    },
}

return M.spec
