import {Component, ElementRef, Input, OnDestroy, OnInit, TemplateRef, ViewChild} from '@angular/core';
import {TimezoneService} from "core-components/datetime/timezone.service";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {takeUntil} from "rxjs/operators";
import {componentDestroyed} from "ng2-rx-componentdestroyed";
import {Transition} from "@uirouter/core";
import {WorkPackageCacheService} from "core-components/work-packages/work-package-cache.service";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {UserResource} from "core-app/modules/hal/resources/user-resource";
import {WorkPackageNotificationService} from "core-components/wp-edit/wp-notification.service";
import {ConfirmDialogService} from "core-components/modals/confirm-dialog/confirm-dialog.service";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";

export interface typeArr {
  name: string;
}

let PROBLEM_TYPE: typeArr[] = [{name: 'problem'}, {name: 'risk'}];
let SOLUTION_TYPE: typeArr[] = [{name: 'created'}, {name: 'solved'}];

export class WpProblem {

  // properties
  public id: number;
  public project_id: number;
  public work_package_id: number;
  public risk_id: number;
  public name: string;
  public problem_type: string;
  public user_creator_id: number;
  public user_source_id: number;
  public organization_source_id: number;
  public user_creator: UserResource | undefined;
  public description: string;
  public status: string;
  public solution_date: string;

  constructor(parameters: {
    id: number, project_id: number, work_package_id: number, risk_id: number, name: string, problem_type?: string, user_creator_id?: number, user_source_id?: number, organization_source_id?: number, description?: string, status?: string, solution_date?: string,
    user?: UserResource
  }) {
    let {id, project_id, work_package_id, risk_id, name, problem_type = PROBLEM_TYPE[0].name, user_creator_id = 0, user_source_id = 0, organization_source_id = 0, description = '', status = '', solution_date = '', user = undefined} = parameters;

    this.id = id;
    this.project_id = project_id;
    this.work_package_id = work_package_id;
    this.risk_id = risk_id;
    this.name = name;
    this.user_creator_id = user_creator_id;
    this.user_source_id = user_source_id;
    this.organization_source_id = organization_source_id;
    this.problem_type = problem_type;

    if (user_creator_id !== 0) {
      this.user_creator = user;
    }

    this.description = description;
    this.status = status;
    if (solution_date.length !== 0) {
      this.solution_date = solution_date;
    }
  }
}


@Component({
  selector: 'problems-tab',
  templateUrl: './problems-tab.component.html',
  styleUrls: ['./problems-tab.component.sass'],
})

export class WorkPackageProblemsTabComponent implements OnInit, OnDestroy {
  @Input() public workPackageId: string;
  @ViewChild('focusAfterSave') readonly focusAfterSave: ElementRef;
  @ViewChild('readOnlyTemplate') readOnlyTemplate: TemplateRef<any>;
  @ViewChild('editTemplate') editTemplate: TemplateRef<any>;
  @ViewChild('readOnlyTemplate2') readOnlyTemplate2: TemplateRef<any>;
  @ViewChild('editTemplate2') editTemplate2: TemplateRef<any>;

  public workPackage: WorkPackageResource;
  public wpProblems: Array<WpProblem>;
  public wpProblem: WpProblem | null;
  public wpContract:any;
  public editedProblem: WpProblem | null;


  public wpContracts: any;
  public showProblemCreateForm:boolean = false;
  public showContractCreateForm:boolean = false;
  public selectedId: string;
  public isDisabled = false;
  problemCanEdit: boolean;

  public orgs = new Map;
  public users = new Map;
  public risks = new Map;
  public contracts:any;

  public text = {
    problems_header: this.I18n.t('js.work_packages.tabs.problems'),
    addNewProblem: this.I18n.t('js.problem_buttons.add_new_problem'),
    save: this.I18n.t('js.target_buttons.save'),
    abort: this.I18n.t('js.target_buttons.abort'),
    edit: this.I18n.t('js.problem_buttons.edit_problem'),
    placeholder: this.I18n.t('js.target_buttons.placeholder'),
    removeButton: this.I18n.t('js.problem_buttons.delete_problem')
  };

  public confirmText = {
    title: 'Удаление',
    text: 'Вы действительно хотите удалить эту запись?',
    button_continue: 'Да'
  };

