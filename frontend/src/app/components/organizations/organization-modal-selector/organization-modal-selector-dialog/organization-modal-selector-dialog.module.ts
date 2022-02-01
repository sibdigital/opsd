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
import {OrganizationModalSelectorDialogComponent} from "core-components/organizations/organization-modal-selector/organization-modal-selector-dialog/organization-modal-selector-dialog.component";

@NgModule({
  declarations: [
    OrganizationModalSelectorDialogComponent
  ],
  exports:[
    OrganizationModalSelectorDialogComponent
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
    MatButtonModule
  ],
  entryComponents:[
    OrganizationModalSelectorDialogComponent
  ]
})
export class OrganizationModalSelectorDialogModule { }
