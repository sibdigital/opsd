import {Component, ElementRef, Input, OnChanges, OnDestroy, OnInit} from "@angular/core";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {WorkPackageCacheService} from "core-components/work-packages/work-package-cache.service";
import {filter, takeUntil} from "rxjs/operators";
import {componentDestroyed} from "ng2-rx-componentdestroyed";
import {States} from "core-components/states.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";

@Component({
  selector: 'link-list',
  templateUrl: './link-list.html'
})
export class LinkListComponent implements OnInit, OnChanges {
  @Input() public resource:HalResource;
  @Input() public selfDestroy:boolean = false;
  public workPackageLinks:any;
  public $element:JQuery;

  constructor(protected elementRef:ElementRef,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) { }

  ngOnChanges() {
    this.workPackageLinks = this.resource.workPackageLinks.elements;
  }

  ngOnInit() {
    this.$element = jQuery(this.elementRef.nativeElement);
    // this.workPackageLinks = this.resource.workPackageLinks.elements;
    this.halResourceService.get<CollectionResource<HalResource>>(
      this.pathHelper.api.v3.work_packages.id(this.resource.getId()).toString())
      .toPromise().then((response) => {
      this.workPackageLinks = response.workPackageLinks.elements;
      this.resource.workPackageLinks = response.workPackageLinks;
    });
  }

  private get linksUpdatable() {
    return (this.resource.workPackageLinks && this.resource.linksBackend);
  }
}
DynamicBootstrapper.register({
  selector: 'link-list',
  cls: LinkListComponent
});
