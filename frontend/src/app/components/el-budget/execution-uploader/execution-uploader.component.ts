import {
  AfterViewInit,
  Component, ElementRef, Inject,
  Input, ViewChild
} from '@angular/core';
import {ExecutionUploaderService} from "./shared/execution-uploader.service";
import {ActivatedRoute, Router} from '@angular/router';
import {FormBuilder, FormGroup, Validators} from "@angular/forms";
import {MatStepper} from "@angular/material/stepper";
import {HttpErrorResponse} from "@angular/common/http";
import {MatRadioChange} from "@angular/material/radio";
import {MatSnackBar, MatSnackBarConfig} from "@angular/material/snack-bar";
import {animate, state, style, transition, trigger} from "@angular/animations";
import {MAT_DIALOG_DATA, MatDialog} from "@angular/material/dialog";
import {WorkPackageModalSelectorComponent} from "core-components/wp-modal-selector/work-package-modal-selector.component";
import {Project} from "core-components/projects/project.model";
import {WorkPackage} from "core-components/work-packages/work-package.model";
import {Target} from "core-components/targets/target.model";
import {ProjectModalSelectorComponent} from "core-components/projects/project-modal-selector/project-modal-selector.component";
import {CostObject} from "core-components/cost-objects/cost-object.model";
import {TargetMatch} from "core-components/el-budget/target-match.model";
import {PurposeCriteria} from "core-components/el-budget/execution/purpose-criteria/purpose-criteria.model";
import {ProjectService} from "core-components/projects/shared/project.service";
import {Organization} from "core-components/organizations/organization.model";
import {OrganizationModalSelectorComponent} from "core-components/organizations/organization-modal-selector/organization-modal-selector.component";
import {TargetService} from "core-components/targets/shared/target.service";
import {TargetModalSelectorComponent} from "core-components/targets/target-modal-selector/target-modal-selector.component";



@Component({
  selector: 'op-execution-uploader',
  templateUrl: 'execution-uploader.component.html',
  styleUrls: ['execution-uploader.component.sass'],
  animations: [
    trigger('detailExpand', [
      state('collapsed', style({height: '0px', minHeight: '0', display: 'none'})),
      state('expanded', style({height: '*'})),
      transition('expanded <=> collapsed', animate('225ms cubic-bezier(0.4, 0.0, 0.2, 1)')),
    ]),
  ],
})

export class ExecutionUploaderComponent implements AfterViewInit {
  @Input() projectIdText:string | undefined;
  @Input() workPackageResultText = '';
  @Input() financeResultText = '';
  @Input() targetResultText = '';
  @Input() riskResultText = '';

  @Input() outputTarget:Target | undefined;

  @ViewChild('fileInput') fileInputRef:ElementRef | undefined;
  @ViewChild('projectModalSelectorComponent') projectModalSelectorComponent:ProjectModalSelectorComponent;
  @ViewChild('workPackageModalSelectorComponent') workPackageModalSelectorComponent:WorkPackageModalSelectorComponent;
  @ViewChild('organizationModalSelectorComponent') organizationModalSelectorComponent:OrganizationModalSelectorComponent;
  @ViewChild('targetModalSelectorComponent') targetModalSelectorComponent:TargetModalSelectorComponent | undefined;
  @ViewChild('targetMatchTable') targetMatchTable:HTMLTableElement | undefined;
  @ViewChild('stepper') stepper:MatStepper;

  isLinear:boolean;
  projectIdFromUrl:number | undefined = undefined;


  selectProjectVisible:boolean;
  selectWorkPackageVisible:boolean;
  workPackageMatRadioGroupVisible:boolean;
  secondSpinnerVisible:boolean;
  thirdSpinnerVisible:boolean;
  targetTableVisible:boolean;
  riskSpinnerVisible:boolean;
  processTargetBtnVisible:boolean;
  disableTargetToggle:boolean = false;
  disabledStartButton:boolean;

  zeroFormGroup:FormGroup;
  firstFormGroup:FormGroup;
  secondFormGroup:FormGroup;
  thirdFormGroup:FormGroup;
  fourthFormGroup:FormGroup;

  workPackageIsMatched:boolean;
  newProjectName:string;
  newWorkPackageName:string;
  selectedProject:Project | undefined;
  selectedWorkPackage:WorkPackage | undefined;
  selectedOrganization:Organization | undefined;
  selectedCostObject:CostObject | undefined;
  selectedFiles:FileList | undefined;
  selectedFileText = '';

  targetMatches:TargetMatch[];
  purposeCriteriaList:PurposeCriteria[];
  chosenTargets:Target[];

  displayedColumns:string[] = ['metaId', 'matched'];
  expandedElement:TargetMatch | null | undefined;


