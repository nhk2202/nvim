vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set({ 'n', 'v' }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set({ 'n', 'v' }, "<Leader>w", "<C-w>")

vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.wrap = false
vim.wo.colorcolumn = "100"

vim.o.cursorline = true
vim.o.mouse = 'a'
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.completeopt = "menuone,preview,noselect"
vim.o.termguicolors = true
vim.o.scrolloff = 10
vim.o.showmode = false
vim.o.undofile = true
vim.o.inccommand = "split"

vim.opt.clipboard:append("unnamedplus")
vim.opt.shortmess:append('S')

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "echasnovski/mini.nvim",
        version = "*",
        config = function()
            local hipatterns = require("mini.hipatterns")
            hipatterns.setup({
                highlighters = {
                    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
                    hack  = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
                    todo  = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
                    note  = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
                    hex_color = hipatterns.gen_highlighter.hex_color()
                }
            })

            local trailspace = require("mini.trailspace")
            trailspace.setup({})

            local statusline = require("mini.statusline")
            statusline.setup({
                use_icons = false
            })
            statusline.section_location = function()
                return ""
            end

            local pick = require("mini.pick")
            pick.setup({
                mappings = {
                    caret_left = "<A-l>",
                    caret_right = "<A-h>",

                    choose_in_vsplit = "<A-s>",

                    mark = "<A-m>",
                    mark_all = "<A-a>",

                    move_down = "<A-j>",
                    move_up = "<A-k>",
                    move_start = "<A-g>",

                    scroll_down = "<A-J>",
                    scroll_up = "<A-K>",
                    scroll_left = "<A-L>",
                    scroll_right = "<A-H>",

                    refine = "<A-r>",
                    refine_marked = "<A-R>",

                    choose_marked = "<S-CR>"
                },

                options = {
                    use_cache = true
                },

                source = {
                    show = pick.default_show
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
                            col = math.floor(0.5 * (vim.o.columns - width)),
                        }
                    end
                }
            })
            vim.keymap.set('n', "<Leader>pf", pick.builtin.files, { desc = "Pick files " })
            vim.keymap.set('n', "<Leader>pg", pick.builtin.grep_live, { desc = "Live grep" })
            vim.keymap.set('n', "<Leader>h", pick.builtin.help, { desc = "Help" })
            vim.keymap.set('n', "<Leader>pb", pick.builtin.buffers, { desc = "Pick buffer" })
            vim.keymap.set('n', "<Leader>pp", pick.builtin.resume, { desc = "Resume last pick" })

            require("mini.completion").setup({})
            vim.keymap.set('i', "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
            vim.keymap.set('i', "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })

            local miniclue = require("mini.clue")
            miniclue.setup({
                triggers = {
                    { mode = 'n', keys = "<Leader>" },
                    { mode = 'v', keys = "<Leader>" }
                },

                clues = {
                    { mode = 'n', keys = "<Leader>p", desc = "+Pick" },
                    { mode = 'n', keys = "<Leader>l", desc = "+LSP" },
                },

                window = {
                    delay = 500,

                    scroll_down = "<A-j>",
                    scroll_up = "<A-k>"
                }
            })

            require("mini.comment").setup({
                options = {
                    ignore_blank_line = true
                }
            })

            require("mini.surround").setup({})

            require("mini.pairs").setup({})
        end
    },

    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "+" },
                    change = { text = "~" },
                    changedelete = { text = "-" },
                    untracked = { text = "?" }
                },
            })
        end
    },

    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                "williamboman/mason.nvim",
                config = function()
                    require("mason").setup({
                        ui = {
                            icons = {
                                package_installed = '✓',
                                package_uninstalled = '✗',
                                package_pending = '⟳'
                            }
                        },
                    })
                end
            },
        },

        config = function()
            local lspconfig = require("lspconfig")
            lspconfig.clangd.setup({})
            lspconfig.lua_ls.setup({
                settings = {
                    Lua = {
                        workspace = {
                            library = { vim.env.VIMRUNTIME }
                        }
                    }
                }
            })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
                    local opts = function(desc)
                        return {
                            buffer = ev.buf,
                            desc = desc
                        }
                    end
                    vim.keymap.set('n', "<Leader>lD", vim.lsp.buf.declaration, opts("Go to declaration"))
                    vim.keymap.set('n', "<Leader>ld", vim.lsp.buf.definition, opts("Go to definition"))
                    vim.keymap.set('n', "<Leader>l.", vim.lsp.buf.hover, opts("Show hover information"))
                    vim.keymap.set('n', "<Leader>li", vim.lsp.buf.implementation, opts("Go to implementation"))
                    vim.keymap.set('n', "<Leader>ls", vim.lsp.buf.signature_help, opts("Signature help"))
                    vim.keymap.set('n', "<Leader>l+", vim.lsp.buf.add_workspace_folder, opts("Add workspace folder"))
                    vim.keymap.set('n', "<Leader>l-", vim.lsp.buf.remove_workspace_folder, opts("Remove workspace folder"))
                    vim.keymap.set('n', "<Leader>ll", function()
                        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end, opts("List workspace folders" ))
                    vim.keymap.set('n', "<Leader>lt", vim.lsp.buf.type_definition, opts("Go to type definition"))
                    vim.keymap.set('n', "<Leader>lr", vim.lsp.buf.rename, opts("Rename buffer" ))
                    vim.keymap.set({ 'n', 'v' }, "<Leader>la", vim.lsp.buf.code_action, opts("Code action"))
                    vim.keymap.set('n', "<Leader>lr", vim.lsp.buf.references, opts("List references"))
                    vim.keymap.set('n', "<Leader>lf", function()
                        vim.lsp.buf.format({ async = true })
                    end, opts("Format code"))
                end
            })

        end
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true }
            })
        end
    },

    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        config = function()
            require("telescope").setup({})
            local telescope = require("telescope.builtin")
            vim.keymap.set('n', "<Leader>ff", telescope.find_files, {})
            vim.keymap.set('n', "<Leader>fg", telescope.live_grep, {})
            vim.keymap.set('n', "<Leader>fb", telescope.buffers, {})
            vim.keymap.set('n', "<Leader>fh", telescope.help_tags, {})
        end
    },

    {
        "Skullamortis/forest.nvim",
        config = function()
            require("forest").setup({
                dim_inactive = true
            })
            vim.cmd.colorscheme("forest")
        end
    }
}, {
    checker = { enabled = true },
    ui = {
        icons = {
            cmd = "🤌",
            config = "🛠️",
            event = "📅",
            ft = "🗂️",
            init = "▶️",
            keys = "🔑",
            plugin = "🔌",
            runtime = "⏰",
            require = "💲",
            source = "📄",
            start = "🚀",
            task = "📌",
            lazy = "💤 "
        }
    }
})

-- vim.keymap.set('n', "<Leader>d", vim.diagnostic.open_float)
-- vim.keymap.set('n', "<Leader>D", vim.diagnostic.setloclist)
-- vim.keymap.set('n', "]d", vim.diagnostic.goto_next)
-- vim.keymap.set('n', "[d", vim.diagnostic.goto_prev)

vim.keymap.set({ 'n', 'v' }, 'H', 'b')
vim.keymap.set({ 'n', 'v' }, 'L', 'w')
vim.keymap.set('n', 'J', "<C-d>")
vim.keymap.set('n', 'K', "<C-u>")
vim.keymap.set('n', "<Esc>", "<cmd>nohlsearch<CR>")


-- vim: ts=4 sts=4 sw=4 et
