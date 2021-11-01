import {MatTableModule} from "@angular/material/table";
import {BrowserModule} from "@angular/platform-browser";
import {NgModule} from "@angular/core";
import {MatCardModule} from "@angular/material/card";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {MatButtonModule} from "@angular/material/button";
import {MatIcon, MatIconModule} from "@angular/material/icon";
import {FormsModule, ReactiveFormsModule} from "@angular/forms";
import {CostTypeFormComponent} from "core-components/cost-types/form/cost-type-form.component";
import {MatTabsModule} from "@angular/material/tabs";
import {MatNativeDateModule} from "@angular/material/core";
import {MatDatepickerModule} from "@angular/material/datepicker";
import {MatDialogModule} from "@angular/material/dialog";
import {EbCostTypesModalSelectorDialogModule} from "core-components/eb-cost-types/eb-cost-types-modal-selector-dialog/eb-cost-types-modal-selector-dialog.module";
import {EbCostTypesModalHelpModule} from "core-components/eb-cost-types/eb-cost-types-modal-help/eb-cost-types-modal-help.module";
@NgModule({
  imports: [
    MatTableModule,
    MatTabsModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatCardModule,
    MatNativeDateModule,
    MatDatepickerModule,
    MatIconModule,
    MatDialogModule,
    FormsModule,
    ReactiveFormsModule,
    BrowserModule,
    EbCostTypesModalSelectorDialogModule,
    EbCostTypesModalHelpModule
  ],
  providers: [],
  declarations: [
    CostTypeFormComponent
  ],
  entryComponents: [
    CostTypeFormComponent,
  ],
  exports: [
    CostTypeFormComponent,
  ]
})
export class CostTypesModule {}
