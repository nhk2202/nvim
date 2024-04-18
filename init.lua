vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set({ 'n', 'v' }, "<Space>", "<Nop>", { silent = true })

vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.wrap = false
vim.wo.colorcolumn = "100"

vim.o.tabstop = 4
vim.o.shiftwidth = 0
vim.o.cursorline = true
vim.o.mouse = 'a'
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.completeopt = "menuone,preview,noselect"
vim.o.termguicolors = true
vim.o.scrolloff = 10
vim.o.showmode = false
vim.o.showcmd = false
vim.o.undofile = true

vim.opt.clipboard:append("unnamedplus") -- NOTE: (WSL) Make sure win32yank.exe is in Path.
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
		version = false,
		config = function()
			local ai = require("mini.ai")
			ai.setup({})

			local comment = require("mini.comment")
			comment.setup({
				options = {
					ignore_blank_line = true
				}
			})

			local completion = require("mini.completion")
			completion.setup({})
			vim.keymap.set('i', "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
			vim.keymap.set('i', "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })

			local hipatterns = require("mini.hipatterns")
			hipatterns.setup({
				highlighters = {
					fixme     = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
					hack      = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
					todo      = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
					note      = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
					hex_color = hipatterns.gen_highlighter.hex_color()
				}
			})

			local hues = require("mini.hues")
			math.randomseed(vim.loop.hrtime())
			hues.setup(hues.gen_random_base_colors())

			local miniclue = require("mini.clue")
			miniclue.setup({
				triggers = {
					{ mode = 'n', keys = "<Leader>" },
					{ mode = 'v', keys = "<Leader>" }
				},

				clues = {
					{ mode = 'n', keys = "<Leader>p", desc = "+Pick" },
					{ mode = 'n', keys = "<Leader>l", desc = "+LSP" },
					{ mode = 'n', keys = "<Leader>w", desc = "+Window" },
				},

				window = {
					delay = 500,

					scroll_down = "<A-j>",
					scroll_up = "<A-k>"
				}
			})

			local pairs = require("mini.pairs")
			pairs.setup({})

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

			local statusline = require("mini.statusline")
			statusline.setup({
				use_icons = false
			})
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return ""
			end

			local surround = require("mini.surround")
			surround.setup({})

			local trailspace = require("mini.trailspace")
			trailspace.setup({})
		end
	},

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = '+',
				change = '~',
				delete = '-',
				topdelete = '^',
				untracked = '?'
			}
		}
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"williamboman/mason.nvim",
				opts = {
					ui = {
						icons = {
							package_installed = '✓',
							package_uninstalled = '✗',
							package_pending = '…'
						}
					}
				}
			},

			"williamboman/mason-lspconfig.nvim",

			{ "folke/neodev.nvim", opts = {} }
		},

		config = function()
			local lsp = vim.lsp
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("MyLspConfig", {}),
				callback = function(event)
					vim.keymap.set('n', "<Leader>ld", lsp.buf.definition,
					    { buffer = event.buf, desc = "Go to definition" })
					vim.keymap.set('n', "<Leader>lD", lsp.buf.type_definition,
					    { buffer = event.buf, desc = "Go to type definition" })
					vim.keymap.set('n', "<Leader>lh", lsp.buf.hover,
					    { buffer = event.buf, desc = "Show hover information" })
					vim.keymap.set('n', "<Leader>li", lsp.buf.implementation,
					    { buffer = event.buf, desc = "Go to implementation" })
					vim.keymap.set('n', "<Leader>ln", lsp.buf.rename,
					    { buffer = event.buf, desc = "Rename" })
					vim.keymap.set({ 'n', 'v' }, "<Leader>la", lsp.buf.code_action,
					    { buffer = event.buf, desc = "Code action" })
					vim.keymap.set('n', "<Leader>lr", lsp.buf.references,
					    { buffer = event.buf, desc = "Go to references" })
				end
			})

			local servers = {
				lua_ls = {},
				clangd = {},
			}

			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(servers or {}),
				handlers = {
					function(server_name)
						require("lspconfig")[server_name].setup(servers[server_name] or {})
					end
				}
			})
		end
	}
}, {
	ui = {
		icons = {
			cmd = "⌘",
			config = "🛠️",
			event = "📅",
			ft = "📂",
			init = "🏁",
			keys = "🔑",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 "
		}
	}
})

vim.keymap.set({ 'n', 'v' }, 'H', 'b')
vim.keymap.set({ 'n', 'v' }, 'L', 'w')
vim.keymap.set('n', 'J', "<C-d>")
vim.keymap.set('n', 'K', "<C-u>")
vim.keymap.set('n', "<Esc>", "<Cmd>nohlsearch<CR>")
vim.keymap.set('t', "<Esc><Esc>", "<C-\\><C-n>")

vim.keymap.set('n', "<Leader>wn", "<C-w>n", { desc = "Create new window" })
vim.keymap.set('n', "<Leader>wc", "<C-w>c", { desc = "Close window" })
vim.keymap.set('n', "<Leader>wo", "<C-w>o", { desc = "Close other windows" })
vim.keymap.set('n', "<Leader>ww", "<C-w>w", { desc = "Focus other window" })
vim.keymap.set('n', "<Leader>wH", "<C-w>H", { desc = "Move window left" })
vim.keymap.set('n', "<Leader>wJ", "<C-w>J", { desc = "Move window down" })
vim.keymap.set('n', "<Leader>wK", "<C-w>K", { desc = "Move window up" })
vim.keymap.set('n', "<Leader>wL", "<C-w>L", { desc = "Move window right" })
