import {Component, ElementRef, Input, OnDestroy, OnInit, ViewChild} from '@angular/core';
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {I18nService} from 'core-app/modules/common/i18n/i18n.service';
import {WorkPackageRelationsService} from "core-components/wp-relations/wp-relations.service";
import {WorkPackageNotificationService} from "core-components/wp-edit/wp-notification.service";
import {WorkPackageCacheService} from "core-components/work-packages/work-package-cache.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {takeUntil} from "rxjs/operators";
import {componentDestroyed} from "ng2-rx-componentdestroyed";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {LoadingIndicatorService} from "core-app/modules/common/loading-indicator/loading-indicator.service";
import {WpTargetsService} from "core-components/wp-target/wp-targets.service";
import {TargetResource} from "core-app/modules/hal/resources/target-resource";

@Component({
  selector: 'wp-target-create',
  templateUrl: './wp-target-create.html',
})
export class WpTargetCreateComponent implements OnInit, OnDestroy {
  @Input() readonly workPackage:WorkPackageResource;
  //@Input() readonly targets: any;

  @ViewChild('focusAfterSave') readonly focusAfterSave:ElementRef;

  public showTargetsCreateForm:boolean = false;
  public selectedTgId:string;
  public isDisabled = false;
  public year: number;
  public quarter: number;
  public month: number;
  public plan_value: number;
  public value: number;

  public text = {
    save: this.I18n.t('js.target_buttons.save'),
    abort: this.I18n.t('js.target_buttons.abort'),
    addNewTarget: this.I18n.t('js.target_buttons.add_new_target')
  };

  constructor(readonly I18n:I18nService,
              protected wpTargetsService:WpTargetsService,
              protected wpNotificationsService:WorkPackageNotificationService,
              protected wpCacheService:WorkPackageCacheService,
              readonly loadingIndicator:LoadingIndicatorService,
              readonly pathHelper:PathHelperService) {
  }

  ngOnInit() {
  }

  ngOnDestroy(): void {
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
        console.log(wpTarget);
        this.wpNotificationsService.showSave(this.workPackage);
        this.toggleTargetsCreateForm();
        //TODO: (zbd) доделать обновление таблицы
        this.wpTargetsService.getWpTargets(this.workPackage.id);
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


}
