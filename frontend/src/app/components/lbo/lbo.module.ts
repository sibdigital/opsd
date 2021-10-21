import {MatTableModule} from "@angular/material/table";
import {BrowserModule} from "@angular/platform-browser";
import {NgModule} from "@angular/core";
import {LboComponent} from "core-components/lbo/lbo.component";
import {MatCardModule} from "@angular/material/card";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {MatButtonModule} from "@angular/material/button";
import {MatIconModule} from "@angular/material/icon";
import {FormsModule, ReactiveFormsModule} from "@angular/forms";
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
    LboComponent
  ],
  entryComponents: [
    LboComponent,
  ],
  exports: [
    LboComponent,
  ]
})
export class LboModule {}
