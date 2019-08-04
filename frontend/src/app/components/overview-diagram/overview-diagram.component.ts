import {Component, ElementRef, Injector, OnInit} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {States} from "core-components/states.service";
import {StateService} from "@uirouter/core";

export const overviewDiagramSelector = 'overview-diagram';

@Component({
  selector: overviewDiagramSelector,
  templateUrl: './overview-diagram.html'
})
export class OverviewDiagramComponent implements OnInit {
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
