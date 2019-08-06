import {Component, ElementRef, Input, OnDestroy, OnInit, TemplateRef, ViewChild} from '@angular/core';
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {takeUntil} from "rxjs/operators";
import {componentDestroyed} from "ng2-rx-componentdestroyed";
import {Transition} from "@uirouter/core";
import {WorkPackageCacheService} from "core-components/work-packages/work-package-cache.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {WorkPackageNotificationService} from "core-components/wp-edit/wp-notification.service";
import {ConfirmDialogService} from "core-components/modals/confirm-dialog/confirm-dialog.service";
import {LoadingIndicatorService} from "core-app/modules/common/loading-indicator/loading-indicator.service";
import {convertValueToOutputAst} from "@angular/compiler/src/output/value_util";
import {el} from "@angular/platform-browser/testing/src/browser_util";

export class WpTarget {

  public id: number;
  public project_id: number;
  public work_package_id: number;
  public target_id: number;
  public year: number;
  public quarter: number;
  public month: number;
  public plan_value: number;
  public value: number;
  public name: string;

  constructor (parameters: { id: number, project_id: number, work_package_id: number, target_id: number, year: number, quarter?: number,
    month?: number , plan_value?: number , value?: number , name?: string})
  {
    let {id, project_id, work_package_id, target_id, year, quarter = 0, month = 0, plan_value = 0, value = 0, name = ''} = parameters;

    this.id = id;
    this.project_id = project_id;
    this.work_package_id = work_package_id;
    this.target_id = target_id;
    this.year = year;
    this.quarter = quarter;
    this.month = month;
    this.plan_value = plan_value;
    this.value = value;
    this.name = name;
  }

}

@Component({
  selector: 'wp-targets-tab',
  templateUrl: './targets-tab.html'
})
export class WorkPackageTargetsTabComponent implements OnInit, OnDestroy {
  @Input() public workPackageId:string;
  @ViewChild('focusAfterSave') readonly focusAfterSave:ElementRef;
  @ViewChild('readOnlyTemplate2') readOnlyTemplate: TemplateRef<any>;
  @ViewChild('editTemplate2') editTemplate: TemplateRef<any>;

  public workPackage:WorkPackageResource;
  public wpTargets: Array<WpTarget>;
  public wpTargetIds: number[] = [];
  public editedTarget: WpTarget | null;
  
  public showTargetsCreateForm:boolean = false;
  public selectedTgId:string;
  public isDisabled = false;
  public targetCanEdit: boolean;

  public text = {
    targets_header: this.I18n.t('js.work_packages.tabs.targets'),
    save: this.I18n.t('js.target_buttons.save'),
    abort: this.I18n.t('js.target_buttons.abort'),
    edit: this.I18n.t('js.problem_buttons.edit_problem'),
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
                     protected wpNotificationsService:WorkPackageNotificationService,
                     readonly loadingIndicator:LoadingIndicatorService,
                     readonly wpCacheService:WorkPackageCacheService,
                     protected pathHelper:PathHelperService,
                     protected confirmDialog: ConfirmDialogService,
                     protected halResourceService: HalResourceService)
  {
    this.wpTargets = new Array<WpTarget>();
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

    this.loadWpTargets()
      .then(()=>{
        console.log(this.wpTargets);
        console.log(this.wpTargetIds);
        console.log('getTargetFromArr: ' + this.getTargetFromArr(1));
      });

    //TODO (zbd) возможно здесь доавить проверку
    this.targetCanEdit = true;

  }

  ngOnDestroy() {
    // Nothing to do
  }

  public loadWpTargets(){
    return this.halResourceService
      .get<HalResource>(this.pathHelper.api.v3.work_package_targets.toString(), {'work_package_id': this.workPackageId})
      .toPromise()
      .then((resource:HalResource) => {
        let els = resource.elements;
        this.wpTargets = els.map( (el:any) => {
            if(this.wpTargetIds.indexOf(Number(el.targetId)) === -1){
              this.wpTargetIds.push(el.targetId);
            }
            return new WpTarget({
              id: el.getId(),
              project_id: el.projectId,
              work_package_id: el.workPackageId,
              target_id: el.targetId,
              year: el.year,
              quarter: el.quarter,
              month: el.month,
              plan_value: el.planValue,
              value: el.value,
              name: el.$links.self.title
            })
          }
        );
        //console.log(this.wpTargets)
      })
      .catch(() => {
        return false;
      });
  }

