# Navix

## UI

### 框架

'''
Column
├── TitleBar
├── Row
│   ├── LeftTriggerBar
│   ├── Column
│   │   └── LeftPanel
│   ├── MainCanvas
│   ├── Column
│   │   └── RightPanel
│   └── RightTriggerBar
└── StatusBar


### TitleBar

TitleBar (ComponentV2, @ComponentV2)
└── Row
├── Row (space: 8)
│   ├── Image (app_icon, 24x24)
│   ├── SymbolGlyph (square_grid_2x2, 20fp)
│   └── SymbolGlyph (lightbulb, 20fp)
├── Blank
├── Row (space: 6)
│   ├── SymbolGlyph (backward_end_fill, 18fp, onClick → store.currentStep=0)
│   ├── SymbolGlyph (play_fill, 18fp)
│   ├── SymbolGlyph (forward_end_fill, 18fp, onClick → store.nextStep())
│   └── Text ("步骤 {currentStep}/{searchSteps.length}")
├── Blank
└── Row (space: 10)
├── SymbolGlyph (gearshape, 20fp)
├── SymbolGlyph (minus, 20fp)
├── SymbolGlyph (square, 20fp)
└── SymbolGlyph (xmark, 20fp)

### StatusBar

StatusBar (ComponentV2, @ComponentV2)
└── Row
├── SymbolGlyph (moon_fill, 18fp, onClick → toggleTheme())
├── Row (space: 4, layoutWeight: 1)
│   ├── Text ("● {statusText}")
│   ├── Text (" | ")
│   ├── Text ("地图大小: {cols}×{rows}")
│   ├── Text (" | ")
│   ├── Text ("搜索节点: {searchedNodes}")
│   ├── Text (" | ")
│   ├── Text ("路径长度: {pathLength}")
│   ├── Text (" | ")
│   ├── Text ("时间: {elapsedTime}ms")
│   └── Text (" | ")
└── Row (space: 6)
├── Text ("缩放", 11fp)
├── Slider (width: 110, min: 10, max: 300, step: 1)
├── TextInput (type: Number, width: 44, height: 24)
└── Text ("%", 11fp)