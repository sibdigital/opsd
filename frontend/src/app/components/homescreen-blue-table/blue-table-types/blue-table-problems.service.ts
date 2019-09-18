import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";

export class BlueTableProblemsService extends BlueTableService {
  private project:string;
  private filter:string | undefined;
  private page:number = 0;
  private data:any[] = [];
  private columns:string[] = ['Риск/Проблема', 'Инициатор', 'Адресат', 'Статус', 'Дата решения'];
  private pages:number = 0;
  private national_project_titles:{ id:number, name:string }[] = [];

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
        let params:any = {national: this.national_project_titles[this.page].id};
        this.halResourceService
          .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.risk_problem_stat_view.toString(), params)
          .toPromise()
          .then((resource:CollectionResource<HalResource>) => {
            let data_local:any = {};
            resource.elements.map((el:HalResource) => {
              data_local[el.federal_id] = data_local[el.federal_id] || [];
              data_local[el.federal_id].push(el);
            });
            resources.elements.map((el:HalResource) => {
              if ((el.id === this.national_project_titles[this.page].id) || (el.parentId && el.parentId === this.national_project_titles[this.page].id)) {
                this.data.push(el);
                if (data_local[el.id]) {
                  data_local[el.id].map((row:HalResource) => {
                    this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                    row.problems.map((problem:HalResource) => {
                      this.data.push(problem);
                    });
                  });
                }
              }
            });
          });
      });
  }

  public getColumns():string[] {
    return this.columns;
  }

  public getPages():number {
    if (!this.project || this.project === '0') {
      return this.national_project_titles.length;
    } else {
      return this.pages;
    }
  }

  public pagesToText(i:number):string {
    if (!this.project || this.project === '0') {
      return this.national_project_titles[i].name;
    } else {
      return String(i + 1);
    }
  }

  public getData():any[] {
    return this.data;
  }

  public getDataFromPage(i:number):any[] {
    this.page = i;
    this.data = [];
    if (!this.project || this.project === '0') {
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          let params:any = {national: this.national_project_titles[this.page].id};
          if (this.filter) {
            params.filter = this.filter;
          }
          this.halResourceService
            .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.risk_problem_stat_view.toString(), params)
            .toPromise()
            .then((resource:CollectionResource<HalResource>) => {
              let data_local:any = {};
              resource.elements.map((el:HalResource) => {
                data_local[el.federal_id] = data_local[el.federal_id] || [];
                data_local[el.federal_id].push(el);
              });
              resources.elements.map((el:HalResource) => {
                if ((el.id === this.national_project_titles[this.page].id) || (el.parentId && el.parentId === this.national_project_titles[this.page].id)) {
                  this.data.push(el);
                  if (data_local[el.id]) {
                    data_local[el.id].map((row:HalResource) => {
                      this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                      row.problems.map((problem:HalResource) => {
                        this.data.push(problem);
                      });
                    });
                  }
                }
              });
              if (this.national_project_titles[i].id === 0) {
                this.data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
                if (data_local[0]) {
                  data_local[0].map((row:HalResource) => {
                    this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                    row.problems.map((problem:HalResource) => {
                      this.data.push(problem);
                    });
                  });
                }
              }
            });
        });
      return this.data;
    } else {
      if (this.page === 0) {
        this.page = 1;
      }
      if (this.page > this.getPages()) {
        this.page = this.getPages();
      }
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          let params:any = {project: this.project, offset: this.page};
          if (this.filter) {
            params.filter = this.filter;
          }
          this.halResourceService
            .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.risk_problem_stat_view.toString(), params)
            .toPromise()
            .then((resource:CollectionResource<HalResource>) => {
              let data_local:any = {};
              resource.elements.map((el:HalResource) => {
                data_local[el.federal_id] = [el];
              });
              resource.elements.map((project:HalResource) => {
                resources.elements.map((el:HalResource) => {
                  if ((el.id === project.federal_id) || (el.parentId && el.parentId === project.federal_id)) {
                    this.data.push(el);
                    if (data_local[el.id]) {
                      data_local[el.id].map((row:HalResource) => {
                        this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                        row.problems.map((problem:HalResource) => {
                          this.data.push(problem);
                        });
                      });
                    }
                  }
                });
                if (project.federal_id === 0) {
                  this.data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
                  if (data_local[0]) {
                    data_local[0].map((row:HalResource) => {
                      this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                      row.problems.map((problem:HalResource) => {
                        this.data.push(problem);
                      });
                    });
                  }
                }
              });
            });
        });
      return this.data;
    }
  }

  public formatName(user:HalResource):string {
    if (user.patronymic) {
      return user.lastname + ' ' + user.firstname.slice(0, 1) + '. ' + user.patronymic.slice(0, 1) + '.';
    } else {
      return user.lastname + ' ' + user.firstname.slice(0, 1) + '. ';
    }
  }

  public getTdData(row:any, i:number):string {
    if (row._type === 'NationalProject') {
      switch (i) {
        case 0: {
          return row.name;
          break;
        }
      }
    } else if (row._type === 'Project') {
      switch (i) {
        case 0: {
          return '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.name + '</a>';
          break;
        }
      }
    } else {
      switch (i) {
        case 0: {
          return row.risk_or_problem;
          break;
        }
        case 1: {
          return row.user_creator;
          break;
        }
        case 2: {
          return row.user_source;
          break;
        }
        case 3: {
          if (row.type === 'solved_risk') {
            return 'Решен';
          }
          if (row.type === 'created_risk') {
            return 'Не решен';
          }
          break;
        }
        case 4: {
          return this.format(row.solution_date);
          break;
        }
      }
    }
    return '';
  }

  public format(input:string):string {
    if (input) {
      return input.slice(8, 10) + '.' + input.slice(5, 7) + '.' + input.slice(0, 4);
    } else {
      return '';
    }
  }


  public getTdClass(row:any, i:number):string {
    switch (i) {
      case 0: {
        if (row._type === 'Project') {
          return 'p30';
        }
        if (row._type === 'RiskProblemStat') {
          return 'p40';
        }
        return row.parentId == null ? 'p10' : 'p20';
        break;
      }
    }
    return '';
  }

  public getDataWithFilter(param:string):Promise<any[]> {
    return new Promise((resolve) => {
      if (param.startsWith('project')) {
        this.project = param.slice(7);
        this.filter = undefined;
        this.page = 0;
      } else {
        this.filter = param;
      }
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          if (!this.project || this.project === '0') {
            let params:any = {national: this.national_project_titles[this.page].id};
            if (this.filter) {
              params.filter = this.filter;
            }
            this.halResourceService
              .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.risk_problem_stat_view.toString(), params)
              .toPromise()
              .then((resource:CollectionResource<HalResource>) => {
                let ldata:any[] = [];
                let data_local:any = {};
                resource.elements.map((el:HalResource) => {
                  data_local[el.federal_id] = data_local[el.federal_id] || [];
                  data_local[el.federal_id].push(el);
                });
                if (this.national_project_titles[this.page].id === 0) {
                  ldata.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
                  if (data_local[0]) {
                    data_local[0].map((row:HalResource) => {
                      ldata.push({_type: row._type, identifier: row.identifier, name: row.name});
                      row.problems.map((problem:HalResource) => {
                        ldata.push(problem);
                      });
                    });
                  }
                }
                resources.elements.map((el:HalResource) => {
                  if ((el.id === this.national_project_titles[this.page].id) || (el.parentId && el.parentId === this.national_project_titles[this.page].id)) {
                    ldata.push(el);
                    if (data_local[el.id]) {
                      data_local[el.id].map((row:HalResource) => {
                        ldata.push({_type: row._type, identifier: row.identifier, name: row.name});
                        row.problems.map((problem:HalResource) => {
                          ldata.push(problem);
                        });
                      });
                    }
                  }
                });
                this.data = ldata;
              });
          } else {
            this.page = 1;
            let params:any = {project: this.project, offset: this.page};
            if (this.filter) {
              params.filter = this.filter;
            }
            this.halResourceService
              .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.risk_problem_stat_view.toString(), params)
              .toPromise()
              .then((resource:CollectionResource<HalResource>) => {
                let ldata:any[] = [];
                let data_local:any = {};
                let total:number = resource.total; //всего ex 29
                let pageSize:number = resource.pageSize; //в этой выборке ex 20
                let remainder = total % pageSize;
                this.pages = (total - remainder) / pageSize;
                if (remainder !== 0) {
                  this.pages++;
                }
                resource.elements.map((el:HalResource) => {
                  data_local[el.federal_id] = [el];
                });
                resource.elements.map((project:HalResource) => {
                  resources.elements.map((el:HalResource) => {
                    if ((el.id === project.federal_id) || (el.parentId && el.parentId === project.federal_id)) {
                      ldata.push(el);
                      if (data_local[el.id]) {
                        data_local[el.id].map((row:HalResource) => {
                          ldata.push({_type: row._type, identifier: row.identifier, name: row.name});
                          row.problems.map((problem:HalResource) => {
                            ldata.push(problem);
                          });
                        });
                      }
                    }
                  });
                  if (project.federal_id === 0) {
                    ldata.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
                    if (data_local[0]) {
                      data_local[0].map((row:HalResource) => {
                        ldata.push({_type: row._type, identifier: row.identifier, name: row.name});
                        row.problems.map((problem:HalResource) => {
                          ldata.push(problem);
                        });
                      });
                    }
                  }
                });
                this.data = ldata;
              });
          }
        });
      resolve(this.data);
    });
  }
}
