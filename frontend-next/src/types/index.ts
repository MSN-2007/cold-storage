export interface SensorMetrics {
  temp: number;
  hum: number;
  co2: number;
  eth: number;
}

export interface StorageUnitSettings {
  tempMin: number;
  tempMax: number;
  humMin: number;
  humMax: number;
  co2Max: number;
  ethMax: number;
}

export interface CropBatch {
  id: string;
  cropName: string;
  quantity: string;
  entryDate: string;
  value: string;
}

export interface StorageUnit {
  id: string;
  name: string;
  status: 'Healthy' | 'Warning' | 'Critical' | 'Offline';
  chambers: number;
  crops: string;
  health: number;
  metrics: SensorMetrics;
  settings: StorageUnitSettings;
  batches: CropBatch[];
}

export interface ChamberAlert {
  id: string;
  title: string;
  storageId: string;
  chamberName: string;
  time: string;
  currentValue: string;
  requiredValue: string;
  impactText: string;
  iconType: 'Droplet' | 'Thermometer' | 'FlaskConical' | 'Wind';
  severity: 'Warning' | 'Critical';
}
