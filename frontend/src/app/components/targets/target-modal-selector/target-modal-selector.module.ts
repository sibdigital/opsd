import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import {FormsModule} from "@angular/forms";
import {MatIconModule} from "@angular/material/icon";
import {MatButtonModule} from "@angular/material/button";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {MatDialogModule} from "@angular/material/dialog";
import {TargetModalSelectorComponent} from "core-components/targets/target-modal-selector/target-modal-selector.component";
import {TargetModalSelectorDialogModule} from "core-components/targets/target-modal-selector/target-modal-selector-dialog/target-modal-selector-dialog.module";


@NgModule({
  declarations: [
    TargetModalSelectorComponent
  ],
  exports:[
    TargetModalSelectorComponent
  ],
  imports: [
    CommonModule,
    FormsModule,
    MatIconModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatDialogModule,
    TargetModalSelectorDialogModule
  ]
})
export class TargetModalSelectorModule { }
