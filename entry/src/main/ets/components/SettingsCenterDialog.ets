import { NavixStore, navixStore } from '../store/NavixStore'
import { ConfigurationConstant } from '@kit.AbilityKit'

@ComponentV2
export struct SettingsCenterDialog {
  @Local store: NavixStore = navixStore

  withAlpha(color: string, alphaHex: string): string {
    const hex = color.startsWith('#') ? color.slice(1) : color
    if (hex.length === 6) {
      return `#${alphaHex}${hex}`
    }
    return color
  }

  applyTheme(theme: 'light' | 'dark'): void {
    const newColorMode = theme === 'light'
      ? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
      : ConfigurationConstant.ColorMode.COLOR_MODE_DARK
    try {
      const context = getContext(this)
      context.getApplicationContext().setColorMode(newColorMode)
      this.store.setTheme(theme)
    } catch (_err) {
      this.store.setTheme(theme)
    }
    this.store.closeCenterDialog()
  }

  applyViewMode(mode: 'edit' | 'present'): void {
    this.store.setViewMode(mode)
    this.store.closeCenterDialog()
  }

  @Builder
  DialogOption(label: string, selected: boolean, onClick: () => void) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(this.store.getColor('navix_text_primary'))
      Blank()
      if (selected) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize(14)
          .fontColor([this.store.getColor('navix_accent_highlight')])
      }
    }
    .width('100%')
    .height(36)
    .padding({ left: 10, right: 10 })
    .borderRadius(6)
    .backgroundColor(selected ? this.withAlpha(this.store.getColor('navix_accent_highlight'), '22') : Color.Transparent)
    .onClick(() => onClick())
  }

  getDialogTitle(): string {
    if (this.store.centerDialog === 'settings') {
      return '设置'
    }
    if (this.store.centerDialog === 'theme') {
      return '主题'
    }
    if (this.store.centerDialog === 'view') {
      return '视图模式'
    }
    if (this.store.centerDialog === 'usage') {
      return '使用说明'
    }
    if (this.store.centerDialog === 'shortcuts') {
      return '快捷键列表'
    }
    if (this.store.centerDialog === 'about') {
      return '关于'
    }
    return ''
  }

  @Builder
  ShortcutRow(keyText: string, desc: string, header: boolean) {
    Row({ space: 0 }) {
      Text(keyText)
        .fontSize(12)
        .fontWeight(header ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.store.getColor('navix_text_primary'))
        .width(110)
      Text(desc)
        .fontSize(12)
        .fontWeight(header ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.store.getColor('navix_text_primary'))
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
  }

  build() {
    if (this.store.centerDialog !== 'none') {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.withAlpha('#000000', this.store.theme === 'light' ? '22' : '55'))
          .onClick(() => {
            this.store.closeCenterDialog()
          })

        Column({ space: 12 }) {
          Row() {
            Text(this.getDialogTitle())
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.store.getColor('navix_text_primary'))
            Blank()
            SymbolGlyph($r('sys.symbol.xmark'))
              .fontSize(16)
              .fontColor([this.store.getColor('navix_icon_color')])
              .onClick(() => {
                this.store.closeCenterDialog()
              })
          }
          .width('100%')

          if (this.store.centerDialog === 'settings') {
            Text('设置内容占位')
              .fontSize(14)
              .fontColor(this.store.getColor('navix_text_secondary'))
          } else if (this.store.centerDialog === 'theme') {
            Column({ space: 6 }) {
              this.DialogOption('浅色', this.store.theme === 'light', () => this.applyTheme('light'))
              this.DialogOption('深色', this.store.theme === 'dark', () => this.applyTheme('dark'))
            }
            .width('100%')
          } else if (this.store.centerDialog === 'view') {
            Column({ space: 6 }) {
              this.DialogOption('编辑视图', this.store.viewMode === 'edit', () => this.applyViewMode('edit'))
              this.DialogOption('演示视图', this.store.viewMode === 'present', () => this.applyViewMode('present'))
            }
            .width('100%')
          } else if (this.store.centerDialog === 'usage') {
            Text('Navix 是一个用于路径规划与搜索算法对比/可视化的实验平台。通过工具栏编辑地图，通过算法栏选择算法并运行，可在演示模式下查看搜索过程。')
              .fontSize(14)
              .fontColor(this.store.getColor('navix_text_secondary'))
              .lineHeight(20)
          } else if (this.store.centerDialog === 'shortcuts') {
            Column({ space: 0 }) {
              this.ShortcutRow('快捷键', '功能', true)
              Divider()
                .color(this.store.getColor('navix_border_color'))
              this.ShortcutRow('Space', '开始/暂停动画', false)
              Divider()
                .color(this.store.getColor('navix_border_color'))
              this.ShortcutRow('=(+)', '放大网格', false)
              Divider()
                .color(this.store.getColor('navix_border_color'))
              this.ShortcutRow('-(_)', '缩小网格', false)
              Divider()
                .color(this.store.getColor('navix_border_color'))
              this.ShortcutRow('数字', '选择算法', false)
            }
            .width('100%')
            .borderRadius(8)
            .backgroundColor(this.store.getColor('navix_bg_canvas'))
            .border({ width: 1, color: this.store.getColor('navix_border_color') })
            .clip(true)
          } else if (this.store.centerDialog === 'about') {
            Column({ space: 10 }) {
              Text('应用名称：Navix — 智能算法实验平台')
                .fontSize(14)
                .fontColor(this.store.getColor('navix_text_primary'))
                .fontWeight(FontWeight.Medium)
                .width('100%')
              Text('版本号: v1.0.0')
                .fontSize(13)
                .fontColor(this.store.getColor('navix_text_secondary'))
                .width('100%')
              Text('简介: 鸿蒙空间智能算法可视化实验工具')
                .fontSize(13)
                .fontColor(this.store.getColor('navix_text_secondary'))
                .width('100%')
              Text('开发者: 瓜兵永不言弃')
                .fontSize(13)
                .fontColor(this.store.getColor('navix_text_secondary'))
                .width('100%')
              Divider()
                .color(this.store.getColor('navix_border_color'))
              Text('开源协议')
                .fontSize(13)
                .fontColor(this.store.getColor('navix_text_secondary'))
                .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width(320)
        .padding(14)
        .borderRadius(10)
        .backgroundColor(this.store.getColor('navix_bg_panel'))
        .border({ width: 1, color: this.store.getColor('navix_border_color') })
        .shadow({ radius: 18, color: this.withAlpha('#000000', this.store.theme === 'light' ? '22' : '66'), offsetX: 0, offsetY: 8 })
        .onClick(() => {})
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Center)
    }
  }
}
