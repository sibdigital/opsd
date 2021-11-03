import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import {MatDialogModule} from "@angular/material/dialog";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {MatPaginatorModule} from "@angular/material/paginator";
import {MatTableModule} from "@angular/material/table";
import {MatSortModule} from "@angular/material/sort";
import {MatIconModule} from "@angular/material/icon";
import {MatButtonModule} from "@angular/material/button";
import {EbCostTypesModalSelectorDialogComponent} from "core-components/eb-cost-types/eb-cost-types-modal-selector-dialog/eb-cost-types-modal-selector-dialog.component";
import {MatSnackBarModule} from "@angular/material/snack-bar";

@NgModule({
  declarations: [
    EbCostTypesModalSelectorDialogComponent
  ],
  exports:[
    EbCostTypesModalSelectorDialogComponent
  ],
  entryComponents: [
    EbCostTypesModalSelectorDialogComponent,
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
    MatSnackBarModule
  ]
})
export class EbCostTypesModalSelectorDialogModule { }
