# emacs.d

个人 Emacs 配置，Mac 和 Linux 共用。主要用途：日程管理、工作记录、笔记、博客，加上轻量写代码。

框架参照 [Centaur Emacs](https://github.com/seagle0128/.emacs.d)：分层加载、选项集中在 `init-custom.el`、
每台机器的差异写在不进 git 的 `custom.el`。内容只保留用得到的部分。需要 **Emacs 30.1 以上**。

## 安装

### Mac（主力）

```sh
brew tap d12frosted/emacs-plus
brew install emacs-plus ripgrep
brew install --cask font-sarasa-gothic font-symbols-only-nerd-font

git clone git@github.com:ayanamimcy/emacs.d.git ~/.config/emacs
```

按 `brew` 安装完提示的方法把 Emacs.app 放进“应用程序”。第一次启动会自动下载所有包，要等一两分钟。

系统设置 → 键盘 → 键盘快捷键 → 修饰键：把 **Caps Lock 改成 Control**。

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
| `M-s l` / `M-s r` | 在当前文件 / 当前目录里搜索 |
| `C-;` | 跳到屏幕上的某个位置（支持拼音首字母） |
| `C-.` | 对当前候选项执行动作 |
| `C-x u` | 撤销树 |
| `F5` | 切换亮色 / 暗色主题 |

补全时可以用拼音首字母筛选中文，比如 `gzjl` 能匹配“工作记录”。

Mac 上 Cmd 是 Meta（`M-x` 就是 Cmd+X），Option 是 Super。

## 以后

1. 笔记：denote（md 和 org 都支持）
2. 博客：ox-hugo + Hugo
3. 写代码：magit、eglot、tree-sitter、corfu
