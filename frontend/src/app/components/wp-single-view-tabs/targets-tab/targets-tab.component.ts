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

interface ITargetValues {
  project_id: number;
  target_id: number;
  year: number;
  target_year_value: number;
  target_quarter1_value: number;
  target_quarter2_value: number;
  target_quarter3_value: number;
  target_quarter4_value: number;
  fact_quarter1_value: number;
  fact_quarter2_value: number;
  fact_quarter3_value: number;
  fact_quarter4_value: number;
  plan_quarter1_value: number;
  plan_quarter2_value: number;
  plan_quarter3_value: number;
  plan_quarter4_value: number;
}

interface IError {
  result: boolean;
  text: string;
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
  @ViewChild('monthOfQuarter1') monthOfQuarter1: TemplateRef<any>;
  @ViewChild('monthOfQuarter2') monthOfQuarter2: TemplateRef<any>;
  @ViewChild('monthOfQuarter3') monthOfQuarter3: TemplateRef<any>;
  @ViewChild('monthOfQuarter4') monthOfQuarter4: TemplateRef<any>;
  @ViewChild('quarters') quarters: TemplateRef<any>;

  public workPackage:WorkPackageResource;
  public wpTargets: Array<WpTarget>;
  public wpTargetIds: number[] = [];
  public editedTarget: WpTarget | null;
  
  public showTargetsCreateForm:boolean = false;
  public selectedTgId:string;
  public isDisabled = false;
  public targetCanEdit: boolean;

