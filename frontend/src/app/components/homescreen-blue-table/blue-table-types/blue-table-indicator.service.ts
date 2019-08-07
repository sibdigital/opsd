import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";
import {ApiV3FilterBuilder} from "core-components/api/api-v3/api-v3-filter-builder";

export class BlueTableIndicatorService extends BlueTableService {
  private data:any[] = [];
  private data_local:any = {};
  private columns:string[] = ['Республика Бурятия', 'Ответственный', 'I', 'II', 'III', 'IV', 'I', 'II', 'III', 'IV', 'Процент исполнения'];
  private national_project_titles:{id:number, name:string}[] = [];

  public initialize():void {
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        resources.elements.map((el:HalResource) => {
          if (!el.parentId) {
            this.national_project_titles.push({id: el.id, name: el.name});
          }
        });
        this.national_project_titles.push({id: 0, name: 'Проекты Республики Бурятия'});

        this.halResourceService
          .get<HalResource>(this.pathHelper.api.v3.work_package_targets_1c.toString())
          .toPromise()
          .then((targetResources:HalResource) => {
            targetResources.elements.map((el:HalResource) => {
              if (!el.projectId) {
                el.projectId = 0;
              }
              this.data_local[el.projectId] = this.data_local[el.projectId] || {name: el.name, targets: []};
              this.data_local[el.projectId].targets.push(el);
            });

            resources.elements.map((el:HalResource) => {
              if ((el.id === this.national_project_titles[0].id) || (el.parentId && el.parentId === this.national_project_titles[0].id)) {
                this.data.push(el);
                if (el.projects) {
                  el.projects.map((project:ProjectResource) => {
                    project['_type'] = 'Project';
                    this.data.push(project);
                    this.data_local[project.id].targets.map((target:HalResource) => {
                      this.data.push(target);
                    });
                  });
                }
              }
            });
          });
      });
  }

  public getDataFromPage(i:number):any[] {
    this.data = [];
    if (this.national_project_titles[i].id === 0) {
      this.data.push({_type:"National Project", name:"Проекты Республики Бурятия", parentId:null});
      if (this.data_local[0]) {
        this.data_local[0].targets.map( (target:HalResource) => {
          this.data.push(target);
        });
      }
    } else {
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          resources.elements.map((el:HalResource) => {
            if ((el.id === this.national_project_titles[i].id) || (el.parentId && el.parentId === this.national_project_titles[i].id)) {
              this.data.push(el);
              if (el.projects) {
                el.projects.map( (project:ProjectResource) => {
                  project['_type'] = 'Project';
                  this.data.push(project);
                  if (this.data_local[project.id]) {
                    this.data_local[project.id].targets.map( (target:HalResource) => {
                      this.data.push(target);
                    });
                  }
                });
              }
            }
          });
        });
    }
    return this.data;
  }
  public getColumns():string[] {
    return this.columns;
  }
  public getPages():number {
    return this.national_project_titles.length - 2;
  }

  public getData():any[] {
    return this.data;
  }

  public getTdData(row:any, i:number):string {
    if (row._type === 'WorkPackageTarget1C') {
      switch (i) {
        case 0: {
          return row.name;
          break;
        }
        case 1: {
          if (row.otvetstvenniy) {
            return '<a href="' + super.getBasePath() + '/users/' + row.otvetstvenniy.id + '">' + row.otvetstvenniy.lastname + ' ' + row.otvetstvenniy.firstname.slice(0, 1) + '.' + row.otvetstvenniy.patronymic.slice(0, 1) + '.</a>';
          }
          break;
        }
        case 2: {
          return row.quarter1PlanValue;
          break;
        }
        case 3: {
          return row.quarter2PlanValue;
          break;
        }
        case 4: {
          return row.quarter3PlanValue;
          break;
        }
        case 5: {
          return row.quarter4PlanValue;
          break;
        }
        case 6: {
          return row.quarter1Value;
          break;
        }
        case 7: {
          return row.quarter2Value;
          break;
        }
        case 8: {
          return row.quarter3Value;
          break;
        }
        case 9: {
          return row.quarter4Value;
          break;
        }
        case 10: {
          return row.doneRatio;
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
    if (row._type === 'Project') {
      switch (i) {
        case 0: {
          return '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.name + '</a>';
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
        if (row._type === 'WorkPackageTarget1C') {
          return 'p40';
        }
        return row.parentId == null ? 'p10' : 'p20';
        break;
      }
      case 10: {
        if (row._type === 'WorkPackageTarget1C') {
          return 'progressbar';
        }
        break;
      }
    }
    return '';
  }

  public format(input:string):string {
    return input.slice(8, 10) + '.' + input.slice(5, 7) + '.' + input.slice(0, 4);
  }

  public pagesToText(i:number):string {
    return this.national_project_titles[i].name;
  }
}
