# cellwidths.nvim

Yet another `setcellwidths()` wrapper.

<!-- English version README is here →[README.en.md](/README.en.md) -->

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

### テンプレートを使う

予め定められた値を利用するにはテンプレート名を指定して呼び出して下さい。

```lua
require("cellwidths").setup { name = "default" }
```

オリジナルの設定を作りたい場合は以下のようにして下さい。`fallback()` 関数で呼ばれた内容がファイルに保存され、次回起動時からは高速に読み込まれます。

```lua
require("cellwidths").setup {
  name = "user/custom",
  ---@param cw cellwidths
  fallback = function(cw)
    -- 特定のテンプレートから追加・削除を行いたい場合は最初に load() を呼んで下さい。
    -- cw.load "default"

    -- 好きな設定を追加します。以下のどの書式でも構いません。
    cw.add(0x2103, 2)
    cw.add { 0x2160, 0x2169, 2 }
    cw.add {
      { 0x2170, 0x2179, 2 },
      { 0x2190, 0x2193, 2 },
    }

    -- 削除も出来ます。設定に存在しないコードポイントを指定してもエラーになりません。
    cw.delete(0x2103)
    cw.delete { 0x2104, 0x2105, 0x2106 }
  end,
}
```

### コマンドを使う

Neovim を起動中にオンデマンドで設定を変更することも可能です。

```vim
" 「℃」を全角で扱います。
:CellWidthsAdd 0x2103, 2
" 設定を削除します。
:CellWidthsDelete 0x2103
" テンプレートを読み込みます。
:CellWidthsLoad default
" （現在利用中の）テンプレートを削除します。
:CellWidthsRemove
```

より詳しい使い方は[ヘルプ](/doc/cellwidths.jax)を見て下さい。

## リンク

- [rbtnn/vim-ambiwidth: This plugin provides a set of setcellwidths() for Vim that the ambiwidth is single.](https://github.com/rbtnn/vim-ambiwidth)
- [miiton/Cica: プログラミング用日本語等幅フォント Cica(シカ)](https://github.com/miiton/Cica)
- [delphinus/homebrew-sfmono-square: SFMono Square - patched font: SFMono + Migu 1M + Nerd Fonts](https://github.com/delphinus/homebrew-sfmono-square)
