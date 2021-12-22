import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import {MppUploaderComponent} from "./mpp-uploader.component";
import {BrowserModule} from "@angular/platform-browser";
import {BrowserAnimationsModule} from "@angular/platform-browser/animations";
import {FormsModule, ReactiveFormsModule} from "@angular/forms";
import {MatButtonModule} from "@angular/material/button";
import {MatStepperModule} from "@angular/material/stepper";
import {MatTableModule} from "@angular/material/table";
import {MatRadioModule} from "@angular/material/radio";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {MatSlideToggleModule} from "@angular/material/slide-toggle";
import {MatIconModule} from "@angular/material/icon";
import {ProjectModalSelectorModule} from "core-components/projects/project-modal-selector/project-modal-selector.module";


@NgModule({
  declarations: [
    MppUploaderComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,

    CommonModule,
    FormsModule,
    ReactiveFormsModule,

    MatButtonModule,
    MatStepperModule,
    MatRadioModule,
    MatFormFieldModule,
    MatInputModule,
    MatSlideToggleModule,
    MatIconModule,

    ProjectModalSelectorModule,
    MatTableModule,
  ],
  exports: [
    MppUploaderComponent,
  ],
  entryComponents: [
    MppUploaderComponent
  ]
})
export class MppUploaderModule { }