  constructor(private executionUploaderService:ExecutionUploaderService,
              public _formBuilder:FormBuilder,
              private _snackBar:MatSnackBar,
              private projectService:ProjectService,
              private targetService:TargetService,
              public dialog:MatDialog
  ) {
    this.isLinear = false;

    this.newProjectName = "";
    this.newWorkPackageName = "";
    this.purposeCriteriaList = [];
    this.targetMatches = [];
    this.chosenTargets = [];

    this.workPackageIsMatched = false;
    this.selectProjectVisible = true;
    this.workPackageMatRadioGroupVisible = true;
    this.selectWorkPackageVisible = true;
    this.secondSpinnerVisible = true;
    this.thirdSpinnerVisible = true;
    this.targetTableVisible = false;
    this.processTargetBtnVisible = false;
    this.riskSpinnerVisible = false;
    this.disabledStartButton = false;

    // this.secondStepStatus = false;
    this.zeroFormGroup = this._formBuilder.group({
      firstCtrl: ['', Validators.required]
    });
    this.firstFormGroup = this._formBuilder.group({
      firstCtrl: ['', Validators.required]
    });
    this.secondFormGroup = this._formBuilder.group({
      secondCtrl: ['', Validators.required]
    });
    this.thirdFormGroup = this._formBuilder.group({
      thirdCtrl: ['', Validators.required]
    });
    this.fourthFormGroup = this._formBuilder.group({
      thirdCtrl: ['', Validators.required]
    });
  }

  ngOnInit():void {
    this.isLinear = true;

    if (this.projectIdText) {
      this.projectIdFromUrl = parseInt(this.projectIdText);
    }

    this.newProjectName = "";
    this.newWorkPackageName = "";

    this.workPackageIsMatched = false;
    this.selectProjectVisible = true;
    this.workPackageMatRadioGroupVisible = true;
    this.selectWorkPackageVisible = true;
    this.secondSpinnerVisible = true;
    this.thirdSpinnerVisible = true;
    this.targetTableVisible = false;
    this.targetTableVisible = true;
    this.processTargetBtnVisible = false;
    this.riskSpinnerVisible = false;
    this.disabledStartButton = false;
  }

  ngAfterViewInit():void {
    if (this.projectIdFromUrl) {
      this.projectService.getProjectById(this.projectIdFromUrl).subscribe(
        (data:any) => {
          this.getOutputProject(data);
        }
      );
    }
  }

  getOutputProject(outputProject:Project) {
    this.selectedProject = outputProject;
    if (this.workPackageModalSelectorComponent) {
      this.workPackageModalSelectorComponent.setProjectAndResetWorkPackage(outputProject);
    }
  }

  getOutputWorkPackage(outputWorkPackage:WorkPackage) {
    this.selectedWorkPackage = outputWorkPackage;
    this.organizationModalSelectorComponent.setOrganization(this.selectedWorkPackage.organization);
    this.selectedOrganization = this.selectedWorkPackage.organization;
  }

  getOutputOrganization(outputOrganization:Organization) {
    this.selectedOrganization = outputOrganization;
    this.organizationModalSelectorComponent.setOrganization(outputOrganization);
  }

  getOutputTarget(outputSelectedTarget:Target, targetMatch:TargetMatch) {
    targetMatch.target = outputSelectedTarget;
    this.fillChosenTargets(this.targetMatches);
  }

  filesChanged(event:any):void {
    const target = event.target as HTMLInputElement;
    this.selectedFiles = target.files as FileList;
    if (this.selectedFiles) {
      const numSelectedFiles = this.selectedFiles.length;
      this.selectedFileText =
        numSelectedFiles === 1
          ? this.selectedFiles[0].name
          : `${numSelectedFiles} files selected`;
    } else {
      this.selectedFileText = '';
    }
  }

  startProcessFile():void {
    if (this.selectedFiles) {
      this.isLinear = false;
      var currentFileUpload = this.selectedFiles.item(0) as File;
      this.resetResultStep();
      this.executionUploaderService.findWorkPackage(currentFileUpload).subscribe(
         response => {
           this.disabledStartButton = true;
           if (response.cause && response.name === 'null') {
             this.stepper.next();
           } else if (response.id) {
             this.setProjectAndWorkPackageInSelect(response);
             this.stepper.next(); // на шаг 2
             this.stepper.next(); // на шаг 3
             this.processFinance(currentFileUpload, response);
           }
        });
    }
  }

  setProjectAndWorkPackageInSelect(response:WorkPackage) {
    try {
      this.selectedWorkPackage = response;
      this.workPackageIsMatched = true;
      this.projectModalSelectorComponent.disableChoice();
      this.workPackageModalSelectorComponent.disableChoice();
      this.organizationModalSelectorComponent.disableChoice();
      this.selectProjectVisible = true;
      this.selectWorkPackageVisible = true;

      if (response.project) {
        this.projectModalSelectorComponent.setProject(response.project);
        this.workPackageModalSelectorComponent.setProject(response.project);
        this.workPackageModalSelectorComponent.setWorkPackage(response);
        this.organizationModalSelectorComponent.setOrganization(response.organization);
      }
    } catch (error) {
      this._snackBar.open(error);
    }
  }

