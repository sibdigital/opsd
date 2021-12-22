import { Injectable } from '@angular/core';
import {Observable} from "rxjs";
import {HttpClient, HttpParams} from "@angular/common/http";
import {environment} from "../../../../environments/environment";
import {Target} from "core-components/targets/target.model";

@Injectable({
  providedIn: 'root'
})
export class TargetService {

  constructor(private http:HttpClient) { }

  getAllByProjectId(projectId:number):Observable<Target[]> {
    let params = new HttpParams().set("projectId", projectId.toString());
    return this.http.get<Target[]>(environment.jopsd_url + '/target_list', {params: params});
  }

  getAllByProjectIdAndNameAndIdIsNotInAndPageAndSizeAndSort(projectId:number | null, name:string, ids:any, page:number, size:number, sort:string, sortDir:string) {
    sortDir = (sortDir === '') ? 'asc' : sortDir;
    if (ids) {
      let params = new HttpParams().set('projectId', (projectId) ? projectId.toString() : '').set('name', name)
        .set('ids', ids.toString()).set('page', page.toString()).set('size', size.toString()).set('sort', sort.concat(',', sortDir));
      return this.http.get<any>(environment.jopsd_url + '/api/targets/search/findByProject_IdAndNameContainingIgnoreCaseAndIdIsNotIn', {params: params});
    } else {
      let params = new HttpParams().set('projectId',  (projectId) ? projectId.toString() : '').set('name', name)
        .set('page', page.toString()).set('size', size.toString()).set('sort', sort.concat(',', sortDir));
      return this.http.get<any>(environment.jopsd_url + '/api/targets/search/findByProject_IdAndNameContainingIgnoreCase', {params: params});
    }
  }

  changeTargetMetaId(target:Target, metaId:number | null) {
    return this.http.post(environment.jopsd_url + '/targets/metaId',
      {},
      {params: new HttpParams()
          .set("metaId", metaId ? metaId.toString() : '')
          .set("targetId", target.id ? target.id.toString() : '')
         });
  }
}
