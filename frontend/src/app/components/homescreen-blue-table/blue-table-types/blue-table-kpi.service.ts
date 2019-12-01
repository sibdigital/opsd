import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";

export class BlueTableKpiService extends BlueTableService {
  protected columns:string[] = ['Рег. проект', 'Куратор', 'Рук. проекта', 'План', 'Факт'];
  private project:string;
  private page:number = 0;
  private national_project_titles:{ id:number, name:string }[];
  private national_projects:HalResource[];

  public getDataFromPage(i:number):Promise<any[]> {
    return new Promise((resolve) => {
      this.page = i;
      let data:any[] = [];
      let data_local:any = {};
      if (!this.project || this.project === '0') {
        let params:any = {national: this.national_project_titles[this.page].id};
        this.halResourceService
          .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.quartered_work_package_targets_with_quarter_groups_view.toString(), params)
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
                data.push(el);
                if (data_local[el.id]) {
                  data_local[el.id].map((row:HalResource) => {
                    data.push({
                      _type: row._type,
                      identifier: row.identifier,
                      name: row.name,
                      curator: row.curator,
                      curator_id: row.curator_id,
                      rukovoditel: row.rukovoditel,
                      rukovoditel_id: row.rukovoditel_id
                    });
                    row.targets.map((target:HalResource) => {
                      data.push({_type: target._type, target_id: target.target_id, name: target.name});
                      target.work_packages.map((wp:HalResource) => {
                        data.push(wp);
                      });
                    });
                  });
                }
              }
            });
            if (this.national_project_titles[i].id === 0) {
              data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
              if (data_local[0]) {
                data_local[0].map((row:HalResource) => {
                  data.push({
                    _type: row._type,
                    identifier: row.identifier,
                    name: row.name,
                    curator: row.curator,
                    curator_id: row.curator_id,
                    rukovoditel: row.rukovoditel,
                    rukovoditel_id: row.rukovoditel_id
                  });
                  row.targets.map((target:HalResource) => {
                    data.push({_type: target._type, target_id: target.target_id, name: target.name});
                    target.work_packages.map((wp:HalResource) => {
                      data.push(wp);
                    });
                  });
                });
              }
            }
            resolve(data);
          });
      } else {
        this.page += 1;
        let params:any = {project: this.project, offset: this.page};
        this.halResourceService
          .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.quartered_work_package_targets_with_quarter_groups_view.toString(), params)
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
                  data.push(el);
                  if (data_local[el.id]) {
                    data_local[el.id].map((row:HalResource) => {
                      data.push({_type: row._type, identifier: row.identifier, name: row.name});
                      row.problems.map((problem:HalResource) => {
                        data.push(problem);
                      });
                    });
                  }
                }
              });
              if (project.national_id === 0) {
                data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
                if (data_local[0]) {
                  data_local[0].map((row:HalResource) => {
                    data.push({_type: row._type, identifier: row.identifier, name: row.name});
                    row.problems.map((problem:HalResource) => {
                      data.push(problem);
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

  public getDataWithFilter(param:string):Promise<any[]> {
    return new Promise((resolve) => {
      let data:any[] = [];
      let data_local:any = {};
      if (param.startsWith('project')) {
        this.project = param.slice(7);
        this.page = 0;
      }
      if (!this.project || this.project === '0') {
        let params:any = {national: this.national_project_titles[this.page].id};
        this.halResourceService
          .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.quartered_work_package_targets_with_quarter_groups_view.toString(), params)
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
              data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
              if (data_local[0]) {
                data_local[0].map((row:HalResource) => {
                  data.push({
                    _type: row._type,
                    identifier: row.identifier,
                    name: row.name,
                    curator: row.curator,
                    curator_id: row.curator_id,
                    rukovoditel: row.rukovoditel,
                    rukovoditel_id: row.rukovoditel_id
                  });
                  row.targets.map((target:HalResource) => {
                    data.push({_type: target._type, target_id: target.target_id, name: target.name});
                    target.work_packages.map((wp:HalResource) => {
                      data.push(wp);
                    });
                  });
                });
              }
            }
            this.national_projects.map((el:HalResource) => {
              if ((el.id === this.national_project_titles[this.page].id) || (el.parentId && el.parentId === this.national_project_titles[this.page].id)) {
                data.push(el);
                if (data_local[el.id]) {
                  data_local[el.id].map((row:HalResource) => {
                    data.push({
                      _type: row._type,
                      identifier: row.identifier,
                      name: row.name,
                      curator: row.curator,
                      curator_id: row.curator_id,
                      rukovoditel: row.rukovoditel,
                      rukovoditel_id: row.rukovoditel_id
                    });
                    row.targets.map((target:HalResource) => {
                      data.push({_type: target._type, target_id: target.target_id, name: target.name});
                      target.work_packages.map((wp:HalResource) => {
                        data.push(wp);
                      });
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
                if ((el.federal_id !== 0) || (el.federal_id === 0 && el.national_id === 0)) {
                  data_local[el.federal_id] = [el];
                } else {
                  data_local[el.national_id] = [el];
                }
              });
              resource.elements.map((project:HalResource) => {
                this.national_projects.map((el:HalResource) => {
                  if ((el.id === project.federal_id) || (el.parentId && el.parentId === project.national_id) || (el.id === project.national_id)) {
                    data.push(el);
                    if (data_local[el.id]) {
                      data_local[el.id].map((row:HalResource) => {
                        data.push({
                          _type: row._type,
                          identifier: row.identifier,
                          name: row.name,
                          curator: row.curator,
                          curator_id: row.curator_id,
                          rukovoditel: row.rukovoditel,
                          rukovoditel_id: row.rukovoditel_id
                        });
                        row.targets.map((target:HalResource) => {
                          data.push({_type: target._type, target_id: target.target_id, name: target.name});
                          target.work_packages.map((wp:HalResource) => {
                            data.push(wp);
                          });
                        });
                      });
                    }
                  }
                });
                if (project.national_id === 0) {
                  data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
                  if (data_local[0]) {
                    data_local[0].map((row:HalResource) => {
                      data.push({
                        _type: row._type,
                        identifier: row.identifier,
                        name: row.name,
                        curator: row.curator,
                        curator_id: row.curator_id,
                        rukovoditel: row.rukovoditel,
                        rukovoditel_id: row.rukovoditel_id
                      });
                      row.targets.map((target:HalResource) => {
                        data.push({_type: target._type, target_id: target.target_id, name: target.name});
                        target.work_packages.map((wp:HalResource) => {
                          data.push(wp);
                        });
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
    return new Promise((resolve) => {
      this.national_project_titles = [];
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
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

  public getTdData(row:any, i:number):string {
    if (row._type === 'WorkPackageQuarterlyTarget') {
      switch (i) {
        case 0: {
          return '<a href="' + super.getBasePath() + '/work_packages/' + row.work_package_id + '/activity?plan_type=execution">' + row.subject + '</a>';
          break;
        }
        case 2: {
          return '<a href="' + super.getBasePath() + '/users/' + row.assignee_id + '">' + row.assignee + '</a>';
          break;
        }
        case 3: { //+-tan исправлена опечатка был row.fact
          return row.plan;
          break;
        }
        case 4: { //+-tan исправлена опечатка был row.plan
          return row.fact;
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
