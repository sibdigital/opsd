import {MatTableModule} from "@angular/material/table";
import {BrowserModule} from "@angular/platform-browser";
import {NgModule} from "@angular/core";
import {MatCardModule} from "@angular/material/card";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {MatButtonModule} from "@angular/material/button";
import {MatIconModule} from "@angular/material/icon";
import {FormsModule, ReactiveFormsModule} from "@angular/forms";
import {CostTypeFormComponent} from "core-components/cost-types/form/cost-type-form.component";
@NgModule({
  imports: [
    MatTableModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    FormsModule,
    ReactiveFormsModule,
    BrowserModule,
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
