import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import {MatDialogModule} from "@angular/material/dialog";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {MatPaginatorModule} from "@angular/material/paginator";
import {MatTableModule} from "@angular/material/table";
import {MatSortModule} from "@angular/material/sort";
import {MatIconModule} from "@angular/material/icon";
import {TargetModalSelectorDialogComponent} from "./target-modal-selector-dialog.component";
import {MatButtonModule} from "@angular/material/button";
import {EnumerationSelectModule} from "../../../enumerations/enumeration-select/enumeration-select.module";
import {MatToolbarModule} from "@angular/material/toolbar";
import {MatCardModule} from "@angular/material/card";
import {TargetModalCreatorDialogModule} from "../target-modal-creator-dialog/target-modal-creator-dialog.module";



@NgModule({
  declarations: [
    TargetModalSelectorDialogComponent
  ],
  exports:[
    TargetModalSelectorDialogComponent
  ],
  imports: [
    CommonModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatPaginatorModule,
    MatTableModule,
    MatSortModule,
    MatIconModule,
    MatButtonModule,
    EnumerationSelectModule,
    MatToolbarModule,
    MatCardModule,
    TargetModalCreatorDialogModule
  ],
  entryComponents:[
    TargetModalSelectorDialogComponent
  ]
})
export class TargetModalSelectorDialogModule { }
