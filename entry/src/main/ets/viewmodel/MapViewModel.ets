import { map, mapCommon } from '@kit.MapKit';
import { MapState, TILE_OVERLAY_URL } from '../model/MapState';
import { ArcSwiperController } from '@kit.ArkUI';

@Observed
export class MapViewModel {
  public state: MapState = new MapState();
  private mapController?: map.MapComponentController = undefined;

  // Active Overlays
  private activeBuildingOverlay?: map.BuildingOverlay = undefined;
  private activeImageOverlay?: map.ImageOverlay = undefined;
  private activeTileOverlay?: map.TileOverlay = undefined;

  public setMapController(controller: map.MapComponentController) {
    this.mapController = controller;
    this.mapController.setBuildingEnabled(true);
  }

  public handleIndoorMapEnter(indoorMapInfo: map.IndoorMapInfo) {
    this.state.indoorBuildingId = indoorMapInfo.buildingId;
    this.state.currentFloorName = indoorMapInfo.currentFloorName;
  }

  async switchTileLayer(swiperController: ArcSwiperController) {
    if (!this.mapController) {
      return;
    }
    if (this.activeTileOverlay) {
      this.activeTileOverlay.remove();
      this.activeTileOverlay = undefined;
    }
    swiperController.showPrevious();

    this.state.tileMode = (this.state.tileMode + 1) % 2;

    if (this.state.tileMode === 0) {
      this.state.tileButtonText = 'Standard Mode';
      return;
    }

    if (this.state.tileMode === 1) {
      this.state.tileButtonText = 'Radar Mode';
      let options: mapCommon.TileOverlayOptions = {
        fadeIn: true,
        transparency: 0.4,
        visible: true,
        tileUrl: TILE_OVERLAY_URL
      };

      try {
        this.activeTileOverlay = this.mapController.addTileOverlay(options);
      } catch (e) {
        console.error('MapViewModel', `TileOverlay error: ${e.message}`);
      }
    }
  }

  async toggleBuildingOverlay(swiperController: ArcSwiperController) {
    if (!this.mapController) {
      return;
    }
    if (this.state.isBuildingActive && this.activeBuildingOverlay) {
      this.activeBuildingOverlay.remove();
      this.activeBuildingOverlay = undefined;
      this.state.isBuildingActive = false;
      return;
    }

    swiperController.showPrevious();

    let cameraUpdate = map.newCameraPosition({
      target: { latitude: 31.985282, longitude: 118.766661 },
      zoom: 17.5,
      tilt: 45 });
    this.mapController.animateCamera(cameraUpdate);

    let points: Array<mapCommon.LatLng> = [
      { latitude: 31.984794, longitude: 118.765865 }, { latitude: 31.98468, longitude: 118.766076 },
      { latitude: 31.98472, longitude: 118.766116 }, { latitude: 31.98463, longitude: 118.766292 },
      { latitude: 31.984586, longitude: 118.766251 }, { latitude: 31.984536, longitude: 118.766344 },
      { latitude: 31.984633, longitude: 118.766446 }, { latitude: 31.9848, longitude: 118.766285 },
      { latitude: 31.984925, longitude: 118.766661 }, { latitude: 31.985282, longitude: 118.766661 },
      { latitude: 31.985438, longitude: 118.766419 }, { latitude: 31.985801, longitude: 118.766755 },
      { latitude: 31.985856, longitude: 118.766504 }, { latitude: 31.985785, longitude: 118.766434 },
      { latitude: 31.984794, longitude: 118.765865 }
    ];

    points.reverse();

    try {
      this.activeBuildingOverlay = await this.mapController.addBuildingOverlay({
        points: points,
        totalHeight: 51,
        floorBottomHeight: 0,
        topFaceColor: 0xffa4b8f7,
        sideFaceColor: 0x66a4b8f7,
        floorColor: 0xff000000,
        showLevel: 14,
        animationDuration: 1000
      });
      this.state.isBuildingActive = true;
    } catch (e) {
      console.error('MapViewModel', `BuildingOverlay error: ${e.message}`);
    }
  }

  async toggleImageOverlay(swiperController: ArcSwiperController) {
    if (!this.mapController) {
      return;
    }

    if (this.state.isImageOverlayActive && this.activeImageOverlay) {
      try {
        this.activeImageOverlay.remove();
        this.activeImageOverlay = undefined;
        this.state.isImageOverlayActive = false;
      } catch (e) {
        console.error('MapViewModel', `ImageOverlay cannot delete: ${e.message} `);
      }
      return;
    }

    swiperController.showPrevious();

    let cameraUpdate = map.newCameraPosition({
      target: { latitude: 32.2, longitude: 118.2 },
      zoom: 11,
      tilt: 0
    });
    this.mapController.animateCamera(cameraUpdate);

    let imageOverlayParams: mapCommon.ImageOverlayParams = {
      bounds: {
        southwest: { latitude: 32, longitude: 118 },
        northeast: { latitude: 32.4, longitude: 118.4 }
      },
      image: 'icon/icon.png',
      transparency: 0.3,
      zIndex: 101,
      anchorU: 0.5,
      anchorV: 0.5,
      clickable: true,
      visible: true,
      bearing: 0
    };

    try {
      this.activeImageOverlay = await this.mapController.addImageOverlay(imageOverlayParams);
      this.state.isImageOverlayActive = true;
    } catch (e) {
      console.error('TAG', `ImageOverlay adding error: ${e.message}`);
    }
  }

  public clearAllLayers() {
    if (this.activeTileOverlay) {
      this.activeTileOverlay.remove();
    }
    if (this.activeBuildingOverlay) {
      this.activeBuildingOverlay.remove();
    }
    if (this.activeImageOverlay) {
      this.activeImageOverlay.remove();
    }
    this.state = new MapState();
  }
}