import {Component, OnInit, ViewChild} from '@angular/core';
import {ChartOptions, ChartType, ChartDataSets} from 'chart.js';
import {BaseChartDirective, Label} from 'ng2-charts';
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";
import {StatusResource} from "core-app/modules/hal/resources/status-resource";
import {UserResource} from "core-app/modules/hal/resources/user-resource";
import {TimezoneService} from "core-components/datetime/timezone.service";

export interface ValueOption {
  name:string;
  id:string;
}

/*export interface Params {
  statusCheck:boolean;
  projectCheck:boolean;
  assigneeCheck:boolean;
  organizationCheck:boolean;
  dateCheck:boolean;
  kpiCheck:boolean;
  status:number[];
  project:number [];
  assignee:number [];
  organization:number [];
  dateBegin:string;
  dateEnd:string;
  kpiOperation:string;
  kpiValue:string;
}*/

@Component({
  selector: 'overview-diagram-tab',
  templateUrl: './overview-diagram-tab.html'
})
export class OverviewDiagramTabComponent implements OnInit {
  public barChartOptions:ChartOptions = {
    responsive: true,
    scales: {
      yAxes: [{
        ticks: {
          beginAtZero: true
        }
      }]
    }
  };
  public barChartLabels:Label[] = [];
  public barChartType:ChartType = 'bar';
  public barChartLegend = true;
  public barChartPlugins = [];
  public barChartData:ChartDataSets[] = [
    {data:[]}
  ];

  //define logic var-s
  public statusCheck:boolean = false;
  public projectCheck:boolean = false;
  public assigneeCheck:boolean = false;
  public organizationCheck:boolean = false;
  public dateCheck:boolean = false;
  public kpiCheck:boolean = false;

  public statusSelect:ValueOption | undefined;
  public statusSelectOptions:ValueOption[] = [];

  public projectSelect:ValueOption | undefined;
  public projectSelectOptions:ValueOption[] = [];

  public assigneeSelect:ValueOption | undefined;
  public assigneeSelectOptions:ValueOption[] = [];

  public organizationSelect:ValueOption | undefined;
  public organizationSelectOptions:ValueOption[] = [];

  public dateBegin:string;
  public dateEnd:string;

  public kpiOperation:string;
  public kpiValue:string;

  public seriexSelect:number;
  public serieySelect:number;
  public serierSelect:number;

  @ViewChild(BaseChartDirective) chart:BaseChartDirective;

  constructor(readonly timezoneService:TimezoneService,
              protected I18n:I18nService,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) { }

  ngOnInit() {
    this.getStatuses().then((resources:CollectionResource<StatusResource>) => {
      let els = resources.elements;
      this.statusSelectOptions = els.map(el => {
        return {name: el.name, id: el.getId()};
      });
    });
    this.getProjects().then((resources:CollectionResource<ProjectResource>) => {
      let els = resources.elements;
      this.projectSelectOptions = els.map(el => {
        return {name: el.name, id: el.getId()};
      });
    });
    this.getAssignees().then((resources:CollectionResource<UserResource>) => {
      let els = resources.elements;
      this.assigneeSelectOptions = els.map(el => {
        return {name: el.name, id: el.getId()};
      });
    });
    this.getOrganizations().then((resources:CollectionResource<HalResource>) => {
      let els = resources.elements;
      this.organizationSelectOptions = els.map(el => {
        return {name: el.name, id: el.getId()};
      });
    });
    this.halResourceService
      .get<HalResource>(this.pathHelper.api.v3.diagrams.toString())
      .toPromise()
      .then((resource:HalResource) => {
        this.barChartType = resource.barChartType;
        this.seriexSelect = resource.seriexSelect;
        this.serieySelect = resource.serieySelect;
        this.serierSelect = resource.serierSelect;
        this.barChartData[0].data = resource.y;
        this.barChartData[0].label = resource.serieySelect === 0 ? '% исполнения KPI' :'Количество';
        this.barChartLabels = resource.x;
      });
  }

