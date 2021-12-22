import { Injectable } from '@angular/core';
import {HttpClient, HttpParams} from "@angular/common/http";
import {environment} from "../../../../environments/environment";

@Injectable({
  providedIn: 'root'
})
export class EnumerationService {

  constructor(private http:HttpClient) { }


  getAllByActiveAndTypeAndNameIn(active:boolean, type:string, names:string[]) {
    let params = new HttpParams().set('active', String(active)).set('type', type).set('names', names.toString());
    return this.http.get<any>(environment.jopsd_url + '/api/enumerations/search/findAllByActiveAndTypeAndNameIn', {params: params});
  }

  getAllByPageAndSize(page:number, size:number, sort:string, sortDir:string) {
    sortDir = (sortDir === '') ? 'asc' : sortDir;
    let params = new HttpParams().set('page', page.toString()).set('size', size.toString()).set('sort', sort.concat(',', sortDir));
    return this.http.get<any>(environment.jopsd_url + 'api/enumerations', {params: params});
  }
}