  problem_type = 'problem';

  constructor(readonly timezoneService: TimezoneService,
              protected I18n: I18nService,
              protected wpNotificationsService: WorkPackageNotificationService,
              readonly notificationsService:NotificationsService,
              protected halResourceService: HalResourceService,
              readonly $transition: Transition,
              readonly wpCacheService: WorkPackageCacheService,
              protected confirmDialog: ConfirmDialogService,
              protected pathHelper: PathHelperService) {

    this.wpProblems = new Array<WpProblem>();
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

    this.loadWpProblems(this.workPackageId);
    this.loadWPContracts();
    this.loadContracts();
    this.loadOrgs();
    this.loadUsers();
    this.loadRisks();

    this.isDisabled = false;

    //TODO (zbd) возможно здесь доавить проверку
    this.problemCanEdit = true;
  }

  ngOnDestroy():void {
  }

  /** Загружает данные по проблемам мероприятия
   * */
  public loadWpProblems(workPackageId:string) {
    return this.halResourceService.get<CollectionResource<HalResource>>(
      this.pathHelper.api.v3.work_package_problems.toString(), {'work_package_id': workPackageId} )
      .toPromise()
      .then((collection:CollectionResource<HalResource>) => {
        this.wpProblems = collection.elements.map(el => {
          return new WpProblem(
            {
              id: Number(el.getId()),
              project_id: el.projectId,
              work_package_id: el.workPackageId,
              risk_id: el.riskId,
              name: el.name,
              problem_type: el.type,
              user_creator_id: el.userCreatorId,
              organization_source_id: el.organizationSourceId,
              user_source_id: el.userSourceId,
              status: el.status,
              solution_date: el.solutionDate,
              description: el.description
            });
        });
        }
      )
      .catch((err) => {
        this.wpNotificationsService.handleRawError(err, this.workPackage);
      });
  }

  private loadOrgs() {
    return this.halResourceService.get<CollectionResource<HalResource>>(
      this.pathHelper.api.v3.organizations.toString())
      .toPromise()
      .then((collection:CollectionResource<HalResource>) => {
        this.orgs.set(0, '');
        collection.elements.forEach(el => {
            this.orgs.set(Number(el.getId()), el.name);
          }
        );
      });
  }

  private loadUsers() {
    return this.halResourceService.get<CollectionResource<HalResource>>(
      this.pathHelper.api.v3.users.toString())
      .toPromise()
      .then((collection:CollectionResource<HalResource>) => {
          this.users.set(0, '');
          collection.elements.forEach(el => {
              this.users.set(Number(el.getId()), el.name);
            }
          );
        }
      );
  }

  private loadRisks() {
    return this.halResourceService.get<CollectionResource<HalResource>>(
      this.pathHelper.api.v3.project_risks.toString(), {project_id: this.workPackage.project.id})
      .toPromise()
      .then((collection: CollectionResource<HalResource>) => {
          collection.elements.forEach(el => {
              this.risks.set(Number(el.getId()), el.name);
            }
          );
          //console.log(this.risks)
        }
      );
  }

  /** Добавляет новую запись в wp_problems
   * */
  private addNewProblem(problem: WpProblem) {
    if (problem.problem_type === 'problem') {
      problem.risk_id = 0;
    }

    const path = this.pathHelper.api.v3.work_package_problems.toString();
    const params = {
      project_id: problem.project_id, work_package_id: problem.work_package_id, risk_id: problem.risk_id,
      user_creator_id: problem.user_creator_id, organization_source_id: problem.organization_source_id,
      description: problem.description, status: 'created', type: problem.problem_type,
      user_source_id: problem.user_source_id
    };
    return this.halResourceService
      .post<HalResource>(path, params)
      .toPromise();
  }


