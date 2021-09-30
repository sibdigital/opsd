import {Component, ElementRef, Input, OnChanges, OnInit} from "@angular/core";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";

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
              protected halResourceService:HalResourceService) { }

  ngOnChanges() {
    this.workPackageLinks = this.resource.workPackageLinks.elements;
  }

  ngOnInit() {
    this.$element = jQuery(this.elementRef.nativeElement);
    this.workPackageLinks = this.resource.workPackageLinks.elements;
  }

  private get linksUpdatable() {
    return (this.resource.workPackageLinks && this.resource.linksBackend);
  }
}
DynamicBootstrapper.register({
  selector: 'link-list',
  cls: LinkListComponent
});
