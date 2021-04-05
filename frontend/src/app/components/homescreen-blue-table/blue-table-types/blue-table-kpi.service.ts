import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";

export class BlueTableKpiService extends BlueTableService {
  protected columns:string[] = ['Рег. проект', 'Куратор', 'Рук. проекта', 'План', 'Факт'];
  private project:string;
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
        name: 'homescreen_curator',
        header: this.columns[1]
      },
      {
        name: 'homescreen_director',
        header: this.columns[2]
      },
      {
        name: 'homescreen_plan',
        header: this.columns[3]
      },
      {
        name: 'homescreen_fact',
        header: this.columns[4]
      }
    ]
  };
  private national_project_titles:{ id:number, name:string }[];
  private national_projects:HalResource[];

  public getDataFromPage(i:number):Promise<any[]> {
    return new Promise((resolve) => {
      this.page = i;
      let data:any[] = [];
      let data_local:any = {};
      if (!this.project || this.project === '0') {
        let params:any = {national: this.national_project_titles[this.page].id};
        console.log('getDataFromPage: ' + this.project + ' ' + this.national_project_titles[this.page].id);
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
                data.push({
                  id: el.id + el.type,
                  parentId: el.parentId + 'National' || 0,
                  homescreen_name: el.name
                });
                if (data_local[el.id]) {
                  data_local[el.id].map((row:HalResource) => {
                    data.push({
                      id: row.project_id + 'Project',
                      parentId: !row.federal_id ? row.parentId + el.type : row.parentId + 'Federal',
                      homescreen_name: '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.name + '</a>',
                      homescreen_curator: '<a href="' + super.getBasePath() + '/users/' + row.curator_id + '">' + row.curator + '</a>',
                      homescreen_directtor: '<a href="' + super.getBasePath() + '/users/' + row.rukovoditel_id + '">' + row.rukovoditel + '</a>',
                      homescreen_plan: '',
                      homescreen_fact: ''
                    });
                    row.targets.map((target:HalResource) => {
                      data.push({
                        id: target.target_id + 'Target',
                        parentId: row.project_id + 'Project',
                        homescreen_name: target.name
                      });
                      target.work_packages.map((wp:HalResource) => {
                        data.push({
                          id: wp.work_package_id,
                          parentId: target.target_id + 'Target',
                          homescreen_name: '<a href="' + super.getBasePath() + '/work_packages/' + wp.work_package_id + '/activity">' + wp.subject + '</a>',
                          homescreen_curator: '',
                          homescreen_director: '<a href="' + super.getBasePath() + '/users/' + wp.assignee_id + '">' + wp.assignee + '</a>',
                          homescreen_plan: wp.plan,
                          homescreen_fact: wp.fact
                        });
                      });
                    });
                  });
                }
              }
            });
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
                  data.push({
                    id: el.id + el.type,
                    parentId: el.parentId + 'National' || 0,
                    homescreen_name: el.name
                  });
                  if (data_local[el.id]) {
                    data_local[el.id].map((row:HalResource) => {
                      data.push({
                        id: row.project_id + 'Project',
                        parentId: !row.federal_id ? row.parentId + el.type : row.parentId + 'Federal',
                        homescreen_name: '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.name + '</a>',
                        homescreen_curator: '<a href="' + super.getBasePath() + '/users/' + row.curator_id + '">' + row.curator + '</a>',
                        homescreen_director: '<a href="' + super.getBasePath() + '/users/' + row.rukovoditel_id + '">' + row.rukovoditel + '</a>',
                        homescreen_plan: '',
                        homescreen_fact: ''
                      });
                      row.problems.map((problem:HalResource) => {
                        data.push({
                          id: problem.work_package_id,
                          parentId: problem.id + 'Project',
                          homescreen_name: '<a href="' + super.getBasePath() + '/work_packages/' + problem.work_package_id + '/activity">' + problem.subject + '</a>',
                          homescreen_curator: '',
                          homescreen_director: '<a href="' + super.getBasePath() + '/users/' + problem.assignee_id + '">' + problem.assignee + '</a>',
                          homescreen_plan: problem.plan,
                          homescreen_fact: problem.fact
                        });
                      });
                    });
                  }
                }
              });
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
            this.national_projects.map((el:HalResource) => {
              if ((el.id === this.national_project_titles[this.page].id) || (el.parentId && el.parentId === this.national_project_titles[this.page].id)) {
                data.push({
                  id: el.id + el.type,
                  parentId: el.parentId + 'National' || 0,
                  homescreen_name: el.name
                });
                if (data_local[el.id]) {
                  data_local[el.id].map((row:HalResource) => {
                    data.push({
                      id: row.project_id + 'Project',
                      parentId: !row.federal_id ? row.parentId + el.type : row.parentId + 'Federal',
                      homescreen_name: '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.name + '</a>',
                      homescreen_curator: '<a href="' + super.getBasePath() + '/users/' + row.curator_id + '">' + row.curator + '</a>',
                      homescreen_directtor: '<a href="' + super.getBasePath() + '/users/' + row.rukovoditel_id + '">' + row.rukovoditel + '</a>',
                      homescreen_plan: '',
                      homescreen_fact: ''
                    });
                    row.targets.map((target:HalResource) => {
                      data.push({
                        id: target.target_id + 'Target',
                        parentId: row.project_id + 'Project',
                        homescreen_name: target.name
                      });
                      target.work_packages.map((wp:HalResource) => {
                        data.push({
                          id: wp.work_package_id,
                          parentId: target.target_id + 'Target',
                          homescreen_name: '<a href="' + super.getBasePath() + '/work_packages/' + wp.work_package_id + '/activity">' + wp.subject + '</a>',
                          homescreen_curator: '',
                          homescreen_director: '<a href="' + super.getBasePath() + '/users/' + wp.assignee_id + '">' + wp.assignee + '</a>',
                          homescreen_plan: wp.plan,
                          homescreen_fact: wp.fact
                        });
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
                    data.push({
                      id: el.id + el.type,
                      parentId: el.parentId + 'National' || 0,
                      homescreen_name: el.name
                    });
                    if (data_local[el.id]) {
                      data_local[el.id].map((row:HalResource) => {
                        data.push({
                          id: row.project_id + 'Project',
                          parentId: !row.federal_id ? row.parentId + el.type : row.parentId + 'Federal',
                          homescreen_name: '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.name + '</a>',
                          homescreen_curator: '<a href="' + super.getBasePath() + '/users/' + row.curator_id + '">' + row.curator + '</a>',
                          homescreen_directtor: '<a href="' + super.getBasePath() + '/users/' + row.rukovoditel_id + '">' + row.rukovoditel + '</a>',
                          homescreen_plan: '',
                          homescreen_fact: ''
                        });
                        row.targets.map((target:HalResource) => {
                          data.push({
                            id: target.target_id + 'Target',
                            parentId: row.project_id + 'Project',
                            homescreen_name: target.name
                          });
                          target.work_packages.map((wp:HalResource) => {
                            data.push({
                              id: wp.work_package_id,
                              parentId: target.target_id + 'Target',
                              homescreen_name: '<a href="' + super.getBasePath() + '/work_packages/' + wp.work_package_id + '/activity">' + wp.subject + '</a>',
                              homescreen_curator: '',
                              homescreen_director: '<a href="' + super.getBasePath() + '/users/' + wp.assignee_id + '">' + wp.assignee + '</a>',
                              homescreen_plan: wp.plan,
                              homescreen_fact: wp.fact
                            });
                          });
                        });
                      });
                    }
                  }
                });
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
          return '<a href="' + super.getBasePath() + '/work_packages/' + row.work_package_id + '/activity">' + row.subject + '</a>';
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
