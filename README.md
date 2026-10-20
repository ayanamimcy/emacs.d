# emacs.d

个人 Emacs 配置，Mac 和 Linux 共用。主要用途：日程管理、工作记录、笔记、博客，加上轻量写代码。

分层加载，选项集中在 `init-custom.el`，每台机器的差异写在不进 git 的 `custom.el`。需要 **Emacs 30.1 以上**。

## 安装

### Mac（主力）

```sh
brew tap d12frosted/emacs-plus
brew install emacs-plus ripgrep coreutils
brew install --cask font-sarasa-gothic font-symbols-only-nerd-font

git clone git@github.com:ayanamimcy/emacs.d.git ~/.config/emacs
```

按 `brew` 安装完提示的方法把 Emacs.app 放进“应用程序”。第一次启动会自动下载所有包，要等一两分钟。

系统设置 → 键盘 → 键盘快捷键 → 修饰键：把 **Caps Lock 改成 Control**。

tree-sitter 语法要在本机编译，需要 C 编译器：`xcode-select --install`。

### Linux（CachyOS，偶尔用）

```sh
sudo pacman -S --needed emacs-wayland ttf-sarasa-gothic ttf-nerd-fonts-symbols-mono ripgrep
git clone git@github.com:ayanamimcy/emacs.d.git ~/.config/emacs
systemctl --user enable --now emacs      # 常驻 daemon
```

之后用 `emacsclient -c`（图形窗口）或 `emacsclient -t`（终端）打开。从 Mac 上用：

```sh
ssh <这台机器> -t emacsclient -t
```

在终端里用时 Cmd 当不了 Meta，要在终端程序里把 **Option 设成 Meta**（iTerm2：Profiles → Keys → Left Option key = Esc+；
Ghostty：`macos-option-as-alt = true`）。复制的内容会通过 OSC 52 送到 Mac 剪贴板（iTerm2 要在设置里允许终端访问剪贴板；Terminal.app 不支持）。

## 结构

```
early-init.el          启动早期：GC、去掉工具栏
init.el                入口，按顺序加载下面的模块
custom-example.el      custom.el 的模板
lisp/
  init-const.el        系统判断 sys/macp、sys/linuxp
  init-custom.el       所有选项（my-*）
  init-funcs.el        工具函数、管理配置的命令
  init-package.el      读 custom.el、软件源、use-package
  init-base.el         编码、备份、历史、server、Mac 键位
  init-ui.el           字体、主题、mode-line、图标
  init-edit.el         自动重新载入、撤销树、快速跳转
  init-completion.el   vertico / orderless / consult / embark，支持拼音首字母
  init-calendar.el     农历、中国和日本节假日
  init-org.el          日程、任务、capture、工作记录
  init-markdown.el     Markdown
  init-dired.el        文件管理（dired）
  init-shell.el        终端（eat）
  init-vcs.el          git（magit、diff-hl）
  init-prog.el         项目、tree-sitter、eglot、flymake
```

### 本机设置

- `custom.el`：第一次启动时从 `custom-example.el` 复制，**不进 git**。改 org 目录、字号、主题等用 `setq` 写在这里，
  选项见 `lisp/init-custom.el`。`M-x my-open-custom` 打开。
- `custom-post.el`：可选，所有模块加载完后才加载，用来覆盖模块里的设置。

### 更新

- 配置：`M-x my-update-config`（`git pull`），然后重启 Emacs
- 包：`M-x package-upgrade-all`

## org 文件

都在 `my-org-directory`（默认 `~/org/`），同步由自己负责：

| 文件 | 用途 |
|---|---|
| `inbox.org` | 所有临时想法、任务先记到这里 |
| `tasks.org` | 整理后的任务和日程 |
| `journal.org` | 工作记录，按年/月/日自动分层 |

agenda 读 `inbox.org` 和 `tasks.org`。文件不存在时第一次 capture 会自动创建。

任务状态：`TODO` → `NEXT`（正在做）→ `WAIT`（等别人，要写原因）→ `DONE` / `CANCELLED`。
iOS 上用 Beorg 时，要在 Beorg 的设置里加上 `NEXT`、`WAIT`、`CANCELLED`。

**在 agenda 里显示节假日**：在 `tasks.org` 里加一个标题：

```org
* 节假日
:PROPERTIES:
:CATEGORY: 假日
:END:
%%(org-calendar-holiday)
```

## 常用按键

