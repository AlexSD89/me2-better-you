# 🎨 智能UI组件选择器

## 核心功能
Claude Code Subagents的智能UI组件库访问和选择决策系统

## 组件库资源映射

### React生态系统
```yaml
shadcn/ui:
  访问方式: "mcp__shadcn-ui__get_component"
  使用场景: "基础UI组件，现代设计系统"
  优势: "TypeScript支持，Tailwind CSS集成，高度可定制"
  命令示例: "mcp__shadcn-ui__get_component button"

Material UI:
  访问方式: "WebFetch(domain:mui.com)"
  使用场景: "企业级应用，复杂数据展示"
  优势: "Google Material Design，丰富组件生态"
  文档路径: "https://mui.com/material-ui/getting-started/"

React Bits:
  访问方式: "WebFetch(domain:reactbits.dev)"
  使用场景: "动画效果，用户体验增强"  
  优势: "精美动画，交互效果丰富"
  组件示例: "https://www.reactbits.dev/text-animations/"
```

### Vue生态系统
```yaml
Vue Bits:
  访问方式: "WebFetch(domain:github.com) → DavidHDev/vue-bits"
  使用场景: "Vue.js动画组件"
  优势: "与React Bits同源，Vue专用实现"
  GitHub: "https://github.com/DavidHDev/vue-bits"
```

### 设计工具集成
```yaml
TweakCN:
  访问方式: "WebFetch(domain:tweakcn.jnsahaj.dev)"
  使用场景: "shadcn/ui主题可视化编辑"
  功能: "无代码主题编辑器，CSS变量导出"
  特色: "支持Tailwind v3/v4，OKLCH/HSL颜色模式"
```

## Agent决策逻辑

### Frontend-Developer Agent选择流程
```typescript
interface ComponentSelectionCriteria {
  projectType: 'react' | 'vue' | 'nextjs' | 'nuxt'
  complexity: 'simple' | 'medium' | 'enterprise'
  animationNeeds: boolean
  designSystem: 'cloudsway' | 'material' | 'custom'
  performance: 'high' | 'medium' | 'standard'
}

function selectOptimalComponent(criteria: ComponentSelectionCriteria) {
  // 1. 技术栈检测
  if (criteria.projectType === 'react' || criteria.projectType === 'nextjs') {
    
    // 2. 基础组件优先选择shadcn/ui
    if (criteria.complexity === 'simple' || criteria.designSystem === 'cloudsway') {
      return useShadcnUI()
    }
    
    // 3. 企业级复杂应用选择Material UI
    if (criteria.complexity === 'enterprise') {
      return useMaterialUI()
    }
    
    // 4. 动画需求选择React Bits
    if (criteria.animationNeeds) {
      return useReactBits()
    }
  }
  
  // 5. Vue项目使用Vue Bits
  if (criteria.projectType === 'vue' && criteria.animationNeeds) {
    return useVueBits()
  }
}
```

### 实际使用示例

#### Scenario 1: 基础React组件开发
```bash
# Agent自动选择shadcn/ui
mcp__shadcn-ui__get_component button
mcp__shadcn-ui__get_component_demo button

# 获取主题定制方案
WebFetch(domain:tweakcn.jnsahaj.dev) "shadcn button theme customization"
```

#### Scenario 2: 动画增强需求
```bash
# 先检查React Bits可用动画
WebFetch(domain:reactbits.dev) "text animations falling text"

# 结合shadcn基础组件
mcp__shadcn-ui__get_component card

# E2B测试环境验证
mcp__e2b-code-interpreter__create_sandbox
mcp__e2b-code-interpreter__execute_code "npm install react-bits"
```

#### Scenario 3: 企业级数据展示
```bash
# Material UI表格组件
WebFetch(domain:mui.com) "DataGrid advanced features"

# 获取完整API文档
WebFetch(domain:mui.com) "material-ui table pagination sorting"

# GitHub源码参考
mcp__github-official__search_code "mui DataGrid example"
```

## 智能缓存策略

### 组件信息缓存
```yaml
缓存机制:
  shadcn组件: "mcp__shadcn-ui__list_components → 本地缓存24小时"
  文档页面: "WebFetch结果缓存6小时"
  GitHub代码: "mcp__github-official__* 缓存12小时"
  
更新策略:
  主动更新: "检测package.json变化时重新获取"
  被动更新: "缓存过期时自动刷新"
  智能预取: "根据项目类型预加载相关组件信息"
```

## 性能优化指导

### 组件选择优先级
```yaml
性能考虑:
  Bundle Size: "shadcn/ui < React Bits < Material UI"
  加载速度: "按需加载 > 全量导入"
  运行时性能: "原生组件 > 重度封装组件"
  
最佳实践:
  基础组件: "优先选择shadcn/ui轻量级实现"
  动画组件: "仅在需要时添加React Bits"
  复杂组件: "Material UI提供完整功能"
  主题定制: "使用TweakCN可视化编辑"
```

## 使用方法

Agent在开发UI组件时会自动：
1. 分析项目技术栈和需求
2. 根据决策树选择最优组件库
3. 通过MCP工具获取组件代码和文档
4. 在E2B环境中测试组件功能
5. 返回经过验证的可用代码

这个系统让零代码背景用户能够通过自然语言获得专业级的UI组件选择和实现。