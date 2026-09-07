return {
  {
    "L3MON4D3/LuaSnip",
    opts = {
      history = false,
      region_check_events = "CursorMoved",
      delete_check_events = "TextChanged",
    },
    config = function(_, opts)
      require("luasnip").setup(opts)
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/lua/snippets" },
      })
    end,
  },
}
