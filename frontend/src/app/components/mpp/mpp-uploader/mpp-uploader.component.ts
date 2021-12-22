import {AfterViewInit, Component, ElementRef, Input, OnInit, ViewChild} from '@angular/core';
import {FormBuilder, FormGroup, Validators} from "@angular/forms";
import {MppUploaderService} from "./shared/mpp-uploader.service";
import {MatStepper} from "@angular/material/stepper";
import {HttpErrorResponse} from "@angular/common/http";
import {Project} from "core-components/projects/project.model";
import {WorkPackage} from "core-components/work-packages/work-package.model";
import {ProjectService} from "core-components/projects/shared/project.service";

@Component({
  selector: 'op-mpp-uploader',
  templateUrl: './mpp-uploader.component.html',
  styleUrls: ['./mpp-uploader.component.scss']
})
export class MppUploaderComponent implements AfterViewInit {

  @Input() projectIdText:string | undefined;
  @ViewChild('stepper') stepper:MatStepper;
  @Input() resultText = '';

  isLinear:boolean;

  zeroFormGroup:FormGroup;
  firstFormGroup:FormGroup;
  projectIsMatched:boolean;
  selectProjectVisible:boolean;
  selectedProject:Project | undefined;
  newProjectName:string;
  selectedFiles:FileList | undefined;
  selectedFileText = '';

  displayedColumns:string[] = ['id', 'subject'];
  createdWorkPackages:WorkPackage[] = [];

  projectId:number | undefined = undefined;

  constructor(
    private mppUploaderService:MppUploaderService,
    private projectService:ProjectService,
    public _formBuilder:FormBuilder,
  ) {
    this.isLinear = true;
    this.isLinear = false;
    this.projectIsMatched = false;
    this.selectProjectVisible = true;
    this.newProjectName = "";

    this.zeroFormGroup = this._formBuilder.group({
      firstCtrl: ['', Validators.required]
    });
    this.firstFormGroup = this._formBuilder.group({
      firstCtrl: ['', Validators.required]
    });
  }

  ngAfterViewInit():void {
    if (this.projectId) {
      this.projectService.getProjectById(this.projectId).subscribe(
        (data) => {
            this.selectedProject = data;
        });
    }

  }

  ngOnInit():void {
    this.isLinear = true;
    this.projectIsMatched = false;
    this.selectProjectVisible = true;
    this.newProjectName = "";

    if (this.projectIdText) {
      this.projectId = parseInt(this.projectIdText);
    }
  }

  getOutputProject(outputProject:Project) {
    this.selectedProject = outputProject;
  }

  setNewProjectName(event:any):void {
    this.newProjectName = event.value;
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

  resetResultStep():void {
    this.resultText = '';
    this.createdWorkPackages = [];
  }

  startProcessFile():void {
    if (this.selectedFiles) {
      this.isLinear = false;

      var currentFileUpload = this.selectedFiles.item(0) as File;
      this.resetResultStep();
      if (this.selectedProject) {
        this.mppUploaderService.processMppFile(currentFileUpload, this.selectedProject.id, this.newProjectName).subscribe(
          response => {
            this.createdWorkPackages = response;
            this.stepper.next();
          },
          error => {
            this.resultText = "Не удалось создать контрольные точки.";
            if (error instanceof HttpErrorResponse) {
              this.resultText = this.resultText + " Ошибка: " + error.status;
            }
            this.stepper.next();
          });
      }
    }
  }

  openWorkPackage(row:any):void {
    window.open(window.appBasePath + "/projects/" + row.project.id + "/work_packages/" + row.id, "_blank");
  }
}
