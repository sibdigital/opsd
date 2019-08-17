import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";
import {ApiV3FilterBuilder} from "core-components/api/api-v3/api-v3-filter-builder";

export class BlueTableKpiService extends BlueTableService {
  private project:string;
  private page:number = 0;
  private data:any[] = [];
  private columns:string[] = ['Рег. проект', 'Куратор', 'Рук. проекта', 'План', 'Факт'];
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
        this.halResourceService
          .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.quartered_work_package_targets_with_quarter_groups_view.toString(), params)
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
                    this.data.push({_type: row._type,
                      identifier: row.identifier,
                      name: row.name,
                      curator: row.curator,
                      curator_id: row.curator_id,
                      rukovoditel: row.rukovoditel,
                      rukovoditel_id: row.rukovoditel_id});
                    row.targets.map((target:HalResource) => {
                      this.data.push({_type: target._type, target_id: target.target_id, name: target.name});
                      target.work_packages.map((wp:HalResource) => {
                        this.data.push(wp);
                      });
                    });
                  });
                }
              }
            });
          });
      });
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
          this.halResourceService
            .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.quartered_work_package_targets_with_quarter_groups_view.toString(), params)
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
                      this.data.push({_type: row._type,
                        identifier: row.identifier,
                        name: row.name,
                        curator: row.curator,
                        curator_id: row.curator_id,
                        rukovoditel: row.rukovoditel,
                        rukovoditel_id: row.rukovoditel_id});
                      row.targets.map((target:HalResource) => {
                        this.data.push({_type: target._type, target_id: target.target_id, name: target.name});
                        target.work_packages.map((wp:HalResource) => {
                          this.data.push(wp);
                        });
                      });
                    });
                  }
                }
              });
              if (this.national_project_titles[i].id === 0) {
                this.data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
                if (this.data_local[0]) {
                  this.data_local[0].map((row:HalResource) => {
                    this.data.push({_type: row._type,
                      identifier: row.identifier,
                      name: row.name,
                      curator: row.curator,
                      curator_id: row.curator_id,
                      rukovoditel: row.rukovoditel,
                      rukovoditel_id: row.rukovoditel_id});
                    row.targets.map((target:HalResource) => {
                      this.data.push({_type: target._type, target_id: target.target_id, name: target.name});
                      target.work_packages.map((wp:HalResource) => {
                        this.data.push(wp);
                      });
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
          this.halResourceService
            .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.quartered_work_package_targets_with_quarter_groups_view.toString(), params)
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
                        row.problems.map((problem:HalResource) => {
                          this.data.push(problem);
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

  public getDataWithFilter(param:string):any[] {
    if (param.startsWith('project')) {
      this.project = param.slice(7);
      this.page = 0;
    }
    this.data = [];
    this.data_local = [];
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        if (!this.project || this.project === '0') {
          let params:any = {national: this.national_project_titles[this.page].id};
          this.halResourceService
            .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.quartered_work_package_targets_with_quarter_groups_view.toString(), params)
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
                    this.data.push({_type: row._type,
                      identifier: row.identifier,
                      name: row.name,
                      curator: row.curator,
                      curator_id: row.curator_id,
                      rukovoditel: row.rukovoditel,
                      rukovoditel_id: row.rukovoditel_id});
                    row.targets.map((target:HalResource) => {
                      this.data.push({_type: target._type, target_id: target.target_id, name: target.name});
                      target.work_packages.map((wp:HalResource) => {
                        this.data.push(wp);
                      });
                    });
                  });
                }
              }
              resources.elements.map((el:HalResource) => {
                if ((el.id === this.national_project_titles[this.page].id) || (el.parentId && el.parentId === this.national_project_titles[this.page].id)) {
                  this.data.push(el);
                  if (this.data_local[el.id]) {
                    this.data_local[el.id].map((row:HalResource) => {
                      this.data.push({_type: row._type,
                        identifier: row.identifier,
                        name: row.name,
                        curator: row.curator,
                        curator_id: row.curator_id,
                        rukovoditel: row.rukovoditel,
                        rukovoditel_id: row.rukovoditel_id});
                      row.targets.map((target:HalResource) => {
                        this.data.push({_type: target._type, target_id: target.target_id, name: target.name});
                        target.work_packages.map((wp:HalResource) => {
                          this.data.push(wp);
                        });
                      });
                    });
                  }
                }
              });
            });
        } else {
          this.page = 1;
          let params:any = {project: this.project, offset: this.page};
          this.halResourceService
            .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.quartered_work_package_targets_with_quarter_groups_view.toString(), params)
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
                        this.data.push({_type: row._type,
                          identifier: row.identifier,
                          name: row.name,
                          curator: row.curator,
                          curator_id: row.curator_id,
                          rukovoditel: row.rukovoditel,
                          rukovoditel_id: row.rukovoditel_id});
                        row.targets.map((target:HalResource) => {
                          this.data.push({_type: target._type, target_id: target.target_id, name: target.name});
                          target.work_packages.map((wp:HalResource) => {
                            this.data.push(wp);
                          });
                        });
                      });
                    }
                  }
                });
                if (project.national_id === 0) {
                  this.data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
                  if (this.data_local[0]) {
                    this.data_local[0].map((row:HalResource) => {
                      this.data.push({_type: row._type,
                        identifier: row.identifier,
                        name: row.name,
                        curator: row.curator,
                        curator_id: row.curator_id,
                        rukovoditel: row.rukovoditel,
                        rukovoditel_id: row.rukovoditel_id});
                      row.targets.map((target:HalResource) => {
                        this.data.push({_type: target._type, target_id: target.target_id, name: target.name});
                        target.work_packages.map((wp:HalResource) => {
                          this.data.push(wp);
                        });
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

  public getTdData(row:any, i:number):string {
    if (row._type === 'WorkPackageQuarterlyTarget') {
      switch (i) {
        case 0: {
          return '<a href="' + super.getBasePath() + '/work_packages/' + row.work_package_id + '/activity?plan_type=execution">' + row.subject + '</a>';
          break;
        }
        case 3: {
          return row.fact;
          break;
        }
        case 4: {
          return row.plan;
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
          return '<a href="' + super.getBasePath() + '/users/' + row.curator_id + '">' + row.curator + '</a>';
          break;
        }
        case 2: {
          return '<a href="' + super.getBasePath() + '/users/' + row.rukovoditel_id + '">' + row.rukovoditel + '</a>';
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
      }
    }
    if (row._type === 'NationalProject') {
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
        if (row._type === 'WorkPackageQuarterlyTarget') {
          return 'p50';
        }
        return row.parentId == null ? 'p10' : 'p20';
        break;
      }
    }
    return '';
  }
}
