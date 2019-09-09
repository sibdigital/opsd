import {
  ChangeDetectorRef,
  Component,
  ElementRef, EventEmitter,
  Inject,
  Injector,
  OnDestroy,
  OnInit,
} from '@angular/core';
import {OpModalLocalsMap} from 'core-components/op-modals/op-modal.types';
import {OpModalComponent} from 'core-components/op-modals/op-modal.component';
import {LoadingIndicatorService} from 'core-app/modules/common/loading-indicator/loading-indicator.service';
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {OpModalLocalsToken} from "core-components/op-modals/op-modal.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {PaginationInstance} from "core-components/table-pagination/pagination-instance";
import {Observable} from "rxjs";
import {takeUntil} from "rxjs/operators";
import {input, InputState} from "reactivestates";
import {PaginationUpdateObject} from "core-components/wp-fast-table/state/wp-table-pagination.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";

@Component({
  templateUrl: './wp-topics-configuration.modal.html'
})
export class WpTopicsConfigurationModalComponent extends OpModalComponent implements OnInit, OnDestroy {
  public noResults = false;
  public wpList:WorkPackageResource[];
  public selectedWp:WorkPackageResource;
  public pagination = input<PaginationInstance>();
  private projectId:string;
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
              readonly I18n:I18nService,
              readonly injector:Injector,
              readonly loadingIndicator:LoadingIndicatorService,
              readonly cdRef:ChangeDetectorRef,
              readonly elementRef:ElementRef,
              readonly halResourceService:HalResourceService,
              readonly pathHelper:PathHelperService) {
    super(locals, cdRef, elementRef);
  }

  ngOnInit() {
    this.projectId = this.locals['projectId'];
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
    return this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.wpByProject(this.projectId).toString(), {
        pageSize: 10,
      })
      .toPromise();
  }

  public get state():InputState<PaginationInstance> {
    return this.pagination;
  }

  public observeUntil(unsubscribe:Observable<any>) {
    return this.state.values$().pipe(takeUntil(unsubscribe));
  }

  public updateFromObject(object:PaginationUpdateObject) {
    this.loadingIndicator.indicator('modal').promise = this.halResourceService
      .get<CollectionResource<WorkPackageResource>>(this.pathHelper.api.v3.wpByProject(this.projectId).toString(), {
        pageSize: 10,
        offset: object.page
      })
      .toPromise()
      .then((collection:CollectionResource<WorkPackageResource>) => {
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
