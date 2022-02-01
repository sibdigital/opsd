import { Injectable } from '@angular/core';
import {Observable} from "rxjs";
import {HttpClient, HttpParams} from "@angular/common/http";
import {WorkPackage} from "core-components/work-packages/work-package.model";
import {environment} from "../../../../environments/environment";

@Injectable({
  providedIn: 'root'
})
export class WpService {
  constructor(private http:HttpClient) { }
  getAllByProjectId(projectId:number):Observable<WorkPackage[]> {
    let params = new HttpParams().set('size', '10000').set('projectId', projectId.toString()).set('projection', 'shortProjection');
    return this.http.get<any>(environment.jopsd_url + '/api/workPackages/search/findAllByProjectId', {params: params});
  }

  getAllByProjectIdAndPageAndSize(projectId:number, page:number, size:number) {
    let params = new HttpParams().set('projectId', projectId.toString()).set('page', page.toString()).set('size', size.toString())
                                .set('sort', 'subject').set('projection', 'shortProjection');
    return this.http.get<any>(environment.jopsd_url + '/api/workPackages/search/findAllByProject_Id', {params: params});
  }

  getAllByProjectIdAndNameAndPageAndSizeAndSort(projectId:number | null, name:string, page:number, size:number, sort:string, sortDir:string) {
    sortDir = (sortDir === '') ? 'asc' : sortDir;
    let params = new HttpParams().set('projectId', (projectId) ? projectId.toString() : '').set('subject', name).set('page', page.toString())
                    .set('size', size.toString()).set('sort', sort.concat(',', sortDir)).set('projection', 'shortProjection');
    return this.http.get<any>(environment.jopsd_url + '/api/workPackages/search/findByProject_IdAndSubjectContainingIgnoreCase', {params: params});
  }
}
