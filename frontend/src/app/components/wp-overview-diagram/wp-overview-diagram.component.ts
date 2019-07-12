import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {Component, ElementRef, OnInit} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";

export const overviewDiagramSelector = 'wp-overview-diagram';

@Component({
  selector: overviewDiagramSelector,
  templateUrl: './wp-overview-diagram.html'
})
export class WorkPackageOverviewDiagramComponent implements OnInit {
  public text:any = {};
  public focusAnchorLabel:string;

  constructor(protected I18n:I18nService,
              readonly element:ElementRef) { }

  ngOnInit():void {
    this.text.tabs = {};
    ['overview', 'queries'].forEach(tab => {
      this.text.tabs[tab] = this.I18n.t('js.work_packages.tabs.' + tab);
    });
    this.focusAnchorLabel = 'Dunno';
  }

}
DynamicBootstrapper.register({ selector: overviewDiagramSelector, cls: WorkPackageOverviewDiagramComponent });
