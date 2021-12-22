import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import {MatListModule} from "@angular/material/list";
import {FormsModule} from "@angular/forms";
import {MatTreeModule} from "@angular/material/tree";
import {MatIconModule} from "@angular/material/icon";
import {MatButtonModule} from "@angular/material/button";
import {PurposeCriteriaViewComponent} from "core-components/el-budget/execution/purpose-criteria/purpose-criteria-view/purpose-criteria-view.component";

@NgModule({
  declarations: [
    PurposeCriteriaViewComponent
  ],
  exports: [
    PurposeCriteriaViewComponent
  ],
  imports: [
    CommonModule,
    FormsModule,
    MatListModule,
    MatTreeModule,
    MatIconModule,
    MatButtonModule
  ]
})
export class PurposeCriteriaViewModule { }
