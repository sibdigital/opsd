import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import {FormsModule} from "@angular/forms";
import {MatIconModule} from "@angular/material/icon";
import {MatButtonModule} from "@angular/material/button";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {MatDialogModule} from "@angular/material/dialog";
import {WorkPackageModalSelectorComponent} from "core-components/wp-modal-selector/work-package-modal-selector.component";
import {WorkPackageModalSelectorDialogModule} from "core-components/wp-modal-selector/work-package-modal-selector-dialog/work-package-modal-selector-dialog.module";



@NgModule({
  declarations: [
    WorkPackageModalSelectorComponent,
  ],
  exports: [
    WorkPackageModalSelectorComponent
  ],
  imports: [
    CommonModule,
    FormsModule,
    MatIconModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatDialogModule,
    WorkPackageModalSelectorDialogModule
  ]
})
export class WorkPackageModalSelectorModule { }
