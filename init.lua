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
vim.o.scrolloff = 10
vim.o.showmode = false
vim.o.showcmd = false
vim.o.ruler = false
vim.o.splitbelow = true
vim.o.splitright = true

vim.opt.clipboard:append("unnamedplus") -- NOTE: (WSL) Make sure win32yank.exe is in Path.
vim.opt.shortmess:append('S')

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
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
			version = false,
			config = function()
				require("mini.bracketed").setup({
					undo = { options = { wrap = false } }
				})
				vim.keymap.set('n', "]e", function()
					MiniBracketed.diagnostic("forward", { severity = vim.diagnostic.severity.ERROR })
				end)
				vim.keymap.set('n', "[e", function()
					MiniBracketed.diagnostic("backward", { severity = vim.diagnostic.severity.ERROR })
				end)
				vim.keymap.set('n', "]E", function()
					MiniBracketed.diagnostic("first", { severity = vim.diagnostic.severity.ERROR })
				end)
				vim.keymap.set('n', "[E", function()
					MiniBracketed.diagnostic("last", { severity = vim.diagnostic.severity.ERROR })
				end)
				vim.keymap.set('n', "]w", function()
					MiniBracketed.diagnostic("forward", { severity = vim.diagnostic.severity.WARN })
				end)
				vim.keymap.set('n', "[w", function()
					MiniBracketed.diagnostic("backward", { severity = vim.diagnostic.severity.WARN })
				end)
				vim.keymap.set('n', "]W", function()
					MiniBracketed.diagnostic("first", { severity = vim.diagnostic.severity.WARN })
				end)
				vim.keymap.set('n', "[W", function()
					MiniBracketed.diagnostic("last", { severity = vim.diagnostic.severity.WARN })
				end)

				local clue = require("mini.clue")
				clue.setup({
					triggers = {
						{ mode = 'n', keys = "<Leader>" },
						{ mode = 'n', keys = '"'},
						{ mode = 'n', keys = "'" },
						{ mode = 'n', keys = '`' },
					},

					clues = {
						clue.gen_clues.marks(),
						clue.gen_clues.registers(),

						{ mode = 'n', keys = "<Leader>b", desc = "+Buffer" },
						{ mode = 'n', keys = "<Leader>d", desc = "+Diagnostic" },
						{ mode = 'n', keys = "<Leader>g", desc = "+Git" },
						{ mode = 'n', keys = "<Leader>l", desc = "+LSP" },
						{ mode = 'n', keys = "<Leader>p", desc = "+Pick" },
						{ mode = 'n', keys = "<Leader>t", desc = "+VimTeX" },
						{ mode = 'n', keys = "<Leader>w", desc = "+Window" }
					},

					window = {
						delay = 200,
						scroll_down = "<A-j>",
						scroll_up = "<A-k>"
					}
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

				require("mini.diff").setup({
					view = {
						style = "sign",
						signs = {
							add = '+',
							change = '~',
							delete = '-'
						}
					}
				})
				vim.keymap.set('n', "<Leader>go", MiniDiff.toggle_overlay, { desc = "Toggle diff overlay" })

				require("mini.extra").setup()

				require("mini.files").setup({
					content = {
						prefix = function() end
					}
				})
				vim.keymap.set('n', "<Leader>e", MiniFiles.open, { desc = "Explore" })

				require("mini.git").setup({
					command = {
						split = "vertical"
					}
				})
				vim.keymap.set('n', "<Leader>gg", MiniGit.show_at_cursor, { desc = "Show git data" })

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

				require("mini.notify").setup()

				require("mini.pairs").setup()

				local pick = require("mini.pick")
				pick.setup({
					mappings = {
						move_down   = "<A-j>",
						move_up     = "<A-k>",
						scroll_down = "<A-J>",
						scroll_up   = "<A-K>",

						choose_in_split   = "<A-s>",
						choose_in_vsplit  = "<A-v>",

						refine = "<A-r>"
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
						}
					})
				end, { desc = "Help" })
				-- TODO: Add custom actions to builtin pickers e.g delete buffer in MiniPick.builtin.buffer.
				vim.keymap.set('n', "<Leader>bp", MiniPick.builtin.buffers,
				{ desc = "Pick" })
				vim.keymap.set('n', "<Leader>pf", MiniPick.builtin.files, { desc = "Files" })
				vim.keymap.set('n', "<Leader>pg", MiniPick.builtin.grep_live, { desc = "Grep" })
				vim.keymap.set('n', "<Leader>pp", MiniPick.builtin.resume, { desc = "Resume" })
				vim.keymap.set('n', "<Leader>dp", MiniExtra.pickers.diagnostic, { desc = "Pick" })
				vim.keymap.set('n', "<Leader>pm", MiniExtra.pickers.marks, { desc = "Marks" })
				vim.keymap.set('n', "<Leader>pr", MiniExtra.pickers.registers, { desc = "Registers" })

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

				require("mini.trailspace").setup()
				vim.keymap.set('n', "ds", MiniTrailspace.trim)
			end
		},

		{
			"sainnhe/everforest",
			config = function()
				vim.g.everforest_enable_italic = 1
				vim.g.everforest_dim_inactive_windows = 1
				vim.g.everforest_better_performance = 1
				vim.cmd.colorscheme("everforest")
			end
		},

		{
			"lervag/vimtex",
			lazy = false,
			init = function()
				vim.g.vimtex_view_method = "sioyek"
				vim.g.vimtex_mappings_prefix = "<LocalLeader>t"
				vim.g.vimtex_compiler_latexmk = {
					aux_dir = "./aux",
					out_dir = "./out",
					options = {
						"-emulate-aux-dir",
						"-verbose",
						"-file-line-error",
						"-synctex=1",
						"-interaction=nonstopmode"
					}
				}
				vim.g.vimtex_compiler_latexmk_engines = { _ = "-lualatex" }
				vim.keymap.set('n', "<LocalLeader>ti", "<plug>(vimtex-info)", { desc = "Info" })
				vim.keymap.set('n', "<LocalLeader>tI", "<plug>(vimtex-info-full)", { desc = "Info (full)" })
				vim.keymap.set('n', "<LocalLeader>td", "<plug>(vimtex-doc-package)", { desc = "Documentation" })
				vim.keymap.set('n', "<LocalLeader>tt", "<plug>(vimtex-toc-toggle)", { desc = "Toggle toc" })
				vim.keymap.set('n', "<LocalLeader>tl", "<plug>(vimtex-log)", { desc = "Log" })
				vim.keymap.set('n', "<LocalLeader>tv", "<plug>(vimtex-view)", { desc = "View pdf" })
				vim.keymap.set('n', "<LocalLeader>tc", "<plug>(vimtex-compile)", { desc = "Compile" })
				vim.keymap.set('n', "<LocalLeader>tC", "<plug>(vimtex-compile-selected)", { desc = "Compile selected" })
				vim.keymap.set('n', "<LocalLeader>tk", "<plug>(vimtex-stop)", { desc = "Stop" })
				vim.keymap.set('n', "<LocalLeader>tK", "<plug>(vimtex-stop-all)", { desc = "Stop all" })
				vim.keymap.set('n', "<LocalLeader>te", "<plug>(vimtex-errors)", { desc = "Errors" })
				vim.keymap.set('n', "<LocalLeader>to", "<plug>(vimtex-compile-output)", { desc = "Compile output" })
				vim.keymap.set('n', "<LocalLeader>ts", "<plug>(vimtex-status)", { desc = "Status" })
				vim.keymap.set('n', "<LocalLeader>tS", "<plug>(vimtex-status-all)", { desc = "Status (full)" })
				vim.keymap.set('n', "<LocalLeader>tx", "<plug>(vimtex-clean)", { desc = "Clean" })
				vim.keymap.set('n', "<LocalLeader>tX", "<plug>(vimtex-clean-full)", { desc = "Clean all" })
				vim.keymap.set('n', "<LocalLeader>ta", "<plug>(vimtex-context-menu)", { desc = "Action" })
				vim.keymap.set('n', "<LocalLeader>tm", "<plug>(vimtex-imaps-list)", { desc = "List imaps" })
			end
		},

		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				integrations = {
					cmp = false
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
			},
			config = function()
				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("MyLspConfig", {}),
					callback = function(event)
						vim.bo[event.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
						vim.keymap.set('n', "<Leader>ld", function()
							MiniExtra.pickers.lsp({ scope = "definition" })
						end, { buffer = event.buf, desc = "Definition" })
						vim.keymap.set('n', "<Leader>lD", function()
							MiniExtra.pickers.lsp({ scope = "type_definition" })
						end, { buffer = event.buf, desc = "Type definition" })
						vim.keymap.set('n', "<Leader>li", function()
							MiniExtra.pickers.lsp({ scope = "implementation" })
						end, { buffer = event.buf, desc = "Implementation" })
						vim.keymap.set('n', "<Leader>lr", function()
							MiniExtra.pickers.lsp({ scope = "references" })
						end, { buffer = event.buf, desc = "References" })
						vim.keymap.set('n', "<Leader>ls", function()
							MiniExtra.pickers.lsp({ scope = "document_symbol" })
						end, { buffer = event.buf, desc = "Symbols in file" })
						vim.keymap.set('n', "<Leader>lS", function()
							MiniExtra.pickers.lsp({ scope = "workspace_symbol" })
						end, { buffer = event.buf, desc = "Symbols in workspace" })
						vim.keymap.set('n', "<Leader>ll", vim.lsp.buf.hover, { buffer = event.buf, desc = "Information" })
						vim.keymap.set('n', "<Leader>ln", vim.lsp.buf.rename, { buffer = event.buf, desc = "Rename" })
						vim.keymap.set({ 'n', 'v' }, "<Leader>la", vim.lsp.buf.code_action, { buffer = event.buf, desc = "Action" })
						vim.keymap.set({ 'n', 'v' }, "<Leader>lf", function()
							vim.lsp.buf.format({ async = true })
						end, { buffer = event.buf, desc = "Format" })
					end
				})

				local servers = {
					lua_ls = {},
					clangd = {},
					texlab = {}
				}

				require("mason").setup()
				require("mason-lspconfig").setup({
					ensure_installed = { "lua_ls", "clangd" },
					handlers = {
						function(server_name)
							require("lspconfig")[server_name].setup(servers[server_name] or {})
						end
					}
				})
			end
		}
	},

	ui = {
		icons = {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	}
})

