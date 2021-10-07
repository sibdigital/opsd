import {Component, ElementRef, Input, OnInit} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {Page} from "core-components/pages/pages.component";
import {LoadingIndicatorService} from "core-app/modules/common/loading-indicator/loading-indicator.service";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";
import {ICKEditorContext, ICKEditorInstance} from "core-app/modules/common/ckeditor/ckeditor-setup.service";

@Component({
  selector: 'op-page-form',
  templateUrl: './page-form.component.html',
  styleUrls: ['./page-form.component.sass']
})
export class PageFormComponent implements OnInit {
  @Input() pageId:string;
  page:Page = {};
  projects:any;
  projectId:number;
  groupId:number;
  workPackageId:number;
  groups:any;
  workPackages:any;
  indicator:any;
  ckEditorContext = {
    macros: 'none' as 'none',
  };
  editorInstance:ICKEditorInstance;
  public initializationError = false;
  public $element:JQuery;
  public context:ICKEditorContext;
  constructor(
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    protected httpClient:HttpClient,
    protected elementRef:ElementRef,
    private loadingIndicatorService:LoadingIndicatorService,
    private notificationService:NotificationsService) {
  }

  ngOnInit():void {
    this.$element = jQuery(this.elementRef.nativeElement);
    this.pageId = this.$element.attr('pageId')!;
    this.indicator = this.loadingIndicatorService.indicator('page-form');
    if (this.pageId) {
      this.indicator.start();
      this.getPage();
    }
    else {
      this.getProjects();
      this.getGroups();
    }
  }

  private getPage() {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + '/pages/' + this.pageId,
      {params: new HttpParams().set('projection', 'pageProjection')}).toPromise()
      .then((page) => {
        this.page = page;
        this.editorInstance.setData(this.page.content ? this.page.content : '');
        // this.page.project ? this.page.project : this.page.project = {id: null};
        // this.page.author ? this.page.author :this.page.author = {id: null};
        // this.page.workPackage ? this.page.workPackage : this.page.workPackage = {id: null};
        // this.page.parent ? this.page.parent : this.page.parent = {id: null};
        this.getProjects();
        this.getGroups();
      })
      .catch((reason) => console.error(reason));
  }

  getProjects() {
    this.httpClient.get(
      this.pathHelper.javaUrlPath + '/projects/all').toPromise()
      .then((projects) => {
        this.projects = projects;
        if (this.pageId && this.page.project) {
          this.projectId = this.page.project.id;
          this.getWorkPackages(this.projectId!);
        }
        else {
          this.indicator.stop();
        }
      })
      .catch((reason) => console.error(reason));
  }

  getGroups() {
    this.httpClient.get(
      this.pathHelper.javaUrlPath + '/pages/groups', this.page.id ? {params: new HttpParams().set('id', `${this.page.id}`)} : {}).toPromise()
      .then((groups) => {
        this.groups = groups;
        if (this.pageId && this.page.parent) {
          this.groupId = this.page.parent.id;
        }
      })
      .catch((reason) => console.error(reason));
  }

  getWorkPackages(projectId:number) {
    projectId ? this.httpClient.get(
      this.pathHelper.javaUrlPath + '/work_packages/all',
      {params: new HttpParams().set('projectId', projectId.toString())})
      .toPromise()
      .then((workPackages) => {
        this.workPackages = workPackages;
        if (this.pageId && this.page.workPackage) {
          this.workPackageId = this.page.workPackage.id;
        }
        this.indicator.stop();
      })
      .catch((reason) => console.error(reason)) : 0;
  }

  savePage() {
    this.httpClient.post(this.pathHelper.javaUrlPath + '/pages/upsert', this.page)
      .toPromise()
      .then((page) => {
        this.page = page;
        this.editorInstance.setData(this.page.content ? this.page.content : '');
        // this.page.project ? this.page.project : this.page.project = {id: null};
        // this.page.author ? this.page.author :this.page.author = {id: null};
        // this.page.workPackage ? this.page.workPackage : this.page.workPackage = {id: null};
        // this.page.parent ? this.page.parent : this.page.parent = {id: null};
        this.notificationService.addSuccess('Изменения сохранены');
      })
      .catch((reason) => {
        this.notificationService.addError(`Ошибка сохранения: ${reason.message}`);
        console.error(reason);
      });
  }

  projectSelected(selected:string) {
    this.page.projectId = parseInt(selected) || null;
    this.page.project = this.page.projectId ? {id: this.page.projectId} : null;
    this.page.projectId ? this.getWorkPackages(this.page.projectId) : 0;
  }

  titleChanged(value:string) {
    this.page.title = value;
  }

  workPackageSelected(value:string) {
    this.page.workPackageId = parseInt(value);
    this.page.workPackage = this.page.workPackageId ? {id: this.page.workPackageId} : null;
  }

  groupSelected(value:string) {
    this.page.parentId = parseInt(value);
    this.page.parent = this.page.parentId ? {id: this.page.parentId} : null;
  }

  typeChanged(value:boolean) {
    this.page.isGroup = value;
  }

  deletePage() {
    this.page.isDeleted = !this.page.isDeleted;
  }

  publicatePage() {
    this.page.isPublicated = !this.page.isPublicated;
  }

  public onContentChange(value:string) {
    this.page.content = value;
  }

  public onCkeditorSetup(editor:ICKEditorInstance) {
    this.editorInstance = editor;
  }
}
DynamicBootstrapper.register({selector: 'op-page-form', cls: PageFormComponent});
