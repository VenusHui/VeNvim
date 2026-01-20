-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Terminal 模式下按 Esc 退出到 Normal 模式
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- 命令行模式下使用 Ctrl+j/Ctrl+k 选择补全项
vim.keymap.set("c", "<C-j>", "<C-n>", { desc = "Next completion" })
vim.keymap.set("c", "<C-k>", "<C-p>", { desc = "Prev completion" })

-- C++ 编译运行（类似 Code Runner）
vim.keymap.set("n", "<leader>rr", function()
  -- 保存当前文件
  vim.cmd("write")
  
  local file = vim.fn.expand("%:p") -- 完整路径
  local dir = vim.fn.expand("%:p:h") .. "/" -- 目录路径
  local fileName = vim.fn.expand("%:t") -- 文件名
  local fileNameWithoutExt = vim.fn.expand("%:t:r") -- 不带扩展名的文件名
  
  -- 构建命令
  local cmd = string.format(
    "cd %s && g++ %s -o %s && ./%s < input.txt && rm %s",
    dir,
    fileName,
    fileNameWithoutExt,
    fileNameWithoutExt,
    fileNameWithoutExt
  )
  
  -- 在终端中运行（高度为窗口的 1/3）
  local height = math.floor(vim.o.lines / 3)
  vim.cmd("botright " .. height .. "split | terminal " .. cmd)
end, { desc = "Run C++ with input.txt" })

-- C++ 编译运行（不使用 input.txt）
vim.keymap.set("n", "<leader>rc", function()
  -- 保存当前文件
  vim.cmd("write")
  
  local dir = vim.fn.expand("%:p:h") .. "/"
  local fileName = vim.fn.expand("%:t")
  local fileNameWithoutExt = vim.fn.expand("%:t:r")
  
  local cmd = string.format(
    "cd %s && g++ %s -o %s && ./%s && rm %s",
    dir,
    fileName,
    fileNameWithoutExt,
    fileNameWithoutExt,
    fileNameWithoutExt
  )
  
  -- 在终端中运行（高度为窗口的 1/3）
  local height = math.floor(vim.o.lines / 3)
  vim.cmd("botright " .. height .. "split | terminal " .. cmd)
end, { desc = "Run C++ without input" })
