import { NgModule } from '@angular/core';
import {
  ConfirmationOfUnattachComponent,
  // ConfirmationOfUnattachComponent,
  ExecutionUploaderComponent
} from "core-components/el-budget/execution-uploader/execution-uploader.component";

import {BrowserModule} from "@angular/platform-browser";
import {BrowserAnimationsModule} from "@angular/platform-browser/animations";
import {MatButtonModule} from "@angular/material/button";
import {MatSelectModule} from "@angular/material/select";
import {MatOptionModule} from "@angular/material/core";
import {MatStepperModule} from "@angular/material/stepper";
import {MatProgressSpinnerModule} from "@angular/material/progress-spinner";
import {FormsModule, ReactiveFormsModule} from "@angular/forms";
import {MatTableModule} from "@angular/material/table";
import {MatRadioModule} from "@angular/material/radio";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {CommonModule} from "@angular/common";
import {MatSnackBarModule} from "@angular/material/snack-bar";
import {MatIconModule} from "@angular/material/icon";
import {MatDialogModule} from "@angular/material/dialog";
import {WorkPackageModalSelectorModule} from "core-components/wp-modal-selector/work-package-modal-selector.module";
import {ProjectModalSelectorModule} from "core-components/projects/project-modal-selector/project-modal-selector.module";
import {TargetModalSelectorModule} from "core-components/targets/target-modal-selector/target-modal-selector.module";
import {OrganizationModalSelectorModule} from "core-components/organizations/organization-modal-selector/organization-modal-selector.module";
import {PurposeCriteriaViewModule} from "core-components/el-budget/execution/purpose-criteria/purpose-criteria-view/purpose-criteria-view.module";


@NgModule({
  declarations: [
    ExecutionUploaderComponent,
    ConfirmationOfUnattachComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,

    CommonModule,
    FormsModule,

    MatButtonModule,
    MatSelectModule,
    MatOptionModule,
    MatStepperModule,
    MatProgressSpinnerModule,
    MatTableModule,
    MatRadioModule,
    MatFormFieldModule,
    MatInputModule,
    MatSnackBarModule,
    MatIconModule,
    MatDialogModule,

    WorkPackageModalSelectorModule,
    ReactiveFormsModule,
    PurposeCriteriaViewModule,
    ProjectModalSelectorModule,
    TargetModalSelectorModule,
    OrganizationModalSelectorModule
    ],
  exports:[
    ExecutionUploaderComponent,
    ConfirmationOfUnattachComponent
  ],
  entryComponents: [
    ExecutionUploaderComponent,
    ConfirmationOfUnattachComponent
  ]
})
export class ExecutionUploaderModule { }
