import {Component, ElementRef, OnInit} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";

@Component({
  selector: 'wp-overview-diagram-queries-tab',
  templateUrl: './overview-diagram-queries-tab.html'
})
export class WorkPackageOverviewDiagramQueriesTabComponent implements OnInit {

  constructor(protected I18n:I18nService,
              readonly element:ElementRef) { }

  ngOnInit():void {
  }

}
