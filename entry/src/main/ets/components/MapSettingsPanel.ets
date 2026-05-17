import { NavixStore, navixStore } from '../store/NavixStore'
import { RightPanelState, MapType } from '../models/MapTypes'
import { KeyCode } from '@kit.InputKit'

const backgroundColors: string[] = ['#FFFFFF', '#1A1A1A', '#2D2D2D', '#3A3A3A', '#4A4A4A', '#5A5A5A']
const backgroundColorsMore1: string[] = ['#F5F5F5', '#E0E0E0', '#BDBDBD', '#9E9E9E', '#757575', '#616161']
const backgroundColorsMore2: string[] = ['#FFEBEE', '#E3F2FD', '#E8F5E9', '#FFFDE7', '#F3E5F5', '#E0F7FA']
const backgroundColorsMore3: string[] = ['#F44336', '#E91E63', '#9C27B0', '#3F51B5', '#2196F3', '#009688']
const gridLineColors: string[] = ['#DDDDDD', '#AAAAAA', '#888888', '#666666', '#444444', '#333333']
const gridLineColorsMore1: string[] = ['#E0E0E0', '#BDBDBD', '#9E9E9E', '#757575', '#616161', '#424242']
const gridLineColorsMore2: string[] = ['#FFCDD2', '#BBDEFB', '#C8E6C9', '#FFF9C4', '#E1BEE7', '#B2EBF2']

@ComponentV2
export struct MapSettingsPanel {
  @Local store: NavixStore = navixStore
  @Local hoveredMapType: MapType | null = null
  @Local showMoreBackgroundColors: boolean = false
  @Local showMoreGridLineColors: boolean = false
  @Local gridColsText: string = `${navixStore.params.gridCols}`
  @Local gridRowsText: string = `${navixStore.params.gridRows}`
  @Local gridColsValid: boolean = true
  @Local gridRowsValid: boolean = true
  @Local applyGridSizeTimerId: number = -1

  aboutToAppear(): void {
    this.gridColsText = `${this.store.params.gridCols}`
    this.gridRowsText = `${this.store.params.gridRows}`
    this.gridColsValid = true
    this.gridRowsValid = true
  }

  parseGridSize(value: string): number {
    const trimmed = value.trim()
    if (trimmed.length === 0) {
      return 0
    }
    const normalized = trimmed.replace(/[０-９]/g, (ch: string) => {
      return String.fromCharCode(ch.charCodeAt(0) - 0xFEE0)
    })
    if (!/^\d+$/.test(normalized)) {
      return 0
    }
    const num = Number(normalized)
    return num >= 1 && num <= 1000 ? num : 0
  }

  validateGridSize(): void {
    const cols = this.parseGridSize(this.gridColsText)
    const rows = this.parseGridSize(this.gridRowsText)
    this.gridColsValid = cols > 0
    this.gridRowsValid = rows > 0
  }

  isArrowKeyEvent(event: KeyEvent): boolean {
    return event.keyCode === KeyCode.KEYCODE_DPAD_UP
      || event.keyCode === KeyCode.KEYCODE_DPAD_DOWN
      || event.keyCode === KeyCode.KEYCODE_DPAD_LEFT
      || event.keyCode === KeyCode.KEYCODE_DPAD_RIGHT
  }

  isEnterKeyEvent(event: KeyEvent): boolean {
    if (event.keyCode === KeyCode.KEYCODE_ENTER || event.keyCode === KeyCode.KEYCODE_NUMPAD_ENTER) {
      return true
    }
    if (event.keyCode === 13 || event.keyCode === 10) {
      return true
    }
    return event.keyText === 'Enter' || event.keyText === '\n'
  }

  scheduleApplyGridSize(): void {
    if (this.applyGridSizeTimerId >= 0) {
      clearTimeout(this.applyGridSizeTimerId)
      this.applyGridSizeTimerId = -1
    }
    this.applyGridSizeTimerId = setTimeout(() => {
      this.applyGridSizeTimerId = -1
      this.applyGridSize()
    }, 0)
  }

