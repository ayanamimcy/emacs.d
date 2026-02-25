# 个人 Emacs 配置说明

> 本配置主要基于 remacs.fun 提供的入门系列文章进行整理与取舍，并在其基础上加入了一些个人偏好的细节调整。完整教程可在 remacs.fun/posts 查看。  

## 目录结构
- `early-init.el`：启动前的性能与界面裁剪。
- `init.el`：包源、`use-package`/`quelpa` 设置，以及模块化加载。
- `lisp/init-ui.el`：主题、字体、窗口尺寸、状态栏等 UI 相关定制。
- `lisp/init-edit.el`：编辑体验（备份、自动保存、快捷键屏蔽、自动重载）。
- `lisp/init-org.el`：`org-auto-tangle`，保存时自动导出配置。
- `emacs-config.org`：Org Babel 配置母本，修改后会自动 tangle 为上述文件。

## 快速上手
1) 启动 Emacs 即会按照 `emacs-config.org` 已导出的 Lisp 文件加载，无需额外手动步骤。  
2) 若更新了 `emacs-config.org`，在 Org 模式下保存会由 `org-auto-tangle` 自动同步到对应 `.el` 文件。  
3) 主题：`C-c t` 在已安装的 Ef 主题间切换，默认随机挑选明/暗主题（macOS 下随系统外观自动切换）。  
4) 字体：图形界面使用 `Source Code Pro` 为等宽基准，并按系统可用字体自动为中文与 emoji 设置 fallback。  
5) 包管理：默认启用 MELPA / GNU / NonGNU 源；`use-package` 与 `quelpa` 已就绪，可直接在配置中声明包。  

## 个人化要点
- **界面**：启动即最大化；关闭菜单/工具/滚动条；`doom-modeline`+`minions` 精简模式栏；`keycast` 展示当前按键。  
- **主题偏好**：通过 `ef-themes` 随机加载（终端会强制暗色系），并提供系统外观钩子保持一致。  
- **字体策略**：`fontaine` 预设 `regular`、`large` 两档；中文与 emoji 自动匹配本机可用字体并调整缩放比例。  
- **窗口与滚动**：根据屏幕尺寸计算默认窗口大小；优化滚动参数与禁用自动垂直滚动以提升流畅度。  
- **编辑体验**：关闭自动备份与自动保存；选择替换模式；`s-u` 快速刷新缓冲区；常见确认对话框自动默认同意。  
- **Org 工作流**：`org-auto-tangle` 默认开启，保持 Org 源与 Lisp 目标文件一致。  

## 鸣谢
- remacs.fun 系列文章的结构化指导与范例配置。  
- 社区主题与字体方案：`ef-themes`、`fontaine`、`doom-modeline` 等优秀包作者。  

如需扩展或调整，建议直接编辑 `emacs-config.org`，保存后即可同步生效。欢迎基于此 README 继续添加你的个性化注释与使用心得。