  projectRadioChange(event:MatRadioChange):void {
    if (event.value === '1') {
      this.selectProjectVisible = true;
      this.workPackageMatRadioGroupVisible = true;
    } else if (event.value === '2') {
      this.selectProjectVisible = false;
      this.workPackageMatRadioGroupVisible = false;
      this.selectWorkPackageVisible = false;
      this.organizationModalSelectorComponent.enableChoice();
    }
  }

  workPackageRadioChange(event:MatRadioChange):void {
    if (event.value === '1') {
      this.selectWorkPackageVisible = true;
      this.organizationModalSelectorComponent.disableChoice();
    } else if (event.value === '2') {
      this.selectWorkPackageVisible = false;
      this.organizationModalSelectorComponent.enableChoice();
    }
  }

  setNewProjectName(event:any):void {
    this.newProjectName = event.value;
  }

  setNewWorkPackageName(event:any):void {
    this.newWorkPackageName = event.value;
  }

  selectOrCreateWorkPackage():void {
    if (this.checkСompletenessWorkPackages() && this.selectedFiles ) {
      var currentFileUpload = this.selectedFiles.item(0) as File;

      if (this.selectWorkPackageVisible) {
        if (this.selectedWorkPackage) {
          this.executionUploaderService.putMetaIdToWorkPackage(currentFileUpload, this.selectedWorkPackage.id).subscribe(
            response => {
              if (response.id && this.selectedWorkPackage) {
                this.processFinance(currentFileUpload, this.selectedWorkPackage);
                this.stepper.next();
              }
            },
            error => {
              this.workPackageResultText = "Не удалось загрузить в данное мероприятие";
              if (error instanceof HttpErrorResponse) {
                this.workPackageResultText = this.workPackageResultText + " Ошибка: " + error.status;
              }
            });
        }
      } else {
          var projectId = (this.selectProjectVisible && this.selectedProject) ? this.selectedProject.id : 0;
          var projectName = (this.selectProjectVisible) ? "" : this.newProjectName;
          var organizationId = this.selectedOrganization ? this.selectedOrganization.id : 0;
          this.executionUploaderService.createWorkPackage(currentFileUpload, this.newWorkPackageName, projectId, projectName, organizationId).subscribe(
            response => {
              if (response.id) {
                this.setProjectAndWorkPackageInSelect(response);
                this.stepper.next();
                this.processFinance(currentFileUpload, response);
              }
            },
            error => {
              this.workPackageResultText = "Не удалось создать мероприятие.";
              if (error instanceof HttpErrorResponse) {
                this.workPackageResultText = this.workPackageResultText + " Ошибка: " + error.status;
              }
            });
      }
    }
  }

  resetResultStep():void {
    this.projectModalSelectorComponent.enableChoice();
    this.workPackageModalSelectorComponent.enableChoice();
    this.organizationModalSelectorComponent.disableChoice();
    this.secondSpinnerVisible = true;
    this.thirdSpinnerVisible = true;
    this.workPackageResultText = '';
    this.financeResultText = '';
    this.targetResultText = '';
    this.targetMatches = [];
  }

  processFinance(file:File, workPackage:WorkPackage) {
    this.executionUploaderService.processFinance(file, workPackage)
      .subscribe(
    response => {
          if (response.id) {
            this.secondSpinnerVisible = false;
            this.financeResultText = "Бюджет успешно сохранен";
            this.selectedCostObject = response;
            this.stepper.next();
            this.matchPurposeCriteria(file, workPackage);
          }
        },
    error => {
          this.secondSpinnerVisible = false;

          if (error.error.cause) {
            this.financeResultText = error.cause;
          } else {
            this.financeResultText = "Не удалось загрузить файл. " + error.statusText;
          }
        });
  }

  matchPurposeCriteria(file:File, workPackage:WorkPackage) {
    this.executionUploaderService.processPurposeCriteria(file, workPackage)
      .subscribe(
        (response:TargetMatch[]) => {
          response.forEach(match => {
            match.project = this.projectModalSelectorComponent.selectedProject;

            if (match.target) {
              match.disableTargetChoice = true;
              match.attachedTarget = true;
            } else {
              match.disableTargetChoice = false;
              match.attachedTarget = false;
            }
          });

          this.targetMatches = response;
          let completenessTargets = this.checkСompletenessTargets(response);
          if (completenessTargets) {
            this.processTarget(response);
          } else {
            this.thirdSpinnerVisible = false;
            this.targetTableVisible = true;
            this.processTargetBtnVisible = true;
            this.fillChosenTargets(response);
          }
        },
  error => {
          this.thirdSpinnerVisible = false;
          this.targetResultText = "Не удалось загрузить целевые показатели. ";
          if (error instanceof HttpErrorResponse) {
            this.targetResultText = this.targetResultText + "Ошибка: " + error.status;
          }
        }
      );
  }

