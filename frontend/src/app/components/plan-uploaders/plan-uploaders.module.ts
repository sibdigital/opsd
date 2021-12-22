import {NgModule} from "@angular/core";
import {PlanUploadersComponent} from "core-components/plan-uploaders/plan-uploaders.component";
import {ExecutionUploaderModule} from "core-components/el-budget/execution-uploader/execution-uploader.module";
import {BrowserModule} from "@angular/platform-browser";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MppUploaderModule} from "core-components/mpp/mpp-uploader/mpp-uploader.module";

@NgModule({
  imports: [
    BrowserModule,
    ExecutionUploaderModule,
    MatFormFieldModule,
    MppUploaderModule
  ],
  providers: [],
  exports: [PlanUploadersComponent],
  declarations: [PlanUploadersComponent],
  entryComponents: [PlanUploadersComponent],
})
export class PlanUploadersModule {}
