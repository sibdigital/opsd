import {Component, OnInit, ViewChild} from "@angular/core";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {AngularTrackingHelpers} from "core-components/angular/tracking-functions";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";

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

  constructor(protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) {
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
  }

  ngOnInit() {
    this.halResourceService.get<CollectionResource<HalResource>>(this.pathHelper.api.v3.organizations.toString())
      .toPromise()
      .then((organizations:CollectionResource<HalResource>) => {
        this.valueOptions = organizations.elements.map((el:HalResource) => {
          return {name: el.name, $href: el.id};
        });
        this.value = this.valueOptions[0];
      });
    this.data = [];
    const filtersGreen = [
      {
        status: {
          operator: 'o',
          values: []
        },
      },
      {
        planType: {
          operator: '~',
          values: ['execution']
        }
      },
      {
        type: {
          operator: '=',
          values: ['1']
        }
      },
      {
        dueDate: {
          operator: '>t+',
          values: ['0']
        }
      },
      {
        organization: {
          operator: '=',
          values: ['1']
        }
      }
    ];
    this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages.toString(), {filters: JSON.stringify(filtersGreen)})
      .toPromise()
      .then((resources:CollectionResource<WorkPackageResource>) => {
        resources.elements.map( (el, i) => {
          let row = this.data[i] ? this.data[i] :{};
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
    const filtersRed = [
      {
        status: {
          operator: 'o',
          values: []
        },
      },
      {
        planType: {
          operator: '~',
          values: ['execution']
        }
      },
      {
        type: {
          operator: '=',
          values: ['2']
        }
      },
      {
        dueDate: {
          operator: '<t-',
          values: ['0']
        }
      },
      {
        organization: {
          operator: '=',
          values: ['1']
        }
      }
    ];
    this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages.toString(), {filters: JSON.stringify(filtersRed)})
      .toPromise()
      .then((resources:CollectionResource<WorkPackageResource>) => {
        resources.elements.map( (el, i) => {
          let row = this.data[i] ? this.data[i] :{};
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
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.problems.toString())
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
      .get<HalResource>(this.pathHelper.api.v3.summary_budgets.toString())
      .toPromise()
      .then((resources:HalResource) => {
        resources.source.map( (el:HalResource, i:number) => {
          let row = this.data[i] ? this.data[i] :{};
          let id = el.project.id;
          let name = el.project.name;
          let spent = el.spent;
          let total_budget = el.total_budget;
          let budget = {id: id, name: name, value: total_budget === '0.0' ? 0 : spent / total_budget};
          row["budget"] = budget;
          this.data[i] = row;
        });
      });
  }

  public get selectedOption() {
    const $href = this.value ? this.value.$href : null;
    return _.find(this.valueOptions, o => o.$href === $href) || this.valueOptions[0];
  }

  public set selectedOption(val:ValueOption) {
    let option = _.find(this.valueOptions, o => o.$href === val.$href);
    this.value = option;
  }

  public handleUserSubmit() {
    if (this.selectedOption && this.selectedOption.$href) {
      this.blueChild.changeFilter(this.selectedOption.$href);
      this.data = [];
      const filtersGreen = [
        {
          status: {
            operator: 'o',
            values: []
          },
        },
        {
          planType: {
            operator: '~',
            values: ['execution']
          }
        },
        {
          type: {
            operator: '=',
            values: ['1']
          }
        },
        {
          dueDate: {
            operator: '>t+',
            values: ['0']
          }
        },
        {
          organization: {
            operator: '=',
            values: [this.selectedOption.$href]
          }
        }
      ];
      this.halResourceService
        .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages.toString(), {filters: JSON.stringify(filtersGreen)})
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
      const filtersRed = [
        {
          status: {
            operator: 'o',
            values: []
          },
        },
        {
          planType: {
            operator: '~',
            values: ['execution']
          }
        },
        {
          type: {
            operator: '=',
            values: ['2']
          }
        },
        {
          dueDate: {
            operator: '<t-',
            values: ['0']
          }
        },
        {
          organization: {
            operator: '=',
            values: [this.selectedOption.$href]
          }
        }
      ];
      this.halResourceService
        .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages.toString(), {filters: JSON.stringify(filtersRed)})
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
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.problems.toString())
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
        .get<HalResource>(this.pathHelper.api.v3.summary_budgets.toString())
        .toPromise()
        .then((resources:HalResource) => {
          resources.source.map( (el:HalResource, i:number) => {
            let row = this.data[i] ? this.data[i] :{};
            let id = el.project.id;
            let name = el.project.name;
            let spent = el.spent;
            let total_budget = el.total_budget;
            let budget = {id: id, name: name, value: total_budget === '0.0' ? 0 : spent / total_budget};
            row["budget"] = budget;
            this.data[i] = row;
          });
        });
    }
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
