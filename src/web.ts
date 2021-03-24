import { WebPlugin } from '@capacitor/core';
import { CapacitorMapboxNavigationPlugin } from './definitions';

export class CapacitorMapboxNavigationWeb extends WebPlugin implements CapacitorMapboxNavigationPlugin {
  constructor() {
    super({
      name: 'CapacitorMapboxNavigation',
      platforms: ['web'],
    });
  }

  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}

const CapacitorMapboxNavigation = new CapacitorMapboxNavigationWeb();

export { CapacitorMapboxNavigation };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(CapacitorMapboxNavigation);
