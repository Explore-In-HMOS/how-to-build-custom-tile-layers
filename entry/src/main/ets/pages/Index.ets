import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import {
  ArcSwiper,
  ArcSwiperAttribute,
  ArcDotIndicator,
  ArcDirection, ArcSwiperController
} from '@kit.ArkUI';

import { MapViewModel } from '../viewmodel/MapViewModel';

@Entry
@Component
struct WearableUltimateArcMap {
  @State private viewModel: MapViewModel = new MapViewModel();
  @State private mapOptions?: mapCommon.MapOptions = undefined;
  private mapCallback?: AsyncCallback<map.MapComponentController> = undefined;
  private arcSwiperController: ArcSwiperController = new ArcSwiperController();

  aboutToAppear(): void {
    this.mapOptions = {
      position: { target: { latitude: 37.59779769138729, longitude: 126.94873341788303 }, zoom: 11 },
      myLocationControlsEnabled: false,
      scaleControlsEnabled: false,
      indoorMapEnabled: true,
      dayNightMode: mapCommon.DayNightMode.AUTO
    };

    this.mapCallback = async (err, mapController) => {
      if (!err && mapController) {
        this.viewModel.setMapController(mapController);

        try {
          mapController.getEventManager().on('indoorMapEnter', (indoorMapInfo: map.IndoorMapInfo) => {
            this.viewModel.handleIndoorMapEnter(indoorMapInfo);
          });
        } catch (e) {
          console.warn('View', `Indoor events bypassed on this tier. Code: ${e.code}`);
        }
      }
    };
  }

  aboutToDisappear(): void {
    this.viewModel.clearAllLayers();
  }

  build() {
    Stack() {
      ArcSwiper(this.arcSwiperController) {

        Stack() {
          if (this.mapOptions) {
            MapComponent({ mapOptions: this.mapOptions, mapCallback: this.mapCallback })
              .width('100%')
              .height('100%')
          }
        }
        .width('100%')
        .height('100%')

        List({ space: 10 }) {
          ListItem() {
            Text('Map Control Center')
              .width('100%')
              .textAlign(TextAlign.Center)
              .fontSize(13)
              .fontColor('#4CAF50')
              .fontWeight(FontWeight.Bolder)
              .margin({ top: 25, bottom: 5 })
          }

          ListItem() {
            Button(this.viewModel.state.tileButtonText)
              .width('80%')
              .height(40)
              .fontSize(11)
              .backgroundColor('#007DFF')
              .borderRadius(20)
              .onClick(() => {
                this.viewModel.switchTileLayer(this.arcSwiperController);
              })
          }

          ListItem() {
            Button(this.viewModel.state.isBuildingActive ? 'Remove 3D Extrusion' : 'Render 3D Buildings')
              .width('80%')
              .height(40)
              .fontSize(11)
              .backgroundColor(this.viewModel.state.isBuildingActive ? '#E53935' : '#4CAF50')
              .borderRadius(20)
              .onClick(() => this.viewModel.toggleBuildingOverlay(this.arcSwiperController))
          }

          ListItem() {
            Button(this.viewModel.state.isImageOverlayActive ? 'Remove Image Layer' : 'Load Route Overlay')
              .width('80%')
              .height(40)
              .fontSize(11)
              .backgroundColor(this.viewModel.state.isImageOverlayActive ? '#E53935' : '#E91E63')
              .borderRadius(20)
              .onClick(() => this.viewModel.toggleImageOverlay(this.arcSwiperController))
          }

          ListItem() {
            Column() {
              Text('Indoor Telemetry')
                .fontSize(9)
                .fontColor('#888888')
                .margin({ bottom: 2 })
              Text(`Building UUID: ${this.viewModel.state.indoorBuildingId === 'None' ? 'Capability not supported due to limited device capabilities.' : this.viewModel.state.indoorBuildingId.slice(0, 8)}`)
                .fontSize(9)
                .width('70%')
                .maxLines(3)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .margin({ top: 5, bottom: 25 })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#111111')
        .alignListItem(ListItemAlign.Center)
        .scrollBar(BarState.Off)
      }
      .vertical(false)
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
      .digitalCrownSensitivity(CrownSensitivity.MEDIUM)
    }
    .width('100%')
    .height('100%')
  }
}