  processTarget(targetMatches:TargetMatch[]) {
    if (this.workPackageModalSelectorComponent.selectedWorkPackage) {
      this.executionUploaderService.processTargets(targetMatches, this.workPackageModalSelectorComponent.selectedWorkPackage)
        .subscribe(
          (response) => {
            response.forEach(match => {
              match.project = this.projectModalSelectorComponent.selectedProject;
              if (match.target) {
                match.disableTargetChoice = true;
                match.attachedTarget = true;
              } else {
                match.disableTargetChoice = false;
                match.attachedTarget = false;
              }
            });
            this.targetMatches = response;
            this.thirdSpinnerVisible = false;
            this.disableTargetToggle = true;
            this.targetResultText = "Целевые показатели сохранены.";

            this.stepper.next();
            this.processRisks();
        },
          error => {
                  this.thirdSpinnerVisible = false;
                  this.targetResultText = "Не удалось загрузить целевые показатели. ";
                  if (error instanceof HttpErrorResponse) {
                    this.targetResultText = this.targetResultText + "Ошибка: " + error.status;
                  }
          });
    }
  }

  continueProcessTarget() {
    this.thirdSpinnerVisible = true;
    this.processTargetBtnVisible = false;
    this.processTarget(this.targetMatches);
  }

  processRisks() {
    this.riskSpinnerVisible = true;
    if (this.selectedFiles && this.selectedWorkPackage) {
      var file = this.selectedFiles.item(0) as File;
      this.executionUploaderService.processRisks(file, this.selectedWorkPackage).subscribe(
        (data) => {
          this.riskResultText = 'Риски сохранены';
        },
        (error => {
          this.riskResultText = 'Не удалось сохранить риск';
        })
      );
    } else {
       this.riskResultText = 'Не удалось сохранить риск';
    }
     this.riskSpinnerVisible = false;
  }

  fillChosenTargets(targetMatches:TargetMatch[]) {
    this.chosenTargets = [];
    targetMatches.forEach(targetMatch => {
      if (targetMatch.target !== null) {
        this.chosenTargets.push(targetMatch.target);
      }
    });
  }

  checkСompletenessTargets(targetMatches:TargetMatch[]) {
    let isComplete = true;
    targetMatches.forEach(targetMatch => {
      if (!targetMatch.target) {
        isComplete = false;
      }
    });

    return isComplete;
  }

  checkСompletenessWorkPackages():boolean {
    let isComplete = true;

    if (this.selectProjectVisible && !this.selectedProject) {
      isComplete = false;
      this.showMessage("Не выбран проект");
    } else if (!this.selectProjectVisible && (this.newProjectName === "" || this.newProjectName === undefined)) {
      isComplete = false;
      this.showMessage("Не заполнен проект");
    } else if (this.selectWorkPackageVisible && !this.selectedWorkPackage) {
      isComplete = false;
      this.showMessage("Не выбрано мероприятие");
    } else if (!this.selectWorkPackageVisible && (this.newWorkPackageName === "" || this.newWorkPackageName === undefined)) {
      isComplete = false;
      this.showMessage("Не заполнено мероприятие");
    }

    return isComplete;
  }

  breakBinding(targetMatch:any) {
    if (targetMatch.attachedTarget) {
      const dialogRef = this.dialog.open(ConfirmationOfUnattachComponent);

      dialogRef.afterClosed().subscribe(result => {
        if (result) {
          this.targetService.changeTargetMetaId(targetMatch.target, null).subscribe(
            (result:any) => {
              targetMatch.disableTargetChoice = false;
              targetMatch.attachedTarget = false;
            },
            (error:any) => {
              this.showMessage(error.error.errorMessage);
            }
          );
        }
      });
    }
  }

  showMessage(message:string):void {
    const config = new MatSnackBarConfig();
    config.panelClass = ['background-red'];
    config.verticalPosition = "top";
    config.horizontalPosition = 'right';
    config.duration = 2000;

    this._snackBar.open(message, 'x', config);
  }


  openCostObject(event:any) {
    if (this.selectedCostObject) {
      window.open(window.appBasePath + "/cost_objects/" + this.selectedCostObject.id, "_blank");
    }
  }

}

@Component({
  selector: 'confirmation-of-unattach',
  templateUrl: 'confirmation-of-unattach.html',
})
export class ConfirmationOfUnattachComponent {
  constructor() {
    //
  }
}