  /** Изменяет запись
   * */
  public saveWpProblem(problem: WpProblem) {
    const path = this.pathHelper.api.v3.work_package_problems.toString() + '/' + problem.id;
    const params = {
      project_id: problem.project_id, work_package_id: problem.work_package_id, risk_id: problem.risk_id,
      user_creator_id: problem.user_creator_id, organization_source_id: problem.organization_source_id,
      description: problem.description, status: problem.status, type: problem.problem_type,
      user_source_id: problem.user_source_id, solution_date: problem.solution_date
    };

    if (problem.problem_type === 'problem') {
      problem.risk_id = 0;
    }

    if (problem.status === 'solved' && problem.solution_date === undefined) {
      this.wpNotificationsService.handleRawError('Для статуса "Решено" необходимо наличие даты решения', this.workPackage);
      return false;
    }
    if (problem.status === 'created' && (problem.solution_date !== undefined && problem.solution_date !== '')) {
      this.wpNotificationsService.handleRawError('Дата решения может устанавливается только для статуса "Решено"', this.workPackage);
      return false;
    }

    return this.halResourceService
      .patch<HalResource>(path, params)
      .toPromise()
      .then(() => {
        this.loadWpProblems(this.workPackageId);
        this.editedProblem = null;
      })
      .catch(err => {
        this.wpNotificationsService.handleRawError(err, this.workPackage);
      });
  }

  public editProblem(problem: WpProblem) {
    this.editedProblem = new WpProblem({
      id: problem.id, project_id: problem.project_id,
      work_package_id: Number(this.workPackageId), risk_id: problem.risk_id, name: problem.name,
      problem_type: problem.problem_type, status: problem.status,
      user_source_id: problem.user_source_id, organization_source_id: problem.organization_source_id,
      description: problem.description, solution_date: problem.solution_date,
      user_creator_id: problem.user_creator_id
    });
  }

  public cancelEdit() {
    this.editedProblem = null;
  }

  /** загружаем один из двух шаблонов
   */
  loadTemplate(problem: WpProblem) {
    if (this.editedProblem && this.editedProblem.id === problem.id) {
      return this.editTemplate2;
    } else {
      return this.readOnlyTemplate2;
    }
  }


  /** по нажатию на кнопку Сохранить
   * */
  public createProblem() {
    // if (!this.selectedId) {
    //   return;
    // }

    if (!this.checkForm(<WpProblem>this.wpProblem)) {
      return;
    }
    this.isDisabled = true;
    this.createCommonProblem()
      .catch(() => this.isDisabled = false)
      .then(() => this.isDisabled = false);
  }

  // public updateSelectedId(targetId:string) {
  //   this.selectedId = targetId;
  // }

  /** Добавляет запись и скрывает блок ввода
   * */
  protected createCommonProblem() {
    return this.addNewProblem(<WpProblem>this.wpProblem)
      .then(() => {
        this.wpNotificationsService.showSave(this.workPackage);

        //TODO: (zbd) доделать обновление таблицы
        this.loadWpProblems(this.workPackage.id);

        this.toggleProblemCreateForm();
      })
      .catch((err:any) => {
        this.wpNotificationsService.handleRawError(err, this.workPackage);
        this.toggleProblemCreateForm();
      });
  }

  public toggleProblemCreateForm() {
    if (this.showProblemCreateForm) {
      // Reset value
      this.wpProblem = null;
      this.selectedId = '';
    } else {
      this.wpProblem = new WpProblem({
        id: 0, project_id: this.workPackage.project.getId(),
        work_package_id: Number(this.workPackageId), risk_id: 0, name: ''
      });
      //console.log(this.wpProblem);
    }
    this.showProblemCreateForm = !this.showProblemCreateForm;
  }

  public handleButtonSave(componentName: string) {
    console.log('[problems-tab.component.ts].handleButtonSave() componentName:', componentName);
    if (componentName === 'problem') {
      if (this.wpProblem) {
        if (this.wpProblem.description.length === 0) {
          this.isDisabled = true;
        } else {
          this.isDisabled = false;
        }
      } else {
        this.isDisabled = true;
      }
    } else {
      this.isDisabled = false;
    }
  }

  private deleteProblem(problem:WpProblem) {
    const path = this.pathHelper.api.v3.work_package_problems.toString() + '/' + problem.id;
    const params = {project_id: problem.project_id};
    //const params = new HttpParams().set('project_id', problem.project_id.toString());
    this.confirmDialog.confirm({
      text: this.confirmText,
      closeByEscape: true,
      showClose: true,
      closeByDocument: true,
    }).then(() => {
      this.halResourceService
        .delete(path, params)
        .toPromise()
        .then(wpProblem => {
            this.wpNotificationsService.showSave(this.workPackage);
            this.wpProblems.splice(this.wpProblems.indexOf(problem), 1);
          }
        )
        .catch(err => {
            this.wpNotificationsService.handleRawError(err, this.workPackage);
          }
        );
    })
      .catch(function () {
        return false;
      });
  }

