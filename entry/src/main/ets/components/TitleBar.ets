import { NavixStore } from '../store/NavixStore'
import { navixStore } from '../store/NavixStore'
import { VisualizationMode } from '../models/MapTypes'

@ComponentV2
export struct TitleBar {
  @Local store: NavixStore = navixStore
  @Local hoveredMenu: 'file' | 'tools' | 'algorithms' | 'map' | 'help' | null = null

  @Builder
  MenuTab(label: string, key: 'file' | 'tools' | 'algorithms' | 'map' | 'help') {
    Text(label)
      .fontSize(13)
      .fontColor(this.store.getColor('navix_text_primary'))
      .padding({ left: 8, right: 8, top: 6, bottom: 6 })
      .width(64)
      .textAlign(TextAlign.Center)
      .borderRadius(6)
      .backgroundColor(
        this.store.titleMenuActive === key
          ? this.store.getColor('navix_border_color')
          : (this.hoveredMenu === key ? this.store.getColor('navix_bg_panel') : Color.Transparent)
      )
      .onHover((isHover: boolean) => {
        this.hoveredMenu = isHover ? key : null
      })
      .onClick(() => {
        this.store.openTitleMenu(key)
      })
  }

  build() {
    Row() {
      Row({ space: 8 }) {
        Image($r('app.media.app_icon'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
        SymbolGlyph($r('sys.symbol.list_bullet'))
          .fontSize(20)
          .fontColor([this.store.getColor('navix_icon_color')])
          .onClick(() => {
            this.store.toggleTitleMenuExpanded()
          })

        if (this.store.titleMenuExpanded) {
          Row({ space: 6 }) {
            this.MenuTab('文件', 'file')
            this.MenuTab('工具', 'tools')
            this.MenuTab('算法', 'algorithms')
            this.MenuTab('地图', 'map')
            this.MenuTab('帮助', 'help')
          }
        }
      }
      Blank()
      Row({ space: 6 }) {
        SymbolGlyph($r('sys.symbol.backward_end_fill'))
          .fontSize(18)
          .fontColor([this.store.getColor('navix_icon_color')])
          .onClick(() => {
            if (this.store.visualizationMode !== VisualizationMode.NONE) {
              this.store.prevStep()
              return
            }
            this.store.setVisualizationStep(0)
          })
        if (this.store.visualizationMode !== VisualizationMode.NONE) {
          if (this.store.visualizationPlaying) {
            SymbolGlyph($r('sys.symbol.pause_fill'))
              .fontSize(18)
              .fontColor([this.store.getColor('navix_icon_color')])
              .onClick(() => {
                this.store.toggleVisualizationPlayback()
              })
          } else {
            SymbolGlyph($r('sys.symbol.play_fill'))
              .fontSize(18)
              .fontColor([this.store.getColor('navix_icon_color')])
              .onClick(() => {
                this.store.toggleVisualizationPlayback()
              })
          }

          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(18)
            .fontColor([this.store.getColor('navix_icon_color')])
            .onClick(() => {
              this.store.clearVisualization()
            })
        } else {
          SymbolGlyph($r('sys.symbol.play_fill'))
            .fontSize(18)
            .fontColor([this.store.getColor('navix_icon_color')])
            .onClick(() => {
              this.store.runCompare()
            })
        }
        SymbolGlyph($r('sys.symbol.forward_end_fill'))
          .fontSize(18)
          .fontColor([this.store.getColor('navix_icon_color')])
          .onClick(() => {
            this.store.nextStep()
          })
        if (this.store.visualizationMode !== VisualizationMode.NONE) {
          Text(`步骤 ${this.store.currentStep + 1}/${this.store.searchSteps.length}`)
            .fontSize(12)
            .fontColor(this.store.getColor('navix_text_secondary'))
        }
      }
      Blank()
      Row({ space: 10 }) {
        SymbolGlyph($r('sys.symbol.gearshape'))
          .fontSize(20)
          .fontColor([this.store.getColor('navix_icon_color')])
          .onClick(() => {
            this.store.openSettingsMenu()
          })
          .bindMenu(this.store.settingsMenuOpen, [
            {
              value: '设置...',
              action: () => {
                this.store.closeSettingsMenu()
                this.store.openCenterDialog('settings')
              }
            },
            {
              value: '主题...',
              action: () => {
                this.store.closeSettingsMenu()
                this.store.openCenterDialog('theme')
              }
            },
            {
              value: '视图模式...',
              action: () => {
                this.store.closeSettingsMenu()
                this.store.openCenterDialog('view')
              }
            }
          ], {
            onDisappear: () => {
              this.store.closeSettingsMenu()
            }
          })
        SymbolGlyph($r('sys.symbol.minus'))
          .fontSize(20)
          .fontColor([this.store.getColor('navix_icon_color')])
        SymbolGlyph($r('sys.symbol.square'))
          .fontSize(20)
          .fontColor([this.store.getColor('navix_icon_color')])
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(20)
          .fontColor([this.store.getColor('navix_icon_color')])
      }
    }
    .width('100%')
    .height(48)
    .backgroundColor(this.store.getColor('navix_bg_toolbar'))
    .padding({ left: 8, right: 8 })
    .alignItems(VerticalAlign.Center)
  }
}