更完整的速查（Emacs 基础、本配置的按键、Org 按键和语法，可筛选）：[Emacs 与 Org 速查](https://claude.ai/artifact/NKVCaoywSZhVnuGnebscKe)

| 按键 | 作用 |
|---|---|
| `C-h t` | 内置教程 |
| `C-h k` 再按一个键 | 查这个键是做什么的 |
| `C-c c` | capture：`t` 任务、`n` 随手记、`j` 工作记录、`m` 会议 |
| `C-c a` | agenda |
| `C-c o d` | 今天：日程 + 正在做 + 收件箱 |
| `C-c o i` / `C-c o t` | 打开 inbox / tasks |
| `C-c o s` | 在 org 目录里全文搜索 |
| `C-c o h` | 在所有任务的标题里跳转 |
| `C-c C-t` | 改任务状态 |
| `C-c C-s` / `C-c C-d` | 设开始日期 / 截止日期 |
| `C-c C-w` | 把条目移到别的标题下（整理收件箱） |
| `C-x b` | 切换 buffer / 最近的文件 |
| `C-s` / `M-s l` | 在当前文件里搜索：列出所有匹配的行，浮在窗口中间，支持拼音首字母。选中了文字时用它作为关键词；`M-n` 按一次填入当前行、两次填入光标处的词 |
| `C-r` / `C-M-s` | 原来的逐个跳转搜索（向上 / 正则）。搜索中按 `M-s l` 带着已输入的词转到上面的列表，`M-e` 从搜索历史里选 |
| `M-s r` | 在当前项目 / 目录里全文搜索 |
| `C-;` | 跳到屏幕上的某个位置（支持拼音首字母） |
| `C-.` | 对当前候选项执行动作 |
| `C-x u` | 撤销树 |
| `F5` | 切换亮色 / 暗色主题 |
| `` C-` `` / `C-c t` | 在底部弹出 / 收起终端（终端里的 Emacs 只能用 `C-c t`） |
| `C-x d` / `C-x C-j` | 打开目录 / 当前文件所在的目录 |
| `C-x g` | magit：当前仓库的状态 |
| `C-c g` | magit：当前文件的 blame、历史等 |
| `C-x p p` | 切换项目 |
| `C-x p f` / `C-x p g` | 在项目里找文件 / 全文搜索 |
| `M-.` / `M-,` | 跳到定义 / 跳回来 |
| `M-n` / `M-p` | 下一个 / 上一个错误 |
| `C-c e r` / `C-c e a` / `C-c e f` | 重命名 / 代码操作 / 格式化（需要语言服务器） |

补全时可以用拼音首字母筛选中文，比如 `gzjl` 能匹配“工作记录”。

org 里只有 `a_{b}` / `a^{b}` 显示成上下标，`a_b` 原样显示（导出也是）。

### 浮动窗口

图形界面里，补全列表（`M-x`、`C-x b`、查找文件等）、按键提示（which-key）和 magit 的命令菜单显示在窗口中间偏下的
浮动窗口（child frame，vertico-posframe / which-key-posframe / transient-posframe）里。终端里（`emacsclient -t`）
用不了浮动窗口，自动在底部显示。daemon 每开一个窗口都会重新判断。
想一直在底部显示：`custom.el` 里 `(setq my-completion-style 'minibuffer)`。

Mac 上 Cmd 是 Meta（`M-x` 就是 Cmd+X），Option 是 Super。

## 文件管理

dired 里常用：`RET` 打开、`^` 上一级、`m` / `u` 标记 / 取消、`C` 复制、`R` 重命名或移动、
`D` 删除（删到废纸篓）、`+` 新建目录、`C-x C-q` 把列表当文本改（批量重命名，`C-c C-c` 保存）。
两个 dired 窗口并排时，复制和移动的目标默认是另一个窗口。Mac 上装了 coreutils 才会把目录排在前面。

## 写代码

- **补全**：写代码时输入两个字符自动弹出候选；写文字时按 `TAB`（已经缩进好时）或 `C-M-i` 才弹出。
- **tree-sitter**：第一次打开某种语言的文件时会问要不要下载这种语言的语法（下载后在本机编译，几秒钟），
  装好后高亮和缩进更准确（重新打开文件生效）。不下载也能用，用的是原来的模式；Go、Rust、TypeScript 这些
  Emacs 没有自带模式的语言除外，要下载语法才有高亮。语法放在配置目录的 `tree-sitter/` 里。
- **eglot（LSP）**：打开代码文件时，装了对应语言服务器的自动连上，提供跳转、补全、报错、重命名；
  没装的语言不会提示。常用的语言服务器：

  | 语言 | 语言服务器 | Mac 安装 |
  |---|---|---|
  | Python | basedpyright 或 pylsp | `uv tool install basedpyright` |
  | JavaScript / TypeScript | typescript-language-server | `npm i -g typescript-language-server typescript` |
  | Go | gopls | `go install golang.org/x/tools/gopls@latest` |
  | Rust | rust-analyzer | `rustup component add rust-analyzer` |
  | C / C++ | clangd | Xcode Command Line Tools 自带 |
  | Bash | bash-language-server | `npm i -g bash-language-server` |

  Mac 上从 Dock 启动的 Emacs 会从登录 shell 读取 PATH，装在 `~/.local/bin`、`~/go/bin` 等处的程序也能找到。
- **magit**：`C-x g` 打开状态页，`s` 暂存、`u` 取消暂存、`c c` 提交（写完说明 `C-c C-c`）、`P p` push、
  `F p` pull、`l l` 看历史，`?` 列出所有命令。行号旁边的颜色条标出改过的行。
- **终端**：`` C-` `` 在底部弹出终端，在项目里时目录是项目根目录，每个项目一个终端。
  终端里按键基本都发给 shell，`C-x`、`M-x` 等仍是 Emacs 的；`C-c C-e` 切到可以像普通 buffer 一样移动、复制的模式，`C-c C-j` 回来。

## 以后

1. 笔记：denote（md 和 org 都支持）
2. 博客：ox-hugo + Hugo
