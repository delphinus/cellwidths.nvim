# cellwidths.nvim

Yet another `setcellwidths()` wrapper.

English version README is here →[README.en.md][]

## これは何？

関数 [`setcellwidths()`][setcellwidths] の設定を簡単にするプラグインです。この関数は以下のようにして使います。

[setcellwidths]: https://neovim.io/doc/user/builtin.html#setcellwidths()

```vim
call setcellwidths([[0x2103, 0x2103, 2], [0x2160, 0x2169, 2]])
```

引数には `[開始, 終了, 文字幅]` という配列の配列を指定するのですが、いくつかの理由から直接指定するのが困難です。

* 現在指定している値を後から参照出来ない。
* 値の追加、削除は出来ず、全ての配列を毎回指定しないといけない。
* [`'listchars'`][listchars] や [`'fillchars'`][fillchars] に指定した値と被っていると設定に失敗する。

[listchars]: https://neovim.io/doc/user/options.html#'listchars'
[fillchars]: https://neovim.io/doc/user/options.html#'fillchars'

このプラグインはこれらを解決します。

## インストール

[`'packpath'`][packpath] 配下のディレクトリにクローンして下さい。

[packpath]: https://neovim.io/doc/user/options.html#'packpath'

```sh
git clone https://github.com/delphinus/cellwidths.nvim \
  ~/.local/share/nvim/site/pack/foo/start/cellwidths.nvim
```

または、好きなプラグインマネージャーを使って下さい。

```lua
-- for packer.nvim
use {
  "delphinus/cellwidths.nvim",
  config = function()
    -- 'listchars' と 'fillchars' を事前に設定しておくのがお勧めです。
    -- vim.opt.listchars = { eol = "⏎" }
    -- vim.opt.fillchars = { eob = "‣" }
    require("cellwidths").setup {
      name = "default",
    }
  end,
}
```

## 使い方

予め定められた値を利用するにはテンプレート名を指定して呼び出して下さい。

```lua
require("cellwidths").setup { name = "default" }
```

オリジナルの設定を作りたい場合は以下のようにして下さい。

```lua
local cw = require "cellwidths"
-- 空っぽの設定から始める場合は { name = "empty" }
cw.setup { name = "default" }

-- 好きな設定を追加します。以下のどの書式でも構いません。
cw.add(0x2103, 2)
cw.add { 0x2160, 0x2169, 2 }
cw.add {
  { 0x2170, 0x2179, 2 },
  { 0x2190, 0x2193, 2 },
}

-- 名前を付けて保存
cw.save "foobar"

-- 次回からはその名前で呼び出せます。"user/" を頭に付けて下さい。
require("cellwidths").setup { name = "user/foobar" }
```

より詳しい使い方は[ヘルプ][doc/cellwidths.jax]を見て下さい。

## リンク

- [rbtnn/vim-ambiwidth: This plugin provides a set of setcellwidths() for Vim that the ambiwidth is single.](https://github.com/rbtnn/vim-ambiwidth)
- [miiton/Cica: プログラミング用日本語等幅フォント Cica(シカ)](https://github.com/miiton/Cica)
- [delphinus/homebrew-sfmono-square: SFMono Square - patched font: SFMono + Migu 1M + Nerd Fonts](https://github.com/delphinus/homebrew-sfmono-square)
