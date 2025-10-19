vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.wo.wrap = false
vim.wo.colorcolumn = "80"

vim.o.termguicolors = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.cursorline = true
vim.o.mouse = 'a'
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.scrolloff = 10
vim.o.sidescrolloff = 5
vim.o.ruler = false
vim.o.showmode = false
vim.o.showcmd = false
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.updatetime = 500
vim.o.confirm = true

vim.opt.clipboard:append("unnamedplus") -- NOTE: For Windows, make sure Win32yank is installed.
vim.opt.shortmess:append('S')

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        {
            "echasnovski/mini.nvim",
            event = "VeryLazy",
            config = function()
                require("mini.bracketed").setup({
                    window = { suffix = '' },
                })
                vim.keymap.set('n', "]e", function()
                    MiniBracketed.diagnostic("forward", { severity = vim.diagnostic.severity.ERROR })
                end)
                vim.keymap.set('n', "[e", function()
                    MiniBracketed.diagnostic("backward", { severity = vim.diagnostic.severity.ERROR })
                end)
                vim.keymap.set('n', "[E", function()
                    MiniBracketed.diagnostic("first", { severity = vim.diagnostic.severity.ERROR })
                end)
                vim.keymap.set('n', "]E", function()
                    MiniBracketed.diagnostic("last", { severity = vim.diagnostic.severity.ERROR })
                end)
                vim.keymap.set('n', "]w", function()
                    MiniBracketed.diagnostic("forward", { severity = vim.diagnostic.severity.WARN })
                end)
                vim.keymap.set('n', "[w", function()
                    MiniBracketed.diagnostic("backward", { severity = vim.diagnostic.severity.WARN })
                end)
                vim.keymap.set('n', "[W", function()
                    MiniBracketed.diagnostic("first", { severity = vim.diagnostic.severity.WARN })
                end)
                vim.keymap.set('n', "]W", function()
                    MiniBracketed.diagnostic("last", { severity = vim.diagnostic.severity.WARN })
                end)

                require("mini.bufremove").setup()
                vim.keymap.set('n', "<Leader>bd", MiniBufremove.delete, { desc = "Delete" })

                require("mini.clue").setup({
                    triggers = {
                        { mode = 'n', keys = "<Leader>" },
                        { mode = 'v', keys = "<Leader>" },
                        { mode = 'n', keys = '"' },
                    },

                    clues = {
                        require("mini.clue").gen_clues.registers(),

                        { mode = 'n', keys = "<Leader>b", desc = "+Buffer" },
                        { mode = 'n', keys = "<Leader>p", desc = "+Pick" },
                        { mode = 'n', keys = "<Leader>w", desc = "+Window" }
                    },

                    window = {
                        config = {
                            width = "auto"
                        },

                        delay = 500,
                    }
                })

                require("mini.comment").setup({
                    options = {
                        ignore_blank_line = true
                    }
                })

                require("mini.diff").setup({
                    view = {
                        style = "sign",
                        signs = {
                            add = '+',
                            change = '~',
                            delete = '-'
                        }
                    },
                    mappings = {
                        apply = "",
                        reset = "",
                        textobject = ""
                    },
                    options = { wrap_goto = true }
                })
                vim.keymap.set('n', "<Leader>d", MiniDiff.toggle_overlay, { desc = "Diff" })

                require("mini.extra").setup()
                vim.keymap.set('n', "<Leader>pq", function() MiniExtra.pickers.list({ scope = "quickfix" }) end, { desc = "Quickfix" })

                require("mini.files").setup({
                    content = {
                        prefix = function() end
                    }
                })
                vim.keymap.set('n', "<Leader>e", MiniFiles.open, { desc = "Explore" })
                local show_dotfiles = true
                local filter_show = function(fs_entry) return true end
                local filter_hide = function(fs_entry)
                    return not vim.startswith(fs_entry.name, '.')
                end
                local toggle_dotfiles = function()
                    show_dotfiles = not show_dotfiles
                    local new_filter = show_dotfiles and filter_show or filter_hide
                    MiniFiles.refresh({ content = { filter = new_filter } })
                end
                vim.api.nvim_create_autocmd("User", {
                    pattern = "MiniFilesBufferCreate",
                    callback = function(args)
                        local buf_id = args.data.buf_id
                        vim.keymap.set('n', "g.", toggle_dotfiles, { buffer = buf_id })
                    end,
                })

                require("mini.git").setup()

                require("mini.hipatterns").setup({
                    highlighters = {
                        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
                        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
                        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
                        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
                        hex_color = require("mini.hipatterns").gen_highlighter.hex_color()
                    }
                })

                require("mini.notify").setup()

                require("mini.pairs").setup()

                require("mini.pick").setup({
                    mappings = {
                        caret_left = "<C-b>",
                        caret_right = "<C-f>",

                        scroll_down = "<C-d>",
                        scroll_up = "<C-u>"
                    }, -- NOTE: If using Windows Terminal, make sure to change the keybinding for Paste so it doesn't intercept Ctrl-v.

                    options = {
                        use_cache = true
                    },

                    source = {
                        show = require("mini.pick").default_show
                    },

                    window = {
                        config = function()
                            local height = math.floor(0.618 * vim.o.lines)
                            local width = math.floor(0.618 * vim.o.columns)
                            return {
                                anchor = 'NW',
                                height = height,
                                width = width,
                                row = math.floor(0.5 * (vim.o.lines - height)),
                                col = math.floor(0.5 * (vim.o.columns - width))
                            }
                        end
                    }
                })
                vim.keymap.set('n', "<Leader>h", MiniPick.builtin.help, { desc = "Help" })
                vim.keymap.set('n', "<Leader>pb", MiniPick.builtin.buffers, { desc = "Buffers" })
                vim.keymap.set('n', "<Leader>pf", MiniPick.builtin.files, { desc = "Files" })
                vim.keymap.set('n', "<Leader>pg", MiniPick.builtin.grep_live, { desc = "Grep" })
                vim.keymap.set('n', "<Leader>pp", MiniPick.builtin.resume, { desc = "Resume" })

                require("mini.statusline").setup({
                    content = {
                        active = function()
                            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
                            local git           = MiniStatusline.section_git({ trunc_width = 40 })
                            local diff          = MiniStatusline.section_diff({ trunc_width = 75 })
                            local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
                            local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
                            local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
                            local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
                            local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })

                            return MiniStatusline.combine_groups({
                                { hl = mode_hl,                  strings = { mode } },
                                { hl = 'MiniStatuslineDevinfo',  strings = { git, diff, diagnostics, lsp } },
                                '%<',
                                { hl = 'MiniStatuslineFilename', strings = { filename } },
                                '%=',
                                { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
                                { hl = mode_hl,                  strings = { search, "%l|%L" } },
                            })
                        end,
                    },
                    use_icons = false
                })

                require("mini.surround").setup({
                    respect_selection_type = true
                })

                require("mini.trailspace").setup()
                vim.keymap.set('n', "ds", MiniTrailspace.trim)
                vim.keymap.set('n', "dl", MiniTrailspace.trim_last_lines)
            end
        },

        {
            "lervag/vimtex",
            enabled = false,
            lazy = false,
            config = function()
                vim.g.vimtex_compiler_silent = 1
                vim.g.vimtex_complete_enabled = 0
                vim.g.vimtex_imaps_enabled = 0
                vim.g.vimtex_mappings_enabled = 0
                if vim.loop.os_uname().sysname == "Windows_NT" then
                    vim.g.vimtex_view_method = "sioyek"
                else
                    vim.g.vimtex_view_method = "zathura"
                end
            end
        },

        {
            "neovim/nvim-lspconfig",
            event = "VeryLazy",
            dependencies = {
                {
                    "mason-org/mason.nvim",
                    opts = {}
                },

                "mason-org/mason-lspconfig.nvim",
            },
            config = function()
                vim.api.nvim_create_autocmd("LspAttach", {
                    group = vim.api.nvim_create_augroup("LSPKeymapConfig", {}),
                    callback = function(args)
                        vim.b[args.buf].miniclue_config = {
                            clues = {
                                { mode = 'n', keys = "<Leader>l", desc = "+LSP" },
                                { mode = 'v', keys = "<Leader>l", desc = "+LSP" },
                                { mode = 'n', keys = "<Leader>pd", desc = "+Diagnostics" }
                            }
                        }
                        vim.keymap.set('n', "<Leader>ld", function()
                            MiniExtra.pickers.lsp({ scope = "definition" })
                        end, { buffer = args.buf, desc = "Go to definition" })
                        vim.keymap.set('n', "<Leader>li", function()
                            MiniExtra.pickers.lsp({ scope = "implementation" })
                        end, { buffer = args.buf, desc = "Go to implementation" })
                        vim.keymap.set('n', "<Leader>lr", function()
                            MiniExtra.pickers.lsp({ scope = "references" })
                        end, { buffer = args.buf, desc = "Go to references" })
                        vim.keymap.set('n', "<Leader>ls", function()
                            MiniExtra.pickers.lsp({ scope = "document_symbol" })
                        end, { buffer = args.buf, desc = "Open document symbols" })
                        vim.keymap.set('n', "<Leader>lS", function()
                            MiniExtra.pickers.lsp({ scope = "workspace_symbol" })
                        end, { buffer = args.buf, desc = "Open workspace symbols" })
                        vim.keymap.set('n', "<Leader>pdw", function()
                            MiniExtra.pickers.diagnostic({
                                get_opts = { severity = vim.diagnostic.severity.WARN },
                                scope = "current"
                            })
                        end, { buffer = args.buf, desc = "Warnings (Current file)" })
                        vim.keymap.set('n', "<Leader>pdW", function()
                            MiniExtra.pickers.diagnostic({
                                get_opts = { severity = vim.diagnostic.severity.WARN }
                            })
                        end, { buffer = args.buf, desc = "Warnings" })
                        vim.keymap.set('n', "<Leader>pde", function()
                            MiniExtra.pickers.diagnostic({
                                get_opts = { severity = vim.diagnostic.severity.ERROR },
                                scope = "current"
                            })
                        end, { buffer = args.buf, desc = "Errors (Current file)" })
                        vim.keymap.set('n', "<Leader>pdE", function()
                            MiniExtra.pickers.diagnostic({
                                get_opts = { severity = vim.diagnostic.severity.ERROR }
                            })
                        end, { buffer = args.buf, desc = "Errors" })
                        vim.keymap.set('n', "<Leader>lD", vim.diagnostic.open_float, { buffer = args.buf, desc = "Show diagnostic" })
                        vim.keymap.set('n', "<Leader>ll", vim.lsp.buf.hover, { buffer = args.buf, desc = "Information" })
                        vim.keymap.set('n', "<Leader>ln", vim.lsp.buf.rename, { buffer = args.buf, desc = "Rename" })
                        vim.keymap.set('n', "<Leader>la", vim.lsp.buf.code_action, { buffer = args.buf, desc = "Action" })
                        vim.keymap.set({ 'n', 'v' }, "<Leader>lf", function()
                            vim.lsp.buf.format({ async = true })
                        end, { buffer = args.buf, desc = "Format" })
                    end
                })

                require("mason").setup()
                local server_config = {
                    clangd = {}
                }
                require("mason-lspconfig").setup({
                    handlers = {
                        function(server_name)
                            require("lspconfig")[server_name].setup(server_config[server_name] or {})
                        end
                    }
                })
            end
        }
    },

    default = {
        version = "*"
    },

    install = {
        colorscheme = { "default" }
    },

    rtp = {
        disabled_plugins = {
            "netrwPlugin",
            "tutor"
        }
    }
})

