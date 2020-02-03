import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";

export class BlueTableProblemsService extends BlueTableService {
  protected columns:string[] = ['Риск/Проблема', 'Инициатор', 'Адресат', 'Статус', 'Дата решения'];
  private project:string;
  private filter:string | undefined;
  private page:number = 0;
  public table_data:any = [];
  public configs:any = {
    id_field: 'id',
    parent_id_field: 'parentId',
    parent_display_field: 'homescreen_name',
    show_summary_row: false,
    css: { // Optional
      expand_class: 'icon-arrow-right2',
      collapse_class: 'icon-arrow-down1',
    },
    columns: [
      {
        name: 'homescreen_name',
        header: this.columns[0]
      },
      {
        name: 'homescreen_initiator',
        header: this.columns[1]
      },
      {
        name: 'homescreen_address',
        header: this.columns[2]
      },
      {
        name: 'homescreen_status',
        header: this.columns[3]
      },
      {
        name: 'homescreen_date',
        header: this.columns[4]
      }
    ]
  };
  private national_project_titles:{ id:number, name:string }[];
  private national_projects:HalResource[];

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

  public initializeAndGetData():Promise<any[]> {
    this.page = 0;
    this.filter = undefined;
    return new Promise((resolve) => {
      this.national_project_titles = [];
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects_problems.toString())
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          this.national_projects = resources.elements;
          this.national_projects.map((el:HalResource) => {
            if (!el.parentId) {
              this.national_project_titles.push({id: el.id, name: el.name});
            }
          });
          this.national_project_titles.push({id: 0, name: 'Проекты Республики Бурятия'});
          this.getDataFromPage(0).then(data => {
            resolve(data);
          });
        });
    });
  }

  public getDataFromPage(i:number):Promise<any[]> {
    return new Promise((resolve) => {
      this.page = i;
      let data:any[] = [];
      let data_local:any = {};
      if (!this.project || this.project === '0') {
        let params:any = {national: this.national_project_titles[this.page].id};
        if (this.filter) {
          params.filter = this.filter;
        }
        this.halResourceService
          .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.risk_problem_stat_view.toString(), params)
          .toPromise()
          .then((resource:CollectionResource<HalResource>) => {
            resource.elements.map((el:HalResource) => {
              if ((el.federal_id !== 0) || (el.federal_id === 0 && el.national_id === 0)) {
                data_local[el.federal_id] = data_local[el.federal_id] || [];
                data_local[el.federal_id].push(el);
              } else {
                data_local[el.national_id] = data_local[el.national_id] || [];
                data_local[el.national_id].push(el);
              }
            });
            this.national_projects.map((el:HalResource) => {
              if ((el.id === this.national_project_titles[this.page].id) || (el.parentId && el.parentId === this.national_project_titles[this.page].id)) {
                data.push(this.getNational(el));
                if (data_local[el.id]) {
                  data_local[el.id].map((row:HalResource) => {
                    data.push(this.getProject(row));
                    row.problems.map((problem:HalResource) => {
                      data.push(this.getProblem(problem));
                    });
                  });
                }
              }
            });
            if (this.national_project_titles[i].id === 0) {
              data.push(this.getNational());
              if (data_local[0]) {
                data_local[0].map((row:HalResource) => {
                  data.push(this.getProject(row, true));
                  row.problems.map((problem:HalResource) => {
                    data.push(this.getProblem(problem));
                  });
                });
              }
            }
            resolve(data);
          });
      } else {
        if (this.page === 0) {
          this.page = 1;
        }
        if (this.page > this.getPages()) {
          this.page = this.getPages();
        }
        let params:any = {project: this.project, offset: this.page};
        if (this.filter) {
          params.filter = this.filter;
        }
        this.halResourceService
          .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.risk_problem_stat_view.toString(), params)
          .toPromise()
          .then((resource:CollectionResource<HalResource>) => {
            resource.elements.map((el:HalResource) => {
              if ((el.federal_id !== 0) || (el.federal_id === 0 && el.national_id === 0)) {
                data_local[el.federal_id] = [el];
              } else {
                data_local[el.national_id] = [el];
              }
            });
            resource.elements.map((project:HalResource) => {
              this.national_projects.map((el:HalResource) => {
                if ((el.id === project.federal_id) || (el.parentId && el.parentId === project.national_id) || (el.id === project.national_id)) {
                  data.push(this.getNational(el));
                  if (data_local[el.id]) {
                    data_local[el.id].map((row:HalResource) => {
                      data.push(this.getProject(row));
                      row.problems.map((problem:HalResource) => {
                        data.push(this.getProblem(problem));
                      });
                    });
                  }
                }
              });
              if (project.national_id === 0) {
                data.push(this.getNational());
                if (data_local[0]) {
                  data_local[0].map((row:HalResource) => {
                    data.push(this.getProject(row, true));
                    row.problems.map((problem:HalResource) => {
                      data.push(this.getProblem(problem));
                    });
                  });
                }
              }
            });
            resolve(data);
          });
      }
    });
  }

  public formatName(user:HalResource):string {
    if (user.patronymic) {
      return user.lastname + ' ' + user.firstname.slice(0, 1) + '. ' + user.patronymic.slice(0, 1) + '.';
    } else {
      return user.lastname + ' ' + user.firstname.slice(0, 1) + '. ';
    }
  }

  // public getTdData(row:any, i:number):string {
  //   if (row._type === 'NationalProject') {
  //     switch (i) {
  //       case 0: {
  //         return row.name;
  //         break;
  //       }
  //     }
  //   } else if (row._type === 'Project') {
  //     switch (i) {
  //       case 0: {
  //         return '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.name + '</a>';
  //         break;
  //       }
  //     }
  //   } else {
  //     switch (i) {
  //       case 0: {
  //         return '<a href="' + super.getBasePath() + '/work_packages/' + row.work_package_id + '/problems">' + row.risk_or_problem + '</a>';
  //         break;
  //       }
  //       case 1: {
  //         return row.user_creator;
  //         break;
  //       }
  //       case 2: {
  //         return row.user_source;
  //         break;
  //       }
  //       case 3: {
  //         if (row.type === 'solved_risk') {
  //           return 'Решен';
  //         }
  //         if (row.type === 'created_risk') {
  //           return 'Не решен';
  //         }
  //         break;
  //       }
  //       case 4: {
  //         return this.format(row.solution_date);
  //         break;
  //       }
  //     }
  //   }
  //   return '';
  // }

  public format(input:string):string {
    if (input) {
      return input.slice(8, 10) + '.' + input.slice(5, 7) + '.' + input.slice(0, 4);
    } else {
      return '';
    }
  }

  private getProblem(problem:any) {
    return {
      id: problem.id,
        parentId: problem.project_id + 'Project',
      homescreen_name: '<a href="' + super.getBasePath() + '/work_packages/' + problem.work_package_id + '/problems">' + problem.risk_or_problem + '</a>',
      homescreen_initiator: problem.user_creator,
      homescreen_address: problem.user_source,
      homescreen_status: problem.type === 'solved_risk' ? 'Решен' : problem.type === 'created_risk' ? 'Не решен' : '',
      homescreen_date: this.format(problem.solution_date)
    };
  }

  // public getTdClass(row:any, i:number):string {
  //   switch (i) {
  //     case 0: {
  //       if (row._type === 'Project') {
  //         return 'p30';
  //       }
  //       if (row._type === 'RiskProblemStat') {
  //         return 'p40';
  //       }
  //       return row.parentId == null ? 'p10' : 'p20';
  //       break;
  //     }
  //   }
  //   return '';
  // }

  public getDataWithFilter(param:string):Promise<any[]> {
    return new Promise((resolve) => {
      let data:any[] = [];
      let data_local:any = {};
      if (param.startsWith('project')) {
        this.project = param.slice(7);
        this.filter = undefined;
        this.page = 0;
      } else {
        this.filter = param;
      }
      if (!this.project || this.project === '0') {
        let params:any = {national: this.national_project_titles[this.page].id};
        if (this.filter) {
          params.filter = this.filter;
        }
        this.halResourceService
          .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.risk_problem_stat_view.toString(), params)
          .toPromise()
          .then((resource:CollectionResource<HalResource>) => {
            resource.elements.map((el:HalResource) => {
              if ((el.federal_id !== 0) || (el.federal_id === 0 && el.national_id === 0)) {
                data_local[el.federal_id] = data_local[el.federal_id] || [];
                data_local[el.federal_id].push(el);
              } else {
                data_local[el.national_id] = data_local[el.national_id] || [];
                data_local[el.national_id].push(el);
              }
            });
            if (this.national_project_titles[this.page].id === 0) {
              data.push(this.getNational());
              if (data_local[0]) {
                data_local[0].map((row:HalResource) => {
                  data.push(this.getProject(row, true));
                  row.problems.map((problem:HalResource) => {
                    data.push(this.getProblem(problem));
                  });
                });
              }
            }
            this.national_projects.map((el:HalResource) => {
              if ((el.id === this.national_project_titles[this.page].id) || (el.parentId && el.parentId === this.national_project_titles[this.page].id)) {
                data.push(this.getNational(el));
                if (data_local[el.id]) {
                  data_local[el.id].map((row:HalResource) => {
                    data.push(this.getProject(row));
                    row.problems.map((problem:HalResource) => {
                      data.push(this.getProblem(problem));
                    });
                  });
                }
              }
            });
            resolve(data);
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
            let total:number = resource.total; //всего ex 29
            let pageSize:number = resource.pageSize; //в этой выборке ex 20
            let remainder = total % pageSize;
            this.pages = (total - remainder) / pageSize;
            if (remainder !== 0) {
              this.pages++;
            }
            resource.elements.map((el:HalResource) => {
              if ((el.federal_id !== 0) || (el.federal_id === 0 && el.national_id === 0)) {
                data_local[el.federal_id] = [el];
              } else {
                data_local[el.national_id] = [el];
              }
            });
            resource.elements.map((project:HalResource) => {
              this.national_projects.map((el:HalResource) => {
                if ((el.id === project.federal_id) || (el.parentId && el.parentId === project.national_id) || (el.id === project.national_id)) {
                  data.push(this.getNational(el));
                  if (data_local[el.id]) {
                    data_local[el.id].map((row:HalResource) => {
                      data.push(this.getProject(row));
                      row.problems.map((problem:HalResource) => {
                        data.push(this.getProblem(problem));
                      });
                    });
                  }
                }
              });
              if (project.national_id === 0) {
                data.push(this.getNational());
                if (data_local[0]) {
                  data_local[0].map((row:HalResource) => {
                    data.push(this.getProject(row, true));
                    row.problems.map((problem:HalResource) => {
                      data.push(this.getProblem(problem));
                    });
                  });
                }
              }
            });
            resolve(data);
          });
      }
    });
  }
}
