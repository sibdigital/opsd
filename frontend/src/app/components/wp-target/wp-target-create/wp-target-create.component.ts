import {Component, ElementRef, Input, OnDestroy, OnInit, ViewChild} from '@angular/core';
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {I18nService} from 'core-app/modules/common/i18n/i18n.service';
import {WorkPackageRelationsService} from "core-components/wp-relations/wp-relations.service";
import {WorkPackageNotificationService} from "core-components/wp-edit/wp-notification.service";
import {WorkPackageCacheService} from "core-components/work-packages/work-package-cache.service";

@Component({
  selector: 'wp-target-create',
  templateUrl: './wp-target-create.html',
})
export class WpTargetCreateComponent implements OnInit, OnDestroy {
  @Input() readonly workPackage:WorkPackageResource;
  @ViewChild('focusAfterSave') readonly focusAfterSave:ElementRef;

  public showTargetsCreateForm:boolean = false;
  public selectedWpId:string;

  public isDisabled = false;

  public text = {
    save: this.I18n.t('js.target_buttons.save'),
    abort: this.I18n.t('js.target_buttons.abort'),
    addNewTarget: this.I18n.t('js.target_buttons.add_new_target')
  };

  constructor(readonly I18n:I18nService,
              protected wpRelations:WorkPackageRelationsService,
              protected wpNotificationsService:WorkPackageNotificationService,
              protected wpCacheService:WorkPackageCacheService) {
  }

  ngOnInit() {
  }

  ngOnDestroy(): void {
  }

  public createTarget() {

    if (!this.selectedWpId) {
      return;
    }

    this.isDisabled = true;
    // this.createCommonTarget()
    //   .catch(() => this.isDisabled = false)
    //   .then(() => this.isDisabled = false);
  }

  public updateSelectedId(workPackageId:string) {
    this.selectedWpId = workPackageId;
  }

  protected createCommonTarget() {
    return true;
    // return this.wpRelations.addCommonRelation(this.workPackage.id,
    //   this.selectedWpId)
    //   .then(relation => {
    //     this.wpNotificationsService.showSave(this.workPackage);
    //     this.toggleRelationsCreateForm();
    //   })
    //   .catch(err => {
    //     this.wpNotificationsService.handleRawError(err, this.workPackage);
    //     this.toggleRelationsCreateForm();
    //   });
  }

  public toggleTargetsCreateForm() {
    this.showTargetsCreateForm = !this.showTargetsCreateForm;

    setTimeout(() => {
      if (!this.showTargetsCreateForm) {
        // Reset value
        this.selectedWpId = '';
        this.focusAfterSave.nativeElement.focus();
      }
    });
  }


}
