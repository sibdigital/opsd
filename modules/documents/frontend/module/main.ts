// -- copyright
// OpenProject Documents Plugin
//
// Former OpenProject Core functionality extracted into a plugin.
//
// Copyright (C) 2009-2014 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
//   # Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See doc/COPYRIGHT.rdoc for more details.
// ++

import {APP_INITIALIZER, Injector, NgModule} from '@angular/core';
import {OpenProjectPluginContext} from "core-app/modules/plugins/plugin-context";
import {DocumentResource} from './hal/resources/document-resource';
import {multiInput} from 'reactivestates';
import {WpDocumentConfigurationModalComponent} from "./wp-document-modal/wp-document-configuration.modal";
import {WpDocumentAutocompleteComponent} from "./wp-document-autocomplete/wp-document-autocomplete.upgraded.component";
import {WorkPackageDocumentPaginationComponent} from "./wp-document-modal/wp-document-pagination.component";
import {OpenprojectCommonModule} from "core-app/modules/common/openproject-common.module";
import {HookService} from "../../hook-service";

export function initializeDocumentPlugin(injector: Injector) {
  return () => {
    window.OpenProject.getPluginContext()
      .then((pluginContext: OpenProjectPluginContext) => {
        let halResourceService = pluginContext.services.halResource;
        halResourceService.registerResource('Document', {cls: DocumentResource});

        let states = pluginContext.services.states;
        states.add('document', multiInput<DocumentResource>());
      });

    const hookService = injector.get(HookService);
    hookService.register('openProjectAngularBootstrap', () => {
      return [,
        {selector: 'wp-document-pagination', cls: WorkPackageDocumentPaginationComponent},
        {selector: 'wp-document-autocomplete-upgraded', cls: WpDocumentAutocompleteComponent}
      ];
    });
  };
}


@NgModule({
  imports: [
    OpenprojectCommonModule
  ],
  declarations: [
    WorkPackageDocumentPaginationComponent,
    WpDocumentConfigurationModalComponent,
    WpDocumentAutocompleteComponent
  ],
  providers: [
    {provide: APP_INITIALIZER, useFactory: initializeDocumentPlugin, deps: [Injector], multi: true},
  ],
  entryComponents: [
    WorkPackageDocumentPaginationComponent,
    WpDocumentConfigurationModalComponent,
    WpDocumentAutocompleteComponent
  ]
})
export class PluginModule {
}
