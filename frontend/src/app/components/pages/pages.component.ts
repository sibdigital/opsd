import {Component, OnInit} from "@angular/core";
import {FormControl} from "@angular/forms";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {IProjectsState} from "core-components/projects/state/projects.state";
import {HttpClient, HttpParams} from "@angular/common/http";

export interface Page {
  id:number;
  title:string;
  content:string;
  isDeleted:boolean;
  isPublicated:boolean;
  isGroup:boolean;
  projectId:number;
  workPackageId:number;
  parentId:number;
  authorId:number;
}

@Component({
  selector: 'op-pages-form',
  templateUrl: './pages.component.html',
  styleUrls: ['./pages.component.sass'],
})
export class PagesComponent implements OnInit {
  pageControl = new FormControl();
  page:Page;
  projects:any;
  groups:any;
  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    protected httpClient:HttpClient
  ) {}

  ngOnInit():void {
    this.getProjects();
    this.getGroups();
  }

  getProjects() {
    this.httpClient.get(
      this.pathHelper.javaUrlPath + '/projects/all').toPromise()
      .then((projects) => {
        this.projects = projects;
      })
      .catch((reason) => console.error(reason));
  }

  getGroups() {
    this.httpClient.get(
      this.pathHelper.javaUrlPath + '/pages/groups').toPromise()
      .then((groups) => {
        this.groups = groups;
      })
      .catch((reason) => console.error(reason));
  }

  getWorkPackages() {
    this.httpClient.get(
      this.pathHelper.javaUrlPath + '/work_packages',
      {params: new HttpParams().set('projectId', '2')})
      .toPromise()
      .then((projects) => {
        this.projects = projects;
      })
      .catch((reason) => console.error(reason));
  }
}
