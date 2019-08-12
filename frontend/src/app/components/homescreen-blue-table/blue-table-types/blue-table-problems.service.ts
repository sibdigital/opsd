import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";

export class BlueTableProblemsService extends BlueTableService {
  private project:string;
  private filter:string | null;
  private data:any[] = [];
  private columns:string[] = ['Проект', 'Инициатор', 'Риск/Проблема', 'Адресат', 'Статус', 'Дата решения'];
  private pages:number = 0;
  private national_project_titles:{id:number, name:string}[] = [];
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
        this.national_project_titles.push({id:0, name: 'Проекты Республики Бурятия'});
        this.halResourceService
          .get<HalResource>(this.pathHelper.api.v3.risk_problem_stat_view.toString())
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
                  this.data_local[el.id].map( (riskProblem:HalResource) => {
                    this.data.push(riskProblem);
                  });
                }
              }
            });
          });
      });
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

  public getColumns():string[] {
    return this.columns;
  }

  public getData():any[] {
    return this.data;
  }

  public getDataFromPage(i:number):any[] {
    if (this.project == null || this.project === '0') {
      this.data = [];
      if (this.national_project_titles[i].id === 0) {
        this.data.push({_type: 'NationalProject', id:0, name: 'Проекты Республики Бурятия'});
        if (this.data_local[0]) {
          this.data_local[0].map( (riskProblem:HalResource) => {
            this.data.push(riskProblem);
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
                  this.data_local[el.id].map( (riskProblem:HalResource) => {
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
  /*  if ( i === 0) {
      i = 1;
    } else if (i > this.getPages()) {
      i = this.getPages();
    }
    this.data = [];
    let promise:Promise<CollectionResource<HalResource>>;
    this.filter;
    if (this.project === '0') {
      promise = this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.problems.toString(),
          this.filter ? {"status": this.filter, "offset": i} :{"offset": i})
        .toPromise();
    } else {
      promise = this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.problems.toString(),
          this.filter ? {"status": this.filter, project: this.project, "offset": i} : {project: this.project, "offset": i})
        .toPromise();
    }
    promise.then((resources:CollectionResource<HalResource>) => {
      let total:number = resources.total; //всего ex 29
      let pageSize:number = resources.pageSize; //в этой выборке ex 20
      let remainder = total % pageSize;
      this.pages = (total - remainder) / pageSize;
      if (remainder !== 0) {
        this.pages++;
      }
      resources.elements.map((el:HalResource) => {
        this.data.push(el);
      });
    });
    return this.data;
  }*/

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
    } else {
      switch (i) {
        case 0: {
          return row.project ? row.project.name : '';
          break;
        }
        case 1: {
          if (row.userCreator) {
            return this.formatName(row.userCreator);
          }
          //return row.userCreator;
          break;
        }
        case 2: {
          return row.riskOrProblem;
          break;
        }
        case 3: {
          if (row.userSource) {
            return this.formatName(row.userSource);
          }
          //return row.userSource;
          break;
        }
        case 4: {
          return row.type;
          break;
        }
        case 5: {
          return this.format(row.solutionDate);
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

  public getDataWithFilter(param:string):any[] {
    if (param.startsWith('project')) {
      this.project = param.slice(7);
      this.filter = null;
    }
    this.data = [];
    this.data_local = [];
    this.national_project_titles = [];
    this.filter;
    switch (param) {
      case 'solved': {
        this.filter = 'solved';
        break;
      }
      case 'notsolved': {
        this.filter = 'created';
        break;
      }
    }
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        resources.elements.map((el:HalResource) => {
          if (!el.parentId) {
            this.national_project_titles.push({id: el.id, name: el.name});
          }
        });
        this.national_project_titles.push({id:0, name: 'Проекты Республики Бурятия'});
        if (this.project === '0') {
          this.halResourceService
            .get<HalResource>(this.pathHelper.api.v3.risk_problem_stat_view.toString())
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
            .get<HalResource>(this.pathHelper.api.v3.risk_problem_stat_view.toString(), {project: this.project})
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
    /*} else {
      promise = this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.problems.toString(),
          this.filter ? {"status": this.filter, project: this.project} : {project: this.project})
        .toPromise();
    }*/
  }
}