  public planValues: ITargetValues[] = [];
  public checkErrors: IError[] = [];
  protected readonly appBasePath:string;

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
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
  }

  ngOnInit() {
    this.checkErrors = [];
    this.planValues = [];

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
          this.editedTarget = new WpTarget({id: 0, project_id: this.workPackage.project.getId(),
            work_package_id: Number(this.workPackageId), target_id: 0, year: Number(moment(new Date()).format('YYYY'))})
        }
      );

    this.targetCanEdit = true;
  }

  ngOnDestroy() { // Nothing to do
  }


  /**
   * Загружаем показатели из БД + плановые и фактические значения
   */
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

            let plans = el.planFactQuarterlyTargetValue;
            this.planValues = plans.map( (pl:any) => {
              return {
                project_id: pl.projectId,
                target_id: pl.target_id,
                year: pl.year,
                target_year_value: pl.target_year_value,
                target_quarter1_value: pl.target_quarter1_value,
                target_quarter2_value: pl.target_quarter2_value,
                target_quarter3_value: pl.target_quarter3_value,
                target_quarter4_value: pl.target_quarter4_value,
                fact_quarter1_value: pl.fact_quarter1_value,
                fact_quarter2_value: pl.fact_quarter2_value,
                fact_quarter3_value: pl.fact_quarter3_value,
                fact_quarter4_value: pl.fact_quarter4_value,
                plan_quarter1_value: pl.plan_quarter1_value,
                plan_quarter2_value: pl.plan_quarter2_value,
                plan_quarter3_value: pl.plan_quarter3_value,
                plan_quarter4_value: pl.plan_quarter4_value
              }
            });
            
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
              name: el.target //el.$links.self.title
            });
        });
        //console.log(this.PlanValues)
      })
      .catch(() => {
        return false;
      });
  }

  getTargetFromArr(targetId: number):WpTarget{
    return <WpTarget>this.wpTargets.find(value => { return value.target_id == targetId; });
  }


  private checkPlanOfQuarter(target: WpTarget, plan_value: number, plan_year_value: number): boolean {
    let result = true;
    // квартал без месяца - сравниваем с планом
    if((target.month == 0) || (target.month == null)) {
      // если plan_value != 0 - значит есть записи по месяцам
      if (plan_value != null && target.plan_value < Number(plan_value)) {
        result = false;
        this.checkErrors.push({result: result, text: 'Введенное значение ('+target.plan_value.toString()+') меньше планового значения целевого показателя ('+plan_value.toString()+')'});
      }
      else // иначе если есть годовой план сравниваем с годовым планом
      if ((plan_year_value != null) && (Number(target.plan_value) > Number(plan_year_value))) {
        result = false;
        this.checkErrors.push({result: result, text: 'Введенное значение ('+target.plan_value.toString()+') превышает плановое значение целевого показателя за год ('+plan_year_value.toString()+')'});
      }
    }
    // иначе (месяц != 0) сравниваем с квартальным планом
    else {
      // // ищем показатель за квартал
      // let quartTarg = this.wpTargets.find(value => {
      //   return (value.target_id == target.target_id)
      //     && (value.year == target.year)
      //     && (value.quarter == target.quarter)
      //     && (value.month == null)
      // });
      //
      // // если за квартал значение есть
      // if(quartTarg != undefined) {
      //   if (target.plan_value > quartTarg.plan_value) {
      //     result = false;
      //     this.checkErrors.push({result: result, text: 'Введенное значение ('+target.plan_value.toString()+') превышает плановое значение целевого показателя за '+target.quarter.toString()+'-й квартал ('+quartTarg.plan_value.toString()+')'});
      //   }
      // }
      //else { // иначе сравниваем все таки с планом, если есть
        if(plan_value != null && target.plan_value > plan_value){
          result = false;
          this.checkErrors.push({result: result, text: 'Введенное значение ('+target.plan_value.toString()+') превышает плановое значение целевого показателя за '+target.quarter.toString()+'-й квартал ('+plan_value.toString()+')'});
        }
        else // или с годовым планом, если он есть
          if(plan_year_value != null && target.plan_value > Number(plan_year_value)) {
            result = false;
            this.checkErrors.push({result: result, text: 'Введенное значение ('+target.plan_value.toString()+') превышает плановое значение целевого показателя за год ('+plan_year_value.toString()+')'});
          }
      //}
    }
    return result;
  }

  /**
   * Проверки при добавлении и редактировании записи
   */
  checkTarget(target: WpTarget): boolean {
    let result = true;
    // обнуляем массив ошибок
    this.checkErrors = [];

    if(target.plan_value == 0) {
      result = false;
      this.checkErrors.push({result: result, text: 'Значение не может буть нулевым.'});
    }

    // сверка на наличие записи за период
    if((target.month == null)||(target.month==0)){
      if (this.wpTargets.find(value => {
        return (value.target_id == target.target_id)
          && (value.year == target.year)
          && (value.quarter == target.quarter)
          && (value.month == null)    // когда месяц не указан
          && (value.id != target.id) // не сравниваем с самим собой
      })
      ) {
        result = false;
        this.checkErrors.push({result: result, text: 'Запись за указанный период уже присутствует в базе. Пожалуйста, выберите другой период.'});
      }
    }
    else {
      if (this.wpTargets.find(value => {
        return (value.target_id == target.target_id)
          && (value.year == target.year)
          && (value.quarter == target.quarter)
          && (value.month == target.month) // указан месяц
          && (value.id != target.id) // не сравниваем с самим собой
      })
      ) {
        result = false;
        this.checkErrors.push({result: result, text: 'Запись за указанный период уже присутствует в базе. Пожалуйста, выберите другой период.'});
      }
    }

    // проверка наличия года в плане
    let yearResult = true;
    if(!this.planValues.find(value => { return (value.target_id == target.target_id) && (value.year == target.year) })) {
      yearResult = false;
      this.checkErrors.push({result: yearResult, text: 'Отсутствует плановое значение целевого показателя за '+target.year.toString()+' год.'});
    }

    // сверка с плановыми значениями
    let quartResult = true;
    this.planValues.forEach(plan => {
        // если совпадает id, год
        if((target.target_id == plan.target_id)
          && target.year == plan.year) {

          // указан квартал
          if ((target.quarter != 0 || target.quarter != null)){
            switch (Number(target.quarter)) {
              case 1: {
                // если не с чем сравнивать - ошибка
                if(plan.plan_quarter1_value == null && plan.target_year_value == null ){
                  quartResult = false;
                  this.checkErrors.push({result: quartResult, text: 'Отсутствует плановое значение целевого показателя.'});
                }
                else {
                  quartResult = this.checkPlanOfQuarter(target, plan.plan_quarter1_value, plan.target_year_value);
                }
                break;
              }
              case 2: {
                if(plan.plan_quarter2_value == null && plan.target_year_value == null ){
                  quartResult = false;
                  this.checkErrors.push({result: quartResult, text: 'Отсутствует плановое значение целевого показателя.'});
                }
                else {
                  quartResult = this.checkPlanOfQuarter(target, plan.plan_quarter2_value, plan.target_year_value);
                }
                break;
              }
              case 3: {
                if(plan.plan_quarter3_value == null && plan.target_year_value == null ){
                  quartResult = false;
                  this.checkErrors.push({result: quartResult, text: 'Отсутствует плановое значение целевого показателя.'});
                }
                else {
                  quartResult = this.checkPlanOfQuarter(target, plan.plan_quarter3_value, plan.target_year_value);
                }
                break;
              }
              case 4: {
                if(plan.plan_quarter4_value == null && plan.target_year_value == null ){
                  quartResult = false;
                  this.checkErrors.push({result: quartResult, text: 'Отсутствует плановое значение целевого показателя.'});
                }
                else {
                  quartResult = this.checkPlanOfQuarter(target, plan.plan_quarter4_value, plan.target_year_value);
                }
                break;
              }
              default: {
                // не указан квартал - сравниваем с годовым значение плана
                if (target.plan_value > plan.target_year_value) {
                  yearResult = false;
                  this.checkErrors.push({result: yearResult, text: 'Введенное плановое значение ('+target.plan_value.toString()+') превышает плановое значение целевого показателя за год ('+plan.target_year_value.toString()+')'});
                }
              }
            }
          }
          else {
            // не указан квартал - сравниваем с годовым значение плана
            if(plan.target_year_value != null) {
              if (plan.target_year_value != null && target.plan_value > plan.target_year_value) {
                result = false;
                this.checkErrors.push({
                  result: result,
                  text: 'Введенное плановое значение (' + target.plan_value.toString() + ') превышает плановое значение целевого показателя за год (' + plan.target_year_value.toString() + ')'
                });
              }
            }
            else {
              result = false;
              this.checkErrors.push({
                result: result,
                text: 'Отсутствует плановое значение целевого показателя за год.'
              });
            }
          }
        }
      }
    );

    // если есть ошибки - выводим все
    result = result && quartResult && yearResult;
    if(result == false) {
      let errors = '';
      this.checkErrors.forEach((value, ind) => {
        if(this.checkErrors.length > 1) {
          errors = errors + (ind + 1).toString() + '. ' + value.text + '\n'
        }
        else {
          errors = errors + value.text + '\n'
        }
      })
      alert(errors);
    }
    return result;
  }

  /**
   * При нажатии на "Добавить .."
   */
  public createTarget() {
    if (!this.selectedTgId) {
      return;
    }

    if(this.checkTarget(<WpTarget>this.editedTarget)) {
      this.isDisabled = true;
      this.createCommonTarget()
        .catch(() => this.isDisabled = false)
        .then(() => this.isDisabled = false);
    }
  }

  /**
   * Действия при редактировании записи
   */
  updateTarget(target: WpTarget){
    if(this.checkTarget(target)) {
      this.saveWpTarget(target)
        .then(() => {
          this.loadWpTargets();
          this.editedTarget = null;
        })
        .catch(err => {
          this.wpNotificationsService.handleRawError(err, this.workPackage);
        });
    }
  }

  public updateSelectedId(targetId:string) {
    this.selectedTgId = targetId;
    (<WpTarget>this.editedTarget).target_id = Number(targetId);
  }

  protected createCommonTarget() {
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
      target_id: target.target_id,
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
      .toPromise();
  }

  public editTarget(el: WpTarget){
    this.editedTarget = new WpTarget({id: el.id,
      project_id: el.project_id,
      work_package_id: el.work_package_id,
      target_id: el.target_id,
      year: el.year,
      quarter: el.quarter,
      month: el.month,
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

  loadTemplateMonth(quarter: number){
    switch (Number(quarter)) {
      case 1: return this.monthOfQuarter1;
      case 2: return this.monthOfQuarter2;
      case 3: return this.monthOfQuarter3;
      case 4: return this.monthOfQuarter4;
      default: return 0;
    }
  }

  changeQuarter(){
    (<WpTarget>this.editedTarget).month = 0;
    return this.quarters;
  }

  public getAppBasePath():string {
    return this.appBasePath;
  }

}
