import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {platformBrowserDynamic} from '@angular/platform-browser-dynamic';
import {Component, ElementRef, Injector, OnInit} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {States} from "core-components/states.service";
import {FirstRouteService} from "core-app/modules/router/first-route-service";
import {KeepTabService} from "core-components/wp-single-view-tabs/keep-tab/keep-tab.service";
import {WorkPackageTableSelection} from "core-components/wp-fast-table/state/wp-table-selection.service";
import {WorkPackageTableFocusService} from "core-components/wp-fast-table/state/wp-table-focus.service";
import {StateService} from "@uirouter/core";

export const overviewDiagramSelector = 'wp-overview-diagram';

@Component({
  selector: overviewDiagramSelector,
  templateUrl: './wp-overview-diagram.html'
})
export class WorkPackageOverviewDiagramComponent implements OnInit {
  public text:any = {};
  public focusAnchorLabel:string;

  constructor(public injector:Injector,
              public states:States,
              readonly $state:StateService,
              protected I18n:I18nService,
              readonly element:ElementRef) { }

  ngOnInit():void {
    this.text.tabs = {};
    ['overview', 'queries'].forEach(tab => {
      this.text.tabs[tab] = this.I18n.t('js.work_packages.tabs.' + tab);
    });
    this.focusAnchorLabel = 'Dunno';
  }

}
//DynamicBootstrapper.register({ selector: overviewDiagramSelector, cls: WorkPackageOverviewDiagramComponent });
