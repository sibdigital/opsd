import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import {FormsModule} from "@angular/forms";
import {MatIconModule} from "@angular/material/icon";
import {MatButtonModule} from "@angular/material/button";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {MatDialogModule} from "@angular/material/dialog";
import {OrganizationModalSelectorComponent} from "./organization-modal-selector.component";
import {OrganizationModalSelectorDialogModule} from "./organization-modal-selector-dialog/organization-modal-selector-dialog.module";



@NgModule({
  declarations: [
    OrganizationModalSelectorComponent
  ],
  exports:[
    OrganizationModalSelectorComponent
  ],
  imports: [
    CommonModule,
    FormsModule,
    MatIconModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatDialogModule,
    OrganizationModalSelectorDialogModule
  ]
})
export class OrganizationModalSelectorModule { }
