import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";
import {OnInit} from "@angular/core";
import {QueryResource} from "core-app/modules/hal/resources/query-resource";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {ApiV3FilterBuilder} from "core-components/api/api-v3/api-v3-filter-builder";

export class BlueTableKpiService extends BlueTableService {
  private project:string = '';
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

  public getDataWithFilter(param:string):any[] {
    if (param.startsWith('project')) {
      this.project = param.slice(7);
    }
    this.data = [];
    this.promises = [];
    this.data_local = {};
    if (this.project !== '0') {
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.work_package_targets.toString(), {"project" : this.project})
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          resources.elements.map( (el:HalResource) => {
            this.data.push(el);
          });
          this.halResourceService
            .get<HalResource>(this.pathHelper.api.v3.projects.toString() + '/' + this.project)
            .toPromise()
            .then((project:HalResource) => {
              this.data.unshift(project);
              if (project.nationalProjectId) {
                this.halResourceService
                  .get<HalResource>(this.pathHelper.api.v3.national_projects.toString() + '/' + project.nationalProjectId)
                  .toPromise()
                  .then((child:HalResource) => {
                    this.data.unshift(child);
                    if (child.parentId) {
                      this.halResourceService
                        .get<HalResource>(this.pathHelper.api.v3.national_projects.toString() + '/' + child.parentId)
                        .toPromise()
                        .then((parent:HalResource) => {
                          this.data.unshift(parent);
                        });
                    }
                  });
              } else {
                this.data.unshift({_type: 'National Project', name: 'Проекты Республики Бурятия', parentId:null});
              }
            });
      });
    } else {
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
          let filters = new ApiV3FilterBuilder();
          filters.add('national_project_id', '!*', []);
          this.halResourceService
            .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.projects.toString(),  {"filters": filters.toJson()})
            .toPromise()
            .then((resources2:CollectionResource<HalResource>) => {
              resources2.elements.map((el:HalResource) => {
                this.promises.push(this.halResourceService
                  .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.work_package_targets.toString(), {"project" : el['id']})
                  .toPromise());
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
                  this.data.push({_type: 'National Project', name: 'Проекты Республики Бурятия', parentId:null});
                  resources2.elements.map((el:HalResource) => {
                    this.data.push(el);
                    if (this.data_local[el['id']]) {
                      this.data_local[el['id']].map( (wpt:HalResource) => {
                        this.data.push(wpt);
                      });
                    }
                  });
                });
              });
            });
        });
    }
    return this.data;
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
    if (row._type === 'WorkPackageTarget') {
      switch (i) {
        case 0: {
          return row.target;
          break;
        }
        case 4: {
          return row.value;
          break;
        }
        case 5: {
          return row.planValue;
          break;
        }
      }
    }
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
        if (row._type === 'Target' || row._type === 'WorkPackageTarget') {
          return 'p40';
        }
        return row.parentId == null ? 'p10' : 'p20';
        break;
      }
    }
    return '';
  }
}
