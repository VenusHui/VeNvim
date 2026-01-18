-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- 配置剪切板：WSL 与 Windows 主机剪切板同步（使用 win32yank）
if vim.fn.has("wsl") == 1 then
  local win32yank_path = vim.fn.expand("$HOME/.local/bin/win32yank.exe")
  -- 验证文件是否存在
  if vim.fn.filereadable(win32yank_path) == 1 then
    vim.g.clipboard = {
      name = "win32yank-wsl",
      copy = {
        ["+"] = win32yank_path .. " -i --crlf",
        ["*"] = win32yank_path .. " -i --crlf",
      },
      paste = {
        ["+"] = win32yank_path .. " -o --lf",
        ["*"] = win32yank_path .. " -o --lf",
      },
      cache_enabled = 0,
    }
    -- 启用系统剪切板
    vim.opt.clipboard = "unnamedplus"
  else
    vim.notify("win32yank.exe 未找到: " .. win32yank_path, vim.log.levels.ERROR)
  end
end
