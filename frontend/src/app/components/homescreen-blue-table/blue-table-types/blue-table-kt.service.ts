import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";

export class BlueTableKtService extends BlueTableService {
  private project:string;
  private limit:string | undefined;
  private filter:string | undefined;
  private page:number = 0;
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
        let params:any = {national: this.national_project_titles[this.page].id};
        if (this.limit) {
          params.limit = this.limit;
        }
        if (this.filter) {
          params.filter = this.filter;
        }
        this.halResourceService
          .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.work_package_ispoln_stat_view.toString(), params)
          .toPromise()
          .then((resource:CollectionResource<HalResource>) => {
            resource.elements.map((el:HalResource) => {
              this.data_local[el.national_id] = this.data_local[el.national_id] || [];
              this.data_local[el.national_id].push(el);
            });
            resources.elements.map((el:HalResource) => {
              if ((el.id === this.national_project_titles[this.page].id) || (el.parentId && el.parentId === this.national_project_titles[this.page].id)) {
                this.data.push(el);
                if (this.data_local[el.id]) {
                  this.data_local[el.id].map((row:HalResource) => {
                    this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                    row.work_packages.map((wp:HalResource) => {
                      this.data.push(wp);
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
      return this.national_project_titles.length - 2;
    } else {
      return this.pages;
    }
  }

  public pagesToText(i:number):string {
    if (!this.project || this.project === '0') {
      return this.national_project_titles[i].name;
    } else {
      if ( i === 0) {
        return '<<';
      }
      if (i > this.getPages()) {
        return '>>';
      }
      return String(i);
    }
  }

  public getData():any[] {
    return this.data;
  }

  public getDataFromPage(i:number):any[] {
    this.page = i;
    this.data = [];
    if (!this.project || this.project === '0') {
      this.data_local = [];
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          let params:any = {national: this.national_project_titles[this.page].id};
          if (this.limit) {
            params.limit = this.limit;
          }
          if (this.filter) {
            params.filter = this.filter;
          }
          this.halResourceService
            .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.work_package_ispoln_stat_view.toString(), params)
            .toPromise()
            .then((resource:CollectionResource<HalResource>) => {
              resource.elements.map((el:HalResource) => {
                this.data_local[el.national_id] = this.data_local[el.national_id] || [];
                this.data_local[el.national_id].push(el);
              });
              resources.elements.map((el:HalResource) => {
                if ((el.id === this.national_project_titles[this.page].id) || (el.parentId && el.parentId === this.national_project_titles[this.page].id)) {
                  this.data.push(el);
                  if (this.data_local[el.id]) {
                    this.data_local[el.id].map((row:HalResource) => {
                      this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                      row.work_packages.map((wp:HalResource) => {
                        this.data.push(wp);
                      });
                    });
                  }
                }
              });
              if (this.national_project_titles[i].id === 0) {
                this.data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
                if (this.data_local[0]) {
                  this.data_local[0].map((row:HalResource) => {
                    this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                    row.work_packages.map((wp:HalResource) => {
                      this.data.push(wp);
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
          if (this.limit) {
            params.limit = this.limit;
          }
          if (this.filter) {
            params.filter = this.filter;
          }
          this.halResourceService
            .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.work_package_ispoln_stat_view.toString(), params)
            .toPromise()
            .then((resource:CollectionResource<HalResource>) => {
              resource.elements.map((el:HalResource) => {
                this.data_local[el.national_id] = [el];
              });
              resource.elements.map((project:HalResource) => {
                resources.elements.map((el:HalResource) => {
                  if ((el.id === project.national_id) || (el.parentId && el.parentId === project.national_id)) {
                    this.data.push(el);
                    if (this.data_local[el.id]) {
                      this.data_local[el.id].map((row:HalResource) => {
                        this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                        row.work_packages.map((wp:HalResource) => {
                          this.data.push(wp);
                        });
                      });
                    }
                  }
                });
                if (project.national_id === 0) {
                  this.data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
                  if (this.data_local[0]) {
                    this.data_local[0].map((row:HalResource) => {
                      this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                      row.work_packages.map((wp:HalResource) => {
                        this.data.push(wp);
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
          return '<a href="' + super.getBasePath() + '/work_packages/' + row.work_package_id + '/activity?plan_type=execution">' + row.subject + '</a>';
          break;
        }
        case 1: {
          return row.otvetstvenniy;
          break;
        }
        case 2: {
          return this.format(row.due_date);
          break;
        }
        case 3: {
          return row.status_name;
          break;
        }
        case 4: {
          return this.format(row.fakt_ispoln);
          break;
        }
        case 5: {
          return '<a href="' + this.getBasePath() + '/vkladka1/problems">' + row.created_problem_count + '</a>';
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

  public getDataWithFilter(param:string):any[] {
    if (param.startsWith('project')) {
      this.project = param.slice(7);
      this.limit = undefined;
      this.filter = undefined;
      this.page = 0;
    } else if (param.startsWith('limit')) {
      this.limit = param.slice(5);
    } else {
      this.filter = param;
      if (param === 'predstoyashie' || param === 'all') {
        this.limit = undefined;
      }
    }
    this.data = [];
    this.data_local = [];
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        if (!this.project || this.project === '0') {
          let params:any = {national: this.national_project_titles[this.page].id};
          if (this.limit) {
            params.limit = this.limit;
          }
          if (this.filter) {
            params.filter = this.filter;
          }
          this.halResourceService
            .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.work_package_ispoln_stat_view.toString(), params)
            .toPromise()
            .then((resource:CollectionResource<HalResource>) => {
              resource.elements.map((el:HalResource) => {
                this.data_local[el.national_id] = this.data_local[el.national_id] || [];
                this.data_local[el.national_id].push(el);
              });
              if (this.national_project_titles[this.page].id === 0) {
                this.data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
                if (this.data_local[0]) {
                  this.data_local[0].map((row:HalResource) => {
                    this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                    row.work_packages.map((wp:HalResource) => {
                      this.data.push(wp);
                    });
                  });
                }
              }
              resources.elements.map((el:HalResource) => {
                if ((el.id === this.national_project_titles[this.page].id) || (el.parentId && el.parentId === this.national_project_titles[this.page].id)) {
                  this.data.push(el);
                  if (this.data_local[el.id]) {
                    this.data_local[el.id].map((row:HalResource) => {
                      this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                      row.work_packages.map((wp:HalResource) => {
                        this.data.push(wp);
                      });
                    });
                  }
                }
              });
            });
        } else {
          this.page = 1;
          let params:any = {project: this.project, offset: this.page};
          if (this.limit) {
            params.limit = this.limit;
          }
          if (this.filter) {
            params.filter = this.filter;
          }
          this.halResourceService
            .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.work_package_ispoln_stat_view.toString(), params)
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
                this.data_local[el.national_id] = [el];
              });
              resource.elements.map((project:HalResource) => {
                resources.elements.map((el:HalResource) => {
                  if ((el.id === project.national_id) || (el.parentId && el.parentId === project.national_id)) {
                    this.data.push(el);
                    if (this.data_local[el.id]) {
                      this.data_local[el.id].map((row:HalResource) => {
                        this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                        row.work_packages.map((wp:HalResource) => {
                          this.data.push(wp);
                        });
                      });
                    }
                  }
                });
                if (project.national_id === 0) {
                  this.data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
                  if (this.data_local[0]) {
                    this.data_local[0].map((row:HalResource) => {
                      this.data.push({_type: row._type, identifier: row.identifier, name: row.name});
                      row.work_packages.map((wp:HalResource) => {
                        this.data.push(wp);
                      });
                    });
                  }
                }
              });
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