  applyGridSize(): void {
    const cols = this.parseGridSize(this.gridColsText)
    const rows = this.parseGridSize(this.gridRowsText)
    this.gridColsValid = cols > 0
    this.gridRowsValid = rows > 0
    if (cols > 0 && rows > 0) {
      this.gridColsText = `${cols}`
      this.gridRowsText = `${rows}`
      this.store.resizeMap(rows, cols)
    }
  }

  build() {
    Scroll() {
      Column({ space: 8 }) {
        Row() {
          Text('地图设置')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.store.getColor('navix_text_primary'))

          Blank()

          SymbolGlyph($r('sys.symbol.minus'))
            .fontSize(14)
            .fontColor([this.store.getColor('navix_icon_color')])
            .onClick(() => {
              this.store.toggleRightPanel(RightPanelState.MAP_SETTINGS)
            })
        }
        .width('100%')
        .padding({ top: 10, left: 8, right: 8 })

        Text('选择地图类型')
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .width('100%')
          .padding({ left: 8, top: 4, bottom: 4 })

        this.MapTypeButton(MapType.GRID, '栅格图', '基于网格的地图表示')
        this.MapTypeButton(MapType.GRAPH, '关系图', '基于图论的地图表示')
        this.MapTypeButton(MapType.MAP_2D5, '2.5D地图', '伪三维地图表示')
        this.MapTypeButton(MapType.MAP_3D, '3D地图', '三维立体地图表示')

        Divider()
          .color(this.store.getColor('navix_border_color'))
          .margin({ left: 8, right: 8, top: 4, bottom: 4 })

        Text('地图参数设置')
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .width('100%')
          .padding({ left: 8, top: 4, bottom: 4 })

        if (this.store.currentMapType === MapType.GRID) {
          this.GridSettings()
        } else if (this.store.currentMapType === MapType.GRAPH) {
          this.GraphSettings()
        } else if (this.store.currentMapType === MapType.MAP_2D5) {
          this.Map2D5Settings()
        } else if (this.store.currentMapType === MapType.MAP_3D) {
          this.Map3DSettings()
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 6, right: 6, bottom: 10 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MapTypeButton(mapType: MapType, name: string, hint: string) {
    Column({ space: 2 }) {
      Text(name)
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))
        .fontWeight(this.store.currentMapType === mapType ? FontWeight.Medium : FontWeight.Normal)

      if (this.hoveredMapType === mapType) {
        Text(hint)
          .fontSize(10)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .lineHeight(13)
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 7, bottom: 7 })
    .borderRadius(6)
    .backgroundColor(this.store.currentMapType === mapType ? this.store.getColor('navix_button_active') : (this.hoveredMapType === mapType ? this.store.getColor('navix_border_color') : Color.Transparent))
    .onHover((isHover: boolean) => {
      this.hoveredMapType = isHover ? mapType : null
    })
    .onClick(() => {
      this.store.setMapType(mapType)
    })
  }

  @Builder
  GridSettings() {
    Column({ space: 12 }) {
      Column({ space: 4 }) {
        Text('宽 * 高')
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .width('100%')
          .padding({ left: 8 })

        Row({ space: 4 }) {
          TextInput({ placeholder: '列数', text: this.gridColsText })
            .fontSize(12)
            .fontColor(this.store.getColor('navix_text_primary'))
            .caretColor(this.store.getColor('navix_accent_highlight'))
            .type(InputType.Number)
            .width(50)
            .height(28)
            .backgroundColor(this.store.getColor('navix_bg_canvas'))
            .border({ width: 1, color: this.gridColsValid ? this.store.getColor('navix_border_color') : this.store.getColor('navix_node_end') })
            .borderRadius(4)
            .padding({ left: 6, right: 6 })
            .id('gridColsInput')
            .onChange((value: string) => {
              this.gridColsText = value
              this.validateGridSize()
            })
            .onSubmit((_enterKey: EnterKeyType, event: SubmitEvent) => {
              this.gridColsText = event.text
              this.scheduleApplyGridSize()
            })
            .onKeyEvent((event?: KeyEvent) => {
              if (event && event.type === KeyType.Down && this.isEnterKeyEvent(event)) {
                this.scheduleApplyGridSize()
              }
            })
            .onKeyPreIme((event: KeyEvent) => {
              if (event.type === KeyType.Down && this.isArrowKeyEvent(event)) {
                try {
                  this.getUIContext().getFocusController().requestFocus('gridRowsInput')
                } catch (_) {
                }
                return true
              }
              if (event.type === KeyType.Down && this.isEnterKeyEvent(event)) {
                this.scheduleApplyGridSize()
                return true
              }
              return false
            })

          Text('x')
            .fontSize(12)
            .fontColor(this.store.getColor('navix_text_secondary'))

          TextInput({ placeholder: '行数', text: this.gridRowsText })
            .fontSize(12)
            .fontColor(this.store.getColor('navix_text_primary'))
            .caretColor(this.store.getColor('navix_accent_highlight'))
            .type(InputType.Number)
            .width(50)
            .height(28)
            .backgroundColor(this.store.getColor('navix_bg_canvas'))
            .border({ width: 1, color: this.gridRowsValid ? this.store.getColor('navix_border_color') : this.store.getColor('navix_node_end') })
            .borderRadius(4)
            .padding({ left: 6, right: 6 })
            .id('gridRowsInput')
            .onChange((value: string) => {
              this.gridRowsText = value
              this.validateGridSize()
            })
            .onSubmit((_enterKey: EnterKeyType, event: SubmitEvent) => {
              this.gridRowsText = event.text
              this.scheduleApplyGridSize()
            })
            .onKeyEvent((event?: KeyEvent) => {
              if (event && event.type === KeyType.Down && this.isEnterKeyEvent(event)) {
                this.scheduleApplyGridSize()
              }
            })
            .onKeyPreIme((event: KeyEvent) => {
              if (event.type === KeyType.Down && this.isArrowKeyEvent(event)) {
                try {
                  this.getUIContext().getFocusController().requestFocus('gridColsInput')
                } catch (_) {
                }
                return true
              }
              if (event.type === KeyType.Down && this.isEnterKeyEvent(event)) {
                this.scheduleApplyGridSize()
                return true
              }
              return false
            })

          Blank()

          Text('应用')
            .fontSize(12)
            .fontColor(this.store.getColor('navix_text_primary'))
            .backgroundColor(this.store.getColor('navix_bg_canvas'))
            .borderRadius(4)
            .border({ width: 1, color: this.store.getColor('navix_border_color') })
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .onClick(() => {
              this.scheduleApplyGridSize()
            })
        }
        .width('100%')
        .padding({ left: 8, right: 8 })

        if (!this.gridColsValid || !this.gridRowsValid) {
          Text('请输入 1-1000 的正整数')
            .fontSize(10)
            .fontColor(this.store.getColor('navix_node_end'))
            .width('100%')
            .padding({ left: 8 })
        }
      }

      Column({ space: 4 }) {
        Text('背景颜色')
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .width('100%')
          .padding({ left: 8 })

        Row({ space: 6 }) {
          Row({ space: 6 }) {
            ForEach(backgroundColors.slice(0, 5), (color: string) => {
              Column()
                .width(24)
                .height(24)
                .borderRadius(4)
                .backgroundColor(color)
                .border({
                  width: 1,
                  color: this.store.params.backgroundColor === color ? this.store.getColor('navix_accent_highlight') : this.store.getColor('navix_border_color')
                })
                .onClick(() => {
                  this.store.updateParams({ backgroundColor: color })
                })
            })
          }
          .layoutWeight(1)

          SymbolGlyph(this.showMoreBackgroundColors ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_left'))
            .fontSize(12)
            .fontColor([this.store.getColor('navix_text_secondary')])
            .width(24)
            .height(24)
            .borderRadius(4)
            .border({ width: 1, color: this.store.getColor('navix_border_color') })
            .onClick(() => {
              this.showMoreBackgroundColors = !this.showMoreBackgroundColors
            })
        }
        .width('100%')
        .padding({ left: 8, right: 8 })

        if (this.showMoreBackgroundColors) {
          Row({ space: 6 }) {
            ForEach(backgroundColorsMore1, (color: string) => {
              Column()
                .width(24)
                .height(24)
                .borderRadius(4)
                .backgroundColor(color)
                .border({
                  width: 1,
                  color: this.store.params.backgroundColor === color ? this.store.getColor('navix_accent_highlight') : this.store.getColor('navix_border_color')
                })
                .onClick(() => {
                  this.store.updateParams({ backgroundColor: color })
                })
            })
          }
          .width('100%')
          .padding({ left: 8, right: 8 })

          Row({ space: 6 }) {
            ForEach(backgroundColorsMore2, (color: string) => {
              Column()
                .width(24)
                .height(24)
                .borderRadius(4)
                .backgroundColor(color)
                .border({
                  width: 1,
                  color: this.store.params.backgroundColor === color ? this.store.getColor('navix_accent_highlight') : this.store.getColor('navix_border_color')
                })
                .onClick(() => {
                  this.store.updateParams({ backgroundColor: color })
                })
            })
          }
          .width('100%')
          .padding({ left: 8, right: 8 })

          Row({ space: 6 }) {
            ForEach(backgroundColorsMore3, (color: string) => {
              Column()
                .width(24)
                .height(24)
                .borderRadius(4)
                .backgroundColor(color)
                .border({
                  width: 1,
                  color: this.store.params.backgroundColor === color ? this.store.getColor('navix_accent_highlight') : this.store.getColor('navix_border_color')
                })
                .onClick(() => {
                  this.store.updateParams({ backgroundColor: color })
                })
            })
          }
          .width('100%')
          .padding({ left: 8, right: 8 })
        }
      }

      Column({ space: 4 }) {
        Text('网格线颜色')
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .width('100%')
          .padding({ left: 8 })

        Row({ space: 6 }) {
          Row({ space: 6 }) {
            ForEach(gridLineColors.slice(0, 5), (color: string) => {
              Column()
                .width(24)
                .height(24)
                .borderRadius(4)
                .backgroundColor(color)
                .border({
                  width: 1,
                  color: this.store.params.gridLineColor === color ? this.store.getColor('navix_accent_highlight') : this.store.getColor('navix_border_color')
                })
                .onClick(() => {
                  this.store.updateParams({ gridLineColor: color })
                })
            })
          }
          .layoutWeight(1)

          SymbolGlyph(this.showMoreGridLineColors ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_left'))
            .fontSize(12)
            .fontColor([this.store.getColor('navix_text_secondary')])
            .width(24)
            .height(24)
            .borderRadius(4)
            .border({ width: 1, color: this.store.getColor('navix_border_color') })
            .onClick(() => {
              this.showMoreGridLineColors = !this.showMoreGridLineColors
            })
        }
        .width('100%')
        .padding({ left: 8, right: 8 })

        if (this.showMoreGridLineColors) {
          Row({ space: 6 }) {
            ForEach(gridLineColorsMore1, (color: string) => {
              Column()
                .width(24)
                .height(24)
                .borderRadius(4)
                .backgroundColor(color)
                .border({
                  width: 1,
                  color: this.store.params.gridLineColor === color ? this.store.getColor('navix_accent_highlight') : this.store.getColor('navix_border_color')
                })
                .onClick(() => {
                  this.store.updateParams({ gridLineColor: color })
                })
            })
          }
          .width('100%')
          .padding({ left: 8, right: 8 })

          Row({ space: 6 }) {
            ForEach(gridLineColorsMore2, (color: string) => {
              Column()
                .width(24)
                .height(24)
                .borderRadius(4)
                .backgroundColor(color)
                .border({
                  width: 1,
                  color: this.store.params.gridLineColor === color ? this.store.getColor('navix_accent_highlight') : this.store.getColor('navix_border_color')
                })
                .onClick(() => {
                  this.store.updateParams({ gridLineColor: color })
                })
            })
          }
          .width('100%')
          .padding({ left: 8, right: 8 })
        }
      }

      Column({ space: 4 }) {
        Text('显示网格线')
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .width('100%')
          .padding({ left: 8 })

        Row({ space: 8 }) {
          Text(this.store.params.showGridLines ? '开启' : '关闭')
            .fontSize(12)
            .fontColor(this.store.params.showGridLines ? this.store.getColor('navix_button_active') : this.store.getColor('navix_text_secondary'))
            .backgroundColor(this.store.getColor('navix_bg_canvas'))
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .onClick(() => {
              this.store.updateParams({ showGridLines: !this.store.params.showGridLines })
            })
        }
        .width('100%')
        .padding({ left: 8, right: 8 })
      }

      Column({ space: 4 }) {
        Text('允许对角移动')
          .fontSize(11)
          .fontColor(this.store.getColor('navix_text_secondary'))
          .width('100%')
          .padding({ left: 8 })

        Row({ space: 8 }) {
          Text(this.store.params.allowDiagonal ? '开启' : '关闭')
            .fontSize(12)
            .fontColor(this.store.params.allowDiagonal ? this.store.getColor('navix_button_active') : this.store.getColor('navix_text_secondary'))
            .backgroundColor(this.store.getColor('navix_bg_canvas'))
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .onClick(() => {
              this.store.updateParams({ allowDiagonal: !this.store.params.allowDiagonal })
            })
        }
        .width('100%')
        .padding({ left: 8, right: 8 })
      }
    }
  }

  @Builder
  GraphSettings() {
    Column({ space: 8 }) {
      Text('关系图设置区域')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_secondary'))
        .width('100%')
        .padding({ left: 8, right: 8 })
        .textAlign(TextAlign.Center)

      Text('节点大小:')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))
        .width('100%')
        .padding({ left: 8, right: 8 })

      Text('边样式:')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))
        .width('100%')
        .padding({ left: 8, right: 8 })

      Text('布局算法:')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))
        .width('100%')
        .padding({ left: 8, right: 8 })
    }
  }

  @Builder
  Map2D5Settings() {
    Column({ space: 8 }) {
      Text('2.5D地图设置区域')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_secondary'))
        .width('100%')
        .padding({ left: 8, right: 8 })
        .textAlign(TextAlign.Center)

      Text('高度缩放:')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))
        .width('100%')
        .padding({ left: 8, right: 8 })

      Text('视角角度:')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))
        .width('100%')
        .padding({ left: 8, right: 8 })

      Text('纹理贴图:')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))
        .width('100%')
        .padding({ left: 8, right: 8 })
    }
  }

  @Builder
  Map3DSettings() {
    Column({ space: 8 }) {
      Text('3D地图设置区域')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_secondary'))
        .width('100%')
        .padding({ left: 8, right: 8 })
        .textAlign(TextAlign.Center)

      Text('光照效果:')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))
        .width('100%')
        .padding({ left: 8, right: 8 })

      Text('阴影模式:')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))
        .width('100%')
        .padding({ left: 8, right: 8 })

      Text('渲染质量:')
        .fontSize(12)
        .fontColor(this.store.getColor('navix_text_primary'))
        .width('100%')
        .padding({ left: 8, right: 8 })
    }
  }
}
