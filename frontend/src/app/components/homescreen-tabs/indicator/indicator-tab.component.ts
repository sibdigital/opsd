import {Component} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";


@Component({
  templateUrl: './indicator-tab.html'
})
export class IndicatorTabComponent {
  public chartsData:any[];
  protected readonly appBasePath:string;
  constructor(protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService,
              readonly I18n:I18nService) {
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
  }
  ngOnInit() {
    this.getChartsData();
  }
  private getChartsData() {
    this.halResourceService
      .get<HalResource>(`${this.pathHelper.api.v3.diagrams.toString()}/municipality`)
      .toPromise()
      .then((resource:HalResource) => {
        this.chartsData = resource.nationalProjects;
      });
  }
}
