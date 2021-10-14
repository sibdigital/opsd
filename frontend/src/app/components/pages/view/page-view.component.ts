import {Component, ElementRef, Injector, Input, OnInit} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {HttpClient, HttpParams} from "@angular/common/http";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {Page} from "core-components/pages/pages.component";
import {DomSanitizer, SafeHtml} from "@angular/platform-browser";
import {MatTreeNestedDataSource} from "@angular/material/tree";

@Component({
  selector: 'op-page-view',
  templateUrl: './page-view.component.html',
  styleUrls: ['./page-view.component.sass']
})
export class PageViewComponent implements OnInit {
  page:Page = {};
  pageItems:any;
  content:SafeHtml;
  @Input() pageId:string;
  public $element:JQuery;

  constructor(protected pathHelper:PathHelperService,
              protected httpClient:HttpClient,
              protected elementRef:ElementRef,
              protected sanitizer:DomSanitizer) {
  }

  ngOnInit():void {
    this.$element = jQuery(this.elementRef.nativeElement);
    this.pageId = this.$element.attr('pageId')!;
    if (this.pageId) {
      this.getPage();
    }
    this.getPages();
  }

  private getPage() {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + '/pages/' + this.pageId,
      {params: new HttpParams().set('projection', 'pageProjection')}).toPromise()
      .then((page) => {
        this.page = page;
        this.content = this.sanitizer.bypassSecurityTrustHtml(this.page.content ? this.page.content : '');
      })
      .catch((reason) => console.error(reason));
  }

  private getPages() {
    this.httpClient.get(
      this.pathHelper.javaUrlPath + '/pages/list').toPromise()
      .then((pages) => {
        console.log(pages);
        this.pageItems = pages;
      })
      .catch((reason) => console.error(reason));
  }
}
DynamicBootstrapper.register({selector: 'op-page-view', cls: PageViewComponent});
