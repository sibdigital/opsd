import {
  ChangeDetectorRef,
  Component,
  ElementRef, EventEmitter,
  Inject,
  Injector, Input,
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
import {QueryFilterInstanceResource} from "core-app/modules/hal/resources/query-filter-instance-resource";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";

@Component({
  templateUrl: './wp-calendar-choose-usertask.modal.html'
})
export class ChooseUserTaskModalComponent extends OpModalComponent implements OnInit, OnDestroy {

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

  public confirmed = false;

  //вид диалогового окна, "period" - выбор периода, "new_tasks" - выбор типа новой задачи
  public type_dialog = "period";

  @Input() public startPeriodDate:string;
  @Input() public endPeriodDate:string;

  public text = {
    title: 'Выберите период',
    noResults: this.I18n.t('js.work_packages.no_results.title'),
    closePopup: this.I18n.t('js.close_popup_title'),
    subject: this.I18n.t('js.work_packages.properties.subject'),
    type: this.I18n.t('js.work_packages.properties.type'),
    status: this.I18n.t('js.work_packages.properties.status'),
    assignee: this.I18n.t('js.work_packages.properties.assignee'),
    planning: this.I18n.t('js.label_plan_stage_package').toLowerCase(),
    execution: this.I18n.t('js.label_work_package').toLowerCase(),
    button_continue: this.I18n.t('js.button_continue'),
    button_cancel: this.I18n.t('js.button_cancel')
  };

  public onDataUpdated = new EventEmitter<void>();

  constructor(@Inject(OpModalLocalsToken) public locals:OpModalLocalsMap,
              readonly I18n:I18nService,
              readonly injector:Injector,
              readonly loadingIndicator:LoadingIndicatorService,
              readonly cdRef:ChangeDetectorRef,
              readonly pathHelper:PathHelperService,
              readonly elementRef:ElementRef) {
    super(locals, cdRef, elementRef);
  }

  ngOnInit() {
  this.$element = jQuery(this.elementRef.nativeElement);

    // this.startPeriodDate = this.locals.start;
    // this.endPeriodDate = this.locals.end;
    //console.log("startPeriod: " + this.startPeriodDate);

    this.type_dialog = this.locals.type_dialog;
  }

  ngOnDestroy() {
    this.onDataUpdated.complete();
  }

  /**
   * Called when the user attempts to close the modal window.
   * The service will close this modal if this method returns true
   * @returns {boolean}
   */
  // public onClose():boolean {
  //  // this.afterFocusOn.focus();
  //   this.confirmed = false;
  //   return true;
  // }

  // protected get afterFocusOn():JQuery {
  //   return this.$element;
  // }

  public confirmAndClose(evt:JQueryEventObject) {
    this.confirmed = true;
    console.log("this.confirmed = true;")
    this.closeMe(evt);
  }

  public newUTRequestWPPath() {
    return `${this.pathHelper.appBasePath}/user_tasks/new?head_text=Запрос+на+приемку+задачи&kind=Request&object_type=WorkPackage`;
  }

  public newUTRequestPath() {
    return `${this.pathHelper.appBasePath}/user_tasks/new?head_text=Запрос+на+ввод+данных+в+справочники&kind=Request`;
  }

  public newUTTaskPath() {
    return `${this.pathHelper.appBasePath}/user_tasks/new?head_text=Новая+задача&kind=Task`;
  }
}
