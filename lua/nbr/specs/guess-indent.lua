return {
    "nmac427/guess-indent.nvim",
    event = "BufRead",
    opts = {},
    config = function(_, opts)
        require("guess-indent").setup(opts)

        vim.api.nvim_create_autocmd("BufWritePost", {
            group = vim.api.nvim_create_augroup("guess_indent", { clear = true }),
            callback = function()
                vim.cmd("silent GuessIndent")
            end,
        })
    end,
}
