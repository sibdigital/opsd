import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";

export class BlueTableProtocolService extends BlueTableService {
  private data:any[] = [];
  private data_local:any = {};
  private columns:string[] = ['', 'Ответственный', 'Срок', 'Исполнение'];

  public initialize():void {
    this.halResourceService
      .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.national_projects.toString())
      .toPromise()
      .then((resources:CollectionResource<HalResource>) => {
        this.halResourceService
          .get<CollectionResource<HalResource>>(this.pathHelper.api.v3.protocols.toString())
          .toPromise()
          .then((response:CollectionResource<HalResource>) => {
            response.elements.map((protocol:HalResource) => {
              if (!protocol.project.national_project_id) {
                protocol.project.national_project_id = 0;
              }
              this.data_local[protocol.project.national_project_id] = this.data_local[protocol.project.national_project_id] || [];
              this.data_local[protocol.project.national_project_id].push(protocol);
            });
            resources.elements.map( (el:HalResource) => {
              this.data.push(el);
              if (this.data_local[el.id]) {
                this.data_local[el.id].map((protocol:HalResource) => {
                  this.data.push(protocol);
                });
              }
            });
          });
      });
  }
  public getColumns():string[] {
    return this.columns;
  }
  public getPages():number {
    return 0;
  }

  public getData():any[] {
    return this.data;
  }

  public getDataFromPage(i:number):any[] {
    return this.data;
  }

  public getTdData(row:any, i:number):string {
    if (row._type === 'Protocol') {
      switch (i) {
        case 0: {
          return 'Поручение: ' + row.name;
          break;
        }
        case 1: {
          if (row.user) {
            let fio = row.user.lastname + ' ' + row.user.firstname.slice(0, 1) + '.';
            if (row.user.patronymic) {
              fio += row.user.patronymic.slice(0, 1) + '.';
            }
            return '<a href="' + super.getBasePath() + '/users/' + row.user.id + '">' + fio + '</a>';
          }
          break;
        }
        case 2: {
          return this.format(row.dueDate);
          break;
        }
        case 3: {
          if (row.completed) {
            return 'Исполнено';
          } else {
            return 'В работе';
          }
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
    let prefix:string = '';
    if (row._type === 'Protocol') {
      if (row.completed) {
        prefix = 'gr';
      } else {
        prefix = 'or';
      }
    }
    switch (i) {
      case 0: {
        if (row._type === 'Protocol') {
          return prefix + ' p30';
        }
        return row.parentId == null ? prefix + ' p10' : prefix + ' p20';
        break;
      }
    }
    return prefix;
  }

  public format(input:string):string {
    return input.slice(8, 10) + '.' + input.slice(5, 7) + '.' + input.slice(0, 4);
  }
}
