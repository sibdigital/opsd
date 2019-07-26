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

import {NgModule} from '@angular/core';
import {UIRouterModule} from "@uirouter/angular";
import {
  HOMESCREEN_ROUTES,
} from "core-app/modules/router/openproject.routes";
import {ChartsModule} from "ng2-charts";
import {FormsModule} from "@angular/forms";
import {BrowserAnimationsModule} from "@angular/platform-browser/animations";
import {BrowserModule} from "@angular/platform-browser";
import {OpenprojectCommonModule} from "core-app/modules/common/openproject-common.module";
import {OverviewDiagramQueriesTabComponent} from "core-components/overview-diagram/overview-diagram-queries-tab/overview-diagram-queries-tab.component";
import {OverviewDiagramTabComponent} from "core-components/overview-diagram/overview-diagram-tab/overview-diagram-tab.component";
import {OverviewDiagramComponent} from "core-components/overview-diagram/overview-diagram.component";
import {KpiTabComponent} from "core-components/homescreen-tabs/kpi-tab/kpi-tab.component";
import {HomescreenTabsComponent} from "core-components/homescreen-tabs/homescreen-tabs.component";
import {HomescreenDiagramComponent} from "core-components/homescreen-diagram/homescreen-diagram.component";
import {DesktopTabComponent} from "core-components/homescreen-tabs/desktop-tab/desktop-tab.component";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";
import {KtTabComponent} from "core-components/homescreen-tabs/kt-tab/kt-tab.component";
import {HomescreenBlueTableService} from "core-components/homescreen-blue-table/homescreen-blue-table.service";
import {BlueTableNationalProjectsService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-national-projects.service";
import {BlueTableKtService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-kt.service";

@NgModule({
  imports: [
    UIRouterModule.forChild({
      states: HOMESCREEN_ROUTES
    }),
    BrowserModule,
    ChartsModule,
    FormsModule,
    BrowserAnimationsModule,
    OpenprojectCommonModule
  ],
  providers: [
    HomescreenDiagramComponent,
    OverviewDiagramComponent,
    OverviewDiagramTabComponent,
    OverviewDiagramQueriesTabComponent,
    HomescreenTabsComponent,
    KpiTabComponent,
    DesktopTabComponent,
    KtTabComponent,
    HomescreenBlueTableComponent,
    HomescreenBlueTableService,
    BlueTableNationalProjectsService,
    BlueTableKtService
  ],
  declarations: [
    HomescreenDiagramComponent,
    OverviewDiagramComponent,
    OverviewDiagramTabComponent,
    OverviewDiagramQueriesTabComponent,
    HomescreenTabsComponent,
    KpiTabComponent,
    DesktopTabComponent,
    KtTabComponent,
    HomescreenBlueTableComponent
  ],
  entryComponents: [
    HomescreenDiagramComponent,
    OverviewDiagramComponent,
    OverviewDiagramTabComponent,
    OverviewDiagramQueriesTabComponent,
    HomescreenTabsComponent,
    KpiTabComponent,
    DesktopTabComponent,
    KtTabComponent,
    HomescreenBlueTableComponent
  ],
  exports: [
  ],
  bootstrap: [
    OverviewDiagramComponent,
    HomescreenTabsComponent
  ]
})
export class HomescreenOverviewRouterModule {
}