  /**
   * Проверки при добавлении и редактировании записи
   */
  checkForm(wpProblem: WpProblem): boolean {
    let isVaslid = true;
    // обнуляем массив ошибок
    let checkErrors = [];

    if (wpProblem.problem_type === 'problem') {
      if (wpProblem) {
        if (wpProblem.description.length === 0) {
          isVaslid = false;
          checkErrors.push({result: isVaslid, text: 'Описание не может быть пустым.'});
        }
      } else {
        isVaslid = false;
        checkErrors.push({result: isVaslid, text: 'Заполните все поля.'});
      }
    }

    if (wpProblem.problem_type === 'risk') {
      if (wpProblem) {
        if (!wpProblem.risk_id) {
          isVaslid = false;
          checkErrors.push({result: isVaslid, text: 'Поле риск не может быть пустым.'});
        }
      } else {
        isVaslid = false;
        checkErrors.push({result: isVaslid, text: 'Заполните все поля.'});
      }
    }


    // если есть ошибки - выводим все
    if (isVaslid === false) {
      let errors = '';
      checkErrors.forEach((value, ind) => {
        if (checkErrors.length > 1) {
          errors = errors + (ind + 1).toString() + '. ' + value.text + '\n';
        } else {
          errors = errors + value.text + '\n';
        }
      });
      alert(errors);
    }
    return isVaslid;
  }

  private loadWPContracts() {
    this.halResourceService.get<CollectionResource<HalResource>>(
      this.pathHelper.api.v3.work_package_contracts.toString(), {'work_package_id': this.workPackageId}
    ).toPromise().then((response) => {
      this.wpContracts = response.elements;
    }).catch((error) => {
      this.wpNotificationsService.handleRawError(error);
    });
  }

  private loadContracts() {
    this.halResourceService.get<CollectionResource<HalResource>>(
      this.pathHelper.api.v3.project_contracts.toString(), {project_id: this.workPackage.project.id})
      .toPromise()
      .then((collection:CollectionResource<HalResource>) => {
          this.contracts = collection.elements;
        }
      ).catch((error) => {
      this.wpNotificationsService.handleRawError(error);
    });
  }

  toggleContractAddForm(contract?:any) {
    if (this.showContractCreateForm) {
      this.wpContract = null;
    } else {
      this.wpContract = {id: contract.idFromLink,
        comment: '' || contract.comment,
        contract_id: contract.contract.idFromLink || null,
        work_package_id: contract.workPackage.idFromLink || this.workPackageId};
    }
    this.showContractCreateForm = !this.showContractCreateForm;
  }

  createContract() {
    this.halResourceService.post<CollectionResource<HalResource>>(
      this.pathHelper.api.v3.work_package_contracts.toString(),
      {contract_id: this.wpContract.contract_id,
        work_package_id: this.wpContract.work_package_id,
        comment: this.wpContract.comment})
      .toPromise()
      .then((collection:CollectionResource<HalResource>) => {
        this.toggleContractAddForm();
          this.loadWPContracts();
        }
      ).catch((error) => {
      this.wpNotificationsService.handleRawError(error);
    });
  }

  editContract() {
    this.halResourceService.patch<HalResource>(
      `/api/v3/work_package_contracts/${this.wpContract.id}`,
      {contract_id: this.wpContract.contract_id,
        work_package_id: this.wpContract.work_package_id,
        comment: this.wpContract.comment})
      .toPromise()
      .then((collection:CollectionResource<HalResource>) => {
          this.toggleContractAddForm();
          this.notificationsService.addSuccess('Успешно удалено');
          this.loadWPContracts();
        }
      ).catch((error) => {
      this.wpNotificationsService.handleRawError(error);
    });
  }

  deleteContract(contract:any) {
    contract.delete().then(() => {
      this.notificationsService.addSuccess('Успешно удалено');
      this.loadWPContracts();
    }).catch((error:any) => {
      this.wpNotificationsService.handleRawError(error);
    });
  }
}
