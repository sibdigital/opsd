// -- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
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
import {FirstRouteService} from "core-app/modules/router/first-route-service";
import {UIRouterModule} from "@uirouter/angular";
import {ApplicationBaseComponent} from "core-app/modules/router/base/application-base.component";
import {
  initializeUiRouterListeners,
  OPENPROJECT_ROUTES,
  uiRouterConfiguration
} from "core-app/modules/router/openproject.routes";
import {ChartsModule} from "ng2-charts";
import {FormsModule} from "@angular/forms";
import {WpTopicsDialogComponent} from "core-components/wp-topics-dialog/wp-topics-dialog.component";
import {WpTopicsAutocompleteComponent} from "core-components/wp-topics-autocomplete/wp-topics-autocomplete.upgraded.component";
import {MatDialogModule, MatPaginatorIntl, MatPaginatorModule, MatTableModule} from "@angular/material";
import {BrowserAnimationsModule} from "@angular/platform-browser/animations";
import {MatPaginatorIntlRussian} from "core-app/components/wp-topics-dialog/MatPaginatorIntlRussian";
import {HomescreenDiagramComponent} from "core-components/homescreen-diagram/homescreen-diagram.component";
//knm
import { MatTooltipModule } from '@angular/material/tooltip';
import { DragDropModule } from '@angular/cdk/drag-drop';
@NgModule({
  imports: [
    UIRouterModule.forRoot({
      states: OPENPROJECT_ROUTES,
      useHash: false,
      config: uiRouterConfiguration
    } as any),
    //bbm(
    ChartsModule,
    FormsModule,
    MatDialogModule,
    MatTableModule,
    MatPaginatorModule,
    BrowserAnimationsModule,
    //)
    //knm
    MatTooltipModule,
    DragDropModule
  ],
  providers: [
    {
      provide: APP_INITIALIZER,
      useFactory: initializeUiRouterListeners,
      deps: [Injector],
      multi: true
    },
    { provide: MatPaginatorIntl, useClass: MatPaginatorIntlRussian },
    FirstRouteService,
  ],
  declarations: [
    ApplicationBaseComponent,
  ],
  entryComponents: [
    ApplicationBaseComponent,
  ],
  exports: [
  ]
})
export class OpenprojectRouterModule {
}
