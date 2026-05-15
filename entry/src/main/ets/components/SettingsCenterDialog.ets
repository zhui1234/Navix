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
    return ''
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
