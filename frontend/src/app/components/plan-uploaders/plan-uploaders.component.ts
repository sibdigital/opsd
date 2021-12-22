import {Component, ElementRef, Input, OnInit} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";

@Component({
  selector: 'op-plan-uploaders',
  templateUrl: './plan-uploaders.component.html',
  styleUrls: ['./plan-uploaders.component.sass']
})
export class PlanUploadersComponent implements OnInit {
  public $element:JQuery;
  @Input() projectId:string;
  constructor(protected elementRef:ElementRef) {
    //
  }

  ngOnInit():void {
    this.$element = jQuery(this.elementRef.nativeElement);
    this.projectId = this.$element.attr('projectId')!;
  }

}

DynamicBootstrapper.register({selector: 'op-plan-uploaders', cls: PlanUploadersComponent});
