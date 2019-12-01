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

import {NgModule, APP_INITIALIZER, Injector} from '@angular/core';
import {DynamicModule} from 'ng-dynamic-component';
import {HookService} from "core-app/modules/plugins/hook-service";
import {MyPageComponent} from "core-components/routing/my-page/my-page.component";
import {OpenprojectCommonModule} from "core-app/modules/common/openproject-common.module";
import {BrowserModule} from '@angular/platform-browser';
import {FormsModule} from '@angular/forms';
import {DragDropModule} from '@angular/cdk/drag-drop';
import {OpenprojectWorkPackagesModule} from "core-app/modules/work_packages/openproject-work-packages.module";
import {WidgetWpAssignedComponent} from "core-app/modules/grids/widgets/wp-assigned/wp-assigned.component.ts";
//#zbd(
import {WidgetWpRemainingComponent} from "core-app/modules/grids/widgets/wp-remaining/wp-remaining.component.ts";
//)
//#ban(
import {WidgetUtNotesComponent} from "core-app/modules/grids/widgets/ut-notes/ut-notes.component.ts";
import {WidgetUtRequestsComponent} from "core-app/modules/grids/widgets/ut-requests/ut-requests.component.ts";
import {WidgetUtMyRequestsComponent} from "core-app/modules/grids/widgets/ut-my-requests/ut-my-requests.component.ts";
import {WidgetUtResponsesComponent} from "core-app/modules/grids/widgets/ut-responses/ut-responses.component.ts";
import {WidgetUtTasksComponent} from "core-app/modules/grids/widgets/ut-tasks/ut-tasks.component.ts";
import {WidgetUtMyTasksComponent} from "core-app/modules/grids/widgets/ut-my-tasks/ut-my-tasks.component.ts";
import {WidgetDayTasksComponent} from "core-app/modules/grids/widgets/day-tasks/day-tasks.component.ts";
import {WidgetOverdueListComponent} from "core-app/modules/grids/widgets/overdue-list/overdue-list.component.ts";
//)
//#knm(
import {WidgetNotificationsComponent} from "core-app/modules/grids/widgets/notifications/notifications.component";
//)
import {WidgetWpCreatedComponent} from "core-app/modules/grids/widgets/wp-created/wp-created.component.ts";
import {WidgetWpWatchedComponent} from "core-app/modules/grids/widgets/wp-watched/wp-watched.component.ts";
import {WidgetWpCalendarComponent} from "core-app/modules/grids/widgets/wp-calendar/wp-calendar.component.ts";
import {WidgetTimeEntriesCurrentUserComponent} from "core-app/modules/grids/widgets/time-entries-current-user/time-entries-current-user.component";
import {GridWidgetsService} from "core-app/modules/grids/widgets/widgets.service";
import {GridComponent} from "core-app/modules/grids/grid/grid.component";
import {AddGridWidgetModal} from "core-app/modules/grids/widgets/add/add.modal";
import {GridColumnContextMenu} from "core-app/modules/grids/context_menus/column.directive";
import {GridRowContextMenu} from "core-app/modules/grids/context_menus/row.directive";
import {OpenprojectCalendarModule} from "core-app/modules/calendar/openproject-calendar.module";
import {Ng2StateDeclaration, UIRouterModule} from '@uirouter/angular';
import {WidgetDocumentsComponent} from "core-app/modules/grids/widgets/documents/documents.component";
import {WidgetNewsComponent} from "core-app/modules/grids/widgets/news/news.component";
import {WidgetWpAccountableComponent} from './widgets/wp-accountable/wp-accountable.component';

export const GRID_ROUTES:Ng2StateDeclaration[] = [
  {
    name: 'my_page',
    url: '/my/page',
    component: MyPageComponent,
  },
];


