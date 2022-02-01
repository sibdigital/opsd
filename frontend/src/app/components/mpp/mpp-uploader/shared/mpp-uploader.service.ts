import { Injectable } from '@angular/core';
import {HttpClient, HttpHeaders, HttpParams} from "@angular/common/http";
import {Observable} from "rxjs";
import {WorkPackage} from "core-components/work-packages/work-package.model";
import {environment} from "../../../../../environments/environment";

@Injectable({
  providedIn: 'root'
})
export class MppUploaderService {

  constructor(private http:HttpClient) { }

  processMppFile(file:File, projectId:number | undefined, projectName:string):Observable<WorkPackage[]> {
    let headers = new HttpHeaders();
    headers.append('Content-Type', 'multipart/form-data');

    let data:FormData = new FormData();
    data.append('file', file, file.name);
    let params = new HttpParams()
      .set("projectId", (projectId === undefined) ? '0' : projectId.toString())
      .set("projectName", projectName);

    return this.http.post<WorkPackage[]>(environment.jopsd_url + '/import/mpp', data, {headers: headers, params: params});
  }
}
