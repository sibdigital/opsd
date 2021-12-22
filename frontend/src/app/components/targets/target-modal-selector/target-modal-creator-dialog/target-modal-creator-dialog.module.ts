import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import {MatDialogModule} from "@angular/material/dialog";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {MatIconModule} from "@angular/material/icon";
import {TargetModalCreatorDialogComponent} from "./target-modal-creator-dialog.component";
import {MatButtonModule} from "@angular/material/button";
import {MatSnackBarModule} from "@angular/material/snack-bar";
import {EnumerationSelectModule} from "core-components/enumerations/enumeration-select/enumeration-select.module";
@NgModule({
  declarations: [
    TargetModalCreatorDialogComponent
  ],
  exports:[
    TargetModalCreatorDialogComponent
  ],
  imports: [
    CommonModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatIconModule,
    MatSnackBarModule,
    MatButtonModule,
    EnumerationSelectModule,
  ],
  entryComponents:[
    TargetModalCreatorDialogComponent
  ]
})
export class TargetModalCreatorDialogModule { }
