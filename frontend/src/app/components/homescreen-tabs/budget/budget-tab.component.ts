import {Component} from "@angular/core";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {DiagramHomescreenResource} from "core-app/modules/hal/resources/diagram-homescreen-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";


@Component({
  templateUrl: './budget-tab.html'
})
export class BudgetTabComponent {
  protected readonly appBasePath:string;
  public budgetFederalChartData:any[];
  public budgetFederalChartLabel:string;
  public budgetRegionalChartData:any[];
  public budgetRegionalChartLabel:string;
  public budgetOtherChartData:any[];
  public budgetOtherChartLabel:string;
  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService) {
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
  }
  ngOnInit() {
    this.getFederalBudgetChart();
    this.getRegionalBudgetChart();
    this.getOtherBudgetChart();
  }
  public getFederalBudgetChart() {
    this.halResourceService
      .get<DiagramHomescreenResource>(`${this.pathHelper.api.v3.diagrams.toString()}/fed_budget`)
      .toPromise()
      .then((resource:DiagramHomescreenResource) => {
        this.budgetFederalChartData = resource.data;
        this.budgetFederalChartLabel = resource.label;
      });
  }
  public getRegionalBudgetChart() {
    this.halResourceService
      .get<DiagramHomescreenResource>(`${this.pathHelper.api.v3.diagrams.toString()}/reg_budget`)
      .toPromise()
      .then((resource:DiagramHomescreenResource) => {
        this.budgetRegionalChartData = resource.data;
        this.budgetRegionalChartLabel = resource.label;
      });
  }
  public getOtherBudgetChart() {
    this.halResourceService
      .get<DiagramHomescreenResource>(`${this.pathHelper.api.v3.diagrams.toString()}/other_budget`)
      .toPromise()
      .then((resource:DiagramHomescreenResource) => {
        this.budgetOtherChartData = resource.data;
        this.budgetOtherChartLabel = resource.label;
      });
  }
}
