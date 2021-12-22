import {NgModule} from "@angular/core";
import {PlanUploadersComponent} from "core-components/plan-uploaders/plan-uploaders.component";
import {ExecutionUploaderModule} from "core-components/el-budget/execution-uploader/execution-uploader.module";
import {BrowserModule} from "@angular/platform-browser";
import {MatFormFieldModule} from "@angular/material/form-field";

@NgModule({
    imports: [
        BrowserModule,
        ExecutionUploaderModule,
        MatFormFieldModule
    ],
  providers: [],
  exports: [PlanUploadersComponent],
  declarations: [PlanUploadersComponent],
  entryComponents: [PlanUploadersComponent],
})
export class PlanUploadersModule {}
