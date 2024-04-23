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
			require("mini.align").setup({})

			require("mini.bracketed").setup({
				undo = { options = { wrap = false } }
			})

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
			vim.keymap.set('i', "<A-j>", [[pumvisible() ? "\<C-n>" : "\<A-j>"]], { expr = true })
			vim.keymap.set('i', "<A-k>", [[pumvisible() ? "\<C-p>" : "\<A-k>"]], { expr = true })

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

			require("mini.files").setup({
				content = {
					prefix = function() end
				}
			})
			vim.keymap.set('n', "<Leader>e", MiniFiles.open, { desc = "File" })

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
					{ mode = 'n', keys = "<Leader>d", desc = "+Diagnostic" },
					{ mode = 'n', keys = "<Leader>g", desc = "+Git" },
					{ mode = 'n', keys = "<Leader>l", desc = "+LSP" },
					{ mode = 'n', keys = "<Leader>p", desc = "+Pick" },
					{ mode = 'n', keys = "<Leader>w", desc = "+Window" },
					clue.gen_clues.marks(),
					clue.gen_clues.registers()
				},

				window = {
					delay = 200
				}
			})

			require("mini.notify").setup({})

			require("mini.pairs").setup({})

			local pick = require("mini.pick")
			pick.setup({
				mappings = {
					move_down   = "<A-j>",
					move_up     = "<A-k>",
					scroll_down = "<A-J>",
					scroll_up   = "<A-K>",

					choose_in_split   = "<A-s>",
					choose_in_vsplit  = "<A-v>",
					choose_in_tabpage = "<A-t>"
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
							col = math.floor(0.5 * (vim.o.columns - width))
						}
					end
				}
			})
			vim.keymap.set('n', "<Leader>h", function()
				MiniPick.builtin.help({}, {
					mappings = {
						show_help_in_split   = { char = "<A-s>" },
						show_help_in_vsplit  = { char = "<A-v>" },
						show_help_in_tabpage = { char = "<A-t>" }
					}
				})
			end, { desc = "Help" })
			-- TODO: Add custom actions to builtin pickers e.g delete buffer in MiniPick.builtin.buffer.
			vim.keymap.set('n', "<Leader>pb", MiniPick.builtin.buffers,
			{ desc = "Pick buffer" })
			vim.keymap.set('n', "<Leader>pf", MiniPick.builtin.files,
			               { desc = "Pick files " })
			vim.keymap.set('n', "<Leader>pg", MiniPick.builtin.grep_live,
			               { desc = "Live grep" })
			vim.keymap.set('n', "<Leader>pp", MiniPick.builtin.resume,
			               { desc = "Resume last pick" })
			vim.keymap.set('n', "<Leader>dp", MiniExtra.pickers.diagnostic,
			               { desc = "Pick diagnostic" })
			vim.keymap.set('n', "<Leader>pm", MiniExtra.pickers.marks,
			               { desc = "Pick marks" })
			vim.keymap.set('n', "<Leader>pr", MiniExtra.pickers.registers,
			               { desc = "Pick registers contents" })

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

			require("mini.visits").setup({})
			vim.keymap.set('n', "<Leader>pv", MiniExtra.pickers.visit_paths,
			               { desc = "Pick recent files" })
		end
	},

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add       = { text = '+' },
				change    = { text = '~' },
				delete    = { text = '-' },
				topdelete = { text = '^' },
				untracked = { text = '?' }
			},

			base = '@',

			on_attach = function(buf_number)
				local gitsigns = require("gitsigns")
				vim.keymap.set('n', "<Leader>gr", gitsigns.refresh,
				               { buffer = buf_number, desc = "Refresh" })
				vim.keymap.set('n', "]g", function() gitsigns.nav_hunk("next") end,
				               { buffer = buf_number, desc = "Go to next hunk" })
				vim.keymap.set('n', "[g", function() gitsigns.nav_hunk("prev") end,
				               { buffer = buf_number, desc = "Go to previous hunk" })
				vim.keymap.set('n', "]G", function() gitsigns.nav_hunk("last") end,
				               { buffer = buf_number, desc = "Go to last hunk" })
				vim.keymap.set('n', "[G", function() gitsigns.nav_hunk("first") end,
				               { buffer = buf_number, desc = "Go to first hunk" })
				vim.keymap.set('n', "<Leader>gb", gitsigns.blame_line,
				               { buffer = buf_number, desc = "Blame" })
				vim.keymap.set('n', "<Leader>gv", gitsigns.select_hunk,
				               { buffer = buf_number, desc = "Select hunk" })
				vim.keymap.set('n', "<Leader>gd", gitsigns.diffthis,
				               { buffer = buf_number, desc = "Diff" })
				vim.keymap.set('n', "<Leader>gg", gitsigns.preview_hunk,
				               { buffer = buf_number, desc = "Preview hunk" })
			end
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
					vim.keymap.set('n', "<Leader>ll", vim.lsp.buf.hover,
					               { buffer = event.buf, desc = "Show hover information" })
					vim.keymap.set('n', "<Leader>ln", vim.lsp.buf.rename,
					               { buffer = event.buf, desc = "Rename" })
					vim.keymap.set({ 'n', 'v' }, "<Leader>la", vim.lsp.buf.code_action,
					               { buffer = event.buf, desc = "Code action" })
				end
			})

			local servers = {
				lua_ls = {},
				clangd = {}
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
			cmd     = "⌘",
			config  = "🛠️",
			event   = "📅",
			ft      = "📂",
			init    = "🏁",
			keys    = "🔑",
			plugin  = "🔌",
			runtime = "💻",
			require = "🌙",
			source  = "📄",
			start   = "🚀",
			task    = "📌",
			lazy    = "💤 "
		}
	}
})

vim.keymap.set({ 'n', 'v' }, 'H', 'b')
vim.keymap.set({ 'n', 'v' }, 'L', 'w')
vim.keymap.set('n', 'J', "<C-d>")
vim.keymap.set('n', 'K', "<C-u>")
vim.keymap.set('n', "<Esc>", "<Cmd>nohlsearch<CR>")
vim.keymap.set('t', "<Esc><Esc>", "<C-\\><C-n>")
vim.keymap.set('n', 'U', "<C-r>")

vim.keymap.set('n', "<Leader>dd", vim.diagnostic.open_float, { desc = "Show diagnostic errors" })

vim.keymap.set('n', "<Leader>wn", "<C-w>n", { desc = "Create new window" })
vim.keymap.set('n', "<Leader>wc", "<C-w>c", { desc = "Close window" })
vim.keymap.set('n', "<Leader>wo", "<C-w>o", { desc = "Close other windows" })
vim.keymap.set('n', "<Leader>ww", "<C-w>w", { desc = "Focus other window" })
vim.keymap.set('n', "<Leader>wh", "<C-w>h", { desc = "Focus left window" })
vim.keymap.set('n', "<Leader>wj", "<C-w>j", { desc = "Focus window below" })
vim.keymap.set('n', "<Leader>wk", "<C-w>k", { desc = "Focus window above" })
vim.keymap.set('n', "<Leader>wl", "<C-w>l", { desc = "Focus right window" })
vim.keymap.set('n', "<Leader>wH", "<C-w>H", { desc = "Move window left" })
vim.keymap.set('n', "<Leader>wJ", "<C-w>J", { desc = "Move window down" })
vim.keymap.set('n', "<Leader>wK", "<C-w>K", { desc = "Move window up" })
vim.keymap.set('n', "<Leader>wL", "<C-w>L", { desc = "Move window right" })

