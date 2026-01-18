return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    -- 确保配置被正确合并
    opts.defaults = opts.defaults or {}
    opts.pickers = opts.pickers or {}
    
    -- 在 defaults 中设置全局选项
    opts.defaults.hidden = true
    opts.defaults.no_ignore = true
    opts.defaults.no_ignore_parent = true
    
    -- 在 find_files picker 中明确设置
    opts.pickers.find_files = opts.pickers.find_files or {}
    opts.pickers.find_files.hidden = true
    opts.pickers.find_files.no_ignore = true
    opts.pickers.find_files.no_ignore_parent = true
    
    -- 如果系统有 fd，使用它来获得更好的性能
    if vim.fn.executable("fd") == 1 then
      opts.pickers.find_files.find_command = {
        "fd",
        "--type",
        "f",
        "--hidden",
        "--no-ignore",
        "--strip-cwd-prefix",
      }
    elseif vim.fn.executable("rg") == 1 then
      opts.pickers.find_files.find_command = {
        "rg",
        "--files",
        "--hidden",
        "--no-ignore",
      }
    else
      -- 使用 find 命令，不通过 git，这样可以显示 gitignore 文件
      opts.pickers.find_files.find_command = {
        "find",
        ".",
        "-type",
        "f",
      }
      -- 禁用 git_files，强制使用 find_files
      opts.pickers.git_files = nil
    end
    
    return opts
  end,
  keys = {
    -- 覆盖默认的 <leader>ff，使用 find_files 而不是 git_files
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files({
          hidden = true,
          no_ignore = true,
          no_ignore_parent = true,
        })
      end,
      desc = "Find Files (including gitignore)",
    },
    -- 添加一个使用 git_files 的备用 keymap（如果需要）
    {
      "<leader>fg",
      function()
        require("telescope.builtin").git_files()
      end,
      desc = "Find Git Files",
    },
  },
}
