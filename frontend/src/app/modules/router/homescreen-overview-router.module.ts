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
import {BlueTableDesktopService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-desktop.service";
import {BlueTableKtService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-kt.service";
import {ProblemsTabComponent} from "core-components/homescreen-tabs/problems-tab/problems-tab.component";
import {BlueTableProblemsService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-problems.service";
import {BlueTableKpiService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-kpi.service";
import {BlueTableDiscussService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-discuss.service";
import {DiscussTabComponent} from "core-components/homescreen-tabs/discuss-tab/discuss-tab.component";
import {BudgetTabComponent} from "core-components/homescreen-tabs/budget/budget-tab.component";
import {BlueTableBudgetService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-budget.service";
import {IndicatorTabComponent} from "core-components/homescreen-tabs/indicator/indicator-tab.component";
import {BlueTableIndicatorService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-indicator.service";
import {ProtocolTabComponent} from "core-components/homescreen-tabs/protocol-tab/protocol-tab.component";
import {BlueTableProtocolService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-protocol.service";
import {MunicipalityTabComponent} from "core-components/homescreen-tabs/municipality/municipality-tab.component";
import {BlueTableMunicipalityService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-municipality.service";
import {HomescreenProgressBarComponent} from "core-components/homescreen-progress-bar/homescreen-progress-bar.component";
import {PerformanceTabComponent} from "core-components/homescreen-tabs/performance-tab/performance-tab.component";
import {BlueTablePerformanceService} from "core-components/homescreen-blue-table/blue-table-types/blue-table-performance.service";
import {HomescreenPerformanceDiagramComponent} from "core-components/homescreen-performance-diagram/homescreen-performance-diagram.component";
import {ActivatedRoute, RouterModule} from "@angular/router";

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
    BlueTableDesktopService,
    BlueTableKtService,
    BlueTableProblemsService,
    BlueTableKpiService,
    BlueTableDiscussService,
    BlueTableBudgetService,
    BlueTableIndicatorService,
    BlueTableProtocolService,
    BlueTableMunicipalityService,
    BlueTablePerformanceService
  ],
  declarations: [
    HomescreenProgressBarComponent,
    HomescreenDiagramComponent,
    HomescreenPerformanceDiagramComponent,
    OverviewDiagramComponent,
    OverviewDiagramTabComponent,
    OverviewDiagramQueriesTabComponent,
    HomescreenTabsComponent,
    KpiTabComponent,
    DesktopTabComponent,
    KtTabComponent,
    ProblemsTabComponent,
    DiscussTabComponent,
    BudgetTabComponent,
    IndicatorTabComponent,
    ProtocolTabComponent,
    MunicipalityTabComponent,
    PerformanceTabComponent,
    HomescreenBlueTableComponent
  ],
  entryComponents: [
    HomescreenProgressBarComponent,
    HomescreenDiagramComponent,
    HomescreenPerformanceDiagramComponent,
    OverviewDiagramComponent,
    OverviewDiagramTabComponent,
    OverviewDiagramQueriesTabComponent,
    HomescreenTabsComponent,
    KpiTabComponent,
    DesktopTabComponent,
    KtTabComponent,
    ProblemsTabComponent,
    DiscussTabComponent,
    BudgetTabComponent,
    IndicatorTabComponent,
    ProtocolTabComponent,
    MunicipalityTabComponent,
    PerformanceTabComponent,
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
