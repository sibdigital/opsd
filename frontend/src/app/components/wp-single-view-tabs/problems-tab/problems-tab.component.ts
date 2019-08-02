import {Component, ElementRef, Input, OnDestroy, OnInit, ViewChild} from '@angular/core';
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
import {WpTargetResource} from "core-app/modules/hal/resources/wp-target-resource";
import {WorkPackageNotificationService} from "core-components/wp-edit/wp-notification.service";

enum ProblemType {Problem, Risk};

export class WpProblem {
  // properties
  public project_id: number;
  public work_package_id: number;
  public risk_id: number;
  public name: string;
  public type: ProblemType;

  public user_creator_id: number;
  public user_source_id: number;
  public organization_source_id: number;

  public user_creator: UserResource | undefined;
  // public user_source: UserResource;
  // public organization_source: HalResource;

  public description: string;
  public status: string;
  public solution_date: string;

  constructor (parameters: { project_id: number, work_package_id: number, risk_id: number, name: string, type?: ProblemType, user_creator_id?: number, user_source_id?: number, organization_source_id?: number, description?: string, status?: string, solution_date?: string,
      user?: UserResource}){
    let {project_id, work_package_id, risk_id, name, type = 0, user_creator_id = 0, user_source_id = 0, organization_source_id = 0, description = '', status = '', solution_date = '', user = undefined} = parameters;
    this.project_id = project_id;
    this.work_package_id = work_package_id;
    this.risk_id = risk_id;
    this.name = name;
    this.user_creator_id = user_creator_id;
    this.user_source_id = user_source_id;
    this.organization_source_id = organization_source_id;

    if(user_creator_id != 0) this.user_creator = user;

    this.description = description;
    this.status = status;
    if(solution_date.length != 0) this.solution_date = solution_date;
  }
}


@Component({
  selector: 'problems-tab',
  templateUrl: './problems-tab.component.html',
  styleUrls: ['./problems-tab.component.sass'],

})
export class WorkPackageProblemsTabComponent implements OnInit, OnDestroy {
  @Input() public workPackageId:string;
  @Input() public workPackage:WorkPackageResource;
  @ViewChild('focusAfterSave') readonly focusAfterSave:ElementRef;

  //public workPackage:WorkPackageResource;
  public wpProblems:Array<WpProblem>;
  public wpProblem: WpProblem;

  public showProblemCreateForm:boolean = false;
  public selectedId:string;
  public isDisabled = false;

  public orgs = new Map;
  public users = new Map;

  public text = {
    problems_header: this.I18n.t('js.work_packages.tabs.problems'),
    addNewProblem: this.I18n.t('js.problem_buttons.add_new_problem'),
    save: this.I18n.t('js.target_buttons.save'),
    abort: this.I18n.t('js.target_buttons.abort'),
    placeholder: this.I18n.t('js.target_buttons.placeholder')
  };

  constructor(readonly timezoneService:TimezoneService,
              protected I18n:I18nService,
              protected wpNotificationsService:WorkPackageNotificationService,
              protected halResourceService:HalResourceService,
              readonly $transition:Transition,
              readonly wpCacheService:WorkPackageCacheService,
              protected pathHelper:PathHelperService) {

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
    this.loadOrgs();
    this.loadUsers();

  }

  ngOnDestroy(): void {
  }


  public loadWpProblems(workPackageId:string) {
    return this.halResourceService.get<CollectionResource<HalResource>>(
      this.pathHelper.api.v3.work_package_problems.toString(), {'work_package_id': workPackageId} )
      .toPromise()
      .then((collection:CollectionResource<HalResource>) => {
        this.wpProblems = collection.elements.map(el => {
          //let user_creator :UserResource;
          //this.userDmService.load(el.user_creator_id).then((resource:UserResource) => {user_creator = resource; return user_creator;})
          return new WpProblem(
            {project_id: el.projectId, work_package_id: el.workPackageId, risk_id: el.riskId, name: el.name})
          })
        }
      );
  }

  private loadOrgs(){
    return this.halResourceService.get<CollectionResource<HalResource>>(
      this.pathHelper.api.v3.organizations.toString())
      .toPromise()
      .then((collection:CollectionResource<HalResource>) => {
          collection.elements.forEach(el =>
             {this.orgs.set(Number(el.getId()), el.name)}
          );
        }
      );
  }

  private loadUsers(){
    return this.halResourceService.get<CollectionResource<HalResource>>(
      this.pathHelper.api.v3.users.toString())
      .toPromise()
      .then((collection:CollectionResource<HalResource>) => {
          collection.elements.forEach(el =>
            {this.users.set(Number(el.getId()), el.name)}
          );
          console.log(this.users)
        }
      );
  }

  private addNewProblem(problem: WpProblem){
    const path = this.pathHelper.api.v3.work_package_problems.toString();
    const params = {project_id: problem.project_id, work_package_id: problem.work_package_id, risk_id: problem.risk_id,
            user_creator_id: problem.user_creator_id, organization_source_id: problem.organization_source_id,
            description: problem.description, status: problem.status, solution_date: problem.solution_date      
    };
    return this.halResourceService
      .post<WpTargetResource>(path, params)
      .toPromise();
  }




  public createProblem() {

    if (!this.selectedId) {
      return;
    }

    this.isDisabled = true;
    this.createCommonProblem()
      .catch(() => this.isDisabled = false)
      .then(() => this.isDisabled = false);
  }

  public updateSelectedId(targetId:string) {
    this.selectedId = targetId;
  }

  protected createCommonProblem() {
    return this.addNewProblem(this.wpProblem)
      .then(wpTarget => {
        console.log(wpTarget);
        this.wpNotificationsService.showSave(this.workPackage);
        this.toggleProblemCreateForm();
        //TODO: (zbd) доделать обновление таблицы
        this.loadWpProblems(this.workPackage.id);
      })
      .catch(err => {
        this.wpNotificationsService.handleRawError(err, this.workPackage);
        this.toggleProblemCreateForm();
      });
  }

  
  public toggleProblemCreateForm() {
    this.showProblemCreateForm = !this.showProblemCreateForm;
    setTimeout(() => {
      if (!this.showProblemCreateForm) {
        // Reset value
        this.selectedId = '';
        this.focusAfterSave.nativeElement.focus();
      }
    });
  }
  
}
