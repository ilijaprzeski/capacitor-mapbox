declare module '@capacitor/core' {
  interface PluginRegistry {
    CapacitorMapboxNavigation: CapacitorMapboxNavigationPlugin;
  }
}

export interface CapacitorMapboxNavigationPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  show(options: MapboxNavOptions): Promise<void>;
}

export interface MapboxNavOptions {
  routes: LocationOption[];
  mapType?: string;
}

export interface LocationOption {
  latitude: number;
  longitude: number;
}

export interface MapboxNavStyleOption {

}