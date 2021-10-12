import {NgModule} from "@angular/core";
import {MatTabsModule} from "@angular/material/tabs";
import {MatInputModule} from "@angular/material/input";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatDatepickerModule} from "@angular/material/datepicker";
import {MatNativeDateModule} from "@angular/material/core";
import {BrowserModule} from "@angular/platform-browser";
import {BrowserAnimationsModule, NoopAnimationsModule} from "@angular/platform-browser/animations";
import {MatExpansionModule} from "@angular/material/expansion";
import {MatDividerModule} from "@angular/material/divider";
import {ContractFormComponent} from "core-components/contracts/form/contract-form.component";
import {FormsModule, ReactiveFormsModule} from "@angular/forms";

@NgModule({
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    FormsModule,
    MatTabsModule,
    MatFormFieldModule,
    MatInputModule,
    MatNativeDateModule,
    MatDatepickerModule,
    MatDividerModule,
    MatExpansionModule,
    NoopAnimationsModule,
    ReactiveFormsModule
  ],
  providers: [],
  declarations: [
    ContractFormComponent
  ],
  entryComponents: [
    ContractFormComponent
  ],
  exports: [
    ContractFormComponent
  ]
})
export class ContractsModule {}
