import {
  ChangeDetectorRef,
  Component,
  ElementRef, EventEmitter,
  Inject, InjectionToken,
  Injector,
  OnDestroy,
  OnInit, Optional,
} from '@angular/core';
import {OpModalLocalsMap} from 'core-components/op-modals/op-modal.types';
import {OpModalComponent} from 'core-components/op-modals/op-modal.component';
import {LoadingIndicatorService} from 'core-app/modules/common/loading-indicator/loading-indicator.service';
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {OpModalLocalsToken} from "core-components/op-modals/op-modal.service";
import {ComponentType} from "@angular/cdk/portal";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {PaginationInstance} from "core-components/table-pagination/pagination-instance";
import {Observable} from "rxjs";
import {takeUntil} from "rxjs/operators";
import {input, InputState} from "reactivestates";
import {PaginationUpdateObject} from "core-components/wp-fast-table/state/wp-table-pagination.service";

export const WpTableConfigurationModalPrependToken = new InjectionToken<ComponentType<any>>('WpTableConfigurationModalPrependComponent');

@Component({
  templateUrl: './wp-relations-configuration.modal.html'
})
export class WpRelationsConfigurationModalComponent extends OpModalComponent implements OnInit, OnDestroy {

  private workPackage:WorkPackageResource;
  private selectedRelationType:string;
  private filterCandidatesFor:string;
  public noResults = false;
  public wpList:WorkPackageResource[];
  public selectedWp:WorkPackageResource;
  public pagination = input<PaginationInstance>();

  /* Close on escape? */
  public closeOnEscape = true;

  /* Close on outside click */
  public closeOnOutsideClick = true;

  public $element:JQuery;

  public text = {
    title: 'Выберите',
    noResults: this.I18n.t('js.work_packages.no_results.title'),
    closePopup: this.I18n.t('js.close_popup_title'),
    subject: this.I18n.t('js.work_packages.properties.subject'),
    type: this.I18n.t('js.work_packages.properties.type'),
    status: this.I18n.t('js.work_packages.properties.status'),
    assignee: this.I18n.t('js.work_packages.properties.assignee'),
    planning: this.I18n.t('js.label_plan_stage_package').toLowerCase(),
    execution: this.I18n.t('js.label_work_package').toLowerCase()
  };

  public onDataUpdated = new EventEmitter<void>();

  constructor(@Inject(OpModalLocalsToken) public locals:OpModalLocalsMap,
              @Optional() @Inject(WpTableConfigurationModalPrependToken) public prependModalComponent:ComponentType<any> | null,
              readonly I18n:I18nService,
              readonly injector:Injector,
              readonly loadingIndicator:LoadingIndicatorService,
              readonly cdRef:ChangeDetectorRef,
              readonly elementRef:ElementRef) {
    super(locals, cdRef, elementRef);
  }

  ngOnInit() {
    this.$element = jQuery(this.elementRef.nativeElement);
    this.loadingIndicator.indicator('modal').promise = this.loadForm()
      .then((collection:CollectionResource<WorkPackageResource>) => {
        this.noResults = collection.count === 0;
        this.$element.find('.ui-autocomplete--loading').hide();
        this.wpList = collection.elements || [];
        let initialPagination = new PaginationInstance(1, collection.total, collection.pageSize);
        this.state.putValue(initialPagination);
      }).catch(() => {
        this.$element.find('.ui-autocomplete--loading').hide();
        this.wpList = [];
      });
  }

  ngOnDestroy() {
    this.onDataUpdated.complete();
  }

  public submitWPID(wp:WorkPackageResource):void {
    this.selectedWp = wp;
    this.onDataUpdated.emit();
    this.service.close();
  }

  /**
   * Called when the user attempts to close the modal window.
   * The service will close this modal if this method returns true
   * @returns {boolean}
   */
  public onClose():boolean {
    this.afterFocusOn.focus();
    return true;
  }

  protected get afterFocusOn():JQuery {
    return this.$element;
  }

  protected loadForm() {
    this.workPackage = this.locals['workPackage'];
    if (this.workPackage.planType === 'execution') {
      this.text.title += ' ' + this.text.execution;
    }
    if (this.workPackage.planType === 'planning') {
      this.text.title += ' ' + this.text.planning;
    }
    this.selectedRelationType = this.locals['selectedRelationType'];
    this.filterCandidatesFor = this.locals['filterCandidatesFor'];
    return this.workPackage.availableRelationCandidatesPaged.$link.$fetch({
      query: '',
      type: this.filterCandidatesFor || this.selectedRelationType
    });
  }

  public get state():InputState<PaginationInstance> {
    return this.pagination;
  }

  public observeUntil(unsubscribe:Observable<any>) {
    return this.state.values$().pipe(takeUntil(unsubscribe));
  }

  public updateFromObject(object:PaginationUpdateObject) {
    this.loadingIndicator.indicator('modal').promise = this.workPackage.availableRelationCandidatesPaged.$link.$fetch({
      query: '',
      type: this.filterCandidatesFor || this.selectedRelationType,
      offset: object.page
    }).then((collection:CollectionResource<WorkPackageResource>) => {
      this.$element.find('.ui-autocomplete--loading').hide();
      this.wpList = collection.elements || [];
      let currentPagination = new PaginationInstance(collection.offset, collection.total, collection.pageSize);
      this.state.putValue(currentPagination);
    }).catch(() => {
      this.$element.find('.ui-autocomplete--loading').hide();
      this.wpList = [];
    });
  }
}
