import {Component, OnInit, QueryList, ViewChild, ViewChildren} from "@angular/core";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {AngularTrackingHelpers} from "core-components/angular/tracking-functions";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {HomescreenDiagramComponent} from "core-components/homescreen-diagram/homescreen-diagram.component";

export interface ValueOption {
  name:string;
  $href:string | null;
}

@Component({
  templateUrl: './municipality-tab.html',
  styleUrls: ['./municipality-tab.sass']
})
export class MunicipalityTabComponent implements OnInit {
  public options:any[];
  private value:{ [attribute:string]:any } | undefined = {};
  public valueOptions:ValueOption[] = [];
  public compareByHref = AngularTrackingHelpers.compareByHref;
  protected readonly appBasePath:string;
  public data:any[] = [];

  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;
  @ViewChildren(HomescreenDiagramComponent) homescreenDiagrams:QueryList<HomescreenDiagramComponent>;

  constructor(protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService,
              readonly I18n:I18nService) {
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
  }

  ngOnInit() {
    this.halResourceService.get<CollectionResource<HalResource>>(this.pathHelper.api.v3.raions.toString())
      .toPromise()
      .then((raions:CollectionResource<HalResource>) => {
        this.valueOptions = raions.elements.map((el:HalResource) => {
          return {name: el.name, $href: el.id};
        });
        this.value = this.valueOptions[0];
        // this.handleUserSubmit();
        this.updateColorTables();
      });
  }

  public get selectedOption() {
    const $href = this.value ? this.value.$href : null;
    return _.find(this.valueOptions, o => o.$href === $href)!;
  }

  public set selectedOption(val:ValueOption) {
    let option = _.find(this.valueOptions, o => o.$href === val.$href);
    this.value = option;
  }

  public handleUserSubmit() {
    if (this.selectedOption) {
      this.homescreenDiagrams.forEach((diagram) => {
        if (this.selectedOption.$href) {
          diagram.refreshByMunicipality(Number(this.selectedOption.$href));
        }
      });
      this.blueChild.changeFilter(String(this.selectedOption.$href));
      this.updateColorTables();
    }
  }

  public updateColorTables() {
    this.data = [];
    let from = new Date();
    let to = new Date();
    to.setDate(to.getDate() + 14);
    this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages_future.toString(), {raion: this.selectedOption.$href})
      .toPromise()
      .then((resources:CollectionResource<WorkPackageResource>) => {
        resources.elements.map((el, i) => {
          let row = this.data[i] ? this.data[i] : {};
          let id = el.id;
          let subject = el.subject;
          let projectId = '';
          let project = '';
          if (el.$links.project) {
            projectId = el.$links.project.href.substr(17);
            project = el.$links.project.title;
          }
          let upcoming_tasks = {id: id, subject: subject, project: project, projectId: projectId};
          row["upcoming_tasks"] = upcoming_tasks;
          this.data[i] = row;
        });
      });
    this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages_due.toString(), {raion: this.selectedOption.$href})
      .toPromise()
      .then((resources:CollectionResource<WorkPackageResource>) => {
        resources.elements.map((el, i) => {
          let row = this.data[i] ? this.data[i] : {};
          let id = el.id;
          let subject = el.subject;
          let projectId = '';
          let project = '';
          if (el.$links.project) {
            projectId = el.$links.project.href.substr(17);
            project = el.$links.project.title;
          }
          let due_milestone = {id: id, subject: subject, project: project, projectId: projectId};
          row["due_milestone"] = due_milestone;
          this.data[i] = row;
        });
      });
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.problems.toString(), {"status": "created", "raion": this.selectedOption.$href})
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        resources.elements.map( (el, i) => {
          let row = this.data[i] ? this.data[i] :{};
          let id = el.id;
          let risk = el.risk;
          let wptitle = el.workPackage ? el.workPackage.$links.self.title : '';
          let wpid = el.workPackage ? el.workPackage.$links.self.href.slice(22) : '';
          let problems = {id: id, risk: risk, wptitle: wptitle, wpid: wpid};
          row["problems"] = problems;
          this.data[i] = row;
        });
      });
    this.halResourceService
      .get<HalResource>(this.pathHelper.api.v3.summary_budgets.toString(), {"raion": this.selectedOption.$href})
      .toPromise()
      .then((resources:HalResource) => {
        resources.source.map( (el:HalResource, i:number) => {
          let row = this.data[i] ? this.data[i] :{};
          let id = el.project.id;
          let name = el.project.name;
          let spent = el.spent;
          let total_budget = el.total_budget;
          let budget = {id: id, name: name, value: total_budget === '0.0' ? 0 : total_budget - spent};
          row["budget"] = budget;
          this.data[i] = row;
        });
      });
  }

  public getGreenClass(i:number):string {
    if (i % 2 === 0) {
      return "colored-col-bright-green";
    } else {
      return "colored-col-green";
    }
  }

  public getRedClass(i:number):string {
    if (i % 2 === 0) {
      return "colored-col-bright-red";
    } else {
      return "colored-col-red";
    }
  }

  public getOrangeClass(i:number):string {
    if (i % 2 === 0) {
      return "colored-col-bright-orange";
    } else {
      return "colored-col-orange";
    }
  }

  public getPurpleClass(i:number):string {
    if (i % 2 === 0) {
      return "colored-col-bright-purple";
    } else {
      return "colored-col-purple";
    }
  }

  public getBasePath():string {
    return this.appBasePath;
  }

  public shorten(input:string):string {
    if (input) {
      return input.length > 70 ? input.slice(0, 70) + '...' : input;
    } else {
      return '';
    }
  }
}
