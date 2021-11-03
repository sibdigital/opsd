import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import {MatDialogModule} from "@angular/material/dialog";
import {MatIconModule} from "@angular/material/icon";
import {MatButtonModule} from "@angular/material/button";
import {EbCostTypesModalHelpComponent} from "core-components/eb-cost-types/eb-cost-types-modal-help/eb-cost-types-modal-help.component";

@NgModule({
  declarations: [
    EbCostTypesModalHelpComponent
  ],
  exports:[
    EbCostTypesModalHelpComponent
  ],
  entryComponents: [
    EbCostTypesModalHelpComponent,
  ],
  imports: [
    CommonModule,
    MatDialogModule,
    MatIconModule,
    MatButtonModule,
  ]
})
export class EbCostTypesModalHelpModule { }