  public filterChart() {
    this.halResourceService
      .get<HalResource>(this.pathHelper.api.v3.diagrams.toString(), this.getParams())
      .toPromise()
      .then((resource:HalResource) => {
        this.statusSelect = this.statusSelectOptions.find( x => {return x.id.toString() === resource.status; });
        this.projectSelect = this.projectSelectOptions.find( x => {return x.id.toString() === resource.project; });
        this.assigneeSelect = this.assigneeSelectOptions.find( x => {return x.id.toString() === resource.assignee; });
        this.organizationSelect = this.organizationSelectOptions.find( x => {return x.id.toString() === resource.organization; });
        this.dateBegin = this.parser(resource.dateBegin);
        this.dateEnd =  this.parser(resource.dateEnd);
        this.kpiOperation =  resource.kpiOperation;
        this.kpiValue =  resource.kpiValue;
        this.statusCheck = (resource.statusCheck === 'true');
        this.projectCheck = (resource.projectCheck === 'true');
        this.assigneeCheck = (resource.assigneeCheck === 'true');
        this.organizationCheck = (resource.organizationCheck === 'true');
        this.dateCheck = (resource.dateCheck === 'true');
        this.kpiCheck = (resource.kpiCheck === 'true');
        this.seriexSelect = resource.seriexSelect;
        this.serieySelect = resource.serieySelect;
        this.serierSelect = resource.serierSelect;
        this.barChartData[0].data = resource.y;
        this.barChartData[0].label = resource.serieySelect === 0 ? '% исполнения KPI' :'Количество';
        this.barChartLabels = resource.x;
        this.barChartType = resource.barChartType;
      });
  }

  private getStatuses():Promise<CollectionResource<StatusResource>> {
    return this.halResourceService
      .get<CollectionResource<StatusResource>>(this.pathHelper.api.v3.statuses.toString())
      .toPromise();
  }

  private getProjects():Promise<CollectionResource<ProjectResource>> {
    return this.halResourceService
      .get<CollectionResource<ProjectResource>>(this.pathHelper.api.v3.projects.toString())
      .toPromise();
  }

  private getAssignees():Promise<CollectionResource<UserResource>> {
    return this.halResourceService
      .get<CollectionResource<UserResource>>(this.pathHelper.api.v3.users.toString())
      .toPromise();
  }

  private getOrganizations():Promise<CollectionResource<HalResource>> {
    return this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.organizations.toString())
      .toPromise();
  }

  public parser(data:any) {
    if (moment(data, 'YYYY-MM-DD', true).isValid()) {
      return data;
    } else {
      return null;
    }
  }

  public formatter(data:any) {
    if (moment(data, 'YYYY-MM-DD', true).isValid()) {
      var d = this.timezoneService.parseDate(data);
      return this.timezoneService.formattedISODate(d);
    } else {
      return null;
    }
  }

  public changeChartType() {
    this.chart.chartType = this.barChartType;
    this.chart.chart.update();
    this.filterChart();
  }

  public save() {
    this.halResourceService
      .post<HalResource>(this.pathHelper.api.v3.diagram_queries.toString(), this.getParams())
      .toPromise();
  }

  private getParams():any {
    let params:any = {};
    params['statusCheck'] = this.statusCheck;
    params['projectCheck'] = this.projectCheck;
    params['assigneeCheck'] = this.assigneeCheck;
    params['organizationCheck'] = this.organizationCheck;
    params['dateCheck'] = this.dateCheck;
    params['kpiCheck'] = this.kpiCheck;
    params['seriexSelect[0]'] = this.seriexSelect;
    params['serieySelect[0]'] = this.serieySelect;
    params['serierSelect'] = this.serierSelect;
    params['barChartType'] = this.barChartType;
    if (this.statusCheck && this.statusSelect) {
      params['status[0]'] = this.statusSelect.id;
      params['status[1]'] = 10;
    }
    if (this.projectCheck && this.projectSelect) {
      params['project[0]'] = this.projectSelect.id;
    }
    if (this.assigneeCheck && this.assigneeSelect) {
      params['assignee[0]'] = this.assigneeSelect.id;
    }
    if (this.organizationCheck && this.organizationSelect) {
      params['organization[0]'] = this.organizationSelect.id;
    }
    if (this.dateCheck && this.dateBegin) {
      params['dateBegin'] = this.dateBegin;
    }
    if (this.dateCheck && this.dateEnd) {
      params['dateEnd'] = this.dateEnd;
    }
    if (this.kpiCheck && this.kpiOperation) {
      params['kpiOperation'] = this.kpiOperation;
    }
    if (this.kpiCheck && this.kpiValue) {
      params['kpiValue'] = this.kpiValue;
    }
    return params;
  }
}
