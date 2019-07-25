import {Component, ElementRef, OnInit} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {ChartDataSets} from "chart.js";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {StatusResource} from "core-app/modules/hal/resources/status-resource";

@Component({
  selector: 'wp-overview-diagram-queries-tab',
  templateUrl: './overview-diagram-queries-tab.html'
})
export class WorkPackageOverviewDiagramQueriesTabComponent implements OnInit {
  public queriesList:any[] = [];

  constructor(protected I18n:I18nService,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) { }

  ngOnInit():void {
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.diagram_queries.toString())
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        resources.elements.map(el => {
          this.queriesList.push({name: el.name, params: el.params});
        });
      });
  }
}