vim.api.nvim_create_autocmd("BufRead", {
    pattern = { "*.c", "*.h", "*.cc", "*.hh", "*.cpp", "*.hpp", "*.cxx", "*.hxx", "*.C", "*.H" },
    callback = function(args)
        vim.bo[args.buf].commentstring = "//%s"
    end
})

vim.api.nvim_create_autocmd("BufRead", {
    pattern = { "makefile", "Makefile" },
    callback = function(args)
        vim.bo[args.buf].expandtab = false
    end
})

vim.keymap.set('n', "<Esc>", vim.cmd.nohlsearch)
vim.keymap.set({ 'n', 'v' }, 'J', "<C-d>")
vim.keymap.set({ 'n', 'v' }, 'K', "<C-u>")
vim.keymap.set('n', 'U', "<C-r>")

vim.keymap.set('n', "<Leader>bw", vim.cmd.write, { desc = "Write" })

vim.keymap.set('n', "<Leader>ws", vim.cmd.split, { desc = "Split" })
vim.keymap.set('n', "<Leader>wv", vim.cmd.vsplit, { desc = "Split vertically" })
vim.keymap.set('n', "<Leader>wc", "<C-w>c", { desc = "Close" })
vim.keymap.set('n', "<Leader>wo", "<C-w>o", { desc = "Close others" })
vim.keymap.set('n', "<Leader>ww", "<C-w>w", { desc = "Focus other" })
vim.keymap.set('n', "<Leader>wh", "<C-w>h", { desc = "Focus left" })
vim.keymap.set('n', "<Leader>wj", "<C-w>j", { desc = "Focus below" })
vim.keymap.set('n', "<Leader>wk", "<C-w>k", { desc = "Focus above" })
vim.keymap.set('n', "<Leader>wl", "<C-w>l", { desc = "Focus right" })
vim.keymap.set('n', "<Leader>wH", "<C-w>H", { desc = "Move left" })
vim.keymap.set('n', "<Leader>wJ", "<C-w>J", { desc = "Move down" })
vim.keymap.set('n', "<Leader>wK", "<C-w>K", { desc = "Move up" })
vim.keymap.set('n', "<Leader>wL", "<C-w>L", { desc = "Move right" })
