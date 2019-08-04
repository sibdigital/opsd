import {BlueTableService} from "core-components/homescreen-blue-table/blue-table.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {QueryResource} from "core-app/modules/hal/resources/query-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {ApiV3FilterBuilder} from "core-components/api/api-v3/api-v3-filter-builder";

export class BlueTableProtocolService extends BlueTableService {
  private data:any[] = [];
  private promises:Promise<CollectionResource<HalResource>>[] = [];
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
              this.data_local[protocol.project.id] = this.data_local[protocol.project.id] || {targets: []};
              this.data_local[protocol.project.id].targets.push(protocol);
            });
            console.log(this.data_local);
            resources.elements.map( (national:HalResource) => {
              this.data.push(national);
              if (national.projects) {
                national.projects.map((project:HalResource) => {
                  if (this.data_local[project['id']]) {
                    let b = this.data_local[project['id']];
                    b.targets.map((protocol:HalResource) => {
                      this.data.push(protocol);
                    });
                  }
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
          return row.name;
          break;
        }
        case 1: {
          if (row.user) {
            return '<a href="' + super.getBasePath() + '/users/' + row.user.id + '">' + row.user.lastname + ' ' + row.user.firstname.slice(0, 1) + '.' + row.user.patronymic.slice(0, 1) + '.</a>';
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
    if (row._type === 'National Project') {
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
