---
source: "https://mp.weixin.qq.com/s/2EbF7cxioOr_5zrWkXAg9g"
created: 2025-08-05
---
原创 TecDeTec *2025年07月02日 00:36*

![图片](https://mmbiz.qpic.cn/mmbiz_png/6lfpre8l9tS0rHUVdTcV8icz1olZ1DSGx0H3eicWO6Gib1jkM5HphNlh3q87DiaSLfpGS1aia7nDunciaVpcDm41hD2A/640?wx_fmt=png&from=appmsg&watermark=1&tp=webp&wxfrom=5&wx_lazy=1)

## 0\. 引言

Claude Code的最新版本（1.0.38）引入了钩子（Hooks）机制，其本质是通过在Claude Code生命周期的关键节点（如 `PreToolUse` 、 `PostToolUse` 、 `Notification` 、 `Stop` ）注入用户定义的Shell命令，实现对模型行为的硬性约束和功能拓展。这套机制的真正威力不在于实现简单的自动化任务（如代码格式化或日志记录），而在于构建了一个强大的、可定制的 “智能护栏” 与 “动态反馈系统” 。

**其高阶价值体现在以下几点：**

1. 1\. **确定性控制** ：传统上，我们通过prompt工程“请求”或“建议”LLM遵守某些规则，但这无法保证100%的遵从性。钩子机制将这些软性请求硬化为代码级规则。例如，你可以通过 `PreToolUse` 钩子，利用正则表达式匹配器拦截所有 `grep` 命令，并通过返回退出码 `2` 来阻塞它，同时在 `stderr` 中向Claude反馈“请使用性能更优的 `rg` 命令”，从而强制模型学习并使用更符合团队规范的工具。
2. 2\. **闭环反馈与自主修正** ：通过 `stdin` 接收包含上下文的JSON输入，并利用 `stdout` 返回结构化的JSON指令（如 `"decision": "block"` ），钩子能实现对模型行为的实时裁决和干预。这不仅是单向的命令执行，更是一个闭环系统。一个 `PostToolUse` 钩子可以在文件写入后立即运行静态分析工具，如果发现不合规的代码，可以立即阻塞后续流程，并将具体的错误信息作为 `reason` 反馈给Claude，令其在下一次尝试中自行修正。
3. 3\. **无缝集成与环境感知** ：钩子与模型上下文协议（MCP）工具的无缝集成，意味着它可以监管和控制与外部系统（如GitHub、文件系统）的交互，极大地扩展了其应用边界。它使Claude能“感知”并严格遵守本地开发环境的特定约束和工作流。
4. 4\. **安全与权限的精细化管理** ：钩子机制是一把双刃剑，它以用户的完整权限运行，带来了强大的能力和同等的安全责任。但设计者通过配置加载的安全机制（修改不立即生效，需在 `/hooks` 菜单中审核）提供了一层缓冲，防止了恶意脚本的即时注入。

总之，Claude Code的钩子机制是一种前瞻性的设计，它超越了简单的“工具使用”，旨在通过代码化的规则和反馈，将LLM的强大推理能力引导到一条可预测、可信赖且高度定制化的轨道上，是实现LLM在严肃软件工程领域可靠应用的关键一步。

## 1\. Hooks 官方参考（译）

通过注册 shell 命令，自定义和扩展 Claude Code 的行为。

### 简介

Claude Code Hooks 是用户定义的 shell 命令，在 Claude Code生命周期的不同节点上执行。Hooks 为 Claude Code 的行为提供了确定性的控制，确保某些操作总是会发生，而不是依赖 LLM 来选择是否执行它们。

使用场景示例包括：

- • **通知** ：当 Claude Code 等待你的输入或许可来执行某项操作时，自定义通知方式。
- • **自动格式化** ：每次文件编辑后，对 `.ts` 文件运行 prettier ，对 `.go` 文件运行 gofmt 等。
- • **日志记录** ：出于合规性或调试目的，跟踪并统计所有已执行的命令。
- • **反馈** ：当 Claude Code 生成的代码不符合你的代码库规范时，提供自动反馈。
- • **自定义权限** ：阻止对生产文件或敏感目录的修改。

通过将这些规则编码为 Hooks 而不是通过提示指令，你可以将建议转化为应用级别的代码，每次都能在预期时执行。

> **警告**
> 
> Hooks 在没有确认的情况下，以你的完整用户权限执行 shell 命令。你有责任确保你的 Hooks 是安全可靠的。Anthropic 对因使用 Hooks 导致的任何数据丢失或系统损坏概不负责。请查阅 安全注意事项 <sup><span>[1]</span></sup> 。

### 快速入门

在本快速入门中，你将添加一个 Hook，用于记录 Claude Code 运行的 shell 命令。

快速入门前提条件：安装 jq ，以便在命令行中处理 JSON。

#### 步骤 1：打开 Hooks 配置

运行 **/hooks** 斜杠命令 <sup><span>[2]</span></sup> 并选择 PreToolUse Hook 事件。

PreToolUse Hooks 在工具调用之前运行，可以阻止它们，并向 Claude 提供关于如何进行不同操作的反馈。

#### 步骤 2：添加匹配器

选择 \+ Add new matcher… 以便你的 Hook 仅在 Bash 工具调用时运行。

为匹配器键入 Bash 。

#### 步骤 3：添加 Hook

选择 \+ Add new hook… 并输入此命令：

```
jq -r '"\(.tool_input.command) - \(.tool_input.description // "No description")"' >> ~/.claude/bash-command-log.txt
```

#### 步骤 4：保存配置

对于存储位置，选择 User settings ，因为你要将日志记录到你的主目录中。这样，此 Hook 将适用于所有项目，而不仅仅是当前项目。

然后按 Esc 键直到返回 REPL。你的 Hook 现在已注册！

#### 步骤 5：验证你的 Hook

再次运行 **/hooks** 或检查 ~/.claude/settings.json 文件，你会看到你的配置：

```
"hooks" :{
"PreToolUse":[
    {
      "matcher":"Bash",
      "hooks":[
        {
          "type":"command",
          "command":"jq -r '\"\\(.tool_input.command) - \\(.tool_input.description // \"No description\")\"' >> ~/.claude/bash-command-log.txt"
        }
      ]
    }
]
}
```

### 配置

Claude Code Hooks 在你的 设置文件 <sup><span>[3]</span></sup> 中进行配置：

- • ~/.claude/settings.json \- 用户设置
- • .claude/settings.json \- 项目设置
- • .claude/settings.local.json \- 本地项目设置（不应提交到版本控制）
- • 企业管理的策略设置

#### 结构

Hooks 按匹配器（matcher）组织，每个匹配器可以有多个 Hooks：

```
{
  "hooks":{
    "EventName":[
      {
        "matcher":"ToolPattern",
        "hooks":[
          {
            "type":"command",
            "command":"your-command-here"
          }
        ]
      }
    ]
}
}
```
- • **`matcher`** ：匹配工具名称的模式（仅适用于 PreToolUse 和 PostToolUse ）。
- • 简单字符串精确匹配： Write 仅匹配 Write 工具。
	- • 支持正则表达式： Edit|Write 或 Notebook.\* 。
	- • 如果省略或为空字符串，Hooks 将对所有匹配事件运行。
- • **`hooks`** ：模式匹配时要执行的命令数组。
- • **`type`** ：目前仅支持 "command" 。
	- • **`command`** ：要执行的 bash 命令。

### Hook 事件

#### PreToolUse

在 Claude 创建工具参数之后、处理工具调用之前运行。

常见的匹配器：

- • Task \- 代理任务
- • Bash \- Shell 命令
- • Glob \- 文件模式匹配
- • Grep \- 内容搜索
- • Read \- 文件读取
- • Edit 、 MultiEdit \- 文件编辑
- • Write \- 文件写入
- • WebFetch 、 WebSearch \- Web 操作

#### PostToolUse

在工具成功完成后立即运行。

识别与 PreToolUse 相同的匹配器值。

#### Notification

当 Claude Code 发送通知时运行。

#### Stop

当 Claude Code 完成响应时运行。

### Hook 输入

Hooks 通过 stdin 接收包含会话信息和事件特定数据的 JSON 数据：

```
{
  // 通用字段
  "session_id" : "string",
  "transcript_path" : "string", // 对话 JSON 的路径
  // 事件特定字段
  ...
}
```

#### PreToolUse 输入

tool\_input 的确切 schema 取决于具体的工具。

```
{
  "session_id":"abc123",
"transcript_path":"~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
"tool_name":"Write",
"tool_input":{
    "file_path":"/path/to/file.txt",
    "content":"file content"
}
}
```

#### PostToolUse 输入

tool\_input 和 tool\_response 的确切 schema 取决于具体的工具。

```
{
  "session_id":"abc123",
"transcript_path":"~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
"tool_name":"Write",
"tool_input":{
    "file_path":"/path/to/file.txt",
    "content":"file content"
},
"tool_response":{
    "filePath":"/path/to/file.txt",
    "success":true
}
}
```

#### Notification 输入

```
{
  "session_id":"abc123",
"transcript_path":"~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
"message":"Task completed successfully",
"title":"Claude Code"
}
```

#### Stop 输入

当 Claude Code 因为一个 Stop Hook 的结果而已经继续运行时， stop\_hook\_active 为 true。检查此值或处理对话记录，以防止 Claude Code 无限期运行。

```
{
  "session_id" : "abc123",
  "transcript_path" : "~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "stop_hook_active" : true
}
```

### Hook 输出

Hooks 有两种方式将输出返回给 Claude Code。输出传达了是否要阻止操作以及应向 Claude 和用户显示哪些反馈。

#### 简单方式：退出码 (Exit Code)

Hooks 通过退出码、stdout 和 stderr 来通信状态：

- • **退出码 0** ：成功。 stdout 在 transcript 模式（CTRL-R）下显示给用户。
- • **退出码 2** ：阻塞性错误。 stderr 会被反馈给 Claude 以自动处理。请参阅下面每个 Hook 事件的行为。
- • **其他退出码** ：非阻塞性错误。 stderr 显示给用户，执行继续。

#### 退出码 2 的行为

| Hook 事件 | 行为 |
| --- | --- |
| PreToolUse | 阻止工具调用，向 Claude 显示错误 |
| PostToolUse | 向 Claude 显示错误（工具已运行） |
| Notification | 不适用，仅向用户显示 stderr |
| Stop | 阻止停止，向 Claude 显示错误 |

#### 高级方式：JSON 输出

Hooks 可以在 stdout 中返回结构化的 JSON，以实现更复杂的控制：

##### 通用 JSON 字段

所有 Hook 类型都可以包含这些可选字段：

```
{
  "continue" : true,          // Hook 执行后 Claude 是否应继续（默认为 true）
  "stopReason" : "string",    // 当 continue 为 false 时显示的消息
  "suppressOutput" : true     // 从 transcript 模式中隐藏 stdout（默认为 false）
}
```

如果 `continue` 为 `false` ，Claude 在 Hooks 运行后停止处理。

- • 对于 PreToolUse ，这与 `"decision": "block"` 不同，后者只阻止特定的工具调用并向 Claude 提供自动反馈。
- • 对于 PostToolUse ，这与 `"decision": "block"` 不同，后者向 Claude 提供自动反馈。
- • 对于 Stop ，它优先于任何 `"decision": "block"` 输出。
- • 在所有情况下， `"continue": false` 优先于任何 `"decision": "block"` 输出。

`stopReason` 伴随 `continue` 一起使用，向用户显示一个原因，但不会显示给 Claude。

#### PreToolUse 决策控制

PreToolUse Hooks 可以控制工具调用是否继续。

- • **“approve”** 绕过权限系统。 reason 显示给用户，但不显示给 Claude。
- • **“block”** 阻止工具调用执行。 reason 显示给 Claude。
- • **`undefined`** (未定义) 会进入现有的权限流程。 reason 被忽略。
```
{
  "decision" : "approve" | "block" | undefined,
  "reason" : "决策的解释"
}
```

#### PostToolUse 决策控制

PostToolUse Hooks 可以控制工具调用是否继续。

- • **“block”** 会自动用 reason 提示 Claude。
- • **`undefined`** (未定义) 不执行任何操作。 reason 被忽略。
```
{
  "decision" : "block" | undefined,
  "reason" : "决策的解释"
}
```

#### Stop 决策控制

Stop Hooks 可以控制 Claude 是否必须继续。

- • **“block”** 阻止 Claude 停止。你必须填充 reason 以便 Claude 知道如何继续。
- • **`undefined`** (未定义) 允许 Claude 停止。 reason 被忽略。
```
{
  "decision" : "block" | undefined,
  "reason" : "当 Claude 被阻止停止时必须提供"
}
```

### 使用 MCP 工具

Claude Code Hooks 与 模型上下文协议（MCP）工具 <sup><span>[4]</span></sup> 无缝协作。当 MCP 服务器提供工具时，它们会以一种特殊的命名模式出现，你可以在 Hooks 中匹配这种模式。

#### MCP 工具命名

MCP 工具遵循 mcp\_\_<server>\_\_<tool> 的模式，例如：

- • mcp\_\_memory\_\_create\_entities \- Memory 服务器的创建实体工具
- • mcp\_\_filesystem\_\_read\_file \- Filesystem 服务器的读取文件工具
- • mcp\_\_github\_\_search\_repositories \- GitHub 服务器的搜索工具

#### 为 MCP 工具配置 Hooks

你可以针对特定的 MCP 工具或整个 MCP 服务器：

```
{
  "hooks":{
    "PreToolUse":[
      {
        "matcher":"mcp__memory__.*",
        "hooks":[
          {
            "type":"command",
            "command":"echo 'Memory operation initiated' >> ~/mcp-operations.log"
          }
        ]
      },
      {
        "matcher":"mcp__.*__write.*",
        "hooks":[
          {
            "type":"command",
            "command":"/home/user/scripts/validate-mcp-write.py"
          }
        ]
      }
    ]
}
}
```

### 示例

#### 代码格式化

在文件修改后自动格式化代码：

```
{
  "hooks":{
    "PostToolUse":[
      {
        "matcher":"Write|Edit|MultiEdit",
        "hooks":[
          {
            "type":"command",
            "command":"/home/user/scripts/format-code.sh"
          }
        ]
      }
    ]
}
}
```

#### 通知

自定义当 Claude Code 请求权限或当提示输入变为空闲时发送的通知。

```
{
  "hooks":{
    "Notification":[
      {
        "matcher":"",
        "hooks":[
          {
            "type":"command",
            "command":"python3 ~/my_custom_notifier.py"
          }
        ]
      }
    ]
}
}
```

### 安全注意事项

#### 免责声明

**使用风险自负** ：Claude Code Hooks 会在你的系统上自动执行任意 shell 命令。使用 Hooks 即表示你承认：

- • 你对自己配置的命令负全部责任。
- • Hooks 可以修改、删除或访问你的用户帐户可以访问的任何文件。
- • 恶意的或编写不佳的 Hooks 可能导致数据丢失或系统损坏。
- • Anthropic 不提供任何保证，也不对因使用 Hooks 造成的任何损害承担任何责任。
- • 在生产环境中使用之前，你应在安全的环境中彻底测试 Hooks。

在将任何 Hook 命令添加到你的配置之前，请务必审查和理解它们。

#### 安全最佳实践

以下是编写更安全 Hooks 的一些关键实践：

1. 1\. **验证和净化输入** \- 永远不要盲目信任输入数据。
2. 2\. **始终引用 shell 变量** \- 使用 "$VAR" 而不是 $VAR 。
3. 3\. **阻止路径遍历** \- 检查文件路径中的 ..。
4. 4\. **使用绝对路径** \- 为脚本指定完整路径。
5. 5\. **跳过敏感文件** \- 避免 .env 、.git/ 、密钥等。

#### Hook 执行详情

- • **超时** ：60 秒执行限制。
- • **并行化** ：所有匹配的 Hooks 并行运行。
- • **环境** ：在当前目录中以 Claude Code 的环境运行。
- • **输入** ：通过 stdin 传入 JSON。
- • **输出** ：
- • PreToolUse/PostToolUse/Stop：进度显示在 transcript (Ctrl-R) 中。
	- • Notification：仅记录到调试日志 (\--debug)。

#### 调试

要对 Hooks 进行故障排除：

1. 1\. 检查 **/hooks** 菜单是否显示你的配置。
2. 2\. 验证你的 设置文件 <sup><span>[5]</span></sup> 是有效的 JSON。
3. 3\. 手动测试命令。
4. 4\. 检查退出码。
5. 5\. 审查 stdout 和 stderr 的格式是否符合预期。
6. 6\. 确保正确转义引号。

进度消息会出现在 transcript 模式（Ctrl-R）中，显示：

- • 哪个 Hook 正在运行
- • 正在执行的命令
- • 成功/失败状态
- • 输出或错误消息

## 2\. 编码中使用Hook的简单案例

- • 自动格式化代码
- • 自定义通知
- • 验证输入
- • 执行外部脚本
- • 与外部系统集成
- • 调试和日志记录
- • 自动化测试和 CI/CD
- • 数据处理和转换
- • 代码分析和质量保证
- • 代码生成
- • 代码补全
- • 代码解释
- • 代码调试
- • 代码重构

概括一下大概包括编码规范/契约、质量门禁、CI/CD、环境标准化与本地化、上下文动态感知等。以上这些是Hooks最核心、最经典的应用场景。目标是让LLM输出的代码在无需人工干预的情况下，就能符合团队规范。

### 代码安全检查与质量门禁

- • 防敏感信息泄露:
- • Hook事件: PreToolUse
	- • 匹配器: Write|Edit|MultiEdit
	- • 动作: Hook 脚本接收到将要写入文件的内容，使用正则表达式或更高级的扫描工具（如 gitleaks 的库）实时扫描内容中是否包含 API Keys、数据库密码、私钥等常见敏感信息格式。
	- • 反馈: 一旦发现，立即返回 退出码2 或 {"decision": "block",...}，并向 Claude 提供明确的反馈："安全策略冲突：检测到您正尝试将API密钥硬编码写入文件。请改用环境变量或公司指定的密钥管理服务。操作已阻止。" 这不仅阻止了危险操作，还对 LLM 进行了“再教育”。
- • 生产环境“只读”模式:
- • Hook事件: PreToolUse
	- • 匹配器: Write|Edit|MultiEdit|Bash
	- • 动作: Hook 脚本检查当前 Git 分支。如果分支是 main/master 或 production/tag，则立即阻止任何文件写入或删除 (rm) 命令。
	- • 反馈: "操作已阻止。当前处于生产分支，不允许直接修改。如需更改，请创建新的特性分支。"

### 动态管理开发环境

- • 依赖自动安装:
- • Hook事件: PreToolUse
	- • 匹配器: Bash
	- • 动作: Hook 脚本解析 Claude 想要执行的 command。如果命令是 npm start 或 python app.py，脚本会先计算 package.json 或 requirements.txt 的哈希值，并与上次成功安装时的哈希值进行比较。如果不一致，它会先于 Claude 的命令自动运行 npm install 或 pip install -r requirements.txt，然后再让原始命令继续。
	- • 反馈: 无需阻塞，只需在 transcript 中打印一条信息："检测到依赖项变更，已自动为您执行 pip install。"

### 交互式代码审查与静态分析

- • 代码审查:
- • Hook事件: PostToolUse
	- • 匹配器: Write|Edit
	- • 动作: 当 Claude 修改了一个函数后，Hook 可以将这个函数的代码片段发送到另一个 LLM API（甚至是 Claude 自身的一个新实例），并附上一个特殊提示：“请为以下函数编写单元测试。” 然后，Hook 将返回的测试代码写入测试文件，并立即运行测试。
	- • 反馈: 向 Claude 报告测试结果：“我已为您刚才修改的函数自动生成并运行了3个单元测试，全部通过。干得漂亮！” 或者 “单元测试失败，错误信息如下：...，请修复您刚才的代码。”
- • 复杂代码规范执行器:
- • Hook事件: PostToolUse
	- • 匹配器: Write|Edit
	- • 动作: 不仅仅是 Prettier/Gofmt 这类格式化工具。Hook 可以在 Claude 写完代码后，运行一个完整的静态分析套件（如 SonarLint, ESLint with custom rules）。它可以检查圈复杂度、代码异味、反模式等。
	- • 反馈: 它会解析 Linter 的输出，并以非常人性化的方式反馈给 Claude：{"decision": "block", "reason": "代码审查发现几个问题：1. 'calculate\_price' 函数的圈复杂度为15（建议低于10），请尝试重构。2. 检测到在循环中进行数据库查询，可能导致性能问题。请优化。"}

### 测试用例自动生成与执行:

- • Hook事件: PostToolUse
- • 匹配器: Write|Edit
- • 动作: 当 Claude 修改了一个函数后，Hook 可以将这个函数的代码片段发送到另一个 LLM API（甚至是 Claude 自身的一个新实例），并附上一个特殊提示：“请为以下函数编写单元测试。” 然后，Hook 将返回的测试代码写入测试文件，并立即运行测试。
- • 反馈: 向 Claude 报告测试结果：“我已为您刚才修改的函数自动生成并运行了3个单元测试，全部通过。干得漂亮！” 或者 “单元测试失败，错误信息如下：...，请修复您刚才的代码。”

### 自动化与工作流

不同于与AI对话，此处的自动化与工作流是确定性的、生产可用的。

- • Git 提交信息自动生成:
- • Hook事件: Stop
	- • 匹配器: (无，全局)
- • 与项目管理工具联动:
- • Hook事件: Stop
	- • 匹配器: (无，全局)
	- • 动作: 与上一个类似，当任务完成时，Hook 不仅提交代码，还会从 Git 分支名或提交信息中解析出 Jira Ticket ID（如 PROJ-123），然后调用 Jira API，自动将这张票据的状态从 "In Progress" 更新为 "In Review"，并附上一条评论：“Claude 已完成初始实现，代码已提交。@张三 请进行代码审查。”

## 具体代码示例

```
"hooks":{
    "PreToolUse":[
      {
        "matcher":"Write|Edit|MultiEdit",
        "hooks":[
          {
            "type":"command",
            "command":"python3 ~/.claude/scripts/claude_checker.py --strategy security"
          },
          {
            "type":"command",
            "command":"python3 ~/.claude/scripts/claude_checker.py --strategy sensitive"
          },
          {
            "type":"command",
            "command":"python3 ~/.claude/scripts/claude_checker.py --strategy lint"
          },
          {
            "type":"command",
            "command":"python3 ~/.claude/scripts/claude_checker.py --strategy rules"
          }
        ]
      }
    ],
    "PostToolUse":[
      {
        "matcher":"Write|Edit|MultiEdit",
        "hooks":[
          {
            "type":"command",
            "command":"python3 ~/.claude/scripts/claude_checker.py --strategy format"
          }
        ]
      }
    ],
    "Notification":[
      {
        "matcher":"",
        "hooks":[
          {
            "type":"command",
            "command":"python3 ~/.claude/scripts/log_rotator.py --type notification"
          }
        ]
      }
    ]
  }
```
```
# 敏感信息模式 - 基于常见的敏感信息格式
    SENSITIVE_PATTERNS = [
        # API密钥和令牌
        (r'(?i)(api[_-]?key|secret[_-]?key|access[_-]?token)\s*[=:]\s*["\']([a-zA-Z0-9_-]{20,})["\']', 'API密钥/令牌可能泄露'),
        (r'(?i)(password|passwd|pwd)\s*[=:]\s*["\']([^"\']{8,})["\']', '密码可能硬编码'),
        
        # AWS访问密钥
        (r'AKIA[0-9A-Z]{16}', 'AWS访问密钥泄露'),
        (r'(?i)aws[_-]?secret[_-]?access[_-]?key.*["\']([a-zA-Z0-9/+=]{40})["\']', 'AWS密钥泄露'),
        
        # 数据库连接字符串
        (r'(?i)(mysql|postgresql|mongodb)://[^:]+:[^@]+@', '数据库连接包含凭据'),
        
        # 私钥
        (r'-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----', '私钥文件内容'),
        
        # JWT令牌
        (r'ey[A-Za-z0-9_-]*\.ey[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*', 'JWT令牌可能泄露'),
        
        # GitHub令牌
        (r'gh[pousr]_[A-Za-z0-9_]{36,}', 'GitHub令牌泄露'),
        
        # IP地址（内网）
        (r'(?:10\.|172\.(?:1[6-9]|2[0-9]|3[01])\.|192\.168\.)\d{1,3}\.\d{1,3}', '内网IP地址泄露'),
        
        # 电子邮件地址模式（可能包含敏感信息）
        (r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?=.*(?:admin|root|test|dev))', '敏感邮箱地址'),
    ]
```

至于具体的python文件如何写，就看自己的实际需要了。

运行结果：

![图片](https://mp.weixin.qq.com/s/www.w3.org/2000/svg'%20xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg%20stroke='none'%20stroke-width='1'%20fill='none'%20fill-rule='evenodd'%20fill-opacity='0'%3E%3Cg%20transform='translate(-249.000000,%20-126.000000)'%20fill='%23FFFFFF'%3E%3Crect%20x='249'%20y='126'%20width='1'%20height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

🔥推荐阅读

[DeepSeek R2因芯片短缺而延迟发布](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485398&idx=1&sn=4bbfc60c627ae1fa0ffad209504fa004&scene=21#wechat_redirect)

[谷歌说服 OpenAI 使用 TPU 芯片](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485393&idx=1&sn=fb1c1e99834e47db8360f029993c35a2&scene=21#wechat_redirect)

[Claude自主经营一家小店，曾认为自己是真人](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485387&idx=1&sn=f3b5f84612dfe43892a0db4694123211&scene=21#wechat_redirect)

[谷歌推出免费、开源的Gemini CLI](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485377&idx=1&sn=2718b0ac39e0611764e846582d8adb92&scene=21#wechat_redirect)

[AK最新演讲：我们处于软件3.0时代](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485221&idx=1&sn=c3943017566bc03984351d8578a8bd7f&scene=21#wechat_redirect)

[“AI-Ready”是AI提效和转型的前提](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485178&idx=1&sn=53e69c655d4c587211e69a774ac2c4fd&scene=21#wechat_redirect)

[Anthropic：多Agent系统比单Agent得分高90%](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485136&idx=1&sn=edb797ad4ef690562b881cd8bbe11757&scene=21#wechat_redirect)

[OpenAI山姆·奥特曼：AI奇点已至](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485083&idx=1&sn=fcdaaacee885cae36bec077fcc7b6aeb&scene=21#wechat_redirect)

[伊利亚最新演讲：AI是人类最大的挑战](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485061&idx=1&sn=7018f996cba2d09772770bd43628faf3&scene=21#wechat_redirect)

[AI原生时代，GUI转向“文本优先”的技术必然性](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485057&idx=1&sn=0ab49a9bd4f3ffbd7843acd4953a8636&scene=21#wechat_redirect)

[OpenAI关于人机关系的思考与实践](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485050&idx=1&sn=39268c00e593081927fe3ddbc7f39be8&scene=21#wechat_redirect)

[不要刻舟求剑，关于Vibe Coding的几点感想](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485006&idx=1&sn=19ff3c6bd200d6f94a82f695ae93864b&scene=21#wechat_redirect)

[写作即思考，YC创始人对“好文笔”的思考](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247484970&idx=1&sn=aa7e6f1238632ee4b1b6d74ce0091232&scene=21#wechat_redirect)

[Vibe Coding最佳实践：Windsurf的规则机制](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247484900&idx=1&sn=b44cd64e66022d6f066d29ca757e4388&scene=21#wechat_redirect)

[Vibe Coding最佳实践：Cursor的规则解析](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247484882&idx=1&sn=b261f51adb1d017f26297f07622efda9&scene=21#wechat_redirect)

[AI的下半场：从解决问题到定义问题](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247484717&idx=1&sn=cadcd05afb486c704963dc4ee95001c6&scene=21#wechat_redirect)

[谷歌：欢迎来到AI的经验时代](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247484692&idx=1&sn=3a05eec5ea6c9af31c3f4b2db0ea7a4a&scene=21#wechat_redirect)

[深度分析Google ADK vs OpenAI SDK](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247484664&idx=1&sn=26df25a9087c1916a323cc35601d581b&scene=21#wechat_redirect)

[没有prompt，一切都是上下文？](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247484523&idx=1&sn=7497623fb31fc384ba76ec36f3c1b314&scene=21#wechat_redirect)

[「模型即产品」成立吗？](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247484437&idx=1&sn=7a64025b677cc97281dec38f6ee77031&scene=21#wechat_redirect)

[如何用好AI大模型：苏格拉底式提问法](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247484418&idx=1&sn=c9a63801c07bc8c8cac23ce84fa608d3&scene=21#wechat_redirect)

#### #claude #claudecode #hook #vibecoding #anthropic #确定性

#### 引用链接

`[1]` 安全注意事项: *https://docs.anthropic.com/en/docs/claude-code/hooks#security-considerations*  
`[2]` 斜杠命令: *https://docs.anthropic.com/en/docs/claude-code/slash-commands*  
`[3]` 设置文件: *https://docs.anthropic.com/en/docs/claude-code/settings*  
`[4]` 模型上下文协议（MCP）工具: *https://docs.anthropic.com/en/docs/claude-code/mcp*  
`[5]` 设置文件: *https://docs.anthropic.com/en/docs/claude-code/settings*  

  

你的支持是我持续创作的动力！

个人观点，仅供参考

[阅读原文](https://mp.weixin.qq.com/s/)

继续滑动看下一个

AI咖啡馆

向上滑动看下一个