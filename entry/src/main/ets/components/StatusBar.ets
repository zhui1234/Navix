import { NavixStore, navixStore } from '../store/NavixStore'
import { ConfigurationConstant } from '@kit.AbilityKit'

@ComponentV2
export struct StatusBar {
  @Local store: NavixStore = navixStore

  build() {
    Row() {
      SymbolGlyph($r('sys.symbol.moon_fill'))
        .fontSize(18)
        .fontColor([this.store.theme === 'light' ? '#000000' : '#FFFFFF'])
        .onClick(() => {
          this.toggleTheme()
        })

      Blank()

      Row({ space: 4 }) {
        Text('● 就绪')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_node_start'))
        Text(' | ')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text('地图大小: 20×20')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text(' | ')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text('搜索节点: 0')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text(' | ')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text('路径长度: 0')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text(' | ')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
        Text('时间: 0ms')
          .fontSize(12)
          .fontColor(this.store.getColor('navix_text_secondary'))
      }
    }
    .width('100%')
    .height(36)
    .backgroundColor(this.store.getColor('navix_bg_toolbar'))
    .padding({ left: 12, right: 12 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  toggleTheme() {
    const currentTheme = this.store.theme
    const newTheme = currentTheme === 'light' ? 'dark' : 'light'
    const newColorMode = newTheme === 'light' 
      ? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT 
      : ConfigurationConstant.ColorMode.COLOR_MODE_DARK
    
    try {
      const context = getContext(this)
      context.getApplicationContext().setColorMode(newColorMode)
      this.store.toggleTheme()
    } catch (err) {
      console.error('Failed to set color mode', JSON.stringify(err))
      this.store.toggleTheme()
    }
  }
}
