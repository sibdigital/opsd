import {Component, ElementRef, Input, OnDestroy, ViewChild} from '@angular/core';
import {Transition} from '@uirouter/core';
import {WorkPackageCacheService} from 'core-components/work-packages/work-package-cache.service';
import {WorkPackageResource} from 'core-app/modules/hal/resources/work-package-resource';
import {componentDestroyed} from 'ng2-rx-componentdestroyed';
import {takeUntil} from 'rxjs/operators';
import {I18nService} from 'core-app/modules/common/i18n/i18n.service';
import {WpTargetResource} from "core-app/modules/hal/resources/wp-target-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {WpTargetsService} from "core-components/wp-single-view-tabs/targets-tab/wp-targets.service";
import {WorkPackageNotificationService} from "core-components/wp-edit/wp-notification.service";
import {LoadingIndicatorService} from "core-app/modules/common/loading-indicator/loading-indicator.service";
import {WpProblem} from "core-components/wp-single-view-tabs/problems-tab/problems-tab.component";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {ConfirmDialogModal} from "core-components/modals/confirm-dialog/confirm-dialog.modal";
import {ConfirmDialogService} from "core-components/modals/confirm-dialog/confirm-dialog.service";

@Component({
  selector: 'wp-targets-tab',
  templateUrl: './targets-tab.html'

})
export class WorkPackageTargetsTabComponent implements OnDestroy {
  @Input() public workPackageId:string;
  @ViewChild('focusAfterSave') readonly focusAfterSave:ElementRef;

  public workPackage:WorkPackageResource;
  public wpTargets: WpTargetResource;
  public wpTargetIds: number[] = [];

  public showTargetsCreateForm:boolean = false;
  public selectedTgId:string;
  public isDisabled = false;
  public year: number;
  public quarter: number;
  public month: number;
  public plan_value: number;
  public value: number;

  public text = {
    targets_header: this.I18n.t('js.work_packages.tabs.targets'),
    save: this.I18n.t('js.target_buttons.save'),
    abort: this.I18n.t('js.target_buttons.abort'),
    addNewTarget: this.I18n.t('js.target_buttons.add_new_target'),
    removeButton: this.I18n.t('js.problem_buttons.delete_problem')
  };

  public confirmText = {
    title: 'Удаление',
    text: 'Вы действительно хотите удалить эту запись?',
    button_continue: 'Да'
  };

  public constructor(readonly I18n:I18nService,
                     readonly $transition:Transition,
                     protected wpTargetsService:WpTargetsService,
                     protected wpNotificationsService:WorkPackageNotificationService,
                     readonly loadingIndicator:LoadingIndicatorService,
                     readonly wpCacheService:WorkPackageCacheService,
                     protected pathHelper:PathHelperService,
                     protected confirmDialog: ConfirmDialogService,
                     protected halResourceService: HalResourceService) {
  }

  ngOnInit() {
    const wpId = this.workPackageId || this.$transition.params('to').workPackageId;
    this.wpCacheService.loadWorkPackage(wpId)
      .values$()
      .pipe(
        takeUntil(componentDestroyed(this))
      )
      .subscribe((wp) => {
        this.workPackageId = wp.id;
        this.workPackage = wp;
      });

    this.loadWpTargets();
  }

  ngOnDestroy() {
    // Nothing to do
  }

  public loadWpTargets(){
    this.wpTargetsService.getWpTargets(this.workPackageId)
      .then((resource:HalResource) => {
        let els = resource.elements;
        this.wpTargets = els.map( (el:any) => {
            if(this.wpTargetIds.indexOf(Number(el.targetId)) === -1){
              this.wpTargetIds.push(el.targetId);
            }
            return {
              id: el.getId(),
              project_id: el.projectId,
              work_package_id: el.workPackageId,
              wp_target_id: el.targetId,
              year: el.year,
              quarter: el.quarter,
              plan_value: el.planValue,
              value: el.value,
              name: el.$links.self.title
            }
          }
        );
        //console.log(this.wpTargets)
      });
  }

  public createTarget() {

    if (!this.selectedTgId || !this.year) {
      return;
    }

    this.isDisabled = true;
    this.createCommonTarget()
      .catch(() => this.isDisabled = false)
      .then(() => this.isDisabled = false);
  }

  public updateSelectedId(targetId:string) {
    this.selectedTgId = targetId;
  }

  protected createCommonTarget() {
    return this.wpTargetsService.addWpTarget(this.workPackage.id, this.workPackage.project.getId(), this.selectedTgId,
      this.year, this.quarter, this.month, this.plan_value, this.value
    )
      .then(wpTarget => {
        //console.log(wpTarget);
        this.wpNotificationsService.showSave(this.workPackage);
        this.toggleTargetsCreateForm();

        //TODO: (zbd) доделать обновление таблицы
        this.loadWpTargets();

      })
      .catch(err => {
        this.wpNotificationsService.handleRawError(err, this.workPackage);
        this.toggleTargetsCreateForm();
      });
  }

  public toggleTargetsCreateForm() {
    this.showTargetsCreateForm = !this.showTargetsCreateForm;

    setTimeout(() => {
      if (!this.showTargetsCreateForm) {
        // Reset value
        this.selectedTgId = '';
        this.focusAfterSave.nativeElement.focus();
      }
    });
  }

  private deleteTarget(target: WpTargetResource){
    const path = this.pathHelper.api.v3.work_package_targets.toString() + '/' + target.id;
    const params = {project_id: target.project_id};

    this.confirmDialog.confirm({
      text: this.confirmText,
      closeByEscape: true,
      showClose: true,
      closeByDocument: true,
    }).then(() => {
      this.halResourceService
        .delete(path, params)
        .toPromise()
        .then(wpTarget => {
            this.wpNotificationsService.showSave(this.workPackage);
            this.loadWpTargets();
          }
        )
        .catch(err => {
            this.wpNotificationsService.handleRawError(err, this.workPackage);
          }
        )
      })
      .catch(function () { return false; });
  }


}
