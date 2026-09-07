-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Terminal 模式下按 Esc 退出到 Normal 模式
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- 命令行模式下使用 Ctrl+j/Ctrl+k 选择补全项
vim.keymap.set("c", "<C-j>", "<C-n>", { desc = "Next completion" })
vim.keymap.set("c", "<C-k>", "<C-p>", { desc = "Prev completion" })

local function run_cpp(use_input)
  local compiler = vim.fn.exepath("g++")
  if compiler == "" then
    return vim.notify("g++ 未安装或不在 PATH 中", vim.log.levels.ERROR)
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return vim.notify("请先保存当前 C++ 文件", vim.log.levels.WARN)
  end

  vim.cmd.write()

  local dir = vim.fs.dirname(file)
  local input = vim.fs.joinpath(dir, "input.txt")
  if use_input and vim.fn.filereadable(input) == 0 then
    return vim.notify("未找到 " .. input, vim.log.levels.WARN)
  end

  local output = vim.fn.tempname()
  local compile_args = {
    compiler,
    "-std=gnu++20",
    "-Wall",
    "-Wextra",
    "-Wpedantic",
    "-g",
    file,
    "-o",
    output,
  }
  local compile = table.concat(vim.tbl_map(vim.fn.shellescape, compile_args), " ")
  local run = vim.fn.shellescape(output)
  if use_input then
    run = run .. " < " .. vim.fn.shellescape(input)
  end

  local cleanup = "status=$?; rm -f " .. vim.fn.shellescape(output) .. "; exit $status"
  local command = compile .. " && " .. run .. "; " .. cleanup
  local height = math.max(10, math.floor(vim.o.lines / 3))

  vim.cmd("botright " .. height .. "split")
  vim.cmd.enew()
  vim.fn.jobstart(command, { cwd = dir, term = true })
  vim.cmd.startinsert()
end

local function set_cpp_runner_keymaps(buffer)
  vim.keymap.set("n", "<leader>rr", function()
    run_cpp(true)
  end, { buffer = buffer, desc = "Run C++ with input.txt" })
  vim.keymap.set("n", "<leader>rc", function()
    run_cpp(false)
  end, { buffer = buffer, desc = "Run C++" })
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("cpp_runner_keymaps", { clear = true }),
  pattern = "cpp",
  callback = function(event)
    set_cpp_runner_keymaps(event.buf)
  end,
})

for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
  if vim.bo[buffer].filetype == "cpp" then
    set_cpp_runner_keymaps(buffer)
  end
end
