export class MapState {
  isBuildingActive: boolean = false;
  isImageOverlayActive: boolean = false;
  tileMode: number = 0;
  tileButtonText: string = 'Standard Mode';
  indoorBuildingId: string = 'None';
  currentFloorName: string = 'Outdoor';
}

export const TILE_OVERLAY_URL = 'Replace it with your own URL.'