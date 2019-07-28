import {Component, OnInit} from "@angular/core";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {StateService} from "@uirouter/core";
import {QueryResource} from "core-app/modules/hal/resources/query-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";


@Component({
  selector: 'desktop-tab',
  templateUrl: './desktop-tab.html',
  styleUrls: ['./desktop-tab.sass']
})
export class DesktopTabComponent implements OnInit {
  protected readonly appBasePath:string;
  public data:any[] = [];

  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService) {
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
  }

  ngOnInit() {
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
}
