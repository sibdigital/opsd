import {Component, ElementRef, Input, OnDestroy, OnInit} from "@angular/core";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {States} from "core-components/states.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {filter, takeUntil} from "rxjs/operators";
import {componentDestroyed} from "ng2-rx-componentdestroyed";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";

@Component({
  selector: 'links',
  templateUrl: './links.html'
})
export class LinksComponent implements OnInit, OnDestroy {
  @Input('resource') public resource:HalResource;
  public $element:JQuery;
  public $formElement:JQuery;
  public text:any;
  public allowUploading:boolean;
  public destroyImmediately:boolean;
  public initialLinks:HalResource[];

  constructor(protected elementRef:ElementRef,
              protected I18n:I18nService,
              protected states:States,
              protected halResourceService:HalResourceService) {

    this.text = {
      links: this.I18n.t('js.label_links'),
    };
  }

  ngOnInit() {
    this.$element = jQuery(this.elementRef.nativeElement);
    if (!this.resource) {
      // Parse the resource if any exists
      const source = this.$element.data('resource');
      this.resource = this.halResourceService.createHalResource(source, true);
    }

    this.allowUploading = this.$element.data('allow-uploading');

    if (this.$element.data('destroy-immediately') !== undefined) {
      this.destroyImmediately = this.$element.data('destroy-immediately');
    } else {
      this.destroyImmediately = true;
    }

    this.setupLinkDeletionCallback();
    this.setupResourceUpdateListener();
  }

  private setupLinkDeletionCallback() {
    this.memoizeCurrentLinks();

    this.$formElement = this.$element.closest('form');
    this.$formElement.on('submit.link-component', () => {
      this.destroyRemovedLinks();
    });
  }

  private setupResourceUpdateListener() {
    this.states.forResource(this.resource).changes$()
      .pipe(
        takeUntil(componentDestroyed(this)),
        filter(newResource => !!newResource)
      )
      .subscribe((newResource:HalResource) => {
        this.resource = newResource || this.resource;

        if (this.destroyImmediately) {
          this.destroyRemovedLinks();
          this.memoizeCurrentLinks();
        }
      });
  }

  ngOnDestroy() {
    this.$formElement.off('submit.link-component');
  }

  public showLinks() {
    return this.allowUploading || _.get(this.resource, 'links.count', 0) > 0;
  }

  private destroyRemovedLinks() {
    let missingLinks = _.differenceBy(this.initialLinks,
      this.resource.links.elements,
      (link:HalResource) => link.id);

    if (missingLinks.length) {
      missingLinks.forEach((link) => {
        this
          .resource
          .removeLink(link);
      });
    }
  }

  private memoizeCurrentLinks() {
    this.initialLinks = _.clone(this.resource.links.elements);
  }
}

DynamicBootstrapper.register({ selector: 'links', cls: LinksComponent, embeddable: true });
