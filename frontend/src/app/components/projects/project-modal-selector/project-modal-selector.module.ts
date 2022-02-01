import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import {ProjectModalSelectorComponent} from "./project-modal-selector.component";
import {FormsModule} from "@angular/forms";
import {MatIconModule} from "@angular/material/icon";
import {MatButtonModule} from "@angular/material/button";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {ProjectModalSelectorDialogModule} from "./project-modal-selector-dialog/project-modal-selector-dialog.module";
import {MatDialogModule} from "@angular/material/dialog";



@NgModule({
  declarations: [
    ProjectModalSelectorComponent
  ],
  exports : [
    ProjectModalSelectorComponent
  ],
  imports: [
    CommonModule,
    FormsModule,
    MatIconModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    ProjectModalSelectorDialogModule,
    MatDialogModule
  ]
})
export class ProjectModalSelectorModule { }