  getTargetFromArr(targetId: number):WpTarget{
    // let t: WpTarget;
    // this.wpTargets.forEach((target) => {
    //   if (target.target_id == targetId) {
    //     console.log(target.target_id + ' ' + target.name);
    //     return t = target;
    //   } else {
    //     return -1;
    //   }
    // });
    // return t;

    return <WpTarget>this.wpTargets.find(value => { return value.target_id == targetId; });
  }

  public createTarget() {

    if (!this.selectedTgId) {
      return;
    }

    this.isDisabled = true;
    this.createCommonTarget()
      .catch(() => this.isDisabled = false)
      .then(() => this.isDisabled = false);
  }

  public updateSelectedId(targetId:string) {
    this.selectedTgId = targetId;
    //this.editedTarget.target_id = Number(this.selectedTgId);
  }

  protected createCommonTarget() {
    //this.editedTarget.target_id = Number(this.selectedTgId);
    return this.addWpTarget(<WpTarget>this.editedTarget)
      .then(() => {
        this.wpNotificationsService.showSave(this.workPackage);
        this.toggleTargetsCreateForm();
        this.loadWpTargets();
      })
      .catch((err:any) => {
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
        this.editedTarget = null;
      }
      else {
        this.editedTarget = new WpTarget({id: 0, project_id: this.workPackage.project.getId(),
          work_package_id: Number(this.workPackageId), target_id: 0, year: Number(moment(new Date()).format('YYYY'))})
      }
    });
  }

  /**
   * Удаляет запись
   * @param target
   */
  private deleteTarget(target: WpTarget){
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


  /** Добавляет новую запись в work_package_targets
   * */
  addWpTarget(target: WpTarget){
    const params = {project_id: target.project_id, work_package_id: this.workPackageId,
      target_id: this.selectedTgId /*target.target_id*/,
      year: target.year,
      quarter: target.quarter == 0 ? null : target.quarter,
      month: target.month == 0 ? null : target.month,
      plan_value: target.plan_value,
      value: target.value == 0 ? null : target.value
    };
    const path = this.pathHelper.api.v3.work_package_targets.toString();
    return this.halResourceService
      .post<HalResource>(path, params)
      .toPromise();
  }


  /** Изменяет запись
   * */
  public saveWpTarget(target: WpTarget){
    const path = this.pathHelper.api.v3.work_package_targets.toString() + '/' + target.id;
    const params = {       //target_id: this.selectedTgId /*target.target_id*/,
      year: target.year,
      quarter: target.quarter == 0 ? null : target.quarter,
      month: target.month == 0 ? null : target.month,
      plan_value: target.plan_value,
      value: target.value == 0 ? null : target.value
    };
    return this.halResourceService
      .patch<HalResource>(path, params)
      .toPromise()
      .then(() => {
        this.loadWpTargets();
        this.editedTarget = null;
      })
      .catch(err => {
        this.wpNotificationsService.handleRawError(err, this.workPackage);
      });
  }

  public editTarget(el: WpTarget){
    this.editedTarget = new WpTarget({id: el.id,
      project_id: el.project_id,
      work_package_id: el.work_package_id,
      target_id: el.target_id,
      year: el.year,
      quarter: el.quarter,
      plan_value: el.plan_value,
      value: el.value,
      name: el.name});
  }

  public cancelEdit(){
    this.editedTarget = null;
  }

  /** загружаем один из двух шаблонов
   */
  loadTemplate(target: WpTarget) {
    if (this.editedTarget && this.editedTarget.id == target.id) {
      return this.editTemplate;
    } else {
      return this.readOnlyTemplate;
    }
  }

}
