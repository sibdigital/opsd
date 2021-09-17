import {Component, Input, OnDestroy, OnInit} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {Transition} from "@uirouter/core";
import {takeUntil} from "rxjs/operators";
import {componentDestroyed} from "ng2-rx-componentdestroyed";
import {WorkPackageCacheService} from "core-components/work-packages/work-package-cache.service";
import {WorkPackageResource} from "core-app/modules/hal/resources/work-package-resource";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {WorkPackageNotificationService} from "core-components/wp-edit/wp-notification.service";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";

@Component({
  selector: 'contracts-tab',
  templateUrl: './contracts-tab.component.html',
  styleUrls: ['./contracts-tab.component.sass'],
})
export class WorkPackageContractsTabComponent implements OnInit, OnDestroy {
  @Input() public workPackageId:string;

  public showContractCreateForm:boolean = false;
  public wpContracts:any;
  public wpContract:any;
  public contracts:any;
  public isDisabled = false;
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
  public workPackage:WorkPackageResource;
  constructor(protected I18n:I18nService,
              readonly $transition:Transition,
              readonly wpCacheService:WorkPackageCacheService,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService,
              protected wpNotificationsService:WorkPackageNotificationService,
              readonly notificationsService:NotificationsService) {
  }

  ngOnInit():void {
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
    this.loadWPContracts();
    this.loadContracts();
    this.isDisabled = false;
  }

  ngOnDestroy():void {}

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
      this.wpContract = {
        id: contract ? contract.idFromLink : null,
        comment: contract ? contract.comment : '',
        contract_id: contract ?  contract.contract.idFromLink : null,
        work_package_id: contract ?  contract.workPackage.idFromLink : this.workPackageId
      };
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
