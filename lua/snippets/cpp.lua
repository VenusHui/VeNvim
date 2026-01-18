local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- 获取当前日期
local function get_date()
  return os.date("%Y-%m-%d")
end

-- 获取文件名（不含扩展名）
local function get_filename()
  return vim.fn.expand("%:t:r")
end

-- LuaSnip from_lua loader 需要返回 snippets 和 autosnippets 两个列表
return {
  -- ICPC 竞赛模板
  s(
    {
      trig = "ICPC",
      name = "ICPC Template",
      dscr = "ICPC 竞赛模板",
    },
    fmt(
      [[
/**
 * @platform: {}
 * @problem: {}
 * @version: {}
 * @author: VenusHui
 * @date: {}
 */
#include <bits/stdc++.h>
typedef long long ll;
typedef unsigned long long ull;
using namespace std;

int main() {{
  ios_base::sync_with_stdio(false);
  cin.tie(nullptr);
  cout.tie(nullptr);
  {}
  return 0;
}}
]],
      {
        i(1, "platform"),
        f(get_filename, {}),
        i(2, "version"),
        f(get_date, {}),
        i(3, ""),
      }
    )
  ),
}, {}
