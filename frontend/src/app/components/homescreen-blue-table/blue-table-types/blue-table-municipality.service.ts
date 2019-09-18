import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";

export class BlueTableMunicipalityService extends BlueTableService {
  private data:any[] = [];
  private columns:string[] = ['Проект', 'Куратор/\nРП', 'План срок завершения', 'Предстоящие мероприятия', 'Просроченные кт/\nПроблемы', 'Прогресс/\nИсполнение бюджета', 'KPI'];
  private national_project_titles:{id:number, name:string}[] = [];
  private filter:string = '1';
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
          .get<HalResource>(this.pathHelper.api.v3.work_package_stat_by_proj_view.toString(), {"organization": this.filter})
          .toPromise()
          .then((resource:HalResource) => {
            resource.source.map((el:HalResource) => {
              this.data_local[el.federal_id] = this.data_local[el.federal_id] || [];
              this.data_local[el.federal_id].push(el);
            });
            resources.elements.map((el:HalResource) => {
              if ((el.id === this.national_project_titles[0].id) || (el.parentId && el.parentId === this.national_project_titles[0].id)) {
                this.data.push(el);
                if (this.data_local[el.id]) {
                  this.data_local[el.id].map( (project:ProjectResource) => {
                    this.data.push(project);
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
      this.data.push({_type: 'NationalProject', id:0, name: 'Проекты Республики Бурятия'});
      if (this.data_local[0]) {
        this.data_local[0].map((project:ProjectResource) => {
          this.data.push(project);
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
                this.data_local[el.id].map((project:ProjectResource) => {
                  this.data.push(project);
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
    return this.national_project_titles.length;
  }

  public getData():any[] {
    return this.data;
  }

  public getTdData(row:any, i:number):string {
    if (row._type === 'Project') {
      switch (i) {
        case 0: {
          return '<a href="' + super.getBasePath() + '/projects/' + row.identifier + '">' + row.name + '</a>';
          break;
        }
        case 1: {
          let result:string = '<a href="' + super.getBasePath() + '/users/' + row.kurator_id + '">' + row.kurator + '</a>';
          result += '<br>';
          result += '<a href="' + super.getBasePath() + '/users/' + row.rukovoditel_id + '">' + row.rukovoditel + '</a>';
          return result;
          break;
        }
        case 2: {
          return this.format(row.dueDate);
          break;
        }
        case 3: {
          let from = new Date();
          let to = new Date();
          to.setDate(to.getDate() + 14);
          return '<a href=\'' + super.getBasePath() + '/projects/' + row.identifier +
            '/work_packages?plan_type=execution&query_id=3&query_props=%7B"c"%3A%5B"id"%2C"subject"%2C"type"%2C"status"%2C"assignee"%5D%2C"hl"%3A"none"%2C"hi"%3Afalse%2C"g"%3A""%2C"t"%3A""%2C"f"%3A%5B%7B"n"%3A"status"%2C"o"%3A"o"%2C"v"%3A%5B%5D%7D%2C%7B"n"%3A"type"%2C"o"%3A"%3D"%2C"v"%3A%5B"1"%5D%7D%2C%7B"n"%3A"planType"%2C"o"%3A"~"%2C"v"%3A%5B"execution"%5D%7D%2C%7B"n"%3A"dueDate"%2C"o"%3A"<>d"%2C"v"%3A%5B"' + from.toISOString().slice(0, 10) + '"%2C"' + to.toISOString().slice(0, 10) + '"%5D%7D%2C%7B"n"%3A"organization"%2C"o"%3A"="%2C"v"%3A%5B"' + this.filter + '"%5D%7D%5D%2C"pa"%3A1%2C"pp"%3A20%7D\'>' + row.preds + '</a>';
          break;
        }
        case 4: {
          return '<a href=\'' + super.getBasePath() + '/projects/' + row.identifier +
            '/work_packages?plan_type=execution&query_id=5&query_props=%7B"c"%3A%5B"id"%2C"type"%2C"status"%2C"subject"%2C"startDate"%2C"dueDate"%5D%2C"tv"%3Atrue%2C"tzl"%3A"days"%2C"hl"%3A"none"%2C"hi"%3Afalse%2C"g"%3A""%2C"t"%3A"id%3Aasc"%2C"f"%3A%5B%7B"n"%3A"status"%2C"o"%3A"o"%2C"v"%3A%5B%5D%7D%2C%7B"n"%3A"type"%2C"o"%3A"%3D"%2C"v"%3A%5B"2"%5D%7D%2C%7B"n"%3A"planType"%2C"o"%3A"~"%2C"v"%3A%5B"execution"%5D%7D%2C%7B"n"%3A"dueDate"%2C"o"%3A"<t-"%2C"v"%3A%5B"0"%5D%7D%2C%7B"n"%3A"organization"%2C"o"%3A"="%2C"v"%3A%5B"' + this.filter + '"%5D%7D%5D%2C"pa"%3A1%2C"pp"%3A20%7D\'>' + row.prosr + '</a>&nbsp;/&nbsp;' +
            '<a href="' + super.getBasePath() + '/vkladka1/problems?id=' + row.project_id + '">' + row.riski + '</a>';
          break;
        }
        case 5: {
          return row.all_wps === 0 ? '0' : (row.ispolneno / row.all_wps).toString();
          break;
        }
        case 6: {
          return '<a href="' + super.getBasePath() + '/vkladka1/kpi">Посмотреть</a>';
          break;
        }
        case 100: {
          return row.budget_fraction;
          break;
        }
      }
    } else {
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
        return row.parentId == null ? 'p10' : 'p20';
        break;
      }
      case 5: {
        if (row._type === 'Project') {
          return 'progressbar2';
        }
        break;
      }
    }
    return '';
  }

  public format(input:string):string {
    if (!input) {
      return '';
    }
    return input.slice(3, 5) + '.' + input.slice(0, 2) + '.' + input.slice(6, 10);
  }

  public pagesToText(i:number):string {
    return this.national_project_titles[i].name;
  }

  public getDataWithFilter(param:string):Promise<any[]> {
    return new Promise((resolve) => {
      this.filter = param;
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          this.halResourceService
            .get<HalResource>(this.pathHelper.api.v3.work_package_stat_by_proj_view.toString(), {"organization": this.filter})
            .toPromise()
            .then((resource:HalResource) => {
              let ldata:any[] = [];
              let data_local:any = {};
              resource.source.map((el:HalResource) => {
                this.data_local[el.federal_id] = this.data_local[el.federal_id] || [];
                this.data_local[el.federal_id].push(el);
              });
              resources.elements.map((el:HalResource) => {
                if ((el.id === this.national_project_titles[0].id) || (el.parentId && el.parentId === this.national_project_titles[0].id)) {
                  this.data.push(el);
                  if (this.data_local[el.id]) {
                    this.data_local[el.id].map((project:ProjectResource) => {
                      this.data.push(project);
                    });
                  }
                }
              });
              this.data = ldata;
            });
        });
      return this.data;
    });
    }

}
