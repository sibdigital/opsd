import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {QueryResource} from "core-app/modules/hal/resources/query-resource";
import {ApiV3FilterBuilder} from "core-components/api/api-v3/api-v3-filter-builder";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";

export class BlueTableKtService extends BlueTableService {
  private project:string;
  private filters:ApiV3FilterBuilder | null = null;
  private data:any[] = [];
  private columns:string[] = ['Мероприятие', 'Отв. Исполнитель', 'Срок выполнения', 'Статус', 'Факт. выполнение', 'Проблемы'];
  private pages:number = 0;
  private national_project_titles:{ id:number, name:string }[] = [];
  private data_local:any = {};

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
          .get<HalResource>(this.pathHelper.api.v3.work_package_ispoln_stat_view.toString())
          .toPromise()
          .then((resource:HalResource) => {
            resource.elements.map((el:HalResource) => {
              if (!el.project.national_project_id) {
                el.project.national_project_id = 0;
              }
              this.data_local[el.project.national_project_id] = this.data_local[el.project.national_project_id] || [];
              this.data_local[el.project.national_project_id].push(el);
            });
            resources.elements.map((el:HalResource) => {
              if ((el.id === this.national_project_titles[0].id) || (el.parentId && el.parentId === this.national_project_titles[0].id)) {
                this.data.push(el);
                if (this.data_local[el.id]) {
                  this.data_local[el.id].map((ispolnStat:HalResource) => {
                    this.data.push(ispolnStat);
                  });
                }
              }
            });
          });
      });
  }

  public formatName(user:HalResource):string {
    if (user.patronymic) {
      return user.lastname + ' ' + user.firstname.slice(0, 1) + '. ' + user.patronymic.slice(0, 1) + '.';
    } else {
      return user.lastname + ' ' + user.firstname.slice(0, 1) + '. ';
    }
  }

  public getColumns():string[] {
    return this.columns;
  }

  public getPages():number {
    if (this.project == null || this.project === '0') {
      return this.national_project_titles.length - 2;
    } else {
      return this.pages;
    }
  }

  public pagesToText(i:number):string {
    return this.national_project_titles[i].name;
  }

  public getData():any[] {
    return this.data;
  }

  public getDataFromPage(i:number):any[] {
    if (this.project == null || this.project === '0') {
      this.data = [];
      if (this.national_project_titles[i].id === 0) {
        this.data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
        if (this.data_local[0]) {
          this.data_local[0].map((ispolnStat:HalResource) => {
            this.data.push(ispolnStat);
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
                if (this.data_local[el.id]) {
                  this.data_local[el.id].map((riskProblem:HalResource) => {
                    this.data.push(riskProblem);
                  });
                }
              }
            });
          });
      }
      return this.data;
    } else {
      return [];
    }
  }

  /*if ( i === 0) {
    i = 1;
  } else if (i > this.getPages()) {
    i = this.getPages();
  }
  this.data = [];
  let promise:Promise<QueryResource>;
  if (this.project === '0') {
    promise = this.halResourceService
      .get<QueryResource>(this.pathHelper.api.v3.queries.default.toString(), this.filters ? {"filters": this.filters.toJson(), "offset": i} :{"offset": i})
      .toPromise();
  } else {
    promise = this.halResourceService
      .get<QueryResource>(this.pathHelper.api.v3.withOptionalProject(this.project).queries.default.toString(), this.filters ? {"filters": this.filters.toJson(), "offset": i} :{"offset": i})
      .toPromise();
  }
  promise.then((resources:QueryResource) => {
    let total:number = resources.results.total; //всего ex 29
    let remainder = total % 20;
    this.pages = (total - remainder) / 20;
    if (remainder !== 0) {
      this.pages++;
    }
    resources.results.elements.map((el:HalResource) => {
      this.data.push(el);
    });
  });
  return this.data;*/


  public getTdData(row:any, i:number):string {
    if (row._type === 'NationalProject') {
      switch (i) {
        case 0: {
          return row.name;
          break;
        }
      }
    } else {
      switch (i) {
        case 0: {
          return row.project.name;
          break;
        }
        case 1: {
          return row.assignee ? this.formatName(row.assignee) : '';
          break;
        }
        case 2: {
          return this.format(row.dueDate);
          break;
        }
        case 3: {
          return row.statusName;
          break;
        }
        case 5: {
          return '<a href="' + this.getBasePath() + '/vkladka1/problems">' + row.createdProblemCount + '</a>';
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
        if (row._type === 'WorkPackageIspolnStat') {
          return 'p40';
        }
        return row.parentId == null ? 'p10' : 'p20';
        break;
      }
    }
    return '';
  }

  public getDataWithLimit(i:number):any[] {
    this.filters = new ApiV3FilterBuilder();
    this.filters.add('dueDate', '<t+', [i.toString()]);
    this.data = [];
    let promise:Promise<QueryResource>;
    if (this.project === '0') {
      promise = this.halResourceService
        .get<QueryResource>(this.pathHelper.api.v3.queries.default.toString(), this.filters ? {"filters": this.filters.toJson()} : null)
        .toPromise();
    } else {
      promise = this.halResourceService
        .get<QueryResource>(this.pathHelper.api.v3.withOptionalProject(this.project).queries.default.toString(), this.filters ? {"filters": this.filters.toJson()} : null)
        .toPromise();
    }
    promise.then((resources:QueryResource) => {
      let total:number = resources.results.total; //всего ex 29
      let remainder = total % 20;
      this.pages = (total - remainder) / 20;
      if (remainder !== 0) {
        this.pages++;
      }
      resources.results.elements.map((el:HalResource) => {
        this.data.push(el);
      });
    });
    return this.data;
  }

  public getDataWithFilter(param:string):any[] {
    if (param.startsWith('project')) {
      this.project = param.slice(7);
    }
    this.data = [];
    this.data_local = [];
    this.national_project_titles = [];
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
        if (this.project === '0') {
          this.halResourceService
            .get<HalResource>(this.pathHelper.api.v3.work_package_ispoln_stat_view.toString())
            .toPromise()
            .then((resource:HalResource) => {
              resource.elements.map((el:HalResource) => {
                if (!el.project.national_project_id) {
                  el.project.national_project_id = 0;
                }
                this.data_local[el.project.national_project_id] = this.data_local[el.project.national_project_id] || [];
                this.data_local[el.project.national_project_id].push(el);
              });
              resources.elements.map((el:HalResource) => {
                this.data.push(el);
                if (this.data_local[el.id]) {
                  this.data_local[el.id].map((riskProblem:HalResource) => {
                    this.data.push(riskProblem);
                  });
                }
              });
            });
        } else {
          this.halResourceService
            .get<HalResource>(this.pathHelper.api.v3.work_package_ispoln_stat_view.toString(), {project: this.project})
            .toPromise()
            .then((resource:HalResource) => {
              resource.elements.map((el:HalResource) => {
                if (!el.project.national_project_id) {
                  el.project.national_project_id = 0;
                }
                this.data_local[el.project.national_project_id] = this.data_local[el.project.national_project_id] || [];
                this.data_local[el.project.national_project_id].push(el);
              });
              resources.elements.map((el:HalResource) => {
                this.data.push(el);
                if (this.data_local[el.id]) {
                  this.data_local[el.id].map((riskProblem:HalResource) => {
                    this.data.push(riskProblem);
                  });
                }
              });
              this.data.push({_type: 'NationalProject', id:0, name: 'Проекты Республики Бурятия'});
              if (this.data_local[0]) {
                this.data_local[0].map((riskProblem:HalResource) => {
                  this.data.push(riskProblem);
                });
              }

            });
        }
      });
    return this.data;
  }

  public format(input:string):string {
    if (input) {
      return input.slice(8, 10) + '.' + input.slice(5, 7) + '.' + input.slice(0, 4);
    } else {
      return '';
    }
  }
}
