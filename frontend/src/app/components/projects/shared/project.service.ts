import { Injectable } from '@angular/core';
import {HttpClient, HttpParams} from "@angular/common/http";
import {environment} from "../../../../environments/environment";

@Injectable({
  providedIn: 'root'
})
export class ProjectService {

  constructor(private http:HttpClient) { }

  getAllByNameAndPageAndSizeAndSort(name:string, page:number, size:number, sort:string, sortDir:string) {
    sortDir = (sortDir === '') ? 'asc' : sortDir;
    let params = new HttpParams().set('name', name).set('page', page.toString()).set('size', size.toString()).set('sort', sort.concat(',', sortDir));
    return this.http.get<any>(environment.jopsd_url + '/api/projects/search/findByNameContainingIgnoreCase', {params: params});
  }

  getProjectById(projectId:number) {
    return this.http.get<any>(environment.jopsd_url + '/api/projects/' + projectId);
  }
}
