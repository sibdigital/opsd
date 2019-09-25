import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";

export class BlueTableDiscussService extends BlueTableService {
  protected columns:string[] = ['Проект', 'Куратор/\nРП', 'Тема', 'Дата последнего сообщения'];
  private national_project_titles:{ id:number, name:string }[];
  private national_projects:HalResource[];

  public initializeAndGetData():Promise<any[]> {
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

  public getDataFromPage(i:number):Promise<any[]> {
    return new Promise((resolve) => {
      i += 1;
      let data:any[] = [];
      let data_local:any = {};
      this.halResourceService
        .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.topics.toString(), {offset: i})
        .toPromise()
        .then((resources:CollectionResource<HalResource>) => {
          let total:number = resources.total; //всего ex 29
          let pageSize:number = resources.pageSize;
          let remainder = total % pageSize;
          this.pages = (total - remainder) / pageSize;
          if (remainder !== 0) {
            this.pages++;
          }
          resources.elements.map((el:HalResource) => {
            data.push(el);
          });
          /*resources.elements.map((topic:HalResource) => {
            if (!topic.project.federalProjectId) {
              topic.project.federalProjectId = 0;
            }
            if (!topic.project.nationalProjectId) {
              topic.project.nationalProjectId = 0;
            }

            if ((topic.project.federalProjectId !== 0) || (topic.project.federalProjectId === 0 && topic.project.nationalProjectId === 0)) {
              data_local[topic.project.federalProjectId] = data_local[topic.project.federalProjectId] || [];
              data_local[topic.project.federalProjectId].push(topic);
            } else {
              data_local[topic.project.nationalProjectId] = data_local[topic.project.nationalProjectId] || [];
              data_local[topic.project.nationalProjectId].push(topic);
            }
          });
          this.national_projects.map( (el:HalResource) => {
            data.push(el);
            if (data_local[el.id]) {
              data_local[el.id].map((protocol:HalResource) => {
                data.push(protocol);
              });
            }
          });
          data.push({_type: 'NationalProject', id: 0, name: 'Проекты Республики Бурятия'});
          if (data_local[0]) {
            data_local[0].map((topic:ProjectResource) => {
              data.push(topic);
            });
          }*/
          resolve(data);
        });
    });
  }

  public getTdData(row:any, i:number):string {
    if (row._type === 'Message') {
      switch (i) {
        case 0: {
          return '<a href="' + super.getBasePath() + '/projects/' + row.project.identifier + '">' + row.project.name + '</a>';
          break;
        }
        case 1: {
          let result:string = '';
          if (row.project.curator) {
            result += '<a href="' + super.getBasePath() + '/users/' + row.project.curator.id + '">' + row.project.curator.fio + '</a>';
          }
          result += '<br>';
          if (row.project.rukovoditel) {
            result += '<a href="' + super.getBasePath() + '/users/' + row.project.rukovoditel.id + '">' + row.project.rukovoditel.fio + '</a>';
          }
          return result;
          break;
        }
        case 2: {
          return row.subject;
          break;
        }
        case 3: {
          return this.format(row.updatedOn);
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
        if (row._type === 'Message') {
          return 'p30';
        }
        return row.parentId == null ? 'p10' : 'p20';
        break;
      }
    }
    return '';
  }

  public format(input:string):string {
    return input.slice(8, 10) + '.' + input.slice(5, 7) + '.' + input.slice(0, 4);
  }
}