vim.api.nvim_create_autocmd("BufRead", {
	group = vim.api.nvim_create_augroup("MyFiletypeConfig", {}),
	pattern = "*.c,*.h,*.cc,*.hh,*.cpp,*.hpp",
	callback = function(event)
		vim.bo[event.buf].commentstring = "// %s"
	end
})

vim.api.nvim_create_autocmd("BufRead", {
	group = vim.api.nvim_create_augroup("MyModifiableBufferConfig", {}),
	pattern = "*",
	callback = function(event)
		if vim.bo[event.buf].modifiable then
			vim.bo[event.buf].keymap = "vietnamese-telex_utf-8"
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i<C-^><ESC>", true, false, true), 'n', true)
		end
	end
})
vim.keymap.set('i', "<A-i>", "<C-^>")

vim.keymap.set('n', "<Esc>", vim.cmd.nohlsearch)
vim.keymap.set('n', 'J', "<C-d>")
vim.keymap.set('n', 'K', "<C-u>")
vim.keymap.set('t', "<Esc><Esc>", "<C-\\><C-n>")
vim.keymap.set('n', 'U', "<C-r>")

vim.keymap.set('n', "<Leader>dd", vim.diagnostic.open_float, { desc = "Show" })

vim.keymap.set('n', "<Leader>bs", vim.cmd.write, { desc = "Save" })
vim.keymap.set('n', "<Leader>bd", vim.cmd.bdelete, { desc = "Delete" })

vim.keymap.set('n', "<Leader>ws", vim.cmd.new, { desc = "Split" })
vim.keymap.set('n', "<Leader>wv", vim.cmd.vnew, { desc = "Split vertically" })
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
