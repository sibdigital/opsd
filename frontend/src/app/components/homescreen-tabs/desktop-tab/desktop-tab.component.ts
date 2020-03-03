import {Component, OnInit, QueryList, ViewChild, ViewChildren} from "@angular/core";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {AngularTrackingHelpers} from "core-components/angular/tracking-functions";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";
import {HomescreenDiagramComponent} from "core-components/homescreen-diagram/homescreen-diagram.component";

export interface ValueOption {
  name:string;
  $href:string | null;
}

@Component({
  selector: 'desktop-tab',
  templateUrl: './desktop-tab.html',
  styleUrls: ['./desktop-tab.sass']
})
export class DesktopTabComponent implements OnInit {
  protected readonly appBasePath:string;
  public data:any[] = [];
  public problemCount:number = 0;
  keyword = 'name';
  data_autocomplete:any[] = [];
  data_choosed:any;
  is_loading:boolean[] = [true, true, true, true, true];
  public options:any[];
  private value:{ [attribute:string]:any } | undefined = {};
  public valueOptions:ValueOption[] = [];
  public compareByHref = AngularTrackingHelpers.compareByHref;

  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;
  @ViewChildren(HomescreenDiagramComponent) homescreenDiagrams:QueryList<HomescreenDiagramComponent>;
  @ViewChild('autocomplete') auto:any;

  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService) {
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
  }

  ngOnInit() {
    let from = new Date();
    let to = new Date();
    to.setDate(to.getDate() + 14);
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
          operator: '<>d',
          values: [from.toISOString().slice(0, 10), to.toISOString().slice(0, 10)]
        }
      }
    ];
    this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages_by_role.toString(), {filters: JSON.stringify(filtersGreen)})
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
        this.is_loading[1] = false;
      }).catch(function (reason) {
      console.log(reason);
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
          values: ['1']
        }
      }
    ];
    this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages_by_role.toString(), {filters: JSON.stringify(filtersRed)})
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
        this.is_loading[2] = false;
      }).catch(function (reason) {
      console.log(reason);
    });
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.problems.toString(), {"status": "created"})
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
        this.problemCount = resources.elements ? resources.elements.length : 0;
        this.is_loading[3] = false;
      }).catch(function (reason) {
      console.log(reason);
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
          let budget = {id: id, name: name, value: total_budget === '0.0' ? 0 : total_budget - spent };
          row["budget"] = budget;
          this.data[i] = row;
        });
        this.is_loading[4] = false;
      }).catch(function (reason) {
      console.log(reason);
    });
    this.halResourceService.get<CollectionResource<HalResource>>(this.pathHelper.api.v3.projects_for_user.toString())
      .toPromise()
      .then((projects:CollectionResource<HalResource>) => {
        this.valueOptions = projects.elements.sort((a, b) => (a.name > b.name ? 1 : -1)).map((el:HalResource) => {
          this.data_autocomplete.push({id: el.id, name: el.name});
          return {name: el.name, $href: el.id};
        });
        this.is_loading[0] = false;
        this.valueOptions.unshift({name: 'Все проекты', $href: "0"});
        this.value = this.valueOptions[0];
      }).catch(function (reason) {
      console.log(reason);
    });
  }

  public check_load() {
    // console.log(this.is_loading);
    return this.is_loading[0] || this.is_loading[1] || this.is_loading[2] || this.is_loading[3] || this.is_loading[4];

    // let is_ready = true;
    // this.is_loading.forEach(value => (is_ready = value || is_ready));
    // return is_ready;
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
          diagram.refresh(this.selectedOption.$href);
        }
      });
      this.blueChild.changeFilter(String(this.selectedOption.$href));
      this.data = [];
      let from = new Date();
      let to = new Date();
      to.setDate(to.getDate() + 14);
      let filtersGreen = [
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
            operator: '<>d',
            values: [from.toISOString().slice(0, 10), to.toISOString().slice(0, 10)]
          }
        },
        {
          project: {
            operator: '=',
            values: [String(this.selectedOption.$href)]
          }
        }
      ];
      if (this.selectedOption.$href === "0") {
        filtersGreen.pop();
      }
      this.halResourceService
        .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages_by_role.toString(), {filters: JSON.stringify(filtersGreen)})
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
      let filtersRed = [
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
            values: ['1']
          }
        },
        {
          project: {
            operator: '=',
            values: [String(this.selectedOption.$href)]
          }
        }
      ];
      if (this.selectedOption.$href === "0") {
        filtersRed.pop();
      }
      this.halResourceService
        .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages_by_role.toString(), {filters: JSON.stringify(filtersRed)})
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
      let params:any = {"status": "created"};
      if (this.selectedOption.$href !== "0") {
        params = {"status": "created", "project": this.selectedOption.$href};
      }
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.problems.toString(), params)
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
          this.problemCount = resources.elements ? resources.elements.length : 0;
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
  selectEvent(item:any) {
    this.auto.close();
    this.is_loading[1] = true;
    this.is_loading[2] = true;
    this.is_loading[3] = true;
    this.is_loading[4] = true;
    this.data_choosed = item;
    this.homescreenDiagrams.forEach((diagram) => {
        diagram.refresh(this.data_choosed.id);
    });
    this.blueChild.changeFilter(String(this.data_choosed.id));
    this.data = [];
    let from = new Date();
    let to = new Date();
    to.setDate(to.getDate() + 14);
    let filtersGreen = [
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
          operator: '<>d',
          values: [from.toISOString().slice(0, 10), to.toISOString().slice(0, 10)]
        }
      },
      {
        project: {
          operator: '=',
          values: [String(this.data_choosed.id)]
        }
      }
    ];
    if (this.data_choosed.id === 0) {
      filtersGreen.pop();
    }
    this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages_by_role.toString(), {filters: JSON.stringify(filtersGreen)})
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
        this.is_loading[1] = false;
      });
    let filtersRed = [
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
          values: ['1']
        }
      },
      {
        project: {
          operator: '=',
          values: [String(this.data_choosed.id)]
        }
      }
    ];
    if (this.data_choosed.id === 0) {
      filtersRed.pop();
    }
    this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.work_packages_by_role.toString(), {filters: JSON.stringify(filtersRed)})
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
        this.is_loading[2] = false;
      });
    let params:any = {"status": "created"};
    if (this.data_choosed.id !== 0) {
      params = {"status": "created", "project": this.data_choosed.id};
    }
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.problems.toString(), params)
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
        this.problemCount = resources.elements ? resources.elements.length : 0;
        this.is_loading[3] = false;
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
        this.is_loading[4] = false;
      });
    // this.auto.close();
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
