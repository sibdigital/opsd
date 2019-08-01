import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";
import {OnInit} from "@angular/core";
import {QueryResource} from "core-app/modules/hal/resources/query-resource";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";

export class BlueTableKpiService extends BlueTableService {
  private data:any[] = [];
  private promises:Promise<CollectionResource<HalResource>>[] = [];
  private data_local:any = {};
  private columns:string[] = ['Рег. проект', 'Куратор', 'Рук. проекта', 'КТ', 'План', 'Факт'];

  public initialize():void {
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        resources.elements.map((el:HalResource) => {
          if (el.projects) {
            el.projects.map((project:ProjectResource) => {
              project['_type'] = 'Project';
              this.promises.push(this.halResourceService
                .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.work_package_targets.toString(), {"project" : project['id']})
                .toPromise());
            });
          }
        });
        Promise.all(this.promises.map( p => p.then((wpts:CollectionResource<HalResource>) => {
          wpts.elements.map( (wpt:HalResource) => {
            this.data_local[wpt.projectId] = this.data_local[wpt.projectId] || [];
            this.data_local[wpt.projectId].push(wpt);
          });
        }))).then(() => {
          resources.elements.map( (national:HalResource) => {
            this.data.push(national);
            if (national.projects) {
              national.projects.map((project:HalResource) => {
                this.data.push(project);
                if (this.data_local[project['id']]) {
                  this.data_local[project['id']].map( (wpt:HalResource) => {
                    this.data.push(wpt);
                  });
                }
              });
            }
          });
        });
      });
  }

  public getColumns():string[] {
    return this.columns;
  }
  public getPages():number {
    return 0;
  }

  public getData():any[] {
    return this.data;
  }

  public getTdData(row:any, i:number):string {
    if (row._type === 'Project') {
      switch (i) {
        case 0: {
          return '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.name + '</a>';
          break;
        }
        case 1: {
          if (row.curator) {
            return '<a href="' + super.getBasePath() + '/users/' + row.curator.id + '">' + row.curator.fio + '</a>';
          }
          break;
        }
        case 2: {
          if (row.rukovoditel) {
            return '<a href="' + super.getBasePath() + '/users/' + row.rukovoditel.id + '">' + row.rukovoditel.fio + '</a>';
          }
          break;
        }
      }
    }
    if (row._type === 'Target') {
      switch (i) {
        case 0: {
          return row.name;
          break;
        }
        case 3: {
          return row.target;
          break;
        }
        case 4: {
          return row.planValue;
          break;
        }
        case 5: {
          return row.value;
          break;
        }
      }
    }
    if (row._type === 'National Project') {
      switch (i) {
        case 0: {
          return row.name;
          break;
        }
      }
    }
    return '';
  }

  public getTdClass(row:any, i:number):string {
    switch (i) {
      case 0: {
        if (row._type === 'Project') {
          return 'p30';
        }
        if (row._type === 'Target') {
          return 'p40';
        }
        return row.parentId == null ? 'p10' : 'p20';
        break;
      }
    }
    return '';
  }
}