@NgModule({
  imports: [
    BrowserModule,
    FormsModule,
    DragDropModule,

    OpenprojectCommonModule,
    OpenprojectWorkPackagesModule,
    OpenprojectCalendarModule,

    DynamicModule.withComponents([WidgetDocumentsComponent,
                                  WidgetNewsComponent,
                                  //knm
                                  WidgetNotificationsComponent,
                                  //
                                  WidgetWpAssignedComponent,
                                  //zbd
                                  WidgetWpRemainingComponent,
                                  //
                                  //ban
                                  WidgetUtNotesComponent,
                                  WidgetUtRequestsComponent,
                                  WidgetUtMyRequestsComponent,
                                  WidgetUtResponsesComponent,
                                  WidgetUtTasksComponent,
                                  WidgetUtMyTasksComponent,
                                  WidgetDayTasksComponent,
                                  WidgetOverdueListComponent,
                                  //
                                  WidgetWpAccountableComponent,
                                  WidgetWpCreatedComponent,
                                  WidgetWpWatchedComponent,
                                  WidgetWpCalendarComponent,
                                  WidgetTimeEntriesCurrentUserComponent]),

    // Routes for grid pages
    UIRouterModule.forChild({ states: GRID_ROUTES }),
  ],
  providers: [
    {
      provide: APP_INITIALIZER,
      useFactory: registerWidgets,
      deps: [Injector],
      multi: true
    },
    GridWidgetsService,
  ],
  declarations: [
    GridComponent,
    WidgetDocumentsComponent,
    WidgetNewsComponent,
    //knm
    WidgetNotificationsComponent,
    //
    WidgetWpAssignedComponent,
    //zbd
    WidgetWpRemainingComponent,
    //
    //ban
    WidgetUtNotesComponent,
    WidgetUtRequestsComponent,
    WidgetUtMyRequestsComponent,
    WidgetUtResponsesComponent,
    WidgetUtTasksComponent,
    WidgetUtMyTasksComponent,
    WidgetDayTasksComponent,
    WidgetOverdueListComponent,
    //
    WidgetWpAccountableComponent,
    WidgetWpCreatedComponent,
    WidgetWpWatchedComponent,
    WidgetWpCalendarComponent,
    WidgetTimeEntriesCurrentUserComponent,
    AddGridWidgetModal,

    GridColumnContextMenu,
    GridRowContextMenu,

    // MyPage
    MyPageComponent,
  ],
  entryComponents: [
    AddGridWidgetModal,

    // MyPage
    MyPageComponent,
  ],
  exports: [
  ]
})
export class OpenprojectGridsModule {
}

export function registerWidgets(injector:Injector) {
  return () => {
    const hookService = injector.get(HookService);
    hookService.register('gridWidgets', () => {
      return [
        {
          identifier: 'work_packages_assigned',
          component: WidgetWpAssignedComponent
        },
        //zbd(
        {
          identifier: 'work_packages_remaining',
          component: WidgetWpRemainingComponent
        },
        //)
        //ban(
        {
          identifier: 'user_tasks_notes',
          component: WidgetUtNotesComponent
        },
        {
          identifier: 'user_tasks_requests',
          component: WidgetUtRequestsComponent
        },
        {
          identifier: 'user_tasks_my_requests',
          component: WidgetUtMyRequestsComponent
        },
        {
          identifier: 'user_tasks_responses',
          component: WidgetUtResponsesComponent
        },
        {
          identifier: 'user_tasks_tasks',
          component: WidgetUtTasksComponent
        },
        {
          identifier: 'user_tasks_my_tasks',
          component: WidgetUtMyTasksComponent
        },
        {
          identifier: 'day_tasks',
          component: WidgetDayTasksComponent
        },
        {
          identifier: 'overdue_list',
          component: WidgetOverdueListComponent
        },
        //)
        {
          identifier: 'work_packages_accountable',
          component: WidgetWpAccountableComponent
        },
        {
          identifier: 'work_packages_created',
          component: WidgetWpCreatedComponent
        },
        {
          identifier: 'work_packages_watched',
          component: WidgetWpWatchedComponent
        },
        {
          identifier: 'work_packages_calendar',
          component: WidgetWpCalendarComponent
        },
        {
          identifier: 'time_entries_current_user',
          component: WidgetTimeEntriesCurrentUserComponent
        },
        {
          identifier: 'documents',
          component: WidgetDocumentsComponent
        },
        {
          identifier: 'news',
          component: WidgetNewsComponent
        },
        {
          identifier: 'notifications',
          component: WidgetNotificationsComponent
        }
      ];
    });
  };
}
