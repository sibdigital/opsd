import {Component, ElementRef, Input, OnInit} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {Page} from "core-components/pages/pages.component";

@Component({
  selector: 'op-page-form',
  templateUrl: './page-form.component.html',
  styleUrls: ['./page-form.component.sass']
})
export class PageFormComponent implements OnInit {
  @Input() pageId:string;
  page:Page = {};
  projects:any;
  groups:any;
  workPackages:any;
  public $element:JQuery;
  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    protected httpClient:HttpClient,
    protected elementRef:ElementRef) {
  }

  ngOnInit():void {
    this.$element = jQuery(this.elementRef.nativeElement);
    this.pageId = this.$element.attr('pageId')!;
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

  getWorkPackages(projectId:number) {
    this.httpClient.get(
      this.pathHelper.javaUrlPath + '/work_packages',
      {params: new HttpParams().set('projectId', projectId.toString())})
      .toPromise()
      .then((workPackages) => {
        this.workPackages = workPackages;
      })
      .catch((reason) => console.error(reason));
  }

  projectSelected(selected:string) {
    this.page.projectId = parseInt(selected);
    this.getWorkPackages(parseInt(selected));
  }

  savePage() {
    console.log(this.page);
  }

  titleChanged(value:string) {
    this.page.title = value;
  }

  workPackageSelected(value:string) {
    this.page.workPackageId = parseInt(value);
  }

  groupSelected(value:string) {
    this.page.parentId = parseInt(value);
  }

  typeChanged(value:boolean) {
    this.page.isGroup = value;
  }
}
DynamicBootstrapper.register({selector: 'op-page-form', cls: PageFormComponent});
