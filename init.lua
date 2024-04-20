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
vim.o.ruler = false
vim.o.undofile = true
vim.o.splitbelow = true
vim.o.splitright = true

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
			require("mini.bracketed").setup({})

			require("mini.comment").setup({
				options = {
					ignore_blank_line = true
				}
			})

			require("mini.completion").setup({
				lsp_completion = {
					source_func = "omnifunc",
					auto_setup = false
				}
			})
			vim.keymap.set('i', '<M-j>', [[pumvisible() ? "\<C-n>" : "\<M-j>"]], { expr = true })
			vim.keymap.set('i', '<M-k>', [[pumvisible() ? "\<C-p>" : "\<M-k>"]], { expr = true })

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

			require("mini.extra").setup({})

			local hues = require("mini.hues")
			math.randomseed(vim.loop.hrtime())
			hues.setup(vim.tbl_extend("force", hues.gen_random_base_colors(), { saturation = "high" }))

			local clue = require("mini.clue")
			clue.setup({
				triggers = {
					{ mode = 'n', keys = "<Leader>" },
					{ mode = 'n', keys = '['},
					{ mode = 'n', keys = ']'},
					{ mode = 'n', keys = "'"},
					{ mode = 'n', keys = '`'},
					{ mode = 'n', keys = '"'},
				},

				clues = {
					{ mode = 'n', keys = "<Leader>p", desc = "+Pick" },
					{ mode = 'n', keys = "<Leader>pl", desc = "+List" },
					{ mode = 'n', keys = "<Leader>l", desc = "+LSP" },
					{ mode = 'n', keys = "<Leader>w", desc = "+Window" },
					{ mode = 'n', keys = "<Leader>d", desc = "+Diagnostic" },
					clue.gen_clues.marks(),
					clue.gen_clues.registers()
				},

				window = {
					delay = 500,
				}
			})

			require("mini.pairs").setup({})

			local pick = require("mini.pick")
			pick.setup({
				mappings = {
					move_down = "<A-j>",
					move_up = "<A-k>",
					scroll_down = "<A-J>",
					scroll_up = "<A-K>",

					refine = "<A-r>",

					-- FIXME: The keybindings below doesn't work.
					-- choose_in_split = "<A-s>",
					-- choose_in_vsplit = "<A-v>",
					-- choose_in_tabpage = "<A-t>",
				},

				options = {
					use_cache = true
				},

				source = {
					show = pick.default_show,
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
			vim.keymap.set('n', "<Leader>h", MiniPick.builtin.help, { desc = "Help" })
			vim.keymap.set('n', "<Leader>pb", MiniPick.builtin.buffers, { desc = "Pick buffer" })
			vim.keymap.set('n', "<Leader>pf", MiniPick.builtin.files, { desc = "Pick files " })
			vim.keymap.set('n', "<Leader>pg", MiniPick.builtin.grep_live, { desc = "Live grep" })
			vim.keymap.set('n', "<Leader>pp", MiniPick.builtin.resume, { desc = "Resume last pick" })
			vim.keymap.set('n', "<Leader>dp", MiniExtra.pickers.diagnostic, { desc = "Pick diagnostic" })
			vim.keymap.set('n', "<Leader>pe", MiniExtra.pickers.explorer, { desc = "Explore file system" })
			vim.keymap.set('n', "<Leader>ph", MiniExtra.pickers.history, { desc = "Pick history" })
			vim.keymap.set('n', "<Leader>pH", MiniExtra.pickers.hipatterns, { desc = "Pick highlighted patterns" })
			vim.keymap.set('n', "<Leader>plc", function()
			    MiniExtra.pickers.list({ scope = "change" })
			end, { desc = "Pick from change list" })
			vim.keymap.set('n', "<Leader>plj", function()
			    MiniExtra.pickers.list({ scope = "jump" })
			end, { desc = "Pick from jump list" })
			vim.keymap.set('n', "<Leader>pll", function()
			    MiniExtra.pickers.list({ scope = "location" })
			end, { desc = "Pick from location list" })
			vim.keymap.set('n', "<Leader>plq", function()
			    MiniExtra.pickers.list({ scope = "quickfix" })
			end, { desc = "Pick from quickfix list" })
			vim.keymap.set('n', "<Leader>pm", MiniExtra.pickers.marks, { desc = "Pick marks" })
			vim.keymap.set('n', "<Leader>po", MiniExtra.pickers.oldfiles, { desc = "Pick oldfiles" })
			vim.keymap.set('n', "<Leader>pr", MiniExtra.pickers.registers, { desc = "Pick registers" })
			vim.keymap.set('n', "<Leader>ps", MiniExtra.pickers.spellsuggest, { desc = "Pick spelling suggestions" })
			vim.keymap.set('n', "<Leader>pt", MiniExtra.pickers.treesitter, { desc = "Pick treesitter nodes" })
			-- vim.keymap.set('n', "<Leader>pvp", MiniExtra.pickers.visit_paths, { desc = "Pick visit paths" })
			-- vim.keymap.set('n', "<Leader>pvl", MiniExtra.pickers.visit_labels, { desc = "Pick visit labels" })

			require("mini.statusline").setup({
				use_icons = false
			})
			---@diagnostic disable-next-line: duplicate-set-field
			MiniStatusline.section_location = function()
				return ""
			end

			require("mini.surround").setup({
				respect_selection_type = true
			})

			require("mini.trailspace").setup({})
			vim.keymap.set('n', "ds", MiniTrailspace.trim)
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
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("MyLspConfig", {}),
				callback = function(event)
					vim.bo[event.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
					vim.keymap.set('n', "<Leader>ld", function()
					    MiniExtra.pickers.lsp({ scope = "definition" })
					end, { buffer = event.buf, desc = "Go to definition" })
					vim.keymap.set('n', "<Leader>lD", function()
						MiniExtra.pickers.lsp({ scope = "type_definition" })
					end, { buffer = event.buf, desc = "Go to type definition" })
					vim.keymap.set('n', "<Leader>li", function()
						MiniExtra.pickers.lsp({ scope = "implementation" })
					end, { buffer = event.buf, desc = "Go to implementation" })
					vim.keymap.set('n', "<Leader>lr", function()
						MiniExtra.pickers.lsp({ scope = "references" })
					end, { buffer = event.buf, desc = "Go to references" })
					vim.keymap.set('n', "<Leader>ls", function()
						MiniExtra.pickers.lsp({ scope = "document_symbol" })
					end, { buffer = event.buf, desc = "Go to symbol in file"})
					vim.keymap.set('n', "<Leader>lS", function()
						MiniExtra.pickers.lsp({ scope = "workspace_symbol" })
					end, { buffer = event.buf, desc = "Go to symbol in workspace"})
					vim.keymap.set('n', "<Leader>l.", vim.lsp.buf.hover,
					    { buffer = event.buf, desc = "Show hover information" })
					vim.keymap.set('n', "<Leader>ln", vim.lsp.buf.rename,
					    { buffer = event.buf, desc = "Rename" })
					vim.keymap.set({ 'n', 'v' }, "<Leader>la", vim.lsp.buf.code_action,
					    { buffer = event.buf, desc = "Code action" })
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

vim.keymap.set('n', "<Leader>d.", vim.diagnostic.open_float, { desc = "Show diagnostic errors" })

vim.keymap.set('n', "<Leader>wn", "<C-w>n", { desc = "Create new window" })
vim.keymap.set('n', "<Leader>wc", "<C-w>c", { desc = "Close window" })
vim.keymap.set('n', "<Leader>wo", "<C-w>o", { desc = "Close other windows" })
vim.keymap.set('n', "<Leader>ww", "<C-w>w", { desc = "Focus other window" })
vim.keymap.set('n', "<Leader>wH", "<C-w>H", { desc = "Move window left" })
vim.keymap.set('n', "<Leader>wJ", "<C-w>J", { desc = "Move window down" })
vim.keymap.set('n', "<Leader>wK", "<C-w>K", { desc = "Move window up" })
vim.keymap.set('n', "<Leader>wL", "<C-w>L", { desc = "Move window right" })
