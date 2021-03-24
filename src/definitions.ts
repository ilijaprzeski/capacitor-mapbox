declare module '@capacitor/core' {
  interface PluginRegistry {
    CapacitorMapboxNavigation: CapacitorMapboxNavigationPlugin;
  }
}

export interface CapacitorMapboxNavigationPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
